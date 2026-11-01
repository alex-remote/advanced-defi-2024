// 由 scripts/vm.py 自动生成（@generated）。请勿手动修改。

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.2 <0.9.0;
pragma experimental ABIEncoderV2;

/// `VmSafe` 接口不允许操纵 EVM 状态，也不允许执行其他可能导致
/// Script 模拟结果与链上执行结果不一致的操作。建议只在脚本中
/// 使用这些作弊码（cheatcode）。
interface VmSafe {
    /// 作用于 `msg.sender` 或 `tx.origin` 的修改。由 `readCallers` 返回。
    enum CallerMode {
        // 当前没有生效的调用者修改。
        None,
        // 当前有一个由 `vm.broadcast()` 调用触发的一次性广播（broadcast）正在生效。
        Broadcast,
        // 当前有一个由 `vm.startBroadcast()` 调用触发的持续性广播正在生效。
        RecurrentBroadcast,
        // 当前有一个由 `vm.prank()` 调用触发的一次性 prank（模拟调用者）正在生效。
        Prank,
        // 当前有一个由 `vm.startPrank()` 调用触发的持续性 prank 正在生效。
        RecurrentPrank
    }

    /// 所发生的账户访问的类型。
    enum AccountAccessKind {
        // 该账户被调用（call）。
        Call,
        // 该账户通过 delegatecall 被调用。
        DelegateCall,
        // 该账户通过 callcode 被调用。
        CallCode,
        // 该账户通过 staticcall 被调用。
        StaticCall,
        // 该账户被创建。
        Create,
        // 该账户被自毁（selfdestruct）。
        SelfDestruct,
        // 合成的访问记录，表示当前上下文在之前的某个子上下文（AccountAccess）结束后已恢复执行。
        Resume,
        // 读取了该账户的余额。
        Balance,
        // 读取了该账户的代码大小（codesize）。
        Extcodesize,
        // 读取了该账户的代码哈希（codehash）。
        Extcodehash,
        // 复制了该账户的代码。
        Extcodecopy
    }

    /// 一条以太坊日志。由 `getRecordedLogs` 返回。
    struct Log {
        // 日志的 topics，如有则包含事件签名。
        bytes32[] topics;
        // 日志的原始数据。
        bytes data;
        // 发出该日志的地址。
        address emitter;
    }

    /// 一个 RPC URL 及其别名。由 `rpcUrlStructs` 返回。
    struct Rpc {
        // RPC URL 的别名。
        string key;
        // RPC URL 本身。
        string url;
    }

    /// 一个 RPC 日志对象。由 `eth_getLogs` 返回。
    struct EthGetLogs {
        // 发出该日志的地址。
        address emitter;
        // 日志的 topics，如有则包含事件签名。
        bytes32[] topics;
        // 日志的原始数据。
        bytes data;
        // 区块哈希。
        bytes32 blockHash;
        // 区块号。
        uint64 blockNumber;
        // 交易哈希。
        bytes32 transactionHash;
        // 交易在区块中的索引。
        uint64 transactionIndex;
        // 日志索引。
        uint256 logIndex;
        // 该日志是否已被移除。
        bool removed;
    }

    /// 目录列表中的单个条目。由 `readDir` 返回。
    struct DirEntry {
        // 错误信息（如有）。
        string errorMessage;
        // 条目的路径。
        string path;
        // 条目的深度。
        uint64 depth;
        // 条目是否为目录。
        bool isDir;
        // 条目是否为符号链接。
        bool isSymlink;
    }

    /// 文件的元数据信息。
    /// 该结构体由 `fsMetadata` 函数返回，表示文件已知的
    /// 元数据，例如权限、大小、修改
    /// 时间等。
    struct FsMetadata {
        // 若此元数据对应的是目录，则为 true。
        bool isDir;
        // 若此元数据对应的是符号链接，则为 true。
        bool isSymlink;
        // 此元数据所对应文件的大小（字节）。
        uint256 length;
        // 若此元数据对应的是只读（不可写）文件，则为 true。
        bool readOnly;
        // 此元数据中列出的最后修改时间。
        uint256 modified;
        // 此元数据的最后访问时间。
        uint256 accessed;
        // 此元数据中列出的创建时间。
        uint256 created;
    }

    /// 一个包含公钥和私钥的钱包。
    struct Wallet {
        // 钱包的地址。
        address addr;
        // 钱包公钥的 `X` 坐标。
        uint256 publicKeyX;
        // 钱包公钥的 `Y` 坐标。
        uint256 publicKeyY;
        // 钱包的私钥。
        uint256 privateKey;
    }

    /// `tryFfi` 调用的结果。
    struct FfiResult {
        // 调用的退出码。
        int32 exitCode;
        // 可选地经过十六进制解码的 `stdout` 数据。
        bytes stdout;
        // `stderr` 数据。
        bytes stderr;
    }

    /// 链与分叉（fork）的信息。
    struct ChainInfo {
        // 分叉标识符。若当前没有激活的分叉则为零。
        uint256 forkId;
        // 当前分叉的链 ID。
        uint256 chainId;
    }

    /// `stopAndReturnStateDiff` 调用的结果。
    struct AccountAccess {
        // 发生该访问的链与分叉。
        ChainInfo chainInfo;
        // 账户访问的类型，它决定了 account 字段代表什么。
        // 若 kind 为 Call、DelegateCall、StaticCall 或 CallCode，则 account 为被调用者。
        // 若 kind 为 Create，则 account 为新创建的账户。
        // 若 kind 为 SelfDestruct，则 account 为自毁（selfdestruct）资金的接收者。
        // 若 kind 为 Resume，则 account 表示已恢复执行的账户上下文。
        AccountAccessKind kind;
        // 被访问的账户。
        // 对于 CREATE、CALL 或 SELFDESTRUCT，它分别是新创建的账户、被调用者或自毁的接收者。
        address account;
        // 是谁访问了该账户。
        address accessor;
        // 访问之前该账户是已初始化的还是空的。
        // 若账户拥有代码、非零 nonce
        // 或非零余额，则视为已初始化。
        bool initialized;
        // 被访问账户之前的余额。
        uint256 oldBalance;
        // 被访问账户可能的新余额。
        // 也就是说，所有余额变化都会记录在这里，即使发生了回滚（revert）。
        uint256 newBalance;
        // 由 CREATE 部署的账户代码。
        bytes deployedCode;
        // 随本次账户访问一起传递的 value
        uint256 value;
        // 提供给 CREATE 或 CALL 的输入数据
        bytes data;
        // 本次访问是否在当前上下文或父上下文中被回滚（revert）。
        bool reverted;
        // 账户访问操作期间进行的存储访问的有序列表。
        StorageAccess[] storageAccesses;
        // 记录状态差异期间所经过的调用深度
        uint64 depth;
    }

    /// 一次 `AccountAccess` 期间访问的存储。
    struct StorageAccess {
        // 其存储被访问的账户。
        address account;
        // 被访问的存储槽。
        bytes32 slot;
        // 该访问是否为写操作。
        bool isWrite;
        // 该存储槽之前的值。
        bytes32 previousValue;
        // 该存储槽的新值。
        bytes32 newValue;
        // 该访问是否被回滚。
        bool reverted;
    }

    // ======== 环境变量（Environment） ========

