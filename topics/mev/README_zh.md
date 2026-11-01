# MEV - 最大可提取价值（Maximal extractable value）

`MEV` - 在区块生产过程中，通过包含、排除交易或重新排列交易顺序所能提取的最大价值

`Searcher` - 搜寻 MEV 机会并提交有利可图交易的用户或机器人

### 示例

抢跑、尾随交易和三明治

- 抢跑（Front run）- 在目标交易之前执行交易
  - DEX 套利 [示例](https://etherscan.io/tx/0x5e1657ef0e9be9bc72efefe59a2528d0d730d478cfc9e6cdd09af9f997bb3ef4)
  - 清算
- 尾随交易（Backrun）- 在目标交易之后执行交易
  - DEX 套利
- 三明治（Sandwich）- 在目标交易之前和之后各执行一笔交易
  - DEX 交易
  - JIT（Just in time，即时）流动性

### 防护

- 使用 [Flashbots RPC](https://docs.flashbots.net/flashbots-protect)

### 使用 `cast` 的代码示例

通过 Flashbots RPC 发送交易的示例

[FlashbotsTest.sol](./FlashbotsTest.sol) 已部署在 Sepolia 测试网，地址为 [0xA36Cc45540670B8699dE15596618a857f1AB9610](https://sepolia.etherscan.io/address/0xA36Cc45540670B8699dE15596618a857f1AB9610)

1. 将钱包导入 cast

```shell
# 导入私钥
ACCOUNT=burner
PRIVATE_KEY=...
cast wallet import $ACCOUNT --private-key $PRIVATE_KEY
# 清除私钥变量
unset PRIVATE_KEY

# 列出钱包
cast wallet list

# 钱包保存在 ~/.foundry/keystores
ls ~/.foundry/keystores/

# 删除钱包
rm -rf ~/.foundry/keystores/$ACCOUNT
```

2. 使用 Flashbots RPC 发送交易

```shell
# Sepolia 上的 FlashBotsTest 地址
# 0xA36Cc45540670B8699dE15596618a857f1AB9610

ACCOUNT=burner
CHAIN=11155111
DST=0xA36Cc45540670B8699dE15596618a857f1AB9610
FUNC_SIG="unlock(string)"
ARGS="cyfrin"
RPC=https://rpc-sepolia.flashbots.net

# 发送交易
cast send --account $ACCOUNT --rpc-url $RPC --chain $CHAIN $DST $FUNC_SIG $ARGS
```

### 参考资料

- [cyfrin updraft 课程](https://updraft.cyfrin.io/courses/security/mev-and-governance/mev-introduction?lesson_format=video)
- [Flashbots 文档](https://docs.flashbots.net/)
