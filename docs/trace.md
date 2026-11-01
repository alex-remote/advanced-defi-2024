# 英文注释中文翻译 · 任务进度跟踪

> 本文档由主代理维护，用于同步各子代理的翻译进度。勾选框 `[x]` 表示该文件已翻译并通过校验，`[ ]` 表示尚未完成。

## 一、统计概览

| 项目 | 数值 |
|---|---|
| 仓库受 git 跟踪的文件总数 | 391 |
| 需要翻译的文件数 | **189**（代码/配置文件原地翻译注释 170 个，Markdown 生成 `_zh.md` 译本 19 个） |
| 需要翻译的文件总行数 | 45,717 行 |
| 其中含英文的注释 / 文本行（估算） | 约 5,502 行 |
| 不在翻译范围内的文件 | 202 个（见第四节） |
| 子代理批次数 | 27 个（B01–B27） |
| **当前进度** | **187 / 189** 个文件，批次 23 / 27 |

行数说明：按编辑器显示的行数统计（最后一行没有换行符时也计为一行）。“注释行”为脚本估算的含英文单词的注释行数（已排除 `SPDX-License-Identifier` 等不需翻译的行），Markdown 文件为含英文的文本行数。

翻译规则：
1. 英文注释在原位置直接替换为中文，逐行对应，翻译后文件行数不变；代码与字符串字面量不做任何改动。
2. 函数名、变量名、合约名、协议名等专有名词和代码内的明确指代保留英文原样。
3. 英文 `.md` 文件保持原样，在同一路径下新建 `<原名>_zh.md` 译本，且与原文逐行对应。
4. SPDX 标识、版权与许可证文本、被注释掉的代码不翻译。

## 二、批次分配

| 批次 | 文件数 | 负责内容 | 状态 |
|---|---|---|---|
| B01 | 4 | 根目录 README / todo / rocket-pool，whitepapers/README | ✅ 已完成 |
| B02 | 5 | uniswap-v2.md、aave-v3.md、topics/amm/intro | ✅ 已完成 |
| B03 | 3 | uniswap-v3.md、curve-v1/comparisons、mev/README | ✅ 已完成 |
| B04 | 2 | curve-v1.md、curve-v2.md | ✅ 已完成 |
| B05 | 10 | forge-std README 与配置、foundry 配置、notes 下的 README | ✅ 已完成 |
| B06 | 1 | forge-std Vm.sol 第 1–441 行 | ✅ 已完成 |
| B07 | 1 | forge-std Vm.sol 第 442–1062 行 | ✅ 已完成 |
| B08 | 1 | forge-std Vm.sol 第 1063–1638 行 | ✅ 已完成 |
| B09 | 3 | forge-std safeconsole / console / console2 | ✅ 已完成 |
| B10 | 5 | forge-std IERC4626 / IERC20 / IERC165 / mocks | ✅ 已完成 |
| B11 | 2 | forge-std IERC721 / IERC1155 | ✅ 已完成 |
| B12 | 13 | forge-std src 其余 Std* 合约 | ✅ 已完成 |
| B13 | 12 | forge-std test | ✅ 已完成 |
| B14 | 16 | foundry/src 与 notes/uni-v3/src（FullMath、TickMath 等） | ✅ 已完成 |
| B15 | 15 | notes/uni-v3 test 与 py、notebook/arb、utils、两个 notebook | ✅ 已完成 |
| B16 | 13 | notebook 其余 13 个 .ipynb | ✅ 已完成 |
| B17 | 8 | foundry/test uniswap-v2 练习/答案合约 | ✅ 已完成 |
| B18 | 30 | foundry/test uniswap-v2 测试、aave-v3、dai、curve-v1/v2 测试 | ✅ 已完成 |
| B19 | 12 | foundry/test uniswap-v3 | ✅ 已完成 |
| B20 | 15 | notes/uni-v2 v2-core 全部与 v2-periphery 核心合约 | ✅ 已完成 |
| B21 | 8 | v2-periphery libraries 与 examples | ✅ 已完成 |
| B22 | 8 | v2-periphery test | ✅ 已完成 |
| B23 | 2 | StableSwap3Pool.vy、CurveCryptoViews3Optimized.vy | ✅ 已完成 |
| B24 | 1 | CurveTricryptoMathOptimized.vy | ⏳ 进行中 |
| B25 | 1 | CurveTricryptoOptimizedWETH.vy 第 1–859 行 | ⏳ 进行中 |
| B26 | 1 | CurveTricryptoOptimizedWETH.vy 第 860–1574 行 | ⏳ 进行中 |
| B27 | 1 | CurveTricryptoOptimizedWETH.vy 第 1575–2347 行 | ⏳ 进行中 |

## 三、文件清单

### （根目录）（8 / 8）

- [x] 1. `README.md` → `README_zh.md` — 132 行 · 文本 94 行 · B01
- [x] 2. `aave-v3.md` → `aave-v3_zh.md` — 49 行 · 文本 47 行 · B02
- [x] 3. `curve-v1.md` → `curve-v1_zh.md` — 135 行 · 文本 101 行 · B04
- [x] 4. `curve-v2.md` → `curve-v2_zh.md` — 154 行 · 文本 120 行 · B04
- [x] 5. `rocket-pool.md` → `rocket-pool_zh.md` — 31 行 · 文本 24 行 · B01
- [x] 6. `todo.md` → `todo_zh.md` — 113 行 · 文本 95 行 · B01
- [x] 7. `uniswap-v2.md` → `uniswap-v2_zh.md` — 137 行 · 文本 105 行 · B02
- [x] 8. `uniswap-v3.md` → `uniswap-v3_zh.md` — 219 行 · 文本 177 行 · B03

### foundry/src（8 / 8）

