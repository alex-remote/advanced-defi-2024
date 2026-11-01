# 高级 DeFi 2024

[contributors-shield]: https://img.shields.io/github/contributors/cyfrin/advanced-defi-2024.svg?style=for-the-badge
[contributors-url]: https://github.com/cyfrin/advanced-defi-2024/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/cyfrin/advanced-defi-2024.svg?style=for-the-badge
[forks-url]: https://github.com/cyfrin/advanced-defi-2024/network/members
[stars-shield]: https://img.shields.io/github/stars/cyfrin/advanced-defi-2024.svg?style=for-the-badge
[stars-url]: https://github.com/cyfrin/advanced-defi-2024/stargazers
[issues-shield]: https://img.shields.io/github/issues/cyfrin/advanced-defi-2024.svg?style=for-the-badge
[issues-url]: https://github.com/cyfrin/advanced-defi-2024/issues
[license-shield]: https://img.shields.io/github/license/cyfrin/advanced-defi-2024.svg?style=for-the-badge
[license-url]: https://github.com/cyfrin/advanced-defi-2024/blob/main/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555

<p align="center"><strong>学习智能合约开发，助力你的职业进阶
</strong></p>

[![Star 数][stars-shield]][stars-url] [![Fork 数][forks-shield]][forks-url] [![贡献者][contributors-shield]][contributors-url] [![Issues][issues-shield]][issues-url] [![GPLv3 许可证][license-shield]][license-url]

<p align="center">
    <br />
    <a href="https://cyfrin.io/">
        <img src=".github/images/poweredbycyfrinbluehigher.png" width="145" alt=""/></a>
<a href="https://updraft.cyfrin.io/courses/moccasin">
        <img src=".github/images/coursebadge.png" width="242.3" alt=""/></a>
    <br />
</p>

</div>

本仓库存放本课程的课程资源和[讨论区](https://github.com/Cyfrin/advanced-defi-2024/discussions)。

如需深入了解课程内容，请参考以下链接：

- [官网](https://updraft.cyfrin.io) - 加入 Cyfrin Updraft，畅享 50+ 小时的智能合约开发课程
- [Twitter](https://twitter.com/CyfrinUpdraft) - 及时获取最新课程发布动态
- [LinkedIn](https://www.linkedin.com/school/cyfrin-updraft/) - 将 Updraft 添加到你的学习经历中
- [Discord](https://discord.gg/cyfrin) - 加入由 3000+ 名开发者和审计员组成的社区
- [Codehawks](https://codehawks.com) - 智能合约审计竞赛，助力保障 web3 安全

# 目录

- [如何使用本仓库](#如何使用本仓库)
- [主题](#主题)
- [工具](#工具)
- [练习与答案](#练习与答案)
- [资源](#资源)

## 如何使用本仓库

每门 DeFi 课程都有一个 Markdown 文件，列出了该课程的前置知识和所涵盖的主题。

查看[主题](#主题)一节，了解目前有哪些 DeFi 协议可供学习。

以下是学习每门课程的一般步骤。

- 检查前置知识
- 安装[工具](#工具)
- 在 [Cyfrin Updraft](https://updraft.cyfrin.io/) 上观看视频
- 完成[练习并核对答案](#练习与答案)
- 在 [GitHub 讨论区](https://github.com/Cyfrin/advanced-defi-2024/discussions) 提问

## 主题

- [x] AMM
  - [x] 入门
    - [x] [什么是 AMM？](./topics/amm/intro/what_is_amm_zh.md)
    - [x] [AMM 与订单簿对比](./topics/amm/intro/amm_order_book_zh.md)
    - [x] [不同的 AMM 方程](./topics/amm/intro/amm_equations_zh.md)
  - [x] [Uniswap v2](./uniswap-v2_zh.md)
  - [x] [Uniswap v3](./uniswap-v3_zh.md)
  - [x] [Curve v1](./curve-v1_zh.md)
  - [x] [Curve v2](./curve-v2_zh.md)
- [ ] 价格预言机 - Chainlink
- [ ] 稳定币
- [ ] 借贷协议

## 工具

请确保安装本课程中使用的工具

```shell
# 安装 foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## 练习与答案

练习与答案位于 [foundry/test](./foundry/test)

测试按 DeFi 协议分组。

每个 DeFi 协议下都有 `exercises` 和 `solutions` 两个文件夹。

`exercises` 供你编写自己的代码。

`solutions` 供你核对自己的代码。

```shell
# 确保在 foundry 文件夹内执行 foundry 命令
cd foundry

# 编译
forge build --via-ir
```

```shell
# 确保在 foundry 文件夹内执行 foundry 命令
cd foundry

# 设置 FORK_URL
FORK_URL= rpc url for testing on fork

# 测试练习
forge test --fork-url $FORK_URL \
--match-path test/[name of DeFi protocol]/exercises/[name of test].test.sol \
--match-test name_of_test \
-vvv

# 测试答案
forge test --fork-url $FORK_URL \
--match-path test/[name of DeFi protocol]/solutions/[name of test].test.sol \
--match-test name_of_test \
-vvv
```

## 资源

- [Cyfrin Updraft](https://updraft.cyfrin.io/)
- [DeFiLama](https://defillama.com/)
- [白皮书](./whitepapers/README_zh.md)
