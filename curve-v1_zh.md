# Curve V1

## 使用方法

- 查看[前置知识](#前置知识)
- 安装[工具](#工具)
- 在 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/curve-v1) 上观看视频
- 完成[主题](#主题)下的练习
- 在 [GitHub 讨论区](https://github.com/Cyfrin/advanced-defi-2024/discussions) 提问

## 前置知识

- 高级 Solidity 开发者
- 有 Foundry 使用经验
- 了解恒定和（`x + y = K`）与恒定乘积（`xy = K`）AMM
- Python（可选）
- 对 DeFi 有基本了解（可选）
- Uniswap V2 和 V3（可选）

## 工具

- [Foundry](https://github.com/foundry-rs/foundry/tree/master)
- [Python / Jupyter lab](https://jupyter.org/)（可选）

## 主题

每节课的视频请前往 [Cyfrin Updraft](https://updraft.cyfrin.io/courses/curve-v1) 观看。

### 第 1 节 - 简介

> 你将学到
>
> - 什么是 Curve AMM
> - 它与 Uniswap v2 和 v3 有何不同？

- 课程简介
- 主讲讲师
- 最佳实践
- 搭建练习用的仓库
- 如何运行练习
- Curve 简介
- [与 Uniswap v2 和 v3 的比较](./topics/amm/curve-v1/comparisons_zh.md)

### 第 2 节 - 数学

> 你将学到
>
> - Curve v1 AMM 的数学原理
> - Curve v1 的方程如何计算兑换数量和流动性

- 图像 [Curve V1 AMM](https://www.desmos.com/calculator/3xrvh5slce)
- 图像 [Curve V1 xy/(D/2)^2](https://www.desmos.com/3d/t0jtduq4us)
- [数学](./excalidraw/amm/curve-v1/curve-v1-eq.png)
- [牛顿法](./excalidraw/amm/curve-v1/curve-v1-newton.png)
  - [Curve v1 方程](./notebook/curve_v1_equations.ipynb)
  - [Curve v1 牛顿法](./notebook/curve_v1_newton.ipynb)

### 第 3 节 - 合约概览

> 你将学到
>
> - Curve v1 AMM 合约概览
> - 控制 Curve v1 曲线平坦程度的参数 `A`
> - 量化资金池流动性的数值 `D`

- [合约概览](./excalidraw/amm/curve-v1/curve-v1-contract.png)
- 图像 [A 如何影响 D](https://www.desmos.com/calculator/3xrvh5slce)
- 代码讲解 [`A`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L147-L172)
  - 代码讲解 [`ramp_A`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L701-L716)
  - 代码讲解 [`stop_ramp_A`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L719-L730)
- 代码讲解 [`_xp`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L175-L181)
- 代码讲解 [`get_D`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L193-L218)
  - Python [计算 D 的方程](./notebook/curve_v1_equations.ipynb)
- 代码讲解 [`get_virtual_price`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L227-L238)
- 代码讲解 [`calc_token_amount`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L241-L265)

### 第 4 节 - 兑换

> 你将学到
>
> - 兑换（swap）函数是如何实现的

- [合约调用](./excalidraw/amm/curve-v1/curve-v1-contract.png)
- 代码讲解 [`exchange`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L429-L493)
  - 代码讲解 [`get_y`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L354-L397)
    - Python [计算 y 的方程](./notebook/curve_v1_equations.ipynb)
- 代码讲解 [`get_dy`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L400-L411)
- 练习
  - [练习 1](./foundry/test/curve-v1/exercises/CurveV1Swap.test.sol)
  - [答案 1](./foundry/test/curve-v1/solutions/CurveV1Swap.test.sol)
  - [练习 2](./foundry/test/curve-v1/exercises/CurveV1Swap.test.sol)
  - [答案 2](./foundry/test/curve-v1/solutions/CurveV1Swap.test.sol)

### 第 5 节 - 添加流动性

> 你将学到
>
> - 添加流动性的函数是如何实现的
> - 以改变代币比例的方式添加流动性时收取的不平衡手续费（imbalance fee）

- [合约调用](./excalidraw/amm/curve-v1/curve-v1-contract.png)
- [不平衡手续费](./notebook/curve_v1_imbalance_fee.ipynb)
- 代码讲解 [`add_liquidity`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L268-L351)
- 练习
  - [练习](./foundry/test/curve-v1/exercises/CurveV1AddLiquidity.test.sol)
  - [答案](./foundry/test/curve-v1/solutions/CurveV1AddLiquidity.test.sol)

### 第 6 节 - 移除流动性

> 你将学到
>
> - 移除流动性的函数是如何实现的

- [合约调用](./excalidraw/amm/curve-v1/curve-v1-contract.png)
- 代码讲解 [`remove_liquidity`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L496-L524)
- 图像 [calc_withdraw_one_coin](https://www.desmos.com/calculator/6kbxhaq7xv)
- 代码讲解 [`remove_liquidity_one_coin`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L668-L697)
  - 代码讲解 [`_calc_withdraw_one_coin`](https://github.com/curvefi/curve-contract/blob/b0bbf77f8f93c9c5f4e415bce9cd71f0cdee960e/contracts/pools/3pool/StableSwap3Pool.vy#L628-L659)
- 练习
  - [练习 1](./foundry/test/curve-v1/exercises/CurveV1RemoveLiquidity.test.sol)
  - [答案 1](./foundry/test/curve-v1/solutions/CurveV1RemoveLiquidity.test.sol)
  - [练习 2](./foundry/test/curve-v1/exercises/CurveV1RemoveLiquidity.test.sol)
  - [答案 2](./foundry/test/curve-v1/solutions/CurveV1RemoveLiquidity.test.sol)

## 参考资料

- [Curve](https://curve.fi)
- [文档](https://curve.readthedocs.io/)
- [白皮书](https://resources.curve.fi/pdf/curve-stableswap.pdf)
- [Curve 资源](https://resources.curve.fi/)
- [Curve magic](https://hackmd.io/@alltold/curve-magic)
- [不平衡手续费](https://ethereum.stackexchange.com/questions/124850/curve-amm-how-is-fee-calculated-when-adding-liquidity)
- [Curve V1 StableSwap3Pool 代码](https://github.com/curvefi/curve-contract/blob/master/contracts/pools/3pool/StableSwap3Pool.vy)
- [3pool](https://etherscan.io/address/0xbebc44782c7db0a1a60cb6fe97d0b483032ff1c7)
- [牛顿法](https://en.wikipedia.org/wiki/Newton's_method)