- [x] 9. `foundry/src/Constants.sol` — 48 行 · 注释 5 行 · B14
- [x] 10. `foundry/src/ERC20.sol` — 63 行 · 注释 2 行 · B14
- [x] 11. `foundry/src/interfaces/uniswap-v3/ISwapRouter.sol` — 66 行 · 注释 8 行 · B14
- [x] 12. `foundry/src/interfaces/uniswap-v3/IUniswapV3Pool.sol` — 71 行 · 注释 8 行 · B14
- [x] 13. `foundry/src/uniswap-v2/FixedPoint.sol` — 73 行 · 注释 13 行 · B14
- [x] 14. `foundry/src/uniswap-v2/FullMath.sol` — 62 行 · 注释 2 行 · B14
- [x] 15. `foundry/src/uniswap-v3/FullMath.sol` — 131 行 · 注释 58 行 · B14
- [x] 16. `foundry/src/uniswap-v3/TickMath.sol` — 277 行 · 注释 24 行 · B14

### foundry/test（50 / 50）

- [x] 17. `foundry/test/aave-v3/AaveV3.test.sol` — 281 行 · 注释 13 行 · B18
- [x] 18. `foundry/test/curve-v1/exercises/CurveV1AddLiquidity.test.sol` — 37 行 · 注释 4 行 · B18
- [x] 19. `foundry/test/curve-v1/exercises/CurveV1RemoveLiquidity.test.sol` — 94 行 · 注释 10 行 · B18
- [x] 20. `foundry/test/curve-v1/exercises/CurveV1Swap.test.sol` — 43 行 · 注释 9 行 · B18
- [x] 21. `foundry/test/curve-v1/solutions/CurveV1AddLiquidity.test.sol` — 39 行 · 注释 4 行 · B18
- [x] 22. `foundry/test/curve-v1/solutions/CurveV1RemoveLiquidity.test.sol` — 97 行 · 注释 10 行 · B18
- [x] 23. `foundry/test/curve-v1/solutions/CurveV1Swap.test.sol` — 42 行 · 注释 7 行 · B18
- [x] 24. `foundry/test/curve-v2/exercises/CurveV2AddLiquidity.test.sol` — 36 行 · 注释 8 行 · B18
- [x] 25. `foundry/test/curve-v2/exercises/CurveV2PriceScale.test.sol` — 36 行 · 注释 7 行 · B18
- [x] 26. `foundry/test/curve-v2/exercises/CurveV2RemoveLiquidity.test.sol` — 87 行 · 注释 15 行 · B18
- [x] 27. `foundry/test/curve-v2/exercises/CurveV2Swap.test.sol` — 50 行 · 注释 14 行 · B18
- [x] 28. `foundry/test/curve-v2/solutions/CurveV2AddLiquidity.test.sol` — 43 行 · 注释 8 行 · B18
- [x] 29. `foundry/test/curve-v2/solutions/CurveV2PriceScale.test.sol` — 42 行 · 注释 7 行 · B18
- [x] 30. `foundry/test/curve-v2/solutions/CurveV2RemoveLiquidity.test.sol` — 107 行 · 注释 17 行 · B18
- [x] 31. `foundry/test/curve-v2/solutions/CurveV2Swap.test.sol` — 56 行 · 注释 12 行 · B18
- [x] 32. `foundry/test/dai/DaiProxy.test.sol` — 102 行 · 注释 12 行 · B18
- [x] 33. `foundry/test/uniswap-v2/exercises/UniswapV2Arb1.sol` — 60 行 · 注释 23 行 · B17
- [x] 34. `foundry/test/uniswap-v2/exercises/UniswapV2Arb1.test.sol` — 101 行 · 注释 5 行 · B18
- [x] 35. `foundry/test/uniswap-v2/exercises/UniswapV2Arb2.sol` — 68 行 · 注释 19 行 · B17
- [x] 36. `foundry/test/uniswap-v2/exercises/UniswapV2Arb2.test.sol` — 71 行 · 注释 4 行 · B18
- [x] 37. `foundry/test/uniswap-v2/exercises/UniswapV2Factory.test.sol` — 43 行 · 注释 3 行 · B18
- [x] 38. `foundry/test/uniswap-v2/exercises/UniswapV2FlashSwap.sol` — 68 行 · 注释 20 行 · B17
- [x] 39. `foundry/test/uniswap-v2/exercises/UniswapV2FlashSwap.test.sol` — 45 行 · 注释 4 行 · B18
- [x] 40. `foundry/test/uniswap-v2/exercises/UniswapV2Liquidity.test.sol` — 75 行 · 注释 8 行 · B18
- [x] 41. `foundry/test/uniswap-v2/exercises/UniswapV2Swap.test.sol` — 76 行 · 注释 8 行 · B18
- [x] 42. `foundry/test/uniswap-v2/exercises/UniswapV2Twap.sol` — 139 行 · 注释 63 行 · B17
- [x] 43. `foundry/test/uniswap-v2/exercises/UniswapV2Twap.test.sol` — 98 行 · 注释 8 行 · B18
- [x] 44. `foundry/test/uniswap-v2/solutions/UniswapV2Arb1.sol` — 130 行 · 注释 26 行 · B17
- [x] 45. `foundry/test/uniswap-v2/solutions/UniswapV2Arb1.test.sol` — 101 行 · 注释 5 行 · B18
- [x] 46. `foundry/test/uniswap-v2/solutions/UniswapV2Arb2.sol` — 129 行 · 注释 22 行 · B17
- [x] 47. `foundry/test/uniswap-v2/solutions/UniswapV2Arb2.test.sol` — 71 行 · 注释 4 行 · B18
- [x] 48. `foundry/test/uniswap-v2/solutions/UniswapV2Factory.test.sol` — 43 行 · 注释 3 行 · B18
- [x] 49. `foundry/test/uniswap-v2/solutions/UniswapV2FlashSwap.sol` — 84 行 · 注释 21 行 · B17
- [x] 50. `foundry/test/uniswap-v2/solutions/UniswapV2FlashSwap.test.sol` — 45 行 · 注释 4 行 · B18
- [x] 51. `foundry/test/uniswap-v2/solutions/UniswapV2Liquidity.test.sol` — 102 行 · 注释 8 行 · B18
- [x] 52. `foundry/test/uniswap-v2/solutions/UniswapV2Swap.test.sol` — 98 行 · 注释 6 行 · B18
- [x] 53. `foundry/test/uniswap-v2/solutions/UniswapV2Twap.sol` — 160 行 · 注释 63 行 · B17
- [x] 54. `foundry/test/uniswap-v2/solutions/UniswapV2Twap.test.sol` — 98 行 · 注释 8 行 · B18
- [x] 55. `foundry/test/uniswap-v3/exercises/UniswapV3Factory.test.sol` — 50 行 · 注释 4 行 · B19
- [x] 56. `foundry/test/uniswap-v3/exercises/UniswapV3Flash.sol` — 41 行 · 注释 7 行 · B19
- [x] 57. `foundry/test/uniswap-v3/exercises/UniswapV3Liquidity.test.sol` — 191 行 · 注释 25 行 · B19
- [x] 58. `foundry/test/uniswap-v3/exercises/UniswapV3SpotPrice.test.sol` — 34 行 · 注释 8 行 · B19
- [x] 59. `foundry/test/uniswap-v3/exercises/UniswapV3Swap.test.sol` — 94 行 · 注释 26 行 · B19
- [x] 60. `foundry/test/uniswap-v3/exercises/UniswapV3Twap.sol` — 75 行 · 注释 12 行 · B19
- [x] 61. `foundry/test/uniswap-v3/solutions/UniswapV3Factory.test.sol` — 51 行 · 注释 4 行 · B19
- [x] 62. `foundry/test/uniswap-v3/solutions/UniswapV3Flash.sol` — 72 行 · 注释 9 行 · B19
- [x] 63. `foundry/test/uniswap-v3/solutions/UniswapV3Liquidity.test.sol` — 243 行 · 注释 25 行 · B19
- [x] 64. `foundry/test/uniswap-v3/solutions/UniswapV3SpotPrice.test.sol` — 53 行 · 注释 21 行 · B19
- [x] 65. `foundry/test/uniswap-v3/solutions/UniswapV3Swap.test.sol` — 132 行 · 注释 27 行 · B19
- [x] 66. `foundry/test/uniswap-v3/solutions/UniswapV3Twap.sol` — 86 行 · 注释 14 行 · B19

