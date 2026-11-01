// SPDX-License-Identifier: MIT
pragma solidity >= 0.4 < 0.9;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {FixedPoint} from "../../../src/uniswap-v2/FixedPoint.sol";

// 修改自 https://github.com/Uniswap/v2-periphery/blob/master/contracts/examples/ExampleOracleSimple.sol
// 请勿在生产环境中使用此合约
contract UniswapV2Twap {
    using FixedPoint for *;

    // 函数 update 能再次被调用之前的最短等待时间（秒）
    // TWAP 的时间窗口 > MIN_WAIT
    uint256 private constant MIN_WAIT = 300;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    // 累计价格的单位为 uq112x112 价格 * 秒
    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    // 累计价格最后一次更新的时间戳
    uint32 public updatedAt;

    // token0 和 token1 的 TWAP
    // 范围：[0, 2**112 - 1]
    // 分辨率：1 / 2**112
    // 以 token1 计价的 token0 的 TWAP
    FixedPoint.uq112x112 public price0Avg;
    // 以 token0 计价的 token1 的 TWAP
    FixedPoint.uq112x112 public price1Avg;

    // 练习 1
    constructor(address _pair) {
        // 1. 根据构造函数的输入设置 pair 合约
        pair = IUniswapV2Pair(address(0));
        // 2. 从 pair 合约获取并设置 token0 和 token1
        token0 = address(0);
        token1 = address(0);
        // 3. 从 pair 合约读取并存储 price0CumulativeLast 和 price1CumulativeLast
        // 4. 调用 pair.getReserve 获取储备量最后一次更新的时间戳，
        //    并将其存入状态变量 updatedAt
    }

    // 练习 2
    // 计算截至当前时间戳的累计价格
    function _getCurrentCumulativePrices()
        internal
        view
        returns (uint256 price0Cumulative, uint256 price1Cumulative)
    {
        // 1. 从 pair 合约获取最新的累计价格

        // 如果当前区块时间戳 > 储备量最后一次更新的时间戳，
        // 则计算截至当前时间的累计价格。
        // 否则直接返回从 pair 合约获取的最新累计价格。

        // 2. 从 pair 合约获取储备量，以及
        //    储备量最后一次更新的时间戳
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) =
            (0, 0, 0);

        // 3. 将 block.timestamp 转换为 uint32
        uint32 blockTimestamp = 0;
        if (blockTimestampLast != blockTimestamp) {
            // 4. 计算经过的时间
            uint32 dt;

            // 此处的加法上溢是预期行为
            unchecked {
                // 5. 将 现货价格 * 经过的时间 累加到累计价格上。
                //    - 使用 FixedPoint.fraction 计算现货价格。
                //    - FixedPoint.fraction 返回 UQ112x112，因此需将其转换为 uint256。
                //    - 将现货价格乘以经过的时间
                price0Cumulative += 0;
                price1Cumulative += 0;
            }
        }
    }

    // 练习 3
    // 更新累计价格
    function update() external {
        // 1. 将 block.timestamp 转换为 uint32
        uint32 blockTimestamp = 0;
        // 2. 计算自本合约上一次更新累计价格以来
        //    所经过的时间
        uint32 dt = 0;
        // 3. 要求经过的时间 >= MIN_WAIT

        // 4. 调用内部函数 _getCurrentCumulativePrices 获取
        //    当前的累计价格
        (uint256 price0Cumulative, uint256 price1Cumulative) = (0, 0);

        // 上溢是预期行为，类型转换永远不会截断
        // https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/building-an-oracle
        // 两个累计价格值相减，得到的结果
        // 可以落在 uint256 的范围之内，前提是
        // 观测的时间间隔最长不超过 2^32 秒（约 136 年）
        unchecked {
            // 5. 计算 TWAP price0Avg 和 price1Avg
            //    - TWAP = (当前累计价格 - 上次累计价格) / dt
            //    - 先将 TWAP 转换为 uint224，再转换为 FixedPoint.uq112x112
            price0Avg = FixedPoint.uq112x112(0);
            price1Avg = FixedPoint.uq112x112(0);
        }

        // 6. 更新状态变量 price0CumulativeLast、price1CumulativeLast 和 updatedAt
    }

    // 练习 4
    // 对于给定的代币，返回输入数量所对应的输出数量
    function consult(address tokenIn, uint256 amountIn)
        external
        view
        returns (uint256 amountOut)
    {
        // 1. 要求 tokenIn 是 token0 或 token1

        // 2. 计算 amountOut
        //    - amountOut = tokenIn 的 TWAP * amountIn
        //    - 使用 FixePoint.mul 将 tokenIn 的 TWAP 与 amountIn 相乘
        //    - FixedPoint.mul 返回 uq144x112，使用 FixedPoint.decode144 得到 uint144
        if (tokenIn == token0) {
            // 示例
            //   token0 = WETH
            //   token1 = USDC
            //   price0Avg = 以 USDC 计价的 WETH 平均价格 = 2000 USDC / 1 WETH
            //   tokenIn = WETH
            //   amountIn = 2
            //   amountOut = price0Avg * amountIn = 4000 USDC
            amountOut = 0;
        } else {
            amountOut = 0;
        }
    }
}