    /// 获取环境变量 `name` 并将其解析为 `address`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envAddress(string calldata name) external view returns (address value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `address` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envAddress(string calldata name, string calldata delim) external view returns (address[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `bool`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envBool(string calldata name) external view returns (bool value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `bool` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envBool(string calldata name, string calldata delim) external view returns (bool[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `bytes32`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envBytes32(string calldata name) external view returns (bytes32 value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `bytes32` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envBytes32(string calldata name, string calldata delim) external view returns (bytes32[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `bytes`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envBytes(string calldata name) external view returns (bytes memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `bytes` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envBytes(string calldata name, string calldata delim) external view returns (bytes[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `int256`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envInt(string calldata name) external view returns (int256 value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `int256` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envInt(string calldata name, string calldata delim) external view returns (int256[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `bool`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, bool defaultValue) external view returns (bool value);

    /// 获取环境变量 `name` 并将其解析为 `uint256`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, uint256 defaultValue) external view returns (uint256 value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `address` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, address[] calldata defaultValue)
        external
        view
        returns (address[] memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `bytes32` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, bytes32[] calldata defaultValue)
        external
        view
        returns (bytes32[] memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `string` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, string[] calldata defaultValue)
        external
        view
        returns (string[] memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `bytes` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, bytes[] calldata defaultValue)
        external
        view
        returns (bytes[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `int256`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, int256 defaultValue) external view returns (int256 value);

    /// 获取环境变量 `name` 并将其解析为 `address`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, address defaultValue) external view returns (address value);

    /// 获取环境变量 `name` 并将其解析为 `bytes32`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, bytes32 defaultValue) external view returns (bytes32 value);

    /// 获取环境变量 `name` 并将其解析为 `string`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata defaultValue) external view returns (string memory value);

    /// 获取环境变量 `name` 并将其解析为 `bytes`。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, bytes calldata defaultValue) external view returns (bytes memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `bool` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, bool[] calldata defaultValue)
        external
        view
        returns (bool[] memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `uint256` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, uint256[] calldata defaultValue)
        external
        view
        returns (uint256[] memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `int256` 数组。
    /// 若该变量无法解析，则回滚（revert）。
    /// 若该变量不存在，则返回 `defaultValue`。
    function envOr(string calldata name, string calldata delim, int256[] calldata defaultValue)
        external
        view
        returns (int256[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `string`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envString(string calldata name) external view returns (string memory value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `string` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envString(string calldata name, string calldata delim) external view returns (string[] memory value);

    /// 获取环境变量 `name` 并将其解析为 `uint256`。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envUint(string calldata name) external view returns (uint256 value);

    /// 获取环境变量 `name` 并将其解析为以 `delim` 分隔的 `uint256` 数组。
    /// 若该变量不存在或无法解析，则回滚（revert）。
    function envUint(string calldata name, string calldata delim) external view returns (uint256[] memory value);

    /// 设置环境变量。
    function setEnv(string calldata name, string calldata value) external;

    // ======== EVM 相关 ========

    /// 获取给定地址在一次 `vm.record` 会话中所有被读取和写入的存储槽。
    function accesses(address target) external returns (bytes32[] memory readSlots, bytes32[] memory writeSlots);

    /// 获取给定私钥对应的地址。
    function addr(uint256 privateKey) external pure returns (address keyAddr);

    /// 按指定的过滤条件获取所有日志。
    function eth_getLogs(uint256 fromBlock, uint256 toBlock, address target, bytes32[] calldata topics)
        external
        returns (EthGetLogs[] memory logs);

    /// 获取当前的 `block.number`。
    /// 如果你使用了 `vm.roll`，应使用此函数代替 `block.number`，因为 `block.number` 在一笔交易内被假定为常量，
    /// 因此会被编译器优化掉。
    /// 参见 https://github.com/foundry-rs/foundry/issues/6180
    function getBlockNumber() external view returns (uint256 height);

    /// 获取当前的 `block.timestamp`。
    /// 如果你使用了 `vm.warp`，应使用此函数代替 `block.timestamp`，因为 `block.timestamp` 在一笔交易内被假定为常量，
    /// 因此会被编译器优化掉。
    /// 参见 https://github.com/foundry-rs/foundry/issues/6180
    function getBlockTimestamp() external view returns (uint256 timestamp);

    /// 对给定地址，获取位于给定存储槽的 mapping 元素所对应的键（key）及其父槽（parent）。
    function getMappingKeyAndParentOf(address target, bytes32 elementSlot)
        external
        returns (bool found, bytes32 key, bytes32 parent);

    /// 对给定地址，获取位于给定存储槽的 mapping 中的元素数量。
    function getMappingLength(address target, bytes32 mappingSlot) external returns (uint256 length);

    /// 对给定地址，获取位于给定存储槽的 mapping 中索引为 idx 的元素。该
    /// 索引必须小于该 mapping 的长度（即 mapping 中键的数量）。
    function getMappingSlotAt(address target, bytes32 mappingSlot, uint256 idx) external returns (bytes32 value);

    /// 获取账户的 nonce。
    function getNonce(address account) external view returns (uint64 nonce);

    /// 获取所有已记录的日志。
    function getRecordedLogs() external returns (Log[] memory logs);

    /// 从某个地址加载一个存储槽。
    function load(address target, bytes32 slot) external view returns (bytes32 data);

    /// 暂停 gas 计量（即不统计 gas 消耗）。若已暂停则不做任何操作。
    function pauseGasMetering() external;

    /// 记录所有的存储读写。
    function record() external;

    /// 记录所有的交易日志。
    function recordLogs() external;

    /// 恢复 gas 计量（即重新统计 gas 消耗）。若已开启则不做任何操作。
    function resumeGasMetering() external;

    /// 向当前 fork 的 URL 发起一次以太坊 JSON-RPC 请求。
    function rpc(string calldata method, string calldata params) external returns (bytes memory data);

    /// 使用 secp256r1 曲线以 `privateKey` 对 `digest` 签名。
    function signP256(uint256 privateKey, bytes32 digest) external pure returns (bytes32 r, bytes32 s);

    /// 使用 secp256k1 曲线以 `privateKey` 对 `digest` 签名。
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// 开始记录所有 mapping 的 SSTORE，以便之后检索。
    function startMappingRecording() external;

    /// 按顺序记录 CREATE、CALL 或 SELFDESTRUCT 操作码中发生的所有账户访问，
    /// 以及这些调用的上下文
    function startStateDiffRecording() external;

    /// 返回 `vm.startStateDiffRecording` 会话中所有账户访问的有序数组。
    function stopAndReturnStateDiff() external returns (AccountAccess[] memory accountAccesses);

    /// 停止记录 mapping 的 SSTORE（这些记录用于之后检索），并清除已记录的数据。
    function stopMappingRecording() external;

    // ======== 文件系统 ========

    /// 关闭用于读取的文件，重置偏移量，以便之后可以用 readLine 从头开始读取。
    /// `path` 是相对于项目根目录的路径。
    function closeFile(string calldata path) external;

    /// 将一个文件的内容复制到另一个文件。该函数会**覆盖** `to` 的内容。
    /// 成功时返回复制的总字节数，它等于 `metadata` 所报告的 `to` 文件长度。
    /// `from` 和 `to` 都是相对于项目根目录的路径。
    function copyFile(string calldata from, string calldata to) external returns (uint64 copied);

    /// 在给定路径创建一个新的空目录。
    /// 该作弊码（cheatcode）在以下情况下会回滚（revert），但不限于这些情况：
    /// - 用户没有修改 `path` 的权限。
    /// - 给定路径的某个父目录不存在，且 `recursive` 为 false。
    /// - `path` 已存在，且 `recursive` 为 false。
    /// `path` 是相对于项目根目录的路径。
    function createDir(string calldata path, bool recursive) external;

    /// 如果给定路径指向一个已存在的实体则返回 true，否则返回 false。
    function exists(string calldata path) external returns (bool result);

    /// 通过终端执行外部函数调用（FFI）。
    function ffi(string[] calldata commandInput) external returns (bytes memory result);

    /// 给定路径，查询文件系统以获取文件、目录等的信息。
    function fsMetadata(string calldata path) external view returns (FsMetadata memory metadata);

    /// 从构建产物（artifact）文件中获取创建字节码（creation bytecode）。参数为 json 文件的相对路径。
    function getCode(string calldata artifactPath) external view returns (bytes memory creationBytecode);

    /// 从构建产物（artifact）文件中获取已部署字节码（deployed bytecode）。参数为 json 文件的相对路径。
    function getDeployedCode(string calldata artifactPath) external view returns (bytes memory runtimeBytecode);

    /// 如果路径在磁盘上存在且指向一个目录则返回 true，否则返回 false。
    function isDir(string calldata path) external returns (bool result);

    /// 如果路径在磁盘上存在且指向一个普通文件则返回 true，否则返回 false。
    function isFile(string calldata path) external returns (bool result);

    /// 获取当前项目根目录的路径。
    function projectRoot() external view returns (string memory path);

    /// 递归读取给定路径下的目录，最大深度为 `maxDepth`。
    /// `maxDepth` 默认为 1，即只返回给定目录的直接子项。
    /// 如果 `followLinks` 为 true，则跟随符号链接。
    function readDir(string calldata path) external view returns (DirEntry[] memory entries);

    /// 参见 `readDir(string)`。
    function readDir(string calldata path, uint64 maxDepth) external view returns (DirEntry[] memory entries);

    /// 参见 `readDir(string)`。
    function readDir(string calldata path, uint64 maxDepth, bool followLinks)
        external
        view
        returns (DirEntry[] memory entries);

    /// 将文件的全部内容读取为字符串。`path` 是相对于项目根目录的路径。
    function readFile(string calldata path) external view returns (string memory data);

    /// 以二进制形式读取文件的全部内容。`path` 是相对于项目根目录的路径。
    function readFileBinary(string calldata path) external view returns (bytes memory data);

    /// 将文件的下一行读取为字符串。
    function readLine(string calldata path) external view returns (string memory line);

    /// 读取符号链接，返回该链接指向的路径。
    /// 该作弊码在以下情况下会回滚（revert），但不限于这些情况：
    /// - `path` 不是符号链接。
    /// - `path` 不存在。
    function readLink(string calldata linkPath) external view returns (string memory targetPath);

    /// 删除给定路径处的目录。
    /// 该作弊码在以下情况下会回滚（revert），但不限于这些情况：
    /// - `path` 不存在。
    /// - `path` 不是目录。
    /// - 用户没有修改 `path` 的权限。
    /// - 目录非空，且 `recursive` 为 false。
    /// `path` 是相对于项目根目录的路径。
    function removeDir(string calldata path, bool recursive) external;

    /// 从文件系统中删除一个文件。
    /// 该作弊码在以下情况下会回滚（revert），但不限于这些情况：
    /// - `path` 指向一个目录。
    /// - 文件不存在。
    /// - 用户没有删除该文件的权限。
    /// `path` 是相对于项目根目录的路径。
    function removeFile(string calldata path) external;

    /// 通过终端执行外部函数调用（FFI），并返回退出码、stdout 和 stderr。
    function tryFfi(string[] calldata commandInput) external returns (FfiResult memory result);

    /// 返回自 unix 纪元（epoch）以来的时间，单位为毫秒。
    function unixTime() external returns (uint256 milliseconds);

    /// 将数据写入文件：文件不存在则创建，已存在则完全替换其内容。
    /// `path` 是相对于项目根目录的路径。
    function writeFile(string calldata path, string calldata data) external;

    /// 将二进制数据写入文件：文件不存在则创建，已存在则完全替换其内容。
    /// `path` 是相对于项目根目录的路径。
    function writeFileBinary(string calldata path, bytes calldata data) external;

    /// 向文件写入一行，文件不存在则创建。
    /// `path` 是相对于项目根目录的路径。
    function writeLine(string calldata path, string calldata data) external;

    // ======== JSON 处理 ========

    /// 检查 JSON 对象中是否存在 `key`
    /// `keyExists` 即将被弃用，请改用 `keyExistsJson`。它将在未来版本中被移除。
    function keyExists(string calldata json, string calldata key) external view returns (bool);

    /// 检查 JSON 对象中是否存在 `key`。
    function keyExistsJson(string calldata json, string calldata key) external view returns (bool);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `address`。
    function parseJsonAddress(string calldata json, string calldata key) external pure returns (address);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `address[]`。
    function parseJsonAddressArray(string calldata json, string calldata key)
        external
        pure
        returns (address[] memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `bool`。
    function parseJsonBool(string calldata json, string calldata key) external pure returns (bool);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `bool[]`。
    function parseJsonBoolArray(string calldata json, string calldata key) external pure returns (bool[] memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `bytes`。
    function parseJsonBytes(string calldata json, string calldata key) external pure returns (bytes memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `bytes32`。
    function parseJsonBytes32(string calldata json, string calldata key) external pure returns (bytes32);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `bytes32[]`。
    function parseJsonBytes32Array(string calldata json, string calldata key)
        external
        pure
        returns (bytes32[] memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `bytes[]`。
    function parseJsonBytesArray(string calldata json, string calldata key) external pure returns (bytes[] memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `int256`。
    function parseJsonInt(string calldata json, string calldata key) external pure returns (int256);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `int256[]`。
    function parseJsonIntArray(string calldata json, string calldata key) external pure returns (int256[] memory);

    /// 返回 JSON 对象中所有键组成的数组。
    function parseJsonKeys(string calldata json, string calldata key) external pure returns (string[] memory keys);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `string`。
    function parseJsonString(string calldata json, string calldata key) external pure returns (string memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `string[]`。
    function parseJsonStringArray(string calldata json, string calldata key) external pure returns (string[] memory);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `uint256`。
    function parseJsonUint(string calldata json, string calldata key) external pure returns (uint256);

    /// 解析 JSON 数据字符串中 `key` 处的值，并将其强制转换为 `uint256[]`。
    function parseJsonUintArray(string calldata json, string calldata key) external pure returns (uint256[] memory);

    /// 对 JSON 对象进行 ABI 编码。
    function parseJson(string calldata json) external pure returns (bytes memory abiEncodedData);

    /// 对 `key` 处的 JSON 对象进行 ABI 编码。
    function parseJson(string calldata json, string calldata key) external pure returns (bytes memory abiEncodedData);

    /// 参见 `serializeJson`。
    function serializeAddress(string calldata objectKey, string calldata valueKey, address value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeAddress(string calldata objectKey, string calldata valueKey, address[] calldata values)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeBool(string calldata objectKey, string calldata valueKey, bool value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeBool(string calldata objectKey, string calldata valueKey, bool[] calldata values)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32 value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeBytes32(string calldata objectKey, string calldata valueKey, bytes32[] calldata values)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes calldata value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeBytes(string calldata objectKey, string calldata valueKey, bytes[] calldata values)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeInt(string calldata objectKey, string calldata valueKey, int256 value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeInt(string calldata objectKey, string calldata valueKey, int256[] calldata values)
        external
        returns (string memory json);

    /// 将一个键值对序列化到存储在内存中的 JSON 对象里，之后可将该对象写入文件。
    /// 返回截至此刻该 JSON 文件的字符串化版本。
    function serializeJson(string calldata objectKey, string calldata value) external returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeString(string calldata objectKey, string calldata valueKey, string calldata value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeString(string calldata objectKey, string calldata valueKey, string[] calldata values)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeUint(string calldata objectKey, string calldata valueKey, uint256 value)
        external
        returns (string memory json);

    /// 参见 `serializeJson`。
    function serializeUint(string calldata objectKey, string calldata valueKey, uint256[] calldata values)
        external
        returns (string memory json);

    /// 将序列化后的 JSON 对象写入文件。如果文件已存在，将被覆盖。
    function writeJson(string calldata json, string calldata path) external;

    /// 将序列化后的 JSON 对象写入一个**已存在的** JSON 文件，替换键为 <value_key.> 的值
    /// 这适用于替换 JSON 文件中的某个特定值，而无需解析整个文件。
    function writeJson(string calldata json, string calldata path, string calldata valueKey) external;

    // ======== 脚本 ========

    /// 使用调用测试合约的地址，让下一次调用（仅限当前调用深度）
    /// 创建一笔之后可被签名并发送上链的交易。
    function broadcast() external;

    /// 让下一次调用（仅限当前调用深度）以给定的地址
    /// 作为发送者，创建一笔之后可被签名并发送上链的交易。
    function broadcast(address signer) external;

    /// 让下一次调用（仅限当前调用深度）以给定私钥（对应的地址）
    /// 作为发送者，创建一笔之后可被签名并发送上链的交易。
    function broadcast(uint256 privateKey) external;

    /// 使用调用测试合约的地址，让之后的所有调用
    /// （仅限当前调用深度）创建之后可被签名并发送上链的交易。
    function startBroadcast() external;

    /// 让之后的所有调用（仅限当前调用深度）以给定的地址
    /// 创建之后可被签名并发送上链的交易。
    function startBroadcast(address signer) external;

    /// 让之后的所有调用（仅限当前调用深度）以给定私钥（对应的地址）
    /// 创建之后可被签名并发送上链的交易。
    function startBroadcast(uint256 privateKey) external;

    /// 停止收集链上交易。
    function stopBroadcast() external;

    // ======== 字符串 ========

    /// 将给定的 `string` 解析为 `address`。
    function parseAddress(string calldata stringifiedValue) external pure returns (address parsedValue);

    /// 将给定的 `string` 解析为 `bool`。
    function parseBool(string calldata stringifiedValue) external pure returns (bool parsedValue);

    /// 将给定的 `string` 解析为 `bytes`。
    function parseBytes(string calldata stringifiedValue) external pure returns (bytes memory parsedValue);

    /// 将给定的 `string` 解析为 `bytes32`。
    function parseBytes32(string calldata stringifiedValue) external pure returns (bytes32 parsedValue);

    /// 将给定的 `string` 解析为 `int256`。
    function parseInt(string calldata stringifiedValue) external pure returns (int256 parsedValue);

    /// 将给定的 `string` 解析为 `uint256`。
    function parseUint(string calldata stringifiedValue) external pure returns (uint256 parsedValue);

    /// 将给定 `string` 中出现的所有 `from` 替换为 `to`。
    function replace(string calldata input, string calldata from, string calldata to)
        external
        pure
        returns (string memory output);

    /// 按 `delimiter` 将给定的 `string` 分割为字符串数组。
    function split(string calldata input, string calldata delimiter) external pure returns (string[] memory outputs);

    /// 将给定的 `string` 值转换为小写。
    function toLowercase(string calldata input) external pure returns (string memory output);

    /// 将给定的值转换为 `string`。
    function toString(address value) external pure returns (string memory stringifiedValue);

    /// 将给定的值转换为 `string`。
    function toString(bytes calldata value) external pure returns (string memory stringifiedValue);

    /// 将给定的值转换为 `string`。
    function toString(bytes32 value) external pure returns (string memory stringifiedValue);

    /// 将给定的值转换为 `string`。
    function toString(bool value) external pure returns (string memory stringifiedValue);

    /// 将给定的值转换为 `string`。
    function toString(uint256 value) external pure returns (string memory stringifiedValue);

    /// 将给定的值转换为 `string`。
    function toString(int256 value) external pure returns (string memory stringifiedValue);

    /// 将给定的 `string` 值转换为大写。
    function toUppercase(string calldata input) external pure returns (string memory output);

    /// 去除给定 `string` 值首尾的空白字符。
    function trim(string calldata input) external pure returns (string memory output);

    // ======== 测试 ========

    /// 比较两个 `uint256` 值。期望二者之差小于或等于 `maxDelta`。
    /// 在失败信息中按 decimals 格式化数值。
    function assertApproxEqAbsDecimal(uint256 left, uint256 right, uint256 maxDelta, uint256 decimals) external pure;

    /// 比较两个 `uint256` 值。期望二者之差小于或等于 `maxDelta`。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqAbsDecimal(
        uint256 left,
        uint256 right,
        uint256 maxDelta,
        uint256 decimals,
        string calldata error
    ) external pure;

    /// 比较两个 `int256` 值。期望二者之差小于或等于 `maxDelta`。
    /// 在失败信息中按 decimals 格式化数值。
    function assertApproxEqAbsDecimal(int256 left, int256 right, uint256 maxDelta, uint256 decimals) external pure;

    /// 比较两个 `int256` 值。期望二者之差小于或等于 `maxDelta`。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqAbsDecimal(
        int256 left,
        int256 right,
        uint256 maxDelta,
        uint256 decimals,
        string calldata error
    ) external pure;

    /// 比较两个 `uint256` 值。期望二者之差小于或等于 `maxDelta`。
    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta) external pure;

    /// 比较两个 `uint256` 值。期望二者之差小于或等于 `maxDelta`。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqAbs(uint256 left, uint256 right, uint256 maxDelta, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望二者之差小于或等于 `maxDelta`。
    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta) external pure;

    /// 比较两个 `int256` 值。期望二者之差小于或等于 `maxDelta`。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqAbs(int256 left, int256 right, uint256 maxDelta, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    /// 在失败信息中按 decimals 格式化数值。
    function assertApproxEqRelDecimal(uint256 left, uint256 right, uint256 maxPercentDelta, uint256 decimals)
        external
        pure;

    /// 比较两个 `uint256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqRelDecimal(
        uint256 left,
        uint256 right,
        uint256 maxPercentDelta,
        uint256 decimals,
        string calldata error
    ) external pure;

    /// 比较两个 `int256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    /// 在失败信息中按 decimals 格式化数值。
    function assertApproxEqRelDecimal(int256 left, int256 right, uint256 maxPercentDelta, uint256 decimals)
        external
        pure;

    /// 比较两个 `int256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqRelDecimal(
        int256 left,
        int256 right,
        uint256 maxPercentDelta,
        uint256 decimals,
        string calldata error
    ) external pure;

    /// 比较两个 `uint256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    function assertApproxEqRel(uint256 left, uint256 right, uint256 maxPercentDelta) external pure;

    /// 比较两个 `uint256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqRel(uint256 left, uint256 right, uint256 maxPercentDelta, string calldata error)
        external
        pure;

    /// 比较两个 `int256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta) external pure;

    /// 比较两个 `int256` 值。期望二者的相对差（百分比）小于或等于 `maxPercentDelta`。
    /// `maxPercentDelta` 是一个 18 位小数的定点数，其中 1e18 == 100%
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertApproxEqRel(int256 left, int256 right, uint256 maxPercentDelta, string calldata error)
        external
        pure;

    /// 断言两个 `uint256` 值相等，并在失败信息中按 decimals 格式化它们。
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// 断言两个 `uint256` 值相等，并在失败信息中按 decimals 格式化它们。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertEqDecimal(uint256 left, uint256 right, uint256 decimals, string calldata error) external pure;

    /// 断言两个 `int256` 值相等，并在失败信息中按 decimals 格式化它们。
    function assertEqDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// 断言两个 `int256` 值相等，并在失败信息中按 decimals 格式化它们。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertEqDecimal(int256 left, int256 right, uint256 decimals, string calldata error) external pure;

    /// 断言两个 `bool` 值相等。
    function assertEq(bool left, bool right) external pure;

    /// 断言两个 `bool` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(bool left, bool right, string calldata error) external pure;

    /// 断言两个 `string` 值相等。
    function assertEq(string calldata left, string calldata right) external pure;

    /// 断言两个 `string` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(string calldata left, string calldata right, string calldata error) external pure;

    /// 断言两个 `bytes` 值相等。
    function assertEq(bytes calldata left, bytes calldata right) external pure;

    /// 断言两个 `bytes` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(bytes calldata left, bytes calldata right, string calldata error) external pure;

    /// 断言两个 `bool` 数组相等。
    function assertEq(bool[] calldata left, bool[] calldata right) external pure;

    /// 断言两个 `bool` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(bool[] calldata left, bool[] calldata right, string calldata error) external pure;

    /// 断言两个 `uint256 数组相等。
    function assertEq(uint256[] calldata left, uint256[] calldata right) external pure;

    /// 断言两个 `uint256` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(uint256[] calldata left, uint256[] calldata right, string calldata error) external pure;

    /// 断言两个 `int256` 数组相等。
    function assertEq(int256[] calldata left, int256[] calldata right) external pure;

    /// 断言两个 `int256` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(int256[] calldata left, int256[] calldata right, string calldata error) external pure;

    /// 断言两个 `uint256` 值相等。
    function assertEq(uint256 left, uint256 right) external pure;

    /// 断言两个 `address` 数组相等。
    function assertEq(address[] calldata left, address[] calldata right) external pure;

    /// 断言两个 `address` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(address[] calldata left, address[] calldata right, string calldata error) external pure;

    /// 断言两个 `bytes32` 数组相等。
    function assertEq(bytes32[] calldata left, bytes32[] calldata right) external pure;

    /// 断言两个 `bytes32` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(bytes32[] calldata left, bytes32[] calldata right, string calldata error) external pure;

    /// 断言两个 `string` 数组相等。
    function assertEq(string[] calldata left, string[] calldata right) external pure;

    /// 断言两个 `string` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(string[] calldata left, string[] calldata right, string calldata error) external pure;

    /// 断言两个 `bytes` 数组相等。
    function assertEq(bytes[] calldata left, bytes[] calldata right) external pure;

    /// 断言两个 `bytes` 数组相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(bytes[] calldata left, bytes[] calldata right, string calldata error) external pure;

    /// 断言两个 `uint256` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(uint256 left, uint256 right, string calldata error) external pure;

    /// 断言两个 `int256` 值相等。
    function assertEq(int256 left, int256 right) external pure;

    /// 断言两个 `int256` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(int256 left, int256 right, string calldata error) external pure;

    /// 断言两个 `address` 值相等。
    function assertEq(address left, address right) external pure;

    /// 断言两个 `address` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(address left, address right, string calldata error) external pure;

    /// 断言两个 `bytes32` 值相等。
    function assertEq(bytes32 left, bytes32 right) external pure;

    /// 断言两个 `bytes32` 值相等，失败时将错误信息包含在 revert 字符串中。
    function assertEq(bytes32 left, bytes32 right, string calldata error) external pure;

    /// 断言给定条件为 false。
    function assertFalse(bool condition) external pure;

    /// 断言给定条件为 false，失败时将错误信息包含在 revert 字符串中。
    function assertFalse(bool condition, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertGeDecimal(uint256 left, uint256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertGeDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertGeDecimal(int256 left, int256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于或等于第二个值。
    function assertGe(uint256 left, uint256 right) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于或等于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertGe(uint256 left, uint256 right, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于或等于第二个值。
    function assertGe(int256 left, int256 right) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于或等于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertGe(int256 left, int256 right, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertGtDecimal(uint256 left, uint256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertGtDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertGtDecimal(int256 left, int256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于第二个值。
    function assertGt(uint256 left, uint256 right) external pure;

    /// 比较两个 `uint256` 值。期望第一个值大于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertGt(uint256 left, uint256 right, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于第二个值。
    function assertGt(int256 left, int256 right) external pure;

    /// 比较两个 `int256` 值。期望第一个值大于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertGt(int256 left, int256 right, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertLeDecimal(uint256 left, uint256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertLeDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于或等于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertLeDecimal(int256 left, int256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于或等于第二个值。
    function assertLe(uint256 left, uint256 right) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于或等于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertLe(uint256 left, uint256 right, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于或等于第二个值。
    function assertLe(int256 left, int256 right) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于或等于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertLe(int256 left, int256 right, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertLtDecimal(uint256 left, uint256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于第二个值。
    /// 在失败信息中按 decimals 格式化数值。
    function assertLtDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于第二个值。
    /// 在失败信息中按 decimals 格式化数值。失败时将错误信息包含在 revert 字符串中。
    function assertLtDecimal(int256 left, int256 right, uint256 decimals, string calldata error) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于第二个值。
    function assertLt(uint256 left, uint256 right) external pure;

    /// 比较两个 `uint256` 值。期望第一个值小于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertLt(uint256 left, uint256 right, string calldata error) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于第二个值。
    function assertLt(int256 left, int256 right) external pure;

    /// 比较两个 `int256` 值。期望第一个值小于第二个值。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertLt(int256 left, int256 right, string calldata error) external pure;

    /// 断言两个 `uint256` 值不相等，并在失败信息中按 decimals 格式化它们。
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals) external pure;

    /// 断言两个 `uint256` 值不相等，并在失败信息中按 decimals 格式化它们。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertNotEqDecimal(uint256 left, uint256 right, uint256 decimals, string calldata error) external pure;

    /// 断言两个 `int256` 值不相等，并在失败信息中按 decimals 格式化它们。
    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals) external pure;

    /// 断言两个 `int256` 值不相等，并在失败信息中按 decimals 格式化它们。
    /// 失败时将错误信息包含在 revert 字符串中。
    function assertNotEqDecimal(int256 left, int256 right, uint256 decimals, string calldata error) external pure;

    /// 断言两个 `bool` 值不相等。
    function assertNotEq(bool left, bool right) external pure;

    /// 断言两个 `bool` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(bool left, bool right, string calldata error) external pure;

    /// 断言两个 `string` 值不相等。
    function assertNotEq(string calldata left, string calldata right) external pure;

    /// 断言两个 `string` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(string calldata left, string calldata right, string calldata error) external pure;

    /// 断言两个 `bytes` 值不相等。
    function assertNotEq(bytes calldata left, bytes calldata right) external pure;

    /// 断言两个 `bytes` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(bytes calldata left, bytes calldata right, string calldata error) external pure;

    /// 断言两个 `bool` 数组不相等。
    function assertNotEq(bool[] calldata left, bool[] calldata right) external pure;

    /// 断言两个 `bool` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(bool[] calldata left, bool[] calldata right, string calldata error) external pure;

    /// 断言两个 `uint256` 数组不相等。
    function assertNotEq(uint256[] calldata left, uint256[] calldata right) external pure;

    /// 断言两个 `uint256` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(uint256[] calldata left, uint256[] calldata right, string calldata error) external pure;

    /// 断言两个 `int256` 数组不相等。
    function assertNotEq(int256[] calldata left, int256[] calldata right) external pure;

    /// 断言两个 `int256` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(int256[] calldata left, int256[] calldata right, string calldata error) external pure;

    /// 断言两个 `uint256` 值不相等。
    function assertNotEq(uint256 left, uint256 right) external pure;

    /// 断言两个 `address` 数组不相等。
    function assertNotEq(address[] calldata left, address[] calldata right) external pure;

    /// 断言两个 `address` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(address[] calldata left, address[] calldata right, string calldata error) external pure;

    /// 断言两个 `bytes32` 数组不相等。
    function assertNotEq(bytes32[] calldata left, bytes32[] calldata right) external pure;

    /// 断言两个 `bytes32` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(bytes32[] calldata left, bytes32[] calldata right, string calldata error) external pure;

    /// 断言两个 `string` 数组不相等。
    function assertNotEq(string[] calldata left, string[] calldata right) external pure;

    /// 断言两个 `string` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(string[] calldata left, string[] calldata right, string calldata error) external pure;

    /// 断言两个 `bytes` 数组不相等。
    function assertNotEq(bytes[] calldata left, bytes[] calldata right) external pure;

    /// 断言两个 `bytes` 数组不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(bytes[] calldata left, bytes[] calldata right, string calldata error) external pure;

    /// 断言两个 `uint256` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(uint256 left, uint256 right, string calldata error) external pure;

    /// 断言两个 `int256` 值不相等。
    function assertNotEq(int256 left, int256 right) external pure;

    /// 断言两个 `int256` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(int256 left, int256 right, string calldata error) external pure;

    /// 断言两个 `address` 值不相等。
    function assertNotEq(address left, address right) external pure;

    /// 断言两个 `address` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(address left, address right, string calldata error) external pure;

    /// 断言两个 `bytes32` 值不相等。
    function assertNotEq(bytes32 left, bytes32 right) external pure;

    /// 断言两个 `bytes32` 值不相等，失败时将错误信息包含在 revert 字符串中。
    function assertNotEq(bytes32 left, bytes32 right, string calldata error) external pure;

    /// 断言给定条件为真。
    function assertTrue(bool condition) external pure;

    /// 断言给定条件为真，失败时将错误信息包含在 revert 字符串中。
    function assertTrue(bool condition, string calldata error) external pure;

    /// 如果条件为假，则丢弃本轮的模糊测试（fuzz）输入并生成新的输入。
    function assume(bool condition) external pure;

    /// 写入一个断点，供在调试器中跳转。
    function breakpoint(string calldata char) external;

    /// 写入一个条件断点，供在调试器中跳转。
    function breakpoint(string calldata char, bool value) external;

    /// 返回给定别名对应的 RPC url。
    function rpcUrl(string calldata rpcAlias) external view returns (string memory json);

    /// 以结构体形式返回所有 rpc url 及其别名。
    function rpcUrlStructs() external view returns (Rpc[] memory urls);

    /// 返回所有 rpc url 及其别名 `[alias, url][]`。
    function rpcUrls() external view returns (string[2][] memory urls);

    /// 将主线程暂停执行 `duration` 毫秒。
    function sleep(uint256 duration) external;

    // ======== TOML 处理 ========

    /// 检查 `key` 是否存在于 TOML 表中。
    function keyExistsToml(string calldata toml, string calldata key) external view returns (bool);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `address`。
    function parseTomlAddress(string calldata toml, string calldata key) external pure returns (address);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `address[]`。
    function parseTomlAddressArray(string calldata toml, string calldata key)
        external
        pure
        returns (address[] memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `bool`。
    function parseTomlBool(string calldata toml, string calldata key) external pure returns (bool);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `bool[]`。
    function parseTomlBoolArray(string calldata toml, string calldata key) external pure returns (bool[] memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `bytes`。
    function parseTomlBytes(string calldata toml, string calldata key) external pure returns (bytes memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `bytes32`。
    function parseTomlBytes32(string calldata toml, string calldata key) external pure returns (bytes32);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `bytes32[]`。
    function parseTomlBytes32Array(string calldata toml, string calldata key)
        external
        pure
        returns (bytes32[] memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `bytes[]`。
    function parseTomlBytesArray(string calldata toml, string calldata key) external pure returns (bytes[] memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `int256`。
    function parseTomlInt(string calldata toml, string calldata key) external pure returns (int256);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `int256[]`。
    function parseTomlIntArray(string calldata toml, string calldata key) external pure returns (int256[] memory);

    /// 返回 TOML 表中所有键组成的数组。
    function parseTomlKeys(string calldata toml, string calldata key) external pure returns (string[] memory keys);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `string`。
    function parseTomlString(string calldata toml, string calldata key) external pure returns (string memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `string[]`。
    function parseTomlStringArray(string calldata toml, string calldata key) external pure returns (string[] memory);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `uint256`。
    function parseTomlUint(string calldata toml, string calldata key) external pure returns (uint256);

    /// 解析 TOML 数据字符串中 `key` 处的值，并将其强制转换为 `uint256[]`。
    function parseTomlUintArray(string calldata toml, string calldata key) external pure returns (uint256[] memory);

    /// 对 TOML 表进行 ABI 编码。
    function parseToml(string calldata toml) external pure returns (bytes memory abiEncodedData);

    /// 对 `key` 处的 TOML 表进行 ABI 编码。
    function parseToml(string calldata toml, string calldata key) external pure returns (bytes memory abiEncodedData);

    /// 接收序列化的 JSON，将其转换为 TOML，并把序列化后的 TOML 写入文件。
    function writeToml(string calldata json, string calldata path) external;

    /// 接收序列化的 JSON，将其转换为 TOML，并把序列化后的 TOML 表写入一个**已存在的** TOML 文件，替换 key = <value_key.> 对应的值
    /// 这适用于替换 TOML 文件中的某个特定值，而无需解析整个文件。
    function writeToml(string calldata json, string calldata path, string calldata valueKey) external;

    // ======== 工具函数 ========

    /// 计算使用给定 CREATE2 部署器通过 CREATE2 创建的合约地址。
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash, address deployer)
        external
        pure
        returns (address);

    /// 计算使用默认 CREATE2 部署器通过 CREATE2 创建的合约地址。
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash) external pure returns (address);

    /// 根据给定的部署者地址和 nonce，计算合约将被部署到的地址。
    function computeCreateAddress(address deployer, uint256 nonce) external pure returns (address);

    /// 根据名称派生私钥，用该名称为账户打标签（label），并返回钱包。
    function createWallet(string calldata walletLabel) external returns (Wallet memory wallet);

    /// 根据私钥生成钱包并返回该钱包。
    function createWallet(uint256 privateKey) external returns (Wallet memory wallet);

    /// 根据私钥生成钱包，用该名称为账户打标签（label），并返回该钱包。
    function createWallet(uint256 privateKey, string calldata walletLabel) external returns (Wallet memory wallet);

    /// 从提供的助记词字符串（或助记词文件路径）派生私钥，
    /// 派生路径为 `m/44'/60'/0'/0/{index}`。
    function deriveKey(string calldata mnemonic, uint32 index) external pure returns (uint256 privateKey);

    /// 从提供的助记词字符串（或助记词文件路径）派生私钥，
    /// 派生路径为 `{derivationPath}{index}`。
    function deriveKey(string calldata mnemonic, string calldata derivationPath, uint32 index)
        external
        pure
        returns (uint256 privateKey);

    /// 以指定语言从提供的助记词字符串（或助记词文件路径）派生私钥，
    /// 派生路径为 `m/44'/60'/0'/0/{index}`。
    function deriveKey(string calldata mnemonic, uint32 index, string calldata language)
        external
        pure
        returns (uint256 privateKey);

    /// 以指定语言从提供的助记词字符串（或助记词文件路径）派生私钥，
    /// 派生路径为 `{derivationPath}{index}`。
    function deriveKey(string calldata mnemonic, string calldata derivationPath, uint32 index, string calldata language)
        external
        pure
        returns (uint256 privateKey);

    /// 获取指定地址的标签（label）。
    function getLabel(address account) external view returns (string memory currentLabel);

    /// 获取 `Wallet` 的 nonce。
    function getNonce(Wallet calldata wallet) external returns (uint64 nonce);

    /// 在调用追踪（call traces）中为地址设置标签。
    function label(address account, string calldata newLabel) external;

    /// 将私钥添加到本地 forge 钱包并返回对应地址。
    function rememberKey(uint256 privateKey) external returns (address keyAddr);

    /// 使用 `Wallet` 对数据签名。
    function sign(Wallet calldata wallet, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);

    /// 将 `bytes` 值编码为 base64url 字符串。
    function toBase64URL(bytes calldata data) external pure returns (string memory);

    /// 将 `string` 值编码为 base64url 字符串。
    function toBase64URL(string calldata data) external pure returns (string memory);

    /// 将 `bytes` 值编码为 base64 字符串。
    function toBase64(bytes calldata data) external pure returns (string memory);

    /// 将 `string` 值编码为 base64 字符串。
    function toBase64(string calldata data) external pure returns (string memory);
}

/// `Vm` 接口允许操作 EVM 状态。这些函数都旨在用于
/// 测试中，不建议在脚本中使用这些作弊功能（cheats）。
interface Vm is VmSafe {
    // ======== EVM 状态操作 ========

    /// 返回当前激活的分叉（fork）的标识符。如果当前没有激活的分叉则回滚（revert）。
    function activeFork() external view returns (uint256 forkId);

    /// 在分叉模式下，显式授予给定地址使用 cheatcode（作弊码）的权限。
    function allowCheatcodes(address account) external;

    /// 设置 `block.chainid`。
    function chainId(uint256 newChainId) external;

    /// 清除所有模拟（mock）的调用。
    function clearMockedCalls() external;

    /// 设置 `block.coinbase`。
    function coinbase(address newCoinbase) external;

    /// 使用给定的端点和_最新_区块创建一个新分叉，并返回该分叉的标识符。
    function createFork(string calldata urlOrAlias) external returns (uint256 forkId);

    /// 使用给定的端点和区块创建一个新分叉，并返回该分叉的标识符。
    function createFork(string calldata urlOrAlias, uint256 blockNumber) external returns (uint256 forkId);

    /// 使用给定的端点、在给定交易被打包所在的区块创建一个新分叉，
    /// 重放该区块中在此交易之前打包的所有交易，并返回该分叉的标识符。
    function createFork(string calldata urlOrAlias, bytes32 txHash) external returns (uint256 forkId);

    /// 使用给定的端点和最新区块创建并选中一个新分叉，并返回该分叉的标识符。
    function createSelectFork(string calldata urlOrAlias) external returns (uint256 forkId);

    /// 使用给定的端点和区块创建并选中一个新分叉，并返回该分叉的标识符。
    function createSelectFork(string calldata urlOrAlias, uint256 blockNumber) external returns (uint256 forkId);

    /// 使用给定的端点、在给定交易被打包所在的区块创建并选中一个新分叉，
    /// 重放该区块中在此交易之前打包的所有交易，返回该分叉的标识符。
    function createSelectFork(string calldata urlOrAlias, bytes32 txHash) external returns (uint256 forkId);

    /// 设置某个地址的余额。
    function deal(address account, uint256 newBalance) external;

    /// 删除由 `snapshot` 创建的、具有给定 ID 的快照。
    /// 参数为要删除的快照 ID。
    /// 如果快照删除成功，返回 `true`。
    /// 如果快照不存在，返回 `false`。
    function deleteSnapshot(uint256 snapshotId) external returns (bool success);

    /// 删除之前由 `snapshot` 创建的_所有_快照。
    function deleteSnapshots() external;

    /// 设置 `block.difficulty`。
    /// 在 Paris 及之后的 EVM 版本上不可用，请改用 `prevrandao`。
    /// 在不支持的 EVM 版本上使用会回滚（revert）。
    function difficulty(uint256 newDifficulty) external;

    /// 将创世（genesis）JSON 文件的 `allocs` 导出到磁盘。
    function dumpState(string calldata pathToStateJson) external;

    /// 设置某个地址的代码。
    function etch(address target, bytes calldata newRuntimeBytecode) external;

    /// 设置 `block.basefee`。
    function fee(uint256 newBasefee) external;

    /// 如果该账户被标记为持久化（persistent），返回 true。
    function isPersistent(address account) external view returns (bool persistent);

    /// 将创世（genesis）JSON 文件的 `allocs` 加载到内存中的 revm 状态。
    function loadAllocs(string calldata pathToAllocsJson) external;

    /// 标记账户在多分叉（multifork）环境中切换分叉时应使用持久化存储
    /// 也就是说，对该账户状态所做的更改在切换分叉时会被保留。
    function makePersistent(address account) external;

    /// 参见 `makePersistent(address)`。
    function makePersistent(address account0, address account1) external;

    /// 参见 `makePersistent(address)`。
    function makePersistent(address account0, address account1, address account2) external;

    /// 参见 `makePersistent(address)`。
    function makePersistent(address[] calldata accounts) external;

    /// 使对某地址的调用以指定的 revert 数据回滚。
    function mockCallRevert(address callee, bytes calldata data, bytes calldata revertData) external;

    /// 使对某地址、带特定 `msg.value` 的调用以指定的 revert 数据回滚。
    function mockCallRevert(address callee, uint256 msgValue, bytes calldata data, bytes calldata revertData)
        external;

    /// 模拟（mock）对某地址的调用，返回指定的数据。
    /// calldata 可以是严格匹配或部分匹配，例如如果你只
    /// 向期望的 calldata 传入一个 Solidity 选择器，那么整个 Solidity
    /// 函数都会被模拟。
    function mockCall(address callee, bytes calldata data, bytes calldata returnData) external;

    /// 模拟对某地址、带特定 `msg.value` 的调用，返回指定的数据。
    /// 出现歧义时，calldata 匹配优先于 `msg.value`。
    function mockCall(address callee, uint256 msgValue, bytes calldata data, bytes calldata returnData) external;

    /// 将*下一次*调用的 `msg.sender` 设置为输入的地址。
    function prank(address msgSender) external;

    /// 将*下一次*调用的 `msg.sender` 设置为输入的地址，并将 `tx.origin` 设置为第二个输入。
    function prank(address msgSender, address txOrigin) external;

    /// 设置 `block.prevrandao`。
    /// 在 Paris 之前的 EVM 版本上不可用，请改用 `difficulty`。
    /// 如果在不支持的 EVM 版本上使用，将会回滚（revert）。
    function prevrandao(bytes32 newPrevrandao) external;

    /// 从状态中读取当前的 `msg.sender` 和 `tx.origin`，并报告当前是否有生效的调用者修改。
    function readCallers() external returns (CallerMode callerMode, address msgSender, address txOrigin);

    /// 重置账户的 nonce：EOA 重置为 0，合约账户重置为 1。
    function resetNonce(address account) external;

    /// 将 EVM 状态回退到之前的某个快照
    /// 参数为要回退到的快照 ID。
    /// 如果成功回退到该快照，返回 `true`。
    /// 如果快照不存在，返回 `false`。
    /// **注意：** 这不会自动删除快照。要删除快照请使用 `deleteSnapshot`。
    function revertTo(uint256 snapshotId) external returns (bool success);

    /// 将 EVM 状态回退到之前的某个快照，并自动删除这些快照
    /// 参数为要回退到的快照 ID。
    /// 如果快照成功回退并删除，返回 `true`。
    /// 如果快照不存在，返回 `false`。
    function revertToAndDelete(uint256 snapshotId) external returns (bool success);

    /// 撤销之前通过 `makePersistent` 为该地址添加的持久化状态。
    function revokePersistent(address account) external;

    /// 参见 `revokePersistent(address)`。
    function revokePersistent(address[] calldata accounts) external;

    /// 设置 `block.height`。
    function roll(uint256 newHeight) external;

    /// 将当前激活的分叉更新到给定的区块号
    /// 这与 `roll` 类似，但作用于当前激活的分叉。
    function rollFork(uint256 blockNumber) external;

    /// 将当前激活的分叉更新到给定交易。这会以该交易被打包所在区块的
    /// 区块号执行 `rollFork`，并重放该区块中在它之前打包的所有交易。
    function rollFork(bytes32 txHash) external;

    /// 将给定的分叉更新到给定的区块号。
    function rollFork(uint256 forkId, uint256 blockNumber) external;

    /// 将给定的分叉更新到给定交易所在的区块号，并重放该区块中在它之前打包的所有交易。
    function rollFork(uint256 forkId, bytes32 txHash) external;

    /// 接收由 `createFork` 创建的分叉标识符，并将对应的分叉状态设为激活。
    function selectFork(uint256 forkId) external;

    /// 设置账户的 nonce。必须大于该账户当前的 nonce。
    function setNonce(address account, uint64 newNonce) external;

    /// 将账户的 nonce 设置为任意值。
    function setNonceUnsafe(address account, uint64 newNonce) external;

    /// 对 EVM 的当前状态做快照。
    /// 返回所创建快照的 ID。
    /// 要回退到某个快照，请使用 `revertTo`。
    function snapshot() external returns (uint256 snapshotId);

    /// 将之后所有调用的 `msg.sender` 设置为输入的地址，直到调用 `stopPrank` 为止。
    function startPrank(address msgSender) external;

    /// 将之后所有调用的 `msg.sender` 设置为输入的地址（直到调用 `stopPrank` 为止），并将 `tx.origin` 设置为第二个输入。
    function startPrank(address msgSender, address txOrigin) external;

    /// 将之后调用的 `msg.sender` 重置为 `address(this)`。
    function stopPrank() external;

    /// 将一个值写入某地址的存储槽。
    function store(address target, bytes32 slot, bytes32 value) external;

    /// 从当前激活的分叉获取给定交易，并在当前状态上执行。
    function transact(bytes32 txHash) external;

    /// 从给定的分叉获取给定交易，并在当前状态上执行。
    function transact(uint256 forkId, bytes32 txHash) external;

    /// 设置 `tx.gasprice`。
    function txGasPrice(uint256 newGasPrice) external;

    /// 设置 `block.timestamp`。
    function warp(uint256 newTimestamp) external;

    // ======== 测试 ========

    /// 期望对某地址发起一次调用，带有指定的 `msg.value`、calldata 以及*最低* gas 量。
    function expectCallMinGas(address callee, uint256 msgValue, uint64 minGas, bytes calldata data) external;

    /// 期望对某地址发起给定次数的调用，带有指定的 `msg.value`、calldata 以及*最低* gas 量。
    function expectCallMinGas(address callee, uint256 msgValue, uint64 minGas, bytes calldata data, uint64 count)
        external;

    /// 期望对某地址发起一次带指定 calldata 的调用。
    /// calldata 可以是严格匹配或部分匹配。
    function expectCall(address callee, bytes calldata data) external;

    /// 期望对某地址发起给定次数、带指定 calldata 的调用。
    function expectCall(address callee, bytes calldata data, uint64 count) external;

    /// 期望对某地址发起一次带指定 `msg.value` 和 calldata 的调用。
    function expectCall(address callee, uint256 msgValue, bytes calldata data) external;

    /// 期望对某地址发起给定次数、带指定 `msg.value` 和 calldata 的调用。
    function expectCall(address callee, uint256 msgValue, bytes calldata data, uint64 count) external;

    /// 期望对某地址发起一次带指定 `msg.value`、gas 和 calldata 的调用。
    function expectCall(address callee, uint256 msgValue, uint64 gas, bytes calldata data) external;

    /// 期望对某地址发起给定次数、带指定 `msg.value`、gas 和 calldata 的调用。
    function expectCall(address callee, uint256 msgValue, uint64 gas, bytes calldata data, uint64 count) external;

    /// 准备一条期望的日志，参数为 (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData.)。
    /// 先调用此函数，然后 emit 一个事件，再调用某个函数。在该调用之后，内部会检查
    /// 日志是否按期望的顺序、以期望的 topic 和数据被发出（由这些布尔值指定）。
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData) external;

    /// 与上一个方法相同，但还会检查所提供的地址是否与发出日志的合约一致。
    function expectEmit(bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData, address emitter)
        external;

    /// 准备一条期望的日志，启用所有 topic 和数据检查。
    /// 先调用此函数，然后 emit 一个事件，再调用某个函数。在该调用之后，内部会检查
    /// 日志是否按期望的顺序、以期望的 topic 和数据被发出。
    function expectEmit() external;

    /// 与上一个方法相同，但还会检查所提供的地址是否与发出日志的合约一致。
    function expectEmit(address emitter) external;

    /// 期望下一次调用出错，revert 数据任意。
    function expectRevert() external;

    /// 期望下一次调用出错，且 revert 数据以给定数据开头。
    function expectRevert(bytes4 revertData) external;

    /// 期望下一次调用出错，且 revert 数据与给定数据完全匹配。
    function expectRevert(bytes calldata revertData) external;

    /// 在当前子上下文中，仅允许对偏移量 [0x00, 0x60) ∪ [min, max) 进行内存写入。如果有任何其他
    /// 内存被写入，测试将失败。可以多次调用以向集合中添加更多范围。
    function expectSafeMemory(uint64 min, uint64 max) external;

    /// 在下一个创建的子上下文中，仅允许对偏移量 [0x00, 0x60) ∪ [min, max) 进行内存写入。
    /// 如果有任何其他内存被写入，测试将失败。可以多次调用以添加更多范围
    /// 到集合中。
    function expectSafeMemoryCall(uint64 min, uint64 max) external;

    /// 将测试标记为跳过。必须在测试开头调用。
    function skip(bool skipTest) external;

    /// 停止当前子上下文中所有安全内存（safe memory）期望。
    function stopExpectSafeMemory() external;
}