### foundry/lib/forge-std（40 / 40）

- [x] 67. `foundry/lib/forge-std/.github/workflows/ci.yml` — 134 行 · 注释 4 行 · B05
- [x] 68. `foundry/lib/forge-std/README.md` → `foundry/lib/forge-std/README_zh.md` — 250 行 · 文本 157 行 · B05
- [x] 69. `foundry/lib/forge-std/foundry.toml` — 21 行 · 注释 5 行 · B05
- [x] 70. `foundry/lib/forge-std/scripts/vm.py` — 635 行 · 注释 10 行 · B05
- [x] 71. `foundry/lib/forge-std/src/Base.sol` — 35 行 · 注释 7 行 · B12
- [x] 72. `foundry/lib/forge-std/src/Script.sol` — 27 行 · 注释 6 行 · B12
- [x] 73. `foundry/lib/forge-std/src/StdAssertions.sol` — 669 行 · 注释 9 行 · B12
- [x] 74. `foundry/lib/forge-std/src/StdChains.sol` — 250 行 · 注释 42 行 · B12
- [x] 75. `foundry/lib/forge-std/src/StdCheats.sol` — 817 行 · 注释 94 行 · B12
- [x] 76. `foundry/lib/forge-std/src/StdError.sol` — 15 行 · 注释 1 行 · B12
- [x] 77. `foundry/lib/forge-std/src/StdInvariant.sol` — 107 行 · 注释 4 行 · B12
- [x] 78. `foundry/lib/forge-std/src/StdJson.sol` — 179 行 · 注释 12 行 · B12
- [x] 79. `foundry/lib/forge-std/src/StdMath.sol` — 43 行 · 注释 4 行 · B12
- [x] 80. `foundry/lib/forge-std/src/StdStorage.sol` — 473 行 · 注释 22 行 · B12
- [x] 81. `foundry/lib/forge-std/src/StdToml.sol` — 179 行 · 注释 12 行 · B12
- [x] 82. `foundry/lib/forge-std/src/StdUtils.sol` — 226 行 · 注释 35 行 · B12
- [x] 83. `foundry/lib/forge-std/src/Test.sol` — 33 行 · 注释 6 行 · B12
- [x] 84. `foundry/lib/forge-std/src/Vm.sol` — 1638 行 · 注释 653 行 · B06✅ / B07✅ / B08✅
- [x] 85. `foundry/lib/forge-std/src/console.sol` — 1533 行 · 注释 1 行 · B09
- [x] 86. `foundry/lib/forge-std/src/console2.sol` — 1558 行 · 注释 6 行 · B09
- [x] 87. `foundry/lib/forge-std/src/interfaces/IERC1155.sol` — 105 行 · 注释 66 行 · B11
- [x] 88. `foundry/lib/forge-std/src/interfaces/IERC165.sol` — 12 行 · 注释 6 行 · B10
- [x] 89. `foundry/lib/forge-std/src/interfaces/IERC20.sol` — 43 行 · 注释 17 行 · B10
- [x] 90. `foundry/lib/forge-std/src/interfaces/IERC4626.sol` — 190 行 · 注释 136 行 · B10
- [x] 91. `foundry/lib/forge-std/src/interfaces/IERC721.sol` — 164 行 · 注释 112 行 · B11
- [x] 92. `foundry/lib/forge-std/src/mocks/MockERC20.sol` — 234 行 · 注释 21 行 · B10
- [x] 93. `foundry/lib/forge-std/src/mocks/MockERC721.sol` — 235 行 · 注释 21 行 · B10
- [x] 94. `foundry/lib/forge-std/src/safeconsole.sol` — 13248 行 · 注释 348 行 · B09
- [x] 95. `foundry/lib/forge-std/test/StdAssertions.t.sol` — 145 行 · 注释 1 行 · B13
- [x] 96. `foundry/lib/forge-std/test/StdChains.t.sol` — 221 行 · 注释 45 行 · B13
- [x] 97. `foundry/lib/forge-std/test/StdCheats.t.sol` — 618 行 · 注释 38 行 · B13
- [x] 98. `foundry/lib/forge-std/test/StdError.t.sol` — 120 行 · 注释 1 行 · B13
- [x] 99. `foundry/lib/forge-std/test/StdMath.t.sol` — 212 行 · 注释 4 行 · B13
- [x] 100. `foundry/lib/forge-std/test/StdStorage.t.sol` — 463 行 · 注释 26 行 · B13
- [x] 101. `foundry/lib/forge-std/test/StdUtils.t.sol` — 342 行 · 注释 23 行 · B13
- [x] 102. `foundry/lib/forge-std/test/Vm.t.sol` — 15 行 · 注释 3 行 · B13
- [x] 103. `foundry/lib/forge-std/test/compilation/CompilationScript.sol` — 10 行 · 注释 2 行 · B13
- [x] 104. `foundry/lib/forge-std/test/compilation/CompilationScriptBase.sol` — 10 行 · 注释 2 行 · B13
- [x] 105. `foundry/lib/forge-std/test/compilation/CompilationTest.sol` — 10 行 · 注释 2 行 · B13
- [x] 106. `foundry/lib/forge-std/test/compilation/CompilationTestBase.sol` — 10 行 · 注释 2 行 · B13

