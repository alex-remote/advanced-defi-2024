# Uniswap V3

## 如何使用本教程

- 查看[前置知识](#前置知识)
- 安装[工具](#工具)
- 在 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/uniswap-v3) 上观看视频
- 完成[主题](#主题)中的练习
- 在 [GitHub 讨论区](https://github.com/Cyfrin/advanced-defi-2024/discussions) 提问

## 前置知识

- 进阶 Solidity
- Foundry 使用经验
- [Uniswap V2](./uniswap-v2_zh.md)

## 工具

- [Foundry](https://github.com/foundry-rs/foundry/tree/master)
- [Python / Jupyter lab](https://jupyter.org/)（可选）

## 主题

每节课的视频请在 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/uniswap-v3) 上观看。

### 第 1 节 - 简介

> Uniswap V3 简介：它与 Uniswap V2 有何不同？什么是集中流动性？

- [集中流动性](./excalidraw/amm/uniswap-v3/uniswap-v3-intro.png)
- [v2 与 v3 的区别](./excalidraw/amm/uniswap-v3/uniswap-v2-v3-diff.png)
- 图表 - [集中流动性](https://www.desmos.com/calculator/b2jllbh8xk)
- 图表 - [tick](https://www.desmos.com/calculator/i0jaqanhen)
- 图表 - [恒定乘积曲线上的 tick](https://www.desmos.com/calculator/3xpagfgcl2)
- 图表 - [单个头寸](https://www.desmos.com/calculator/afw6llbs8z)
- 图表 - [多个头寸](https://www.desmos.com/calculator/fyvzeasktd)
- [ETH/USDT](https://app.uniswap.org/explore/pools/ethereum/0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640) 流动性-价格图示例
- 代码仓库概览
  - [Uniswap V3 core（Solidity 0.8 版本）](https://github.com/Uniswap/v3-core/tree/0.8)
  - [Uniswap V3 periphery（Solidity 0.8 版本）](https://github.com/Uniswap/v3-periphery/tree/0.8)
  - [Uniswap swap router 合约](https://github.com/Uniswap/swap-router-contracts)
- [合约概览](./excalidraw/amm/uniswap-v3/uniswap-v3-contracts.png)

### 第 2 节 - 现货价格（sqrt price、tick、sqrt x 96）

> 现货价格的数学原理，以及 Uniswap V3 存储价格时特有的数值（`slot0`、`sqrtPriceX96` 和 `tick`）。

- `slot0`（tick 和 sqrtPriceX96）
  - [代码](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/UniswapV3Pool.sol#L56-L74)
  - Etherscan 上的 [WETH/USDT](https://etherscan.io/address/0x4e68Ccd3E89f51C3074ca5072bbAC773960dFa36#code)
- 数学 - [tick 转换为价格](./excalidraw/amm/uniswap-v3/uniswap-v3-price-tick.png)
- Python - [代码示例](./notebook/uniswap_v3_spot_price.ipynb)
- 数学 - [sqrtPriceX96 转换为价格](./excalidraw/amm/uniswap-v3/uniswap-v3-price-tick.png)
- Python - [代码示例](./notebook/uniswap_v3_spot_price.ipynb)
- 数学 - [sqrtPriceX96 转换为 tick](./excalidraw/amm/uniswap-v3/uniswap-v3-price-tick.png)
- Python - [代码示例](./notebook/uniswap_v3_spot_price.ipynb)
- [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3SpotPrice.test.sol)
- [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3SpotPrice.test.sol)

### 第 3 节 - 数学

> 如何推导集中流动性的方程。

- 数学 - [由流动性和价格求 x 和 y 的方程](./excalidraw/amm/uniswap-v3/uniswap-v3-xy-equations.png)
- 数学 - [真实储备量曲线](./excalidraw/amm/uniswap-v3/uniswap-v3-curve-real-reserves.png)
- 数学 - [在 pa 与 pb 之间有多少代币 x 和 y？](./excalidraw/amm/uniswap-v3/uniswap-v3-xy-amounts.png)

### 第 4 节 - 兑换

> 兑换算法、数学、代码，以及使用路由合约兑换代币的练习。

- 兑换算法
  - [单个头寸](./excalidraw/amm/uniswap-v3/uniswap-v3-swap-algo.png)
  - [多个头寸](./excalidraw/amm/uniswap-v3/uniswap-v3-swap-algo.png)
    - 净流动性（liquidity net）简介
    - 数学 - [净流动性](./excalidraw/amm/uniswap-v3/uniswap-v3-liquidity-net.png)
    - 图表 - [净流动性](https://www.desmos.com/calculator/mkoyc4wm9t)
- 兑换数学
  - 数学 - [+/- dx 或 dy 之后的价格是多少](./excalidraw/amm/uniswap-v3/uniswap-v3-delta-price.png)
  - 数学 - [兑换手续费](./excalidraw/amm/uniswap-v3/uniswap-v3-swap-fee.png)
- [swap 代码解读](https://github.com/Uniswap/v3-core/blob/6562c52e8f75f0c10f9deaf44861847585fc8129/contracts/UniswapV3Pool.sol#L605-L819)
- [合约调用](./excalidraw/amm/uniswap-v3/uniswap-v3-swap-contract-calls.png)
  - 单池精确输入（Exact input single）
  - 多池精确输入（Exact input）
  - 单池精确输出（Exact output single）
  - 多池精确输出（Exact output）
- `SwapRouter02` 代码解读
  - [精确输入（Exact input）](https://github.com/Uniswap/swap-router-contracts/blob/70bc2e40dfca294c1cea9bf67a4036732ee54303/contracts/V3SwapRouter.sol#L132-L168)
  - [精确输出（Exact output）](https://github.com/Uniswap/swap-router-contracts/blob/70bc2e40dfca294c1cea9bf67a4036732ee54303/contracts/V3SwapRouter.sol#L226-L238)
- [练习 1 - 单池精确输入](./foundry/test/uniswap-v3/exercises/UniswapV3Swap.test.sol)
- [答案 1 - 单池精确输入](./foundry/test/uniswap-v3/solutions/UniswapV3Swap.test.sol)
- [练习 2 - 多池精确输入](./foundry/test/uniswap-v3/exercises/UniswapV3Swap.test.sol)
- [答案 2 - 多池精确输入](./foundry/test/uniswap-v3/solutions/UniswapV3Swap.test.sol)
- [练习 3 - 单池精确输出](./foundry/test/uniswap-v3/exercises/UniswapV3Swap.test.sol)
- [答案 4 - 单池精确输出](./foundry/test/uniswap-v3/solutions/UniswapV3Swap.test.sol)
- [练习 4 - 多池精确输出](./foundry/test/uniswap-v3/exercises/UniswapV3Swap.test.sol)
- [答案 4 - 多池精确输出](./foundry/test/uniswap-v3/solutions/UniswapV3Swap.test.sol)

### 第 5 节 - 工厂合约（Factory）

> 工厂合约的合约架构。

- [合约调用](./excalidraw/amm/uniswap-v3/uniswap-v3-factory.png)
- [代码解读](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/UniswapV3Factory.sol#L35-L51)
- [练习 1 - 获取池子](./foundry/test/uniswap-v3/exercises/UniswapV3Factory.test.sol)
- [答案 1 - 获取池子](./foundry/test/uniswap-v3/solutions/UniswapV3Factory.test.sol)
- [练习 2 - 创建池子](./foundry/test/uniswap-v3/exercises/UniswapV3Factory.test.sol)
- [答案 2 - 创建池子](./foundry/test/uniswap-v3/solutions/UniswapV3Factory.test.sol)

## 第 6 节 - 流动性

> 先讲解流动性计算的数学原理，然后是代码和练习。

- 数学 - [流动性](./excalidraw/amm/uniswap-v3/uniswap-v3-liquidity.png)
- 数学 - [流动性变化量（liquidity delta）](./excalidraw/amm/uniswap-v3/uniswap-v3-liquidity-delta.png)
- 图表 - [tick 间距（tick spacing）](https://www.desmos.com/calculator/x31s77joxw)
- 合约调用
  - `UniswapV3Pool`
    - `mint`
      - [调用追踪](./excalidraw/amm/uniswap-v3/uniswap-v3-pool-call-trace.png)
      - [代码解读](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/UniswapV3Pool.sol#L457-L487)
    - `burn`
      - [调用追踪](./excalidraw/amm/uniswap-v3/uniswap-v3-pool-call-trace.png)
      - [代码解读](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/UniswapV3Pool.sol#L517-L543)
    - `collect`
      - [调用追踪](./excalidraw/amm/uniswap-v3/uniswap-v3-pool-call-trace.png)
      - [代码解读](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/UniswapV3Pool.sol#L490-L513)
  - `NonFungiblePositionManager`
    - `mint`
      - [合约调用](./excalidraw/amm/uniswap-v3/uniswap-v3-position-manager.png)
      - [代码解读](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/NonfungiblePositionManager.sol#L128-L182)
    - `increaseLiquidity`
      - [合约调用](./excalidraw/amm/uniswap-v3/uniswap-v3-position-manager.png)
      - [代码解读](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/NonfungiblePositionManager.sol#L198-L254)
    - `decreaseLiquidity`
      - [合约调用](./excalidraw/amm/uniswap-v3/uniswap-v3-position-manager.png)
      - [代码解读](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/NonfungiblePositionManager.sol#L257-L306)
- 铸造（Mint）
  - [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3Liquidity.test.sol)
  - [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3Liquidity.test.sol)
- 增加流动性
  - [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3Liquidity.test.sol)
  - [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3Liquidity.test.sol)
- 减少流动性
  - [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3Liquidity.test.sol)
  - [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3Liquidity.test.sol)
- 收取手续费并移除流动性
  - [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3Liquidity.test.sol)
  - [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3Liquidity.test.sol)

### 第 6 节 - Tick bitmap（tick 位图）

> 高效查找下一个流动性头寸的算法。

- [Tick 位图](./excalidraw/amm/uniswap-v3/uniswap-v3-tick-bitmap.png)
- [查找下一个 tick 的算法](./excalidraw/amm/uniswap-v3/uniswap-v3-next-tick.png)

### 第 7 节 - 手续费算法

> 手续费如何在内部记录，以及如何为所有流动性提供者计算。

- 数学 - [手续费方程](./excalidraw/amm/uniswap-v3/uniswap-v3-calc-fee.png)
- [手续费增长（fee growth）](./excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth.png)
- 图表 - [手续费增长](https://www.desmos.com/calculator/eyyefktyjp)
- [区间内手续费增长（fee growth inside）](./excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-inside.png)
- 图表 - [区间内手续费增长](https://www.desmos.com/calculator/3j7xdgxawz)
- [区间外手续费增长（fee growth outside）](./excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-outside.png)
- [下方手续费增长（fee growth below）](./excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-below.png)
- [上方手续费增长（fee growth above）](./excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-above.png)
- [头寸手续费](./excalidraw/amm/uniswap-v3/uniswap-v3-fee-position.png)
- 代码解读
  - [`Tick.update`](https://github.com/Uniswap/v3-core/blob/6562c52e8f75f0c10f9deaf44861847585fc8129/contracts/libraries/Tick.sol#L113-L153)
  - [`Tick.cross`](https://github.com/Uniswap/v3-core/blob/6562c52e8f75f0c10f9deaf44861847585fc8129/contracts/libraries/Tick.sol#L171-L192)
  - [`Tick.getFeeGrowthInside`](https://github.com/Uniswap/v3-core/blob/6562c52e8f75f0c10f9deaf44861847585fc8129/contracts/libraries/Tick.sol#L61-L98)
  - [`Position.update`](https://github.com/Uniswap/v3-core/blob/6562c52e8f75f0c10f9deaf44861847585fc8129/contracts/libraries/Position.sol#L45-L93)

### 第 8 节 - 闪电贷（Flash）

> 如何从 Uniswap V3 池子获取闪电贷

- [代码解读](https://github.com/Uniswap/v3-core/blob/6562c52e8f75f0c10f9deaf44861847585fc8129/contracts/UniswapV3Pool.sol#L822-L867)
- [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3Flash.sol)
- [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3Flash.sol)

### 第 9 节 - TWAP 价格预言机

> 如何使用 Uniswap V3 计算代币的时间加权平均价格

- 数学 - [TWAP](./excalidraw/amm/uniswap-v3/uniswap-v3-twap.png)
- 数学 - [代币 x 和 y 的 TWAP](./excalidraw/amm/uniswap-v3/uniswap-v3-twap-x-y.png)
- Python - [模拟](./notebook/uniswap_v3_twap.ipynb)
- 代码解读
  - [`observe`](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/libraries/Oracle.sol#L300-L325)
  - [`transform`](https://github.com/Uniswap/v3-core/blob/d8b1c635c275d2a9450bd6a78f3fa2484fef73eb/contracts/libraries/Oracle.sol#L30-L45)
  - [`consult`](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/libraries/OracleLibrary.sol#L16-L41)
  - [`getQuoteAtTick`](https://github.com/Uniswap/v3-periphery/blob/697c2474757ea89fec12a4e6db16a574fe259610/contracts/libraries/OracleLibrary.sol#L49-L69)
- [练习 1](./foundry/test/uniswap-v3/exercises/UniswapV3Twap.sol)
- [答案 1](./foundry/test/uniswap-v3/solutions/UniswapV3Twap.sol)

### 第 10 节 - 附注

- [JIT 流动性](./excalidraw/amm/uniswap-v3/uniswap-v3-jit.png)
- 图表 - [恒定乘积 AMM 的流动性与价格影响](https://www.desmos.com/calculator/vs8qodrrl6)
- [套利算法](./notes/uni-v3/README_zh.md)

### 资源

- [Uniswap 官网](https://uniswap.org/)
- [白皮书](https://uniswap.org/whitepaper-v3.pdf)
- [应用](https://app.uniswap.org/)
- [Uniswap V3 Core 代码库](https://github.com/Uniswap/v3-core/)
- [Uniswap V3 Core 代码库（Solidity 0.8 版本）](https://github.com/Uniswap/v3-core/tree/0.8)
- [Uniswap V3 Periphery 代码库](https://github.com/Uniswap/v3-periphery/)
- [Uniswap V3 Periphery 代码库（Solidity 0.8 版本）](https://github.com/Uniswap/v3-periphery/tree/0.8)
- [Uniswap V3 Swap Router 代码库](https://github.com/Uniswap/swap-router-contracts)
- [Uniswap V3 文档](https://docs.uniswap.org/contracts/v3/overview)
- [Uniswap V3 数据分析](https://info.uniswap.org/)
- [Uniswap v3 数学入门](https://blog.uniswap.org/uniswap-v3-math-primer)
- [Uniswap V3 Book（在线教程书）](https://uniswapv3book.com/)
