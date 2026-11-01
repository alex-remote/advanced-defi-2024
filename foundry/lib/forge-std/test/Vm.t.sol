// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test} from "../src/Test.sol";
import {Vm, VmSafe} from "../src/Vm.sol";

contract VmTest is Test {
    // 该测试确保函数不会被意外地从 Vm 接口中移除，
    // 或在 Vm 与 VmSafe 之间被无意移动。每当在 Vm 或 VmSafe 中添加或移除
    // 函数时，都必须更新此测试。
    function test_interfaceId() public pure {
        assertEq(type(VmSafe).interfaceId, bytes4(0xce9c7617), "VmSafe");
        assertEq(type(Vm).interfaceId, bytes4(0xaf68a970), "Vm");
    }
}