### notebook（18 / 18）

- [x] 107. `notebook/aave_supply.ipynb` — 76 行 · 注释 3 行 · B16
- [x] 108. `notebook/amm_dy_dx.ipynb` — 267 行 · 注释 5 行 · B16
- [x] 109. `notebook/arb/arb.ipynb` — 416 行 · 注释 21 行 · B15
- [x] 110. `notebook/arb/calc.py` — 242 行 · 注释 20 行 · B15
- [x] 111. `notebook/arb/data.py` — 60 行 · 注释 4 行 · B15
- [x] 112. `notebook/curve_v1_equations.ipynb` — 203 行 · 注释 10 行 · B16
- [x] 113. `notebook/curve_v1_imbalance_fee.ipynb` — 225 行 · 注释 12 行 · B16
- [x] 114. `notebook/curve_v1_newton.ipynb` — 145 行 · 注释 8 行 · B16
- [x] 115. `notebook/curve_v2.ipynb` — 194 行 · 注释 6 行 · B16
- [x] 116. `notebook/curve_v2_ema.ipynb` — 188 行 · 注释 26 行 · B15
- [x] 117. `notebook/curve_v2_swap_price_scale.ipynb` — 185 行 · 注释 15 行 · B16
- [x] 118. `notebook/hex_addr.ipynb` — 83 行 · 注释 3 行 · B16
- [x] 119. `notebook/mev_sandwich.ipynb` — 80 行 · 注释 2 行 · B16
- [x] 120. `notebook/uniswap_v2_spot_oracle.ipynb` — 114 行 · 注释 4 行 · B16
- [x] 121. `notebook/uniswap_v3_spot_price.ipynb` — 182 行 · 注释 29 行 · B15
- [x] 122. `notebook/uniswap_v3_swap.ipynb` — 73 行 · 注释 1 行 · B16
- [x] 123. `notebook/uniswap_v3_tick_bitmap.ipynb` — 179 行 · 注释 9 行 · B16
- [x] 124. `notebook/uniswap_v3_twap.ipynb` — 109 行 · 注释 3 行 · B16

### notes/uni-v2（34 / 34）

