// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

pragma experimental ABIEncoderV2;

import {IMulticall3} from "./interfaces/IMulticall3.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {MockERC721} from "./mocks/MockERC721.sol";
import {VmSafe} from "./Vm.sol";

abstract contract StdUtils {
    /*//////////////////////////////////////////////////////////////////////////
                                     常量
    //////////////////////////////////////////////////////////////////////////*/

    IMulticall3 private constant multicall = IMulticall3(0xcA11bde05977b3631167028862bE2a173976CA11);
    VmSafe private constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));
    address private constant CONSOLE2_ADDRESS = 0x000000000000000000636F6e736F6c652e6c6f67;
    uint256 private constant INT256_MIN_ABS =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;
    uint256 private constant SECP256K1_ORDER =
        115792089237316195423570985008687907852837564279074904382605163141518161494337;
    uint256 private constant UINT256_MAX =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    // 使用 create2 部署时默认使用此地址，https://github.com/Arachnid/deterministic-deployment-proxy。
    address private constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    /*//////////////////////////////////////////////////////////////////////////
                                 内部函数
    //////////////////////////////////////////////////////////////////////////*/

    function _bound(uint256 x, uint256 min, uint256 max) internal pure virtual returns (uint256 result) {
        require(min <= max, "StdUtils bound(uint256,uint256,uint256): Max is less than min.");
        // 如果 x 位于 min 和 max 之间，则直接返回 x。这是为了确保当 min 不为零时，
        // 字典值（dictionary values）不会被平移。更多信息：https://github.com/foundry-rs/forge-std/issues/188
        if (x >= min && x <= max) return x;

        uint256 size = max - min + 1;

        // 如果值为 0、1、2、3，则将其映射为 min、min+1、min+2、min+3。UINT256_MAX 一侧同理。
        // 这有助于确保覆盖到 min/max 这些边界值。
        if (x <= 3 && size > x) return min + x;
        if (x >= UINT256_MAX - 3 && size > UINT256_MAX - x) return max - (UINT256_MAX - x);

        // 否则，将 x 回绕到区间 [min, max] 内，即该区间是闭区间（包含两端）。
        if (x > max) {
            uint256 diff = x - max;
            uint256 rem = diff % size;
            if (rem == 0) return max;
            result = min + rem - 1;
        } else if (x < min) {
            uint256 diff = min - x;
            uint256 rem = diff % size;
            if (rem == 0) return min;
            result = max - rem + 1;
        }
    }

    function bound(uint256 x, uint256 min, uint256 max) internal pure virtual returns (uint256 result) {
        result = _bound(x, min, max);
        console2_log_StdUtils("Bound Result", result);
    }

    function _bound(int256 x, int256 min, int256 max) internal pure virtual returns (int256 result) {
        require(min <= max, "StdUtils bound(int256,int256,int256): Max is less than min.");

        // 把所有 int256 值平移到 uint256 上，以便使用 _bound 函数。两种类型的取值范围分别为：
        // int256 : -(2**255) ~ (2**255 - 1)
        // uint256:     0     ~ (2**256 - 1)
        // 因此，给这些整数值加上 2**255，即 INT256_MIN_ABS。
        //
        // 如果给定的整数值为 -2**255，由于会发生上溢，我们不能使用 `-uint256(-x)`。
        // 因此改用 `~uint256(x) + 1`。
        uint256 _x = x < 0 ? (INT256_MIN_ABS - ~uint256(x) - 1) : (uint256(x) + INT256_MIN_ABS);
        uint256 _min = min < 0 ? (INT256_MIN_ABS - ~uint256(min) - 1) : (uint256(min) + INT256_MIN_ABS);
        uint256 _max = max < 0 ? (INT256_MIN_ABS - ~uint256(max) - 1) : (uint256(max) + INT256_MIN_ABS);

        uint256 y = _bound(_x, _min, _max);

        // 为了把它变回 int256 值，在这里减去 INT256_MIN_ABS。
        result = y < INT256_MIN_ABS ? int256(~(INT256_MIN_ABS - y) + 1) : int256(y - INT256_MIN_ABS);
    }

    function bound(int256 x, int256 min, int256 max) internal pure virtual returns (int256 result) {
        result = _bound(x, min, max);
        console2_log_StdUtils("Bound result", vm.toString(result));
    }

    function boundPrivateKey(uint256 privateKey) internal pure virtual returns (uint256 result) {
        result = _bound(privateKey, 1, SECP256K1_ORDER - 1);
    }

    function bytesToUint(bytes memory b) internal pure virtual returns (uint256) {
        require(b.length <= 32, "StdUtils bytesToUint(bytes): Bytes length exceeds 32.");
        return abi.decode(abi.encodePacked(new bytes(32 - b.length), b), (uint256));
    }

    /// @dev 根据给定的部署者地址和 nonce，计算合约将被部署到的地址
    /// @notice 改编自 Solmate 的实现（https://github.com/Rari-Capital/solmate/blob/main/src/utils/LibRLP.sol）
    function computeCreateAddress(address deployer, uint256 nonce) internal pure virtual returns (address) {
        console2_log_StdUtils("computeCreateAddress is deprecated. Please use vm.computeCreateAddress instead.");
        return vm.computeCreateAddress(deployer, nonce);
    }

    function computeCreate2Address(bytes32 salt, bytes32 initcodeHash, address deployer)
        internal
        pure
        virtual
        returns (address)
    {
        console2_log_StdUtils("computeCreate2Address is deprecated. Please use vm.computeCreate2Address instead.");
        return vm.computeCreate2Address(salt, initcodeHash, deployer);
    }

    /// @dev 返回使用默认 CREATE2 部署器通过 CREATE2 创建的合约地址
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash) internal pure returns (address) {
        console2_log_StdUtils("computeCreate2Address is deprecated. Please use vm.computeCreate2Address instead.");
        return vm.computeCreate2Address(salt, initCodeHash);
    }

    /// @dev 返回一个已初始化的 mock ERC20 合约
    function deployMockERC20(string memory name, string memory symbol, uint8 decimals)
        internal
        returns (MockERC20 mock)
    {
        mock = new MockERC20();
        mock.initialize(name, symbol, decimals);
    }

    /// @dev 返回一个已初始化的 mock ERC721 合约
    function deployMockERC721(string memory name, string memory symbol) internal returns (MockERC721 mock) {
        mock = new MockERC721();
        mock.initialize(name, symbol);
    }

    /// @dev 返回在 CREATE2 中使用的 init code（creation code + 无参数）的哈希，适用于构造函数无参数的情况
    /// @param creationCode 合约 C 的 creation code，即 type(C).creationCode 的返回值
    function hashInitCode(bytes memory creationCode) internal pure returns (bytes32) {
        return hashInitCode(creationCode, "");
    }

    /// @dev 返回在 CREATE2 中使用的 init code（creation code + ABI 编码的参数）的哈希
    /// @param creationCode 合约 C 的 creation code，即 type(C).creationCode 的返回值
    /// @param args 传给 C 的构造函数的 ABI 编码参数
    function hashInitCode(bytes memory creationCode, bytes memory args) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(creationCode, args));
    }

    // 通过 Multicall3 发起一次调用，查询给定地址列表的 ERC-20 代币余额。
    function getTokenBalances(address token, address[] memory addresses)
        internal
        virtual
        returns (uint256[] memory balances)
    {
        uint256 tokenCodeSize;
        assembly {
            tokenCodeSize := extcodesize(token)
        }
        require(tokenCodeSize > 0, "StdUtils getTokenBalances(address,address[]): Token address is not a contract.");

        // 对发往 Multicall3 的 aggregate 调用进行 ABI 编码。
        uint256 length = addresses.length;
        IMulticall3.Call[] memory calls = new IMulticall3.Call[](length);
        for (uint256 i = 0; i < length; ++i) {
            // 0x70a08231 = bytes4("balanceOf(address)"))
            calls[i] = IMulticall3.Call({target: token, callData: abi.encodeWithSelector(0x70a08231, (addresses[i]))});
        }

        // 发起 aggregate 调用。
        (, bytes[] memory returnData) = multicall.aggregate(calls);

        // 对返回数据进行 ABI 解码，并返回余额。
        balances = new uint256[](length);
        for (uint256 i = 0; i < length; ++i) {
            balances[i] = abi.decode(returnData[i], (uint256));
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                 私有函数
    //////////////////////////////////////////////////////////////////////////*/

    function addressFromLast20Bytes(bytes32 bytesValue) private pure returns (address) {
        return address(uint160(uint256(bytesValue)));
    }

    // 本部分用于避免编译 console，当其他地方没有用到 console 时可以缩短编译时间。我们还
    // 通过一些技巧让编译器允许把 console log 方法声明为 `pure`，以避免
    // 对函数签名造成任何破坏性变更。
    function _castLogPayloadViewToPure(function(bytes memory) internal view fnIn)
        internal
        pure
        returns (function(bytes memory) internal pure fnOut)
    {
        assembly {
            fnOut := fnIn
        }
    }

    function _sendLogPayload(bytes memory payload) internal pure {
        _castLogPayloadViewToPure(_sendLogPayloadView)(payload);
    }

    function _sendLogPayloadView(bytes memory payload) private view {
        uint256 payloadLength = payload.length;
        address consoleAddress = CONSOLE2_ADDRESS;
        /// @solidity memory-safe-assembly
        assembly {
            let payloadStart := add(payload, 32)
            let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
        }
    }

    function console2_log_StdUtils(string memory p0) private pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function console2_log_StdUtils(string memory p0, uint256 p1) private pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }

    function console2_log_StdUtils(string memory p0, string memory p1) private pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
    }
}
