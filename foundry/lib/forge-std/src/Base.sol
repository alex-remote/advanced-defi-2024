// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {StdStorage} from "./StdStorage.sol";
import {Vm, VmSafe} from "./Vm.sol";

abstract contract CommonBase {
    // cheatcode（作弊码）合约地址，0x7109709ECfa91a80626fF3989D68f67F5b1DD12D。
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    // console.sol 和 console2.sol 的工作方式是对该地址执行 staticcall。
    address internal constant CONSOLE = 0x000000000000000000636F6e736F6c652e6c6f67;
    // 使用 create2 部署时使用此地址，https://github.com/Arachnid/deterministic-deployment-proxy。
    address internal constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    // tx.origin 和 msg.sender 的默认地址，0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38。
    address internal constant DEFAULT_SENDER = address(uint160(uint256(keccak256("foundry default caller"))));
    // 测试合约的地址，由 DEFAULT_SENDER 部署。
    address internal constant DEFAULT_TEST_CONTRACT = 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;
    // Multicall3 合约的确定性部署地址。
    address internal constant MULTICALL3_ADDRESS = 0xcA11bde05977b3631167028862bE2a173976CA11;
    // secp256k1 曲线的阶。
    uint256 internal constant SECP256K1_ORDER =
        115792089237316195423570985008687907852837564279074904382605163141518161494337;

    uint256 internal constant UINT256_MAX =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    Vm internal constant vm = Vm(VM_ADDRESS);
    StdStorage internal stdstore;
}

abstract contract TestBase is CommonBase {}

abstract contract ScriptBase is CommonBase {
    VmSafe internal constant vmSafe = VmSafe(VM_ADDRESS);
}
