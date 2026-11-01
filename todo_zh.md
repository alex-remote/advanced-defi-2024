### 主题

✅

🤔

### Curve

- [ ] AMM
  - [ ] Curve v1
    - [ ] 数学
    - [ ] 兑换
    - [ ] 添加 / 移除流动性
    - [ ] TWAP🤔
  - [ ] Curve v2🤔
    - [ ] 数学
  - [ ] dy / dx = dfdx / dfdy 🤔
  - [ ] 总结

### Curve 资源

- [Curve](https://resources.curve.fi/)

### 待办事项

- [ ] MEV
  - [ ] 抢跑、尾随交易和三明治攻击示例
  - [ ] Flashbots RPC 示例
  - [ ] 针对 uni v2 的 MEV 三明治攻击 🤔
  - [ ] 总结
- [ ] 价格预言机 ✅
  - [ ] Chainlink
- [ ] 稳定币 ✅
  - [ ] DAI
    - [ ] 概览
    - [ ] CDP 与金库（vault）
    - [ ] 数学（wad、ray、rad）
    - [ ] 债务数学
    - [ ] 合约概览
    - [ ] 添加抵押品
    - [ ] 借款
    - [ ] 还款
    - [ ] 清算、数学与拍卖
    - [ ] 债务拍卖
    - [ ] 盈余拍卖
    - [ ] DSR（数学）
    - [ ] PSM
    - [ ] Flash（闪电铸造）
    - [ ] 闪电铸造 DAI -> 在 Uniswap 上把 DAI 卖成 USDC -> 把 USDC 卖给 PSM -> 偿还闪电贷
    - [ ] 我们可以用 DAI 和 Maker 协议做什么？🤔
    - [ ] 杠杆🤔
    - [ ] Endgame（终局计划）？ 🤔
    - [ ] OSM? 🤔
    - [ ] RWA?
    - [ ] SKY?
    - [ ] 总结
- [ ] 借贷
  - [ ] AAVE 🚧
    - [ ] 供应（supply）
    - [ ] 借款（borrow）
    - [ ] 还款（repay）
    - [ ] 取出（withdraw）
    - [ ] 闪电贷
    - [ ] 清算
    - [ ] GHO 🤔
    - [ ] Portal（门户） 🤔
    - [ ] 质押 AAVE 🤔
    - [ ] 治理 🤔
    - [ ] 应用 -> 闪电贷、挖治理代币、杠杆、做空 🤔
  - [ ] Compound 🤔
  - [ ] 闪电贷
  - [ ] Rebase 代币
  - [ ] 总结
- [ ] 流动性质押 🚧
  - [ ]Lido
  - [ ]Rocket pool 🤔

## 待办事项 🤔

- [ ] Compound
- [ ] TWAMM
- [ ] AAVE GHO
- [ ] Curve 稳定币
- [ ] Curve VE gauge🤔（流动性 -> 用户获得更好的价格 -> 更多交易 -> 更多手续费 -> 更多流动性）？
- [ ] RAI
- [ ] DEX 聚合器（CowSwap、ParaSwap）

- 如何讲解这些主题？
  - DeFi 中使用的算法
    - AMM
    - 金库（Vault）
    - 质押奖励（离散式与基于时间）
    - DAI 利率
    - 荷兰式拍卖
    - 英式拍卖与荷兰式拍卖
- DEX 聚合器 - cow swap、paraswap？

#### Aave

- [Aave](https://aave.com/)
- [Aave Unleashed](https://calnix.gitbook.io/aave-unleashed/)
- [Aave V3 Made Crystal Clear](https://www.youtube.com/watch?v=UzuZp3Q3xg0)

### Foundry

```shell
forge init --no-commit
forge build
forge test --fork-url $FORK_URL \
--match-path test/path/to/Fork.t.sol \
--match-test name_of_test \
-vvv
```