- [x] 125. `notes/uni-v2/v2-core/README.md` → `notes/uni-v2/v2-core/README_zh.md` — 24 行 · 文本 13 行 · B05
- [x] 126. `notes/uni-v2/v2-core/contracts/UniswapV2ERC20.sol` — 94 行 · 注释 1 行 · B20
- [x] 127. `notes/uni-v2/v2-core/contracts/UniswapV2Factory.sol` — 59 行 · 注释 12 行 · B20
- [x] 128. `notes/uni-v2/v2-core/contracts/UniswapV2Pair.sol` — 253 行 · 注释 79 行 · B20
- [x] 129. `notes/uni-v2/v2-core/contracts/libraries/Math.sol` — 23 行 · 注释 2 行 · B20
- [x] 130. `notes/uni-v2/v2-core/contracts/libraries/SafeMath.sol` — 17 行 · 注释 1 行 · B20
- [x] 131. `notes/uni-v2/v2-core/contracts/libraries/UQ112x112.sol` — 21 行 · 注释 7 行 · B20
- [x] 132. `notes/uni-v2/v2-core/test/UniswapV2ERC20.spec.ts` — 116 行 · 注释 2 行 · B20
- [x] 133. `notes/uni-v2/v2-core/test/UniswapV2Factory.spec.ts` — 86 行 · 注释 2 行 · B20
- [x] 134. `notes/uni-v2/v2-core/test/UniswapV2Pair.spec.ts` — 284 行 · 注释 7 行 · B20
- [x] 135. `notes/uni-v2/v2-periphery/README.md` → `notes/uni-v2/v2-periphery/README_zh.md` — 24 行 · 文本 13 行 · B05
- [x] 136. `notes/uni-v2/v2-periphery/contracts/UniswapV2Migrator.sol` — 49 行 · 注释 4 行 · B20
- [x] 137. `notes/uni-v2/v2-periphery/contracts/UniswapV2Router01.sol` — 280 行 · 注释 9 行 · B20
- [x] 138. `notes/uni-v2/v2-periphery/contracts/UniswapV2Router02.sol` — 470 行 · 注释 38 行 · B20
- [x] 139. `notes/uni-v2/v2-periphery/contracts/examples/ExampleComputeLiquidityValue.sol` — 90 行 · 注释 4 行 · B21
- [x] 140. `notes/uni-v2/v2-periphery/contracts/examples/ExampleFlashSwap.sol` — 67 行 · 注释 16 行 · B21
- [x] 141. `notes/uni-v2/v2-periphery/contracts/examples/ExampleOracleSimple.sol` — 67 行 · 注释 10 行 · B21
- [x] 142. `notes/uni-v2/v2-periphery/contracts/examples/ExampleSlidingWindowOracle.sol` — 125 行 · 注释 29 行 · B21
- [x] 143. `notes/uni-v2/v2-periphery/contracts/examples/ExampleSwapToPrice.sol` — 77 行 · 注释 7 行 · B21
- [x] 144. `notes/uni-v2/v2-periphery/contracts/examples/README.md` → `notes/uni-v2/v2-periphery/contracts/examples/README_zh.md` — 14 行 · 文本 11 行 · B05
- [x] 145. `notes/uni-v2/v2-periphery/contracts/libraries/SafeMath.sol` — 17 行 · 注释 1 行 · B20
- [x] 146. `notes/uni-v2/v2-periphery/contracts/libraries/UniswapV2Library.sol` — 187 行 · 注释 96 行 · B21
- [x] 147. `notes/uni-v2/v2-periphery/contracts/libraries/UniswapV2LiquidityMathLibrary.sol` — 139 行 · 注释 15 行 · B21
- [x] 148. `notes/uni-v2/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol` — 35 行 · 注释 8 行 · B21
- [x] 149. `notes/uni-v2/v2-periphery/contracts/test/DeflatingERC20.sol` — 97 行 · 注释 1 行 · B20
- [x] 150. `notes/uni-v2/v2-periphery/contracts/test/ERC20.sol` — 94 行 · 注释 1 行 · B20
- [x] 151. `notes/uni-v2/v2-periphery/test/ExampleComputeLiquidityValue.spec.ts` — 454 行 · 注释 13 行 · B22
- [x] 152. `notes/uni-v2/v2-periphery/test/ExampleFlashSwap.spec.ts` — 153 行 · 注释 20 行 · B22
- [x] 153. `notes/uni-v2/v2-periphery/test/ExampleSlidingWindowOracle.spec.ts` — 294 行 · 注释 31 行 · B22
- [x] 154. `notes/uni-v2/v2-periphery/test/ExampleSwapToPrice.spec.ts` — 198 行 · 注释 1 行 · B22
- [x] 155. `notes/uni-v2/v2-periphery/test/UniswapV2Migrator.spec.ts` — 70 行 · 注释 1 行 · B22
- [x] 156. `notes/uni-v2/v2-periphery/test/UniswapV2Router01.spec.ts` — 734 行 · 注释 2 行 · B22
- [x] 157. `notes/uni-v2/v2-periphery/test/UniswapV2Router02.spec.ts` — 380 行 · 注释 6 行 · B22
- [x] 158. `notes/uni-v2/v2-periphery/test/shared/fixtures.ts` — 100 行 · 注释 9 行 · B22

### notes/uni-v3（15 / 15）

- [x] 159. `notes/uni-v3/README.md` → `notes/uni-v3/README_zh.md` — 15 行 · 文本 10 行 · B05
- [x] 160. `notes/uni-v3/py/arb/calc.py` — 242 行 · 注释 20 行 · B15
- [x] 161. `notes/uni-v3/py/arb/data.py` — 60 行 · 注释 4 行 · B15
- [x] 162. `notes/uni-v3/py/arb/main.py` — 41 行 · 注释 3 行 · B15
- [x] 163. `notes/uni-v3/py/dev.py` — 13 行 · 注释 2 行 · B15
- [x] 164. `notes/uni-v3/src/Constants.sol` — 17 行 · 注释 2 行 · B14
- [x] 165. `notes/uni-v3/src/V2.sol` — 94 行 · 注释 4 行 · B14
- [x] 166. `notes/uni-v3/src/interfaces/IERC20.sol` — 18 行 · 注释 1 行 · B14
- [x] 167. `notes/uni-v3/src/interfaces/uni-v3/IUniswapV3Pool.sol` — 52 行 · 注释 8 行 · B14
- [x] 168. `notes/uni-v3/src/lib/FullMath.sol` — 131 行 · 注释 58 行 · B14
- [x] 169. `notes/uni-v3/src/lib/TickBitmap.sol` — 61 行 · 注释 8 行 · B14
- [x] 170. `notes/uni-v3/src/lib/TickLiquidity.sol` — 60 行 · 注释 5 行 · B14
- [x] 171. `notes/uni-v3/src/lib/TickMath.sol` — 270 行 · 注释 22 行 · B14
- [x] 172. `notes/uni-v3/test/Py.sol` — 26 行 · 注释 1 行 · B15
- [x] 173. `notes/uni-v3/test/Sim.sol` — 249 行 · 注释 18 行 · B15

