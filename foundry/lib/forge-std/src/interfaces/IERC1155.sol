// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IERC165.sol";

/// @title ERC-1155 多代币标准
/// @dev 参见 https://eips.ethereum.org/EIPS/eip-1155
/// 注意：本接口的 ERC-165 标识符为 0xd9b67a26。
interface IERC1155 is IERC165 {
    /// @dev
    /// - 代币发生转移时（包括零值转账以及铸造或销毁），必须触发 `TransferSingle` 或 `TransferBatch` 二者之一（参见标准中的 "Safe Transfer Rules"（安全转账规则）一节）。
    /// - `_operator` 参数必须是被授权执行该转账的账户/合约地址（应当为 msg.sender）。
    /// - `_from` 参数必须是余额减少的持有者地址。
    /// - `_to` 参数必须是余额增加的接收者地址。
    /// - `_id` 参数必须是被转移的代币类型。
    /// - `_value` 参数必须是持有者余额减少的代币数量，且与接收者余额增加的数量一致。
    /// - 铸造/创建代币时，`_from` 参数必须设为 `0x0`（即零地址）。
    /// - 销毁代币时，`_to` 参数必须设为 `0x0`（即零地址）。
    event TransferSingle(
        address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value
    );

    /// @dev
    /// - 代币发生转移时（包括零值转账以及铸造或销毁），必须触发 `TransferSingle` 或 `TransferBatch` 二者之一（参见标准中的 "Safe Transfer Rules"（安全转账规则）一节）。
    /// - `_operator` 参数必须是被授权执行该转账的账户/合约地址（应当为 msg.sender）。
    /// - `_from` 参数必须是余额减少的持有者地址。
    /// - `_to` 参数必须是余额增加的接收者地址。
    /// - `_ids` 参数必须是被转移的代币列表。
    /// - `_values` 参数必须是持有者余额减少的代币数量列表（与 _ids 中指定的代币列表及顺序一一对应），且与接收者余额增加的数量一致。
    /// - 铸造/创建代币时，`_from` 参数必须设为 `0x0`（即零地址）。
    /// - 销毁代币时，`_to` 参数必须设为 `0x0`（即零地址）。
    event TransferBatch(
        address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values
    );

    /// @dev 当某个持有者地址启用或禁用第二方/操作员地址管理其全部代币的授权时，必须触发此事件（没有该事件则视为禁用）。
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @dev 当某个代币 ID 的 URI 更新时，必须触发此事件。URI 定义于 RFC 3986。
    /// 该 URI 必须指向一个符合 "ERC-1155 Metadata URI JSON Schema"（ERC-1155 元数据 URI JSON 模式）的 JSON 文件。
    event URI(string _value, uint256 indexed _id);

    /// @notice 将 `_value` 数量的 `_id` 从 `_from` 地址转移到指定的 `_to` 地址（带安全调用）。
    /// @dev 调用者必须已被授权管理从 `_from` 账户转出的代币（参见标准中的 "Approval"（授权）一节）。
    /// - 如果 `_to` 是零地址，必须回滚（revert）。
    /// - 如果持有者的代币 `_id` 余额低于发送的 `_value`，必须回滚。
    /// - 发生任何其他错误时，必须回滚。
    /// - 必须触发 `TransferSingle` 事件以反映余额变化（参见标准中的 "Safe Transfer Rules"（安全转账规则）一节）。
    /// - 满足上述条件后，本函数必须检查 `_to` 是否为智能合约（例如代码大小 > 0）。如果是，则必须调用 `_to` 上的 `onERC1155Received` 并做出相应处理（参见标准中的 "Safe Transfer Rules"（安全转账规则）一节）。
    /// @param _from 源地址
    /// @param _to 目标地址
    /// @param _id 代币类型的 ID
    /// @param _value 转账数量
    /// @param _data 无指定格式的附加数据，必须原样传入对 `_to` 上 `onERC1155Received` 的调用
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    /// @notice 将 `_values` 数量的 `_ids` 从 `_from` 地址转移到指定的 `_to` 地址（带安全调用）。
    /// @dev 调用者必须已被授权管理从 `_from` 账户转出的代币（参见标准中的 "Approval"（授权）一节）。
    /// - 如果 `_to` 是零地址，必须回滚（revert）。
    /// - 如果 `_ids` 的长度与 `_values` 的长度不同，必须回滚。
    /// - 如果 `_ids` 中任一代币对应的持有者余额低于 `_values` 中发送给接收者的相应数量，必须回滚。
    /// - 发生任何其他错误时，必须回滚。
    /// - 必须触发 `TransferSingle` 或 `TransferBatch` 事件，使所有余额变化都得到反映（参见标准中的 "Safe Transfer Rules"（安全转账规则）一节）。
    /// - 余额变化和事件必须遵循数组的顺序（_ids[0]/_values[0] 先于 _ids[1]/_values[1]，依此类推）。
    /// - 批量中各笔转账满足上述条件后，本函数必须检查 `_to` 是否为智能合约（例如代码大小 > 0）。如果是，则必须调用 `_to` 上相应的 `ERC1155TokenReceiver` 钩子（hook）并做出相应处理（参见标准中的 "Safe Transfer Rules"（安全转账规则）一节）。
    /// @param _from 源地址
    /// @param _to 目标地址
    /// @param _ids 每种代币类型的 ID（顺序和长度必须与 _values 数组一致）
    /// @param _values 每种代币类型的转账数量（顺序和长度必须与 _ids 数组一致）
    /// @param _data 无指定格式的附加数据，必须原样传入对 `_to` 上 `ERC1155TokenReceiver` 钩子的调用
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    /// @notice 获取某个账户的代币余额。
    /// @param _owner 代币持有者的地址
    /// @param _id 代币的 ID
    /// @return 所请求代币类型中 _owner 的余额
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

    /// @notice 获取多个账户/代币对的余额
    /// @param _owners 代币持有者的地址列表
    /// @param _ids 代币的 ID 列表
    /// @return 所请求各代币类型中 _owner 的余额（即每个 (owner, id) 对的余额）
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    /// @notice 启用或禁用第三方（“操作员”）管理调用者全部代币的授权。
    /// @dev 成功时必须触发 ApprovalForAll 事件。
    /// @param _operator 要加入已授权操作员集合的地址
    /// @param _approved 为 true 表示授权该操作员，为 false 表示撤销授权
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice 查询给定持有者对某个操作员的授权状态。
    /// @param _owner 代币的持有者
    /// @param _operator 已授权操作员的地址
    /// @return 若该操作员已被授权则返回 true，否则返回 false
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
