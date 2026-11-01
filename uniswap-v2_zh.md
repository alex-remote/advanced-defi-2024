# Uniswap V2

## 如何使用本教程

- 查看[前置知识](#前置知识)
- 安装[工具](#工具)
- 在 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/uniswap-v2) 上观看视频
- 完成[课程主题](#课程主题)下的练习
- 在 [GitHub discussions](https://github.com/Cyfrin/advanced-defi-2024/discussions) 上提问

## 前置知识

- 中级 Solidity 水平
- 有 Foundry 使用经验

## 工具

- [Foundry](https://github.com/foundry-rs/foundry/tree/master)

## 课程主题

每节课的视频请在 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/uniswap-v2) 上观看。

### 第 1 节 - 概览

- [图像](https://www.desmos.com/calculator/z7z2donayo)
- [合约概览](./excalidraw/amm/uniswap-v2/uniswap_v2.png)

### 第 2 节 - 兑换（Swap）

- [兑换数学](./excalidraw/amm/uniswap-v2/uniswap_v2_math.png)
- [兑换手续费数学](./excalidraw/amm/uniswap-v2/uniswap_v2_math.png)
- [合约调用](./excalidraw/amm/uniswap-v2/uniswap_v2.png)
- 代码讲解：[periphery](https://github.com/Uniswap/v2-periphery) 与 [core](https://github.com/Uniswap/v2-core) 仓库
- 代码讲解：[`swapExactTokensForTokens`](https://github.com/Uniswap/v2-periphery/blob/0335e8f7e1bd1e8d8329fd300aea2ef2f36dd19f/contracts/UniswapV2Router02.sol#L224-L237)
  - [`getAmountsOut`](https://github.com/Uniswap/v2-periphery/blob/0335e8f7e1bd1e8d8329fd300aea2ef2f36dd19f/contracts/libraries/UniswapV2Library.sol#L62-L70)
  - [`getAmountsOut` fork 测试](./foundry/test/uniswap-v2/UniswapV2SwapAmounts.test.sol)
  - `getAmountsOut` 示例
- 代码讲解：`swapTokensForExactTokens`
  - [`getAmountsIn`](https://github.com/Uniswap/v2-periphery/blob/0335e8f7e1bd1e8d8329fd300aea2ef2f36dd19f/contracts/libraries/UniswapV2Library.sol#L73-L82)
  - [`getAmountsIn` fork 测试](./foundry/test/uniswap-v2/UniswapV2SwapAmounts.test.sol)
  - `getAmountsIn` 示例
- 代码讲解：[`pair.swap`](https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/UniswapV2Pair.sol#L159-L187)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2Swap.test.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2Swap.test.sol)
- [练习 2](./foundry/test/uniswap-v2/exercises/UniswapV2Swap.test.sol)
- [答案 2](./foundry/test/uniswap-v2/solutions/UniswapV2Swap.test.sol)
- [现货价格图像](https://www.desmos.com/calculator/z7z2donayo)
- [现货价格数学](./excalidraw/amm/uniswap-v2/uniswap_v2.png)
- [滑点](./excalidraw/amm/slippage.png)

### 第 3 节 - 创建池子

- 代码讲解：[`createPair`](https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/UniswapV2Factory.sol#L23-L38)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2Factory.test.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2Factory.test.sol)

### 第 4 节 - 添加流动性

- [池子份额简介](./excalidraw/amm/pool_shares.png)
  - 池子份额铸造数学
  - 池子份额铸造数学示例
  - 池子份额销毁
  - 池子份额销毁数学
  - 池子份额销毁数学示例
- [添加流动性图像](https://www.desmos.com/calculator/z7z2donayo)
- [添加流动性数学](./excalidraw/amm/uniswap-v2/uniswap_v2_math.png)
  - 添加流动性时的池子份额数学简介
  - 流动性函数
  - 流动性函数 - sqrt
  - 流动性函数 - 2x
  - 总结
- [合约调用](./excalidraw/amm/uniswap-v2/uniswap_v2.png)
- 代码讲解：[`addLiquidity`](https://github.com/Uniswap/v2-periphery/blob/0335e8f7e1bd1e8d8329fd300aea2ef2f36dd19f/contracts/UniswapV2Router02.sol#L77-L100)
- 代码讲解：[`mint`](https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/UniswapV2Pair.sol#L110-L131)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2Liquidity.test.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2Liquidity.test.sol)

### 第 5 节 - 移除流动性

- [移除流动性图像](https://www.desmos.com/calculator/z7z2donayo)
- [移除流动性数学](./excalidraw/amm/uniswap-v2/uniswap_v2_math.png)
  - 要移除多少 dx 和 dy？
  - 池子份额简介
  - 流动性函数
  - 流动性函数 = sqrt 时的流动性变化量
- [合约调用](./excalidraw/amm/uniswap-v2/uniswap_v2.png)
- 代码讲解：[`removeLiquidity`](https://github.com/Uniswap/v2-periphery/blob/0335e8f7e1bd1e8d8329fd300aea2ef2f36dd19f/contracts/UniswapV2Router02.sol#L103-L119)
- 代码讲解：[`burn`](https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/UniswapV2Pair.sol#L134-L156)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2Liquidity.test.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2Liquidity.test.sol)

### 第 6 节 - 闪电兑换（flash swap）

- [闪电兑换手续费数学](./excalidraw/amm/uniswap-v2/uniswap_v2_math.png)
- [合约调用](./excalidraw/amm/uniswap-v2/uniswap_v2.png)
- 代码讲解：[`swap`](https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/UniswapV2Pair.sol#L172)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2FlashSwap.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2FlashSwap.sol)

### 第 7 节 - TWAP

- [现货价格操纵](./excalidraw/amm/uniswap-v2/uniswap_v2_spot_price_oracle.png)
- [TWAP 数学](./excalidraw/amm/uniswap-v2/uniswap_v2_twap.png)
  - 简介
  - 累计价格
  - 示例
  - 近似计算截至当前时间的 TWAP
  - 常见误解
- 代码讲解：[`_update`](https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/UniswapV2Pair.sol#L75-L81)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2Twap.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2Twap.sol)

### 第 8 节 - 应用 - 闪电兑换套利

- [简介](./excalidraw/amm/uniswap-v2/uniswap_v2_arb.png)
- [练习 1](./foundry/test/uniswap-v2/exercises/UniswapV2Arb1.sol)
- [答案 1](./foundry/test/uniswap-v2/solutions/UniswapV2Arb1.sol)
- [练习 2](./foundry/test/uniswap-v2/exercises/UniswapV2Arb2.sol)
- [答案 2](./foundry/test/uniswap-v2/solutions/UniswapV2Arb2.sol)
- [最优输入数量数学（选学）](./excalidraw/amm/uniswap-v2/uniswap_v2_arb_optimal_amount_in.png)

### 资源

[Uniswap](https://uniswap.org/)

[Uniswap V2 Core](https://github.com/Uniswap/v2-core/)

[Uniswap V2 Periphery](https://github.com/Uniswap/v2-periphery/)

[Uniswap V2 文档](https://docs.uniswap.org/contracts/v2/overview)

[Uniswap V2 数据分析](https://v2.info.uniswap.org/home)

[什么是滑点？](https://support.uniswap.org/hc/en-us/articles/8643879653261-What-is-Price-Slippage)

[Uniswap V2 笔记](./notes/uni-v2)
