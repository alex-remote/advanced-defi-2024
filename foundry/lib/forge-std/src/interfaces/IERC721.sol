// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IERC165.sol";

/// @title ERC-721 非同质化代币标准
/// @dev 参见 https://eips.ethereum.org/EIPS/eip-721
/// 注意：本接口的 ERC-165 标识符为 0x80ac58cd。
interface IERC721 is IERC165 {
    /// @dev 当任何 NFT 的所有权通过任何机制发生变更时，触发此事件。
    /// NFT 被创建（`from` == 0）和被销毁
    /// （`to` == 0）时也会触发此事件。例外：在合约创建期间，可以创建并分配任意数量的 NFT
    /// 而不触发 Transfer。在发生
    /// 任何转账时，该 NFT 的被授权地址（如有）都会被重置为空。
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev 当某个 NFT 的被授权地址被更改或
    /// 被重新确认时，触发此事件。零地址表示没有被授权地址。
    /// 当 Transfer 事件触发时，这同时也表示该 NFT 的被授权
    /// 地址（如有）已被重置为空。
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev 当某个持有者启用或禁用某个操作员时，触发此事件。
    /// 操作员可以管理该持有者的所有 NFT。
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice 统计分配给某个持有者的全部 NFT 数量
    /// @dev 分配给零地址的 NFT 被视为无效，本函数
    /// 在查询零地址时会抛出异常。
    /// @param _owner 要查询余额的地址
    /// @return `_owner` 持有的 NFT 数量，可能为零
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice 查找某个 NFT 的持有者
    /// @dev 分配给零地址的 NFT 被视为无效，对它们的查询
    /// 会抛出异常。
    /// @param _tokenId NFT 的标识符
    /// @return 该 NFT 持有者的地址
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice 将 NFT 的所有权从一个地址转移到另一个地址
    /// @dev 除非 `msg.sender` 是当前持有者、已授权的
    /// 操作员或该 NFT 的被授权地址，否则抛出异常。如果 `_from` 不是
    /// 当前持有者，则抛出异常。如果 `_to` 是零地址，则抛出异常。如果
    /// `_tokenId` 不是有效的 NFT，则抛出异常。转账完成后，本函数
    /// 会检查 `_to` 是否为智能合约（代码大小 > 0）。如果是，则调用
    /// `_to` 上的 `onERC721Received`，若返回值不等于以下值则抛出异常：
    /// `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from 该 NFT 的当前持有者
    /// @param _to 新的持有者
    /// @param _tokenId 要转移的 NFT
    /// @param data 无指定格式的附加数据，会在调用 `_to` 时一并发送
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice 将 NFT 的所有权从一个地址转移到另一个地址
    /// @dev 此函数与另一个带额外 data 参数的同名函数行为完全相同，
    /// 只是此函数会把 data 设为 ""。
    /// @param _from 该 NFT 的当前持有者
    /// @param _to 新的持有者
    /// @param _tokenId 要转移的 NFT
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice 转移 NFT 的所有权 -- 调用者有责任
    /// 确认 `_to` 能够接收 NFT，否则
    /// 这些 NFT 可能会永久丢失
    /// @dev 除非 `msg.sender` 是当前持有者、已授权的
    /// 操作员或该 NFT 的被授权地址，否则抛出异常。如果 `_from` 不是
    /// 当前持有者，则抛出异常。如果 `_to` 是零地址，则抛出异常。如果
    /// `_tokenId` 不是有效的 NFT，则抛出异常。
    /// @param _from 该 NFT 的当前持有者
    /// @param _to 新的持有者
    /// @param _tokenId 要转移的 NFT
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice 更改或重新确认某个 NFT 的被授权地址
    /// @dev 零地址表示没有被授权地址。
    /// 除非 `msg.sender` 是该 NFT 的当前持有者，或是当前持有者的
    /// 已授权操作员，否则抛出异常。
    /// @param _approved 新的被授权 NFT 控制者
    /// @param _tokenId 要授权的 NFT
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice 启用或禁用第三方（“操作员”）管理
    /// `msg.sender` 全部资产的授权
    /// @dev 触发 ApprovalForAll 事件。合约必须允许
    /// 每个持有者拥有多个操作员。
    /// @param _operator 要加入已授权操作员集合的地址
    /// @param _approved 为 true 表示授权该操作员，为 false 表示撤销授权
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice 获取单个 NFT 的被授权地址
    /// @dev 如果 `_tokenId` 不是有效的 NFT，则抛出异常。
    /// @param _tokenId 要查询其被授权地址的 NFT
    /// @return 该 NFT 的被授权地址；若没有，则返回零地址
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice 查询某个地址是否为另一个地址的已授权操作员
    /// @param _owner 持有这些 NFT 的地址
    /// @param _operator 代表持有者行事的地址
    /// @return 若 `_operator` 是 `_owner` 的已授权操作员则返回 true，否则返回 false
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @dev 注意：本接口的 ERC-165 标识符为 0x150b7a02。
interface IERC721TokenReceiver {
    /// @notice 处理 NFT 的接收
    /// @dev ERC721 智能合约在完成一次 `transfer` 之后
    /// 会在接收方上调用此函数。此函数可以抛出异常，以回滚并拒绝
    /// 该转账。返回魔术值（magic value）以外的任何值都必须导致
    /// 交易被回滚。
    /// 注意：合约地址始终是消息发送者（message sender）。
    /// @param _operator 调用 `safeTransferFrom` 函数的地址
    /// @param _from 之前持有该代币的地址
    /// @param _tokenId 正在被转移的 NFT 的标识符
    /// @param _data 无指定格式的附加数据
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  （除非抛出异常）
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns (bytes4);
}

/// @title ERC-721 非同质化代币标准，可选的元数据扩展
/// @dev 参见 https://eips.ethereum.org/EIPS/eip-721
/// 注意：本接口的 ERC-165 标识符为 0x5b5e139f。
interface IERC721Metadata is IERC721 {
    /// @notice 本合约中 NFT 集合的描述性名称
    function name() external view returns (string memory _name);

