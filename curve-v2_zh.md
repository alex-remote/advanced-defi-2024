### Curve v2

## 使用方法

- 查看[前置知识](#前置知识)
- 安装[工具](#工具)
- 在 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/curve-v2) 上观看视频
- 完成[主题](#主题)下的练习
- 在 [GitHub 讨论区](https://github.com/Cyfrin/advanced-defi-2024/discussions) 提问

## 前置知识

- 高级 Solidity 开发者
- 有 Foundry 使用经验
- 了解 Curve V1
- 对 DeFi 有基本了解
- Python（可选）

## 工具

- [Foundry](https://github.com/foundry-rs/foundry/tree/master)
- [Python / Jupyter lab](https://jupyter.org/)（可选）

## 主题

每节课的视频请前往 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/curve-v2) 观看。

### 第 1 节 - 简介

> 本节介绍课程将教授的内容、课程面向的人群以及如何完成练习

- 课程简介
- 主讲讲师
- 搭建仓库

### 第 2 节 - 数学

> 本节讲解 Curve V2 AMM 的数学原理：流动性是如何被集中的，以及 AMM 如何决定在另一个价格上对资金池的流动性进行重新锚定（repeg）。

- Curve V2 简介
- AMM 方程
- 图像 [Curve V2](https://www.desmos.com/calculator/ms7fqtmpxu)
- Python 代码 [集中流动性](./notebook/amm_dy_dx.ipynb)
- 图像 [Gamma](https://www.desmos.com/3d/3ebvcluqdr)
- 回顾
- [Price scale（价格尺度）](./excalidraw/amm/curve-v2/curve-v2-price-scale.png)
- [Price scale 与集中流动性](./excalidraw/amm/curve-v2/curve-v2-price-scale-amm-eq.pprice-scale.png)
- Python 代码（可选）[使用 price scale 进行兑换](./notebook/curve_v2_swap_price_scale.ipynb)
- [Price scale 重新锚定（repeg）](./excalidraw/amm/curve-v2/curve-v2-price-scale-repeg.png)
- 图像 [带 price scale 的 AMM](https://www.desmos.com/calculator/v0ubb9g4oj)
- 图像 [回顾恒定乘积流动性](https://www.desmos.com/calculator/mg1evrmbdq)
- 图像 [量化资金池价值](https://www.desmos.com/calculator/weg6ff1pgk)
- 资金池价值的数学推导
- 图像 [重新锚定损失 第 1 部分](https://www.desmos.com/calculator/weg6ff1pgk)
- 图像 [重新锚定损失 第 2 部分](https://www.desmos.com/calculator/weg6ff1pgk)

### 第 3 节 - 合约概览

> 在这里你将了解与 AMM 交互时需要调用哪些函数。
> 你还将了解 `A`、`gamma` 和 `price_scale` 等状态变量是如何存储的。

- [合约概览](./excalidraw/amm/curve-v2/curve-v2-contract.png)
- [代码讲解：打包存储的状态变量](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L796-L819)
- [代码讲解：price scale](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L822-L854)
- [代码讲解 `A`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1261-L1284)
- [代码讲解 `ramp_A_gamma`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1961-L2008)
- [代码讲解 `get_virtual_price`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1718-L1728)
- [练习：转换后的余额](./foundry/test/curve-v2/exercises/CurveV2PriceScale.test.sol)
- [答案：转换后的余额](./foundry/test/curve-v2/solutions/CurveV2PriceScale.test.sol)

### 第 4 节 - 兑换（exchange）

> 本节讲解 `exchange` 函数的工作原理、如何调用它来兑换代币，随后通过练习模拟一次兑换。

- [合约调用](./excalidraw/amm/curve-v2/curve-v2-contract.png) `exchange`
- [代码概要](./excalidraw/amm/curve-v2/curve-v2-contract.png) `exchange`
- [代码讲解 `exchange`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L860-L960)
- [代码讲解 `_fee`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1287-L1295)
- 图像 [动态手续费](https://www.desmos.com/calculator/64npil5ieq)
- [练习 1 `get_dy`](./foundry/test/curve-v2/exercises/CurveV2Swap.test.sol)
- [答案 1 `get_dy`](./foundry/test/curve-v2/solutions/CurveV2Swap.test.sol)
- [练习 2 `exchange`](./foundry/test/curve-v2/exercises/CurveV2Swap.test.sol)
- [答案 2 `exchange`](./foundry/test/curve-v2/solutions/CurveV2Swap.test.sol)

### 第 5 节 - 添加流动性

> 本节讲解 `add_liquidity` 函数是如何实现的、如何添加流动性，随后是一个练习。

- [合约调用](./excalidraw/amm/curve-v2/curve-v2-contract.png) `add_liquidity`
- [代码概要](./excalidraw/amm/curve-v2/curve-v2-contract.png) `add_liquidity`
- [代码讲解 `add_liquidity`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L511-L648)
- [代码讲解 `calc_token_fee`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1314-L1336)
- [练习 `add_liquidity`](./foundry/test/curve-v2/exercises/CurveV2AddLiquidity.test.sol)
- [答案 `add_liquidity`](./foundry/test/curve-v2/solutions/CurveV2AddLiquidity.test.sol)

### 第 6 节 - 移除流动性

> 移除流动性有 2 种方式（`remove_liquidity` 和 `remove_liquidity_one_coin`）。
> 本节将讲解这两个函数的工作原理，随后是练习。

- [合约调用](./excalidraw/amm/curve-v2/curve-v2-contract.png) `remove_liquidity`
- [代码概要](./excalidraw/amm/curve-v2/curve-v2-contract.png) `remove_liquidity`
- [代码讲解 `remove_liquidity`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L651-L722)
- [练习 1 `remove_liquidity`](./foundry/test/curve-v2/exercises/CurveV2RemoveLiquidity.test.sol)
- [答案 1 `remove_liquidity`](./foundry/test/curve-v2/solutions/CurveV2RemoveLiquidity.test.sol)
- [合约调用](./excalidraw/amm/curve-v2/curve-v2-contract.png) `remove_liquidity_one_coin`
- [代码概要](./excalidraw/amm/curve-v2/curve-v2-contract.png) `remove_liquidity_one_coin`
- [代码讲解 `remove_liquidity_one_coin`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L725-L781)
- [代码讲解 `calc_withdraw_one_coin`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1339-L1410)
- [练习 2 `remove_liquidity_one_coin`](./foundry/test/curve-v2/exercises/CurveV2RemoveLiquidity.test.sol)
- [答案 2 `remove_liquidity_one_coin`](./foundry/test/curve-v2/solutions/CurveV2RemoveLiquidity.test.sol)

### 第 7 节 - 价格重新锚定（repeg）

> Curve V2 有一个内部价格预言机，当内部价格与当前价格显著偏离时，它会决定重新集中流动性。
> 本节讲解内部价格预言机如何跟踪价格的数学原理，以及负责重新锚定的函数（`tweak_price`）。

- EMA 数学 [固定间隔](./excalidraw/amm/curve-v2/curve-v2-ema-regular-interval.png)
- Python [固定间隔示例](./notebook/curve_v2_ema.ipynb)
- EMA 数学 [不固定间隔](./excalidraw/amm/curve-v2/curve-v2-ema-irregular-interval.png)
- 图像 [半衰期](https://www.desmos.com/calculator/m5xmw1poez)
- Python [不固定间隔示例](./notebook/curve_v2_ema.ipynb)
- 数学与代码之间的差异
- [代码讲解 `price_oracle`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1731-L1766)
- [`tweak_price` 何时被调用](./excalidraw/amm/curve-v2/curve-v2-contract.excalidraw)
- [代码概要](./excalidraw/amm/curve-v2/curve-v2-contract.png) `tweak_price`
- [代码讲解 `tweak_price`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L963-L1167)
- `xcp_profit` 如何跟踪盈亏？
- [`claim_admin_fees` 何时被调用](./excalidraw/amm/curve-v2/curve-v2-contract.png)
- [代码讲解 `claim_admin_fees`](https://github.com/curvefi/tricrypto-ng/blob/584591e6613cb6cdb46e4659488a8cccdfff69ad/contracts/main/CurveTricryptoOptimizedWETH.vy#L1170-L1241)

### 第 8 节 - 脚注

> 脚注：介绍如何通过一种称为隐函数求导（implicit differentiation）的数学技巧，计算恒定和、恒定乘积、Curve V1 和 V2 等 AMM 的现货价格。

- [AMM 现货价格 dy / dx](./notebook/amm_dy_dx.ipynb)

### 参考资料

- [Curve](https://curve.fi)
- [Curve 资源](https://resources.curve.fi/)
- [文档](https://docs.curve.fi/)
- [白皮书](https://resources.curve.fi/pdf/curve-cryptopools.pdf)
- [USDC/WBTC/ETH](https://etherscan.io/address/0x7f86bf177dd4f3494b841a37e810a34dd56c829b)
- [GitHub](https://github.com/curvefi/tricrypto-ng/blob/main/contracts/main/CurveTricryptoOptimizedWETH.vy)
- [Tricrypto 优化](https://github.com/curvefi/tricrypto-ng/blob/extended-readme/docs/tricrypto_optimisation.pdf)
- [Curve magic](https://hackmd.io/@alltold/curve-magic)
- [理解 Crypto Pools](https://docs.kokonutswap.finance/understanding-crypto-pools)
- [Curve v2 CryptoSwap 的重新锚定（Repegging）|Curve|代码审查 • 0xreviews.xyz](https://0xreviews.xyz/posts/2022-03-04-Curve-CryptoSwap-repegging)
- [深入解析：Curve v2 参数](https://nagaking.substack.com/p/deep-dive-curve-v2-parameters)
- [不平衡手续费](https://ethereum.stackexchange.com/questions/124850/curve-amm-how-is-fee-calculated-when-adding-liquidity)
- [隐函数](https://en.wikipedia.org/wiki/Implicit_function)
- [隐函数求导](https://www.khanacademy.org/math/ap-calculus-ab/ab-differentiation-2-new/ab-3-2/v/implicit-differentiation-1)
- https://x.com/Kurt_M_Barry/status/1404496489703952384?s=20&t=5sGVQL4HbLrwzA_ALxivhA
