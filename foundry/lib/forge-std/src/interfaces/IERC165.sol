// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IERC165 {
    /// @notice 查询合约是否实现了某个接口
    /// @param interfaceID 接口标识符，规范见 ERC-165
    /// @dev 接口识别方式由 ERC-165 规定。该函数
    /// 消耗的 gas 少于 30,000。
    /// @return `true`：若合约实现了 `interfaceID` 且
    /// `interfaceID` 不为 0xffffffff；否则返回 `false`
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
