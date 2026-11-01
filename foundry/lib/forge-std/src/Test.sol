// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

// 💬 简介
// Forge Std 的默认 Test。

// 🧩 模块
import {console} from "./console.sol";
import {console2} from "./console2.sol";
import {safeconsole} from "./safeconsole.sol";
import {StdAssertions} from "./StdAssertions.sol";
import {StdChains} from "./StdChains.sol";
import {StdCheats} from "./StdCheats.sol";
import {stdError} from "./StdError.sol";
import {StdInvariant} from "./StdInvariant.sol";
import {stdJson} from "./StdJson.sol";
import {stdMath} from "./StdMath.sol";
import {StdStorage, stdStorage} from "./StdStorage.sol";
import {StdStyle} from "./StdStyle.sol";
import {stdToml} from "./StdToml.sol";
import {StdUtils} from "./StdUtils.sol";
import {Vm} from "./Vm.sol";

// 📦 样板代码
import {TestBase} from "./Base.sol";

// ⭐️ 测试
abstract contract Test is TestBase, StdAssertions, StdChains, StdCheats, StdInvariant, StdUtils {
    // 注意：IS_TEST() 必须返回 true。
    bool public IS_TEST = true;
}
