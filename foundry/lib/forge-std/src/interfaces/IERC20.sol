// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/// @dev EIP 中定义的 ERC20 标准接口。
/// @dev 其中包含可选的 name、symbol 和 decimals 元数据。
interface IERC20 {
    /// @dev 当 `value` 数量的代币从一个账户（`from`）转移到另一个账户（`to`）时触发。
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev 当 `owner` 为 `spender` 设置授权额度时触发，其中 `value`
    /// 为新的授权额度。
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice 返回现存代币的总量。
    function totalSupply() external view returns (uint256);

    /// @notice 返回 `account` 持有的代币数量。
    function balanceOf(address account) external view returns (uint256);

    /// @notice 将 `amount` 数量的代币从调用者账户转移给 `to`。
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice 返回 `spender` 被允许代表 `owner`
    /// 花费的剩余代币数量
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice 将 `spender` 对调用者代币的授权额度设置为 `amount`。
    /// @dev 注意抢跑风险：https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice 利用授权额度机制，将 `amount` 数量的代币从 `from` 转移给 `to`。
    /// 随后从调用者的授权额度中扣除 `amount`。
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice 返回代币的名称。
    function name() external view returns (string memory);

    /// @notice 返回代币的符号。
    function symbol() external view returns (string memory);

    /// @notice 返回代币的小数位数。
    function decimals() external view returns (uint8);
}
