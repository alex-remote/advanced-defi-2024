// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import "./IERC20.sol";

/// @dev ERC4626“代币化金库标准”（Tokenized Vault Standard）的接口，定义见
/// https://eips.ethereum.org/EIPS/eip-4626
interface IERC4626 is IERC20 {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    /// @notice 返回金库（Vault）用于记账、存入和取出的底层代币地址。
    /// @dev
    /// - 必须是 ERC-20 代币合约。
    /// - 不得回滚（revert）。
    function asset() external view returns (address assetTokenAddress);

    /// @notice 返回由金库“管理”的底层资产总量。
    /// @dev
    /// - 应当包含收益产生的任何复利。
    /// - 必须包含针对金库中资产收取的任何手续费。
    /// - 不得回滚（revert）。
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /// @notice 返回在理想情况下（即所有条件都满足时），金库针对所提供的
    /// 底层资产数量所兑换出的份额数量。
    /// @dev
    /// - 不得包含针对金库中资产收取的任何手续费。
    /// - 不得因调用者不同而产生任何差异。
    /// - 不得反映实际兑换时的滑点或其他链上状况。
    /// - 不得回滚（revert）。
    ///
    /// 注意：该计算可以不反映“单个用户”的每份额价格，而应当反映
    /// “平均用户”的每份额价格，即平均用户在兑换为份额以及从份额
    /// 兑换回来时应当预期看到的价格。
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /// @notice 返回在理想情况下（即所有条件都满足时），金库针对所提供的
    /// 份额数量所兑换出的底层资产数量。
    /// @dev
    /// - 不得包含针对金库中资产收取的任何手续费。
    /// - 不得因调用者不同而产生任何差异。
    /// - 不得反映实际兑换时的滑点或其他链上状况。
    /// - 不得回滚（revert）。
    ///
    /// 注意：该计算可以不反映“单个用户”的每份额价格，而应当反映
    /// “平均用户”的每份额价格，即平均用户在兑换为份额以及从份额
    /// 兑换回来时应当预期看到的价格。
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /// @notice 返回可通过 deposit 调用为 receiver 存入金库的
    /// 底层资产最大数量。
    /// @dev
    /// - 如果 receiver 受某种存入限额约束，必须返回一个有限值。
    /// - 如果可存入的资产最大数量没有限制，必须返回 2 ** 256 - 1。
    /// - 不得回滚（revert）。
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /// @notice 允许链上或链下用户在当前区块、基于当前链上状况，
    /// 模拟其存入操作的效果。
    /// @dev
    /// - 返回值必须尽可能接近且不超过在同一交易中调用 deposit
    ///   实际会铸造的金库份额数量。即：若在同一交易中调用，deposit 返回的份额应当等于或多于
    ///   previewDeposit 的返回值。
    /// - 不得考虑存入限额（如 maxDeposit 返回的限额），并且应当始终假设
    ///   存入会被接受，而不论用户是否已授权足够的代币等。
    /// - 必须包含存入手续费。集成方应当注意存入手续费的存在。
    /// - 不得回滚（revert）。
    ///
    /// 注意：convertToShares 与 previewDeposit 之间任何不利的差异都应当被视为份额价格的
    /// 滑点或其他某种状况，意味着存入者会因存入而损失资产。
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /// @notice 通过存入确切数量（amount）的底层代币，向 receiver 铸造 shares 数量的金库份额。
    /// @dev
    /// - 必须触发 Deposit 事件。
    /// - 可以支持另一种流程：在 deposit 执行之前底层代币就已由金库合约持有，
    ///   并在 deposit 过程中对其进行记账。
    /// - 如果无法存入全部 assets（由于达到存入限额、滑点、用户未向金库合约
    ///   授权足够的底层代币等原因），必须回滚（revert）。
    ///
    /// 注意：大多数实现会要求事先用金库的底层资产代币向金库授权。
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /// @notice 返回可通过 mint 调用为 receiver 铸造的金库份额最大数量。
    /// @dev
    /// - 如果 receiver 受某种铸造限额约束，必须返回一个有限值。
    /// - 如果可铸造的份额最大数量没有限制，必须返回 2 ** 256 - 1。
    /// - 不得回滚（revert）。
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /// @notice 允许链上或链下用户在当前区块、基于当前链上状况，
    /// 模拟其铸造操作的效果。
    /// @dev
    /// - 返回值必须尽可能接近且不少于在同一交易中调用 mint 实际会存入的
    ///   资产数量。即：若在同一交易中调用，mint 返回的资产应当等于或少于
    ///   previewMint 的返回值。
    /// - 不得考虑铸造限额（如 maxMint 返回的限额），并且应当始终假设铸造
    ///   会被接受，而不论用户是否已授权足够的代币等。
    /// - 必须包含存入手续费。集成方应当注意存入手续费的存在。
    /// - 不得回滚（revert）。
    ///
    /// 注意：convertToAssets 与 previewMint 之间任何不利的差异都应当被视为份额价格的
    /// 滑点或其他某种状况，意味着存入者会因铸造而损失资产。
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /// @notice 通过存入相应数量（amount）的底层代币，向 receiver 铸造恰好 shares 数量的金库份额。
    /// @dev
    /// - 必须触发 Deposit 事件。
    /// - 可以支持另一种流程：在 mint 执行之前底层代币就已由金库合约持有，
    ///   并在 mint 过程中对其进行记账。
    /// - 如果无法铸造全部 shares（由于达到存入限额、滑点、用户未向金库合约
    ///   授权足够的底层代币等原因），必须回滚（revert）。
    ///
    /// 注意：大多数实现会要求事先用金库的底层资产代币向金库授权。
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /// @notice 返回可通过 withdraw 调用从 owner 在金库中的余额里
    /// 取出的底层资产最大数量。
    /// @dev
    /// - 如果 owner 受某种取出限额或时间锁约束，必须返回一个有限值。
    /// - 不得回滚（revert）。
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /// @notice 允许链上或链下用户在当前区块、基于当前链上状况，
    /// 模拟其取出操作的效果。
    /// @dev
    /// - 返回值必须尽可能接近且不少于在同一交易中调用 withdraw
    ///   实际会销毁的金库份额数量。即：若在同一交易中调用，withdraw 返回的份额
    ///   应当等于或少于
    ///   previewWithdraw 的返回值。
    /// - 不得考虑取出限额（如 maxWithdraw 返回的限额），并且应当始终假设
    ///   取出会被接受，而不论用户是否有足够的份额等。
    /// - 必须包含取出手续费。集成方应当注意取出手续费的存在。
    /// - 不得回滚（revert）。
    ///
    /// 注意：convertToShares 与 previewWithdraw 之间任何不利的差异都应当被视为份额价格的
    /// 滑点或其他某种状况，意味着存入者会因存入而损失资产。
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /// @notice 从 owner 处销毁份额，并向 receiver 发送恰好 assets 数量的底层代币。
    /// @dev
    /// - 必须触发 Withdraw 事件。
    /// - 可以支持另一种流程：在 withdraw 执行之前底层代币就已由金库合约持有，
    ///   并在 withdraw 过程中对其进行记账。
    /// - 如果无法取出全部 assets（由于达到取出限额、滑点、owner
    ///   没有足够的份额等原因），必须回滚（revert）。
    ///
    /// 注意：某些实现会要求在执行取出之前先向金库提交预请求。
    /// 这些方法应当单独执行。
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /// @notice 返回可通过 redeem 调用从 owner 在金库中的余额里
    /// 赎回的金库份额最大数量。
    /// @dev
    /// - 如果 owner 受某种取出限额或时间锁约束，必须返回一个有限值。
    /// - 如果 owner 不受任何取出限额或时间锁约束，必须返回 balanceOf(owner)。
    /// - 不得回滚（revert）。
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /// @notice 允许链上或链下用户在当前区块、基于当前链上状况，
    /// 模拟其赎回操作的效果。
    /// @dev
    /// - 返回值必须尽可能接近且不超过在同一交易中调用 redeem 实际会取出的
    ///   资产数量。即：若在同一交易中调用，redeem 返回的资产应当等于或多于
    ///   previewRedeem 的返回值。
    /// - 不得考虑赎回限额（如 maxRedeem 返回的限额），并且应当始终假设
    ///   赎回会被接受，而不论用户是否有足够的份额等。
    /// - 必须包含取出手续费。集成方应当注意取出手续费的存在。
    /// - 不得回滚（revert）。
    ///
    /// 注意：convertToAssets 与 previewRedeem 之间任何不利的差异都应当被视为份额价格的
    /// 滑点或其他某种状况，意味着存入者会因赎回而损失资产。
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /// @notice 从 owner 处销毁恰好 shares 数量的份额，并向 receiver 发送相应数量（assets）的底层代币。
    /// @dev
    /// - 必须触发 Withdraw 事件。
    /// - 可以支持另一种流程：在 redeem 执行之前底层代币就已由金库合约持有，
    ///   并在 redeem 过程中对其进行记账。
    /// - 如果无法赎回全部 shares（由于达到取出限额、滑点、owner
    ///   没有足够的份额等原因），必须回滚（revert）。
    ///
    /// 注意：某些实现会要求在执行取出之前先向金库提交预请求。
    /// 这些方法应当单独执行。
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