### topics（8 / 10）

- [x] 174. `topics/amm/curve-v1/StableSwap3Pool.vy` — 897 行 · 注释 140 行 · B23
- [x] 175. `topics/amm/curve-v1/comparisons.md` → `topics/amm/curve-v1/comparisons_zh.md` — 10 行 · 文本 8 行 · B03
- [x] 176. `topics/amm/curve-v2/CurveCryptoViews3Optimized.vy` — 414 行 · 注释 17 行 · B23
- [ ] 177. `topics/amm/curve-v2/CurveTricryptoMathOptimized.vy` — 878 行 · 注释 198 行 · B24
- [ ] 178. `topics/amm/curve-v2/CurveTricryptoOptimizedWETH.vy` — 2347 行 · 注释 654 行 · B25⏳ / B26⏳ / B27⏳
- [x] 179. `topics/amm/intro/amm_equations.md` → `topics/amm/intro/amm_equations_zh.md` — 8 行 · 文本 6 行 · B02
- [x] 180. `topics/amm/intro/amm_order_book.md` → `topics/amm/intro/amm_order_book_zh.md` — 62 行 · 文本 42 行 · B02
- [x] 181. `topics/amm/intro/what_is_amm.md` → `topics/amm/intro/what_is_amm_zh.md` — 31 行 · 文本 18 行 · B02
- [x] 182. `topics/mev/FlashbotsTest.sol` — 19 行 · 注释 2 行 · B15
- [x] 183. `topics/mev/README.md` → `topics/mev/README_zh.md` — 70 行 · 文本 47 行 · B03

### utils（3 / 3）

- [x] 184. `utils/flat.js` — 69 行 · 注释 4 行 · B15
- [x] 185. `utils/rename.js` — 37 行 · 注释 2 行 · B15
- [x] 186. `utils/video_durations.py` — 52 行 · 注释 3 行 · B15

### whitepapers（1 / 1）

- [x] 187. `whitepapers/README.md` → `whitepapers/README_zh.md` — 25 行 · 文本 13 行 · B01

### foundry（2 / 2）

- [x] 188. `foundry/.gitignore` — 17 行 · 注释 4 行 · B05
- [x] 189. `foundry/foundry.toml` — 10 行 · 注释 2 行 · B05

## 四、不在翻译范围内的文件

<details><summary>二进制文件（图片 / PDF）：63 个</summary>

- `.github/images/coursebadge.png`
- `.github/images/poweredbycyfrinbluehigher.png`
- `excalidraw/amm/csamm_example.png`
- `excalidraw/amm/curve-v1/curve-v1-contract.png`
- `excalidraw/amm/curve-v1/curve-v1-eq.png`
- `excalidraw/amm/curve-v1/curve-v1-newton.png`
- `excalidraw/amm/curve-v2/curve-v2-contract.png`
- `excalidraw/amm/curve-v2/curve-v2-ema-irregular-interval.png`
- `excalidraw/amm/curve-v2/curve-v2-ema-regular-interval.png`
- `excalidraw/amm/curve-v2/curve-v2-price-scale-amm-eq.png`
- `excalidraw/amm/curve-v2/curve-v2-price-scale-repeg.png`
- `excalidraw/amm/curve-v2/curve-v2-price-scale.png`
- `excalidraw/amm/pool_shares.png`
- `excalidraw/amm/slippage.png`
- `excalidraw/amm/uniswap-v2/uniswap_v2.png`
- `excalidraw/amm/uniswap-v2/uniswap_v2_arb.png`
- `excalidraw/amm/uniswap-v2/uniswap_v2_arb_optimal_amount_in.png`
- `excalidraw/amm/uniswap-v2/uniswap_v2_math.png`
- `excalidraw/amm/uniswap-v2/uniswap_v2_spot_price_oracle.png`
- `excalidraw/amm/uniswap-v2/uniswap_v2_twap.png`
- `excalidraw/amm/uniswap-v3/uni-v3-arbitrage.png`
- `excalidraw/amm/uniswap-v3/uniswap-v2-v3-diff.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-calc-fee.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-contracts.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-curve-real-reserves.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-delta-price.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-factory.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-above.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-below.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-inside.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-outside.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-position.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-intro.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-jit.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-liquidity-delta.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-liquidity-net.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-liquidity.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-next-tick.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-pool-call-trace.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-position-manager.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-price-tick.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-swap-algo.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-swap-contract-calls.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-swap-fee.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-tick-bitmap.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-twap-x-y.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-twap.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-xy-amounts.png`
- `excalidraw/amm/uniswap-v3/uniswap-v3-xy-equations.png`
- `excalidraw/amm/what_is_amm.png`
- `excalidraw/mev.png`
- `img/curve.png`
- `img/dai.png`
- `img/uniswap.png`
- `whitepapers/aave/aave-gho.pdf`
- `whitepapers/aave/aave-v1.pdf`
- `whitepapers/aave/aave-v2.pdf`
- `whitepapers/aave/aave-v3.pdf`
- `whitepapers/curve/curve-cryptopools.pdf`
- `whitepapers/curve/curve-stableswap.pdf`
- `whitepapers/uniswap/uniswap-v2.pdf`
- `whitepapers/uniswap/uniswap-v3.pdf`

</details>

<details><summary>不含需要翻译的英文注释：66 个</summary>

