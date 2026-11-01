// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

import "../../src/Script.sol";

// 该合约的目的是对编译时间做基准测试，以避免意外引入
// 导致 via-ir 编译时间过长的改动。参见 https://github.com/foundry-rs/forge-std/issues/207
contract CompilationScriptBase is ScriptBase {}
