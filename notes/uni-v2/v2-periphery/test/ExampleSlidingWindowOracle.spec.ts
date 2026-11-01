import chai, { expect } from 'chai'
import { Contract } from 'ethers'
import { BigNumber, bigNumberify } from 'ethers/utils'
import { solidity, MockProvider, createFixtureLoader, deployContract } from 'ethereum-waffle'

import { expandTo18Decimals, mineBlock, encodePrice } from './shared/utilities'
import { v2Fixture } from './shared/fixtures'

import ExampleSlidingWindowOracle from '../build/ExampleSlidingWindowOracle.json'

chai.use(solidity)

const overrides = {
  gasLimit: 9999999
}

const defaultToken0Amount = expandTo18Decimals(5)
const defaultToken1Amount = expandTo18Decimals(10)

describe('ExampleSlidingWindowOracle', () => {
  const provider = new MockProvider({
    hardfork: 'istanbul',
    mnemonic: 'horn horn horn horn horn horn horn horn horn horn horn horn',
    gasLimit: 9999999
  })
  const [wallet] = provider.getWallets()
  const loadFixture = createFixtureLoader(provider, [wallet])

  let token0: Contract
  let token1: Contract
  let pair: Contract
  let weth: Contract
  let factory: Contract

  async function addLiquidity(amount0: BigNumber = defaultToken0Amount, amount1: BigNumber = defaultToken1Amount) {
    if (!amount0.isZero()) await token0.transfer(pair.address, amount0)
    if (!amount1.isZero()) await token1.transfer(pair.address, amount1)
    await pair.sync()
  }

  const defaultWindowSize = 86400 // 24 小时
  const defaultGranularity = 24 // 每个 1 小时

  function observationIndexOf(
    timestamp: number,
    windowSize: number = defaultWindowSize,
    granularity: number = defaultGranularity
  ): number {
    const periodSize = Math.floor(windowSize / granularity)
    const epochPeriod = Math.floor(timestamp / periodSize)
    return epochPeriod % granularity
  }

  function deployOracle(windowSize: number, granularity: number) {
    return deployContract(wallet, ExampleSlidingWindowOracle, [factory.address, windowSize, granularity], overrides)
  }

  beforeEach('deploy fixture', async function() {
    const fixture = await loadFixture(v2Fixture)

    token0 = fixture.token0
    token1 = fixture.token1
    pair = fixture.pair
    weth = fixture.WETH
    factory = fixture.factoryV2
  })

  // 2020/1/1 @ UTC 凌晨 12:00
  // 不能为 0，因为那会让 ganache 将其设置为当前时间戳
  // 不能为 86400，因为那样时间戳 0 会成为一个有效的历史观测值（observation）
  const startTime = 1577836800

  // 必须在向交易对添加流动性之前执行，以保证累计价格计算正确
  // 不能用 0，因为那会重置为当前时间戳
  beforeEach(`set start time to ${startTime}`, () => mineBlock(provider, startTime))

  it('requires granularity to be greater than 0', async () => {
    await expect(deployOracle(defaultWindowSize, 0)).to.be.revertedWith('SlidingWindowOracle: GRANULARITY')
  })

  it('requires windowSize to be evenly divisible by granularity', async () => {
    await expect(deployOracle(defaultWindowSize - 1, defaultGranularity)).to.be.revertedWith(
      'SlidingWindowOracle: WINDOW_NOT_EVENLY_DIVISIBLE'
    )
  })

  it('computes the periodSize correctly', async () => {
    const oracle = await deployOracle(defaultWindowSize, defaultGranularity)
    expect(await oracle.periodSize()).to.eq(3600)
    const oracleOther = await deployOracle(defaultWindowSize * 2, defaultGranularity / 2)
    expect(await oracleOther.periodSize()).to.eq(3600 * 4)
  })

  describe('#observationIndexOf', () => {
    it('works for examples', async () => {
      const oracle = await deployOracle(defaultWindowSize, defaultGranularity)
      expect(await oracle.observationIndexOf(0)).to.eq(0)
      expect(await oracle.observationIndexOf(3599)).to.eq(0)
      expect(await oracle.observationIndexOf(3600)).to.eq(1)
      expect(await oracle.observationIndexOf(4800)).to.eq(1)
      expect(await oracle.observationIndexOf(7199)).to.eq(1)
      expect(await oracle.observationIndexOf(7200)).to.eq(2)
      expect(await oracle.observationIndexOf(86399)).to.eq(23)
      expect(await oracle.observationIndexOf(86400)).to.eq(0)
      expect(await oracle.observationIndexOf(90000)).to.eq(1)
    })
    it('overflow safe', async () => {
      const oracle = await deployOracle(25500, 255) // 周期长度为 100
      expect(await oracle.observationIndexOf(0)).to.eq(0)
      expect(await oracle.observationIndexOf(99)).to.eq(0)
      expect(await oracle.observationIndexOf(100)).to.eq(1)
      expect(await oracle.observationIndexOf(199)).to.eq(1)
      expect(await oracle.observationIndexOf(25499)).to.eq(254) // 第 255 个元素
      expect(await oracle.observationIndexOf(25500)).to.eq(0)
    })
    it('matches offline computation', async () => {
      const oracle = await deployOracle(defaultWindowSize, defaultGranularity)
      for (let timestamp of [0, 5000, 1000, 25000, 86399, 86400, 86401]) {
        expect(await oracle.observationIndexOf(timestamp)).to.eq(observationIndexOf(timestamp))
      }
    })
  })

  describe('#update', () => {
    let slidingWindowOracle: Contract

    beforeEach(
      'deploy oracle',
      async () => (slidingWindowOracle = await deployOracle(defaultWindowSize, defaultGranularity))
    )

    beforeEach('add default liquidity', () => addLiquidity())

    it('succeeds', async () => {
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
    })

    it('sets the appropriate epoch slot', async () => {
      const blockTimestamp = (await pair.getReserves())[2]
      expect(blockTimestamp).to.eq(startTime)
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
      expect(await slidingWindowOracle.pairObservations(pair.address, observationIndexOf(blockTimestamp))).to.deep.eq([
        bigNumberify(blockTimestamp),
        await pair.price0CumulativeLast(),
        await pair.price1CumulativeLast()
      ])
    }).retries(2) // 交易对的 blockTimestamp 与预期时间戳之间可能存在细微差异
    // 因为上一个区块的时间戳可能与当前区块的时间戳相差 1 秒

    it('gas for first update (allocates empty array)', async () => {
      const tx = await slidingWindowOracle.update(token0.address, token1.address, overrides)
      const receipt = await tx.wait()
      expect(receipt.gasUsed).to.eq('116816')
    }).retries(2) // gas 测试结果不稳定

    it('gas for second update in the same period (skips)', async () => {
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
      const tx = await slidingWindowOracle.update(token0.address, token1.address, overrides)
      const receipt = await tx.wait()
      expect(receipt.gasUsed).to.eq('25574')
    }).retries(2) // gas 测试结果不稳定

    it('gas for second update different period (no allocate, no skip)', async () => {
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
      await mineBlock(provider, startTime + 3600)
      const tx = await slidingWindowOracle.update(token0.address, token1.address, overrides)
      const receipt = await tx.wait()
      expect(receipt.gasUsed).to.eq('94703')
    }).retries(2) // gas 测试结果不稳定

    it('second update in one timeslot does not overwrite', async () => {
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
      const before = await slidingWindowOracle.pairObservations(pair.address, observationIndexOf(0))
      // 仍处于第一个小时
      await mineBlock(provider, startTime + 1800)
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
      const after = await slidingWindowOracle.pairObservations(pair.address, observationIndexOf(1800))
      expect(observationIndexOf(1800)).to.eq(observationIndexOf(0))
      expect(before).to.deep.eq(after)
    })

    it('fails for invalid pair', async () => {
      await expect(slidingWindowOracle.update(weth.address, token1.address)).to.be.reverted
    })
  })

  describe('#consult', () => {
    let slidingWindowOracle: Contract

    beforeEach(
      'deploy oracle',
      async () => (slidingWindowOracle = await deployOracle(defaultWindowSize, defaultGranularity))
    )

    // 必须在把时间设为 0 之后执行，以保证交易对中累计价格计算正确
    beforeEach('add default liquidity', () => addLiquidity())

    it('fails if previous bucket not set', async () => {
      await slidingWindowOracle.update(token0.address, token1.address, overrides)
      await expect(slidingWindowOracle.consult(token0.address, 0, token1.address)).to.be.revertedWith(
        'SlidingWindowOracle: MISSING_HISTORICAL_OBSERVATION'
      )
    })

    it('fails for invalid pair', async () => {
      await expect(slidingWindowOracle.consult(weth.address, 0, token1.address)).to.be.reverted
    })

    describe('happy path', () => {
      let blockTimestamp: number
      let previousBlockTimestamp: number
      let previousCumulativePrices: any
      beforeEach('add some prices', async () => {
        previousBlockTimestamp = (await pair.getReserves())[2]
        previousCumulativePrices = [await pair.price0CumulativeLast(), await pair.price1CumulativeLast()]
        await slidingWindowOracle.update(token0.address, token1.address, overrides)
        blockTimestamp = previousBlockTimestamp + 23 * 3600
        await mineBlock(provider, blockTimestamp)
        await slidingWindowOracle.update(token0.address, token1.address, overrides)
      })

      it('has cumulative price in previous bucket', async () => {
        expect(
          await slidingWindowOracle.pairObservations(pair.address, observationIndexOf(previousBlockTimestamp))
        ).to.deep.eq([bigNumberify(previousBlockTimestamp), previousCumulativePrices[0], previousCumulativePrices[1]])
      }).retries(5) // 测试不稳定，因为时间戳没有被 mock

      it('has cumulative price in current bucket', async () => {
        const timeElapsed = blockTimestamp - previousBlockTimestamp
        const prices = encodePrice(defaultToken0Amount, defaultToken1Amount)
        expect(
          await slidingWindowOracle.pairObservations(pair.address, observationIndexOf(blockTimestamp))
        ).to.deep.eq([bigNumberify(blockTimestamp), prices[0].mul(timeElapsed), prices[1].mul(timeElapsed)])
      }).retries(5) // 测试不稳定，因为时间戳没有被 mock

      it('provides the current ratio in consult token0', async () => {
        expect(await slidingWindowOracle.consult(token0.address, 100, token1.address)).to.eq(200)
      })

      it('provides the current ratio in consult token1', async () => {
        expect(await slidingWindowOracle.consult(token1.address, 100, token0.address)).to.eq(50)
      })
    })

    describe('price changes over period', () => {
      const hour = 3600
      beforeEach('add some prices', async () => {
        // 起始价格为 1:2，即 token0 = 2token1，token1 = 0.5token0
        await slidingWindowOracle.update(token0.address, token1.address, overrides) // 第 0 小时，1:2
        // 在第 3 小时把价格改为 1:1 并立即更新
        await mineBlock(provider, startTime + 3 * hour)
        await addLiquidity(defaultToken0Amount, bigNumberify(0))
        await slidingWindowOracle.update(token0.address, token1.address, overrides)

        // 在 6:00 把比率改为 2:1，暂不立即更新
        await mineBlock(provider, startTime + 6 * hour)
        await token0.transfer(pair.address, defaultToken0Amount.mul(2))
        await pair.sync()

        // 在 9:00 更新（价格已保持 2:1 达 3 小时，会触发反事实（counterfactual）计算）
        await mineBlock(provider, startTime + 9 * hour)
        await slidingWindowOracle.update(token0.address, token1.address, overrides)
        // 移动到 23:00，以便检查价格
        await mineBlock(provider, startTime + 23 * hour)
      })

      it('provides the correct ratio in consult token0', async () => {
        // 在第 23 小时，token 0 的价格有 3 小时为 2、3 小时为 1、17 小时为 0.5，因此价格应
        // 小于 1
        expect(await slidingWindowOracle.consult(token0.address, 100, token1.address)).to.eq(76)
      })

      it('provides the correct ratio in consult token1', async () => {
        // 价格应大于 1
        expect(await slidingWindowOracle.consult(token1.address, 100, token0.address)).to.eq(167)
      })

      // 价格在全部 23 小时内都保持 2:1
      describe('hour 32', () => {
        beforeEach('set hour 32', () => mineBlock(provider, startTime + 32 * hour))
        it('provides the correct ratio in consult token0', async () => {
          // 在第 23 小时，token 0 的价格有 3 小时为 2、3 小时为 1、17 小时为 0.5，因此价格应
          // 小于 1
          expect(await slidingWindowOracle.consult(token0.address, 100, token1.address)).to.eq(50)
        })

        it('provides the correct ratio in consult token1', async () => {
          // 价格应大于 1
          expect(await slidingWindowOracle.consult(token1.address, 100, token0.address)).to.eq(200)
        })
      })
    })
  })
})