- `.gitignore`
- `.gitmodules`
- `foundry/lib/forge-std/.gitattributes`
- `foundry/lib/forge-std/.github/workflows/sync.yml`
- `foundry/lib/forge-std/.gitignore`
- `foundry/lib/forge-std/src/StdStyle.sol`
- `foundry/lib/forge-std/src/interfaces/IMulticall3.sol`
- `foundry/lib/forge-std/test/StdJson.t.sol`
- `foundry/lib/forge-std/test/StdStyle.t.sol`
- `foundry/lib/forge-std/test/StdToml.t.sol`
- `foundry/lib/forge-std/test/fixtures/test.toml`
- `foundry/lib/forge-std/test/mocks/MockERC20.t.sol`
- `foundry/lib/forge-std/test/mocks/MockERC721.t.sol`
- `foundry/src/dai/DaiProxy.sol`
- `foundry/src/interfaces/IERC20.sol`
- `foundry/src/interfaces/IERC721.sol`
- `foundry/src/interfaces/IWETH.sol`
- `foundry/src/interfaces/curve/IStableSwap3Pool.sol`
- `foundry/src/interfaces/curve/ITriCrypto.sol`
- `foundry/src/interfaces/uniswap-v2/IUniswapV2Factory.sol`
- `foundry/src/interfaces/uniswap-v2/IUniswapV2Pair.sol`
- `foundry/src/interfaces/uniswap-v2/IUniswapV2Router01.sol`
- `foundry/src/interfaces/uniswap-v2/IUniswapV2Router02.sol`
- `foundry/src/interfaces/uniswap-v3/INonfungiblePositionManager.sol`
- `foundry/src/interfaces/uniswap-v3/IUniswapV3Factory.sol`
- `foundry/src/interfaces/uniswap-v3/IUniswapV3FlashCallback.sol`
- `foundry/src/interfaces/uniswap-v3/IUniswapV3MintCallback.sol`
- `foundry/src/interfaces/uniswap-v3/IUniswapV3SwapCallback.sol`
- `foundry/test/uniswap-v2/UniswapV2SwapAmounts.test.sol`
- `foundry/test/uniswap-v3/exercises/UniswapV3Flash.test.sol`
- `foundry/test/uniswap-v3/exercises/UniswapV3Twap.test.sol`
- `foundry/test/uniswap-v3/solutions/UniswapV3Flash.test.sol`
- `foundry/test/uniswap-v3/solutions/UniswapV3Twap.test.sol`
- `notebook/uniswap_v2_twap.ipynb`
- `notes/uni-v2/v2-core/.gitattributes`
- `notes/uni-v2/v2-core/.gitignore`
- `notes/uni-v2/v2-core/contracts/interfaces/IERC20.sol`
- `notes/uni-v2/v2-core/contracts/interfaces/IUniswapV2Callee.sol`
- `notes/uni-v2/v2-core/contracts/interfaces/IUniswapV2ERC20.sol`
- `notes/uni-v2/v2-core/contracts/interfaces/IUniswapV2Factory.sol`
- `notes/uni-v2/v2-core/contracts/interfaces/IUniswapV2Pair.sol`
- `notes/uni-v2/v2-core/contracts/test/ERC20.sol`
- `notes/uni-v2/v2-core/test/shared/fixtures.ts`
- `notes/uni-v2/v2-core/test/shared/utilities.ts`
- `notes/uni-v2/v2-periphery/.gitattributes`
- `notes/uni-v2/v2-periphery/.gitignore`
- `notes/uni-v2/v2-periphery/.yarnrc`
- `notes/uni-v2/v2-periphery/contracts/interfaces/IERC20.sol`
- `notes/uni-v2/v2-periphery/contracts/interfaces/IUniswapV2Migrator.sol`
- `notes/uni-v2/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol`
- `notes/uni-v2/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol`
- `notes/uni-v2/v2-periphery/contracts/interfaces/IWETH.sol`
- `notes/uni-v2/v2-periphery/contracts/interfaces/V1/IUniswapV1Exchange.sol`
- `notes/uni-v2/v2-periphery/contracts/interfaces/V1/IUniswapV1Factory.sol`
- `notes/uni-v2/v2-periphery/contracts/test/RouterEventEmitter.sol`
- `notes/uni-v2/v2-periphery/test/ExampleOracleSimple.spec.ts`
- `notes/uni-v2/v2-periphery/test/shared/utilities.ts`
- `notes/uni-v3/foundry.toml`
- `notes/uni-v3/src/V3.sol`
- `notes/uni-v3/src/interfaces/IERC721.sol`
- `notes/uni-v3/src/interfaces/IPool.sol`
- `notes/uni-v3/src/interfaces/IWETH.sol`
- `notes/uni-v3/src/interfaces/uni-v2/IUniswapV2Pair.sol`
- `notes/uni-v3/src/interfaces/uni-v3/IUniswapV3SwapCallback.sol`
- `notes/uni-v3/src/lib/BitMath.sol`
- `notes/uni-v3/src/lib/Math.sol`

</details>

<details><summary>许可证法律文本：5 个</summary>

- `LICENSE`
- `foundry/lib/forge-std/LICENSE-APACHE`
- `foundry/lib/forge-std/LICENSE-MIT`
- `notes/uni-v2/v2-core/LICENSE`
- `notes/uni-v2/v2-periphery/LICENSE`

</details>

<details><summary>Excalidraw 绘图数据（JSON，非注释）：51 个</summary>