    /// @notice 本合约中 NFT 的简称
    function symbol() external view returns (string memory _symbol);

    /// @notice 给定资产的唯一统一资源标识符（URI）。
    /// @dev 如果 `_tokenId` 不是有效的 NFT，则抛出异常。URI 定义于 RFC
    /// 3986。该 URI 可以指向一个符合 "ERC721
    /// Metadata JSON Schema"（ERC721 元数据 JSON 模式）的 JSON 文件。
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

/// @title ERC-721 非同质化代币标准，可选的枚举扩展
/// @dev 参见 https://eips.ethereum.org/EIPS/eip-721
/// 注意：本接口的 ERC-165 标识符为 0x780e9d63。
interface IERC721Enumerable is IERC721 {
    /// @notice 统计本合约所跟踪的 NFT 数量
    /// @return 本合约所跟踪的有效 NFT 数量，其中每一个
    /// 都有一个已分配、可查询且不等于零地址的持有者
    function totalSupply() external view returns (uint256);

    /// @notice 枚举有效的 NFT
    /// @dev 如果 `_index` >= `totalSupply()`，则抛出异常。
    /// @param _index 小于 `totalSupply()` 的计数器
    /// @return 第 `_index` 个 NFT 的代币标识符
    /// （排序顺序未指定）
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice 枚举分配给某个持有者的 NFT
    /// @dev 如果 `_index` >= `balanceOf(_owner)`，或者
    /// `_owner` 是零地址（代表无效 NFT），则抛出异常。
    /// @param _owner 我们想要查询其所持 NFT 的地址
    /// @param _index 小于 `balanceOf(_owner)` 的计数器
    /// @return 分配给 `_owner` 的第 `_index` 个 NFT 的代币标识符
    /// （排序顺序未指定）
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}