- `excalidraw/aave-v3.excalidraw`
- `excalidraw/amm/csamm_example.excalidraw`
- `excalidraw/amm/curve-v1/curve-v1-contract.excalidraw`
- `excalidraw/amm/curve-v1/curve-v1-eq.excalidraw`
- `excalidraw/amm/curve-v1/curve-v1-newton.excalidraw`
- `excalidraw/amm/curve-v2/curve-v2-contract.excalidraw`
- `excalidraw/amm/curve-v2/curve-v2-ema-irregular-interval.excalidraw`
- `excalidraw/amm/curve-v2/curve-v2-ema-regular-interval.excalidraw`
- `excalidraw/amm/curve-v2/curve-v2-price-scale-amm-eq.excalidraw`
- `excalidraw/amm/curve-v2/curve-v2-price-scale-repeg.excalidraw`
- `excalidraw/amm/curve-v2/curve-v2-price-scale.excalidraw`
- `excalidraw/amm/pool_shares.excalidraw`
- `excalidraw/amm/slippage.excalidraw`
- `excalidraw/amm/uniswap-v2/uniswap_v2.excalidraw`
- `excalidraw/amm/uniswap-v2/uniswap_v2_arb.excalidraw`
- `excalidraw/amm/uniswap-v2/uniswap_v2_arb_optimal_amount_in.excalidraw`
- `excalidraw/amm/uniswap-v2/uniswap_v2_math.excalidraw`
- `excalidraw/amm/uniswap-v2/uniswap_v2_spot_price_oracle.excalidraw`
- `excalidraw/amm/uniswap-v2/uniswap_v2_twap.excalidraw`
- `excalidraw/amm/uniswap-v3/uni-v3-arbitrage.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v2-v3-diff.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-calc-fee.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-contracts.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-curve-real-reserves.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-delta-price.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-factory.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-above.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-below.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-inside.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth-outside.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-growth.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-fee-position.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-intro.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-jit.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-liquidity-delta.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-liquidity-net.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-liquidity.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-next-tick.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-pool-call-trace.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-position-manager.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-price-tick.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-swap-algo.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-swap-contract-calls.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-swap-fee.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-tick-bitmap.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-twap-x-y.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-twap.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-xy-amounts.excalidraw`
- `excalidraw/amm/uniswap-v3/uniswap-v3-xy-equations.excalidraw`
- `excalidraw/amm/what_is_amm.excalidraw`
- `excalidraw/mev.excalidraw`

</details>

<details><summary>JSON / 锁文件 / 元数据（无注释）：16 个</summary>

- `foundry/lib/forge-std/package.json`
- `foundry/lib/forge-std/test/fixtures/broadcast.log.json`
- `foundry/lib/forge-std/test/fixtures/test.json`
- `notes/uni-v2/v2-core/.mocharc.json`
- `notes/uni-v2/v2-core/.prettierrc`
- `notes/uni-v2/v2-core/.waffle.json`
- `notes/uni-v2/v2-core/CITATION.cff`
- `notes/uni-v2/v2-core/package.json`
- `notes/uni-v2/v2-core/tsconfig.json`
- `notes/uni-v2/v2-core/yarn.lock`
- `notes/uni-v2/v2-periphery/.mocharc.json`
- `notes/uni-v2/v2-periphery/.prettierrc`
- `notes/uni-v2/v2-periphery/.waffle.json`
- `notes/uni-v2/v2-periphery/package.json`
- `notes/uni-v2/v2-periphery/tsconfig.json`
- `notes/uni-v2/v2-periphery/yarn.lock`

</details>

<details><summary>仅含 GPL 许可证文本与被注释掉的代码：1 个</summary>

- `notes/uni-v2/v2-periphery/contracts/test/WETH9.sol`

</details>

## 五、更新日志

- 2026-11-01 任务初始化：统计 391 个跟踪文件，确定 189 个待翻译文件，分为 27 个批次交由子代理并行翻译。
- 2026-11-01 启动 B01–B20 共 20 个子代理（达到并发上限 20），B21–B27 排队，待有子代理完成后补位启动。
- 2026-11-01 15:07 B09 完成（3 项，校验通过）：safeconsole 342 行选择器注释批量译出；SPDX、@author、@solidity memory-safe-assembly 编译器注解保留
- 2026-11-01 B09 完成后补位启动 B21。
- 2026-11-01 15:07 B06 完成（1 项，校验通过）：Vm.sol 第 1–441 行 200 行注释
- 2026-11-01 B06 完成后补位启动 B22。
- 2026-11-01 15:08 B02 完成（5 项，校验通过）：围栏内为纯英文说明文字（非代码），一并译出
- 2026-11-01 15:08 B05 完成（10 项，校验通过）
- 2026-11-01 B02、B05 完成后补位启动 B23、B24。
- 2026-11-01 15:08 B04 完成（2 项，校验通过）
- 2026-11-01 15:08 B07 完成（1 项，校验通过）
- 2026-11-01 15:08 B13 完成（12 项，校验通过）
- 2026-11-01 15:08 B16 完成（13 项，校验通过）
- 2026-11-01 15:08 B17 完成（8 项，校验通过）
- 2026-11-01 15:08 B18 完成（30 项，校验通过）
- 2026-11-01 15:08 B19 完成（12 项，校验通过）
- 2026-11-01 补位启动最后 3 个批次 B25、B26、B27，至此 27 个批次全部启动。
- 2026-11-01 15:08 B01 完成（4 项，校验通过）
- 2026-11-01 15:08 B03 完成（3 项，校验通过）
- 2026-11-01 15:08 B11 完成（2 项，校验通过）
- 2026-11-01 15:09 B14 完成（16 项，校验通过）
- 2026-11-01 15:09 B15 完成（15 项，校验通过）
- 2026-11-01 15:09 B08 完成（1 项，校验通过）
- 2026-11-01 15:09 B10 完成（5 项，校验通过）
- 2026-11-01 15:09 B12 完成（13 项，校验通过）
- 2026-11-01 15:09 B20 完成（15 项，校验通过）
- 2026-11-01 15:09 B22 完成（8 项，校验通过）
- 2026-11-01 15:10 B21 完成（8 项，校验通过）：NOTE 统一译为“注意：”（含 B20 三个文件）
- 2026-11-01 15:10 B23 完成（2 项，校验通过）：Vyper 的 # dev: revert 注释保留 dev: 前缀、翻译说明
