// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {IUniswapV3Pool} from
    "../../../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";

contract UniswapV3Flash {
    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    IUniswapV3Pool private immutable pool;
    IERC20 private immutable token0;
    IERC20 private immutable token1;

    constructor(address _pool) {
        pool = IUniswapV3Pool(_pool);
        token0 = IERC20(pool.token0());
        token1 = IERC20(pool.token1());
    }

    function flash(uint256 amount0, uint256 amount1) external {
        // 任务 1 - 对 FlashCallbackData 进行 ABI 编码
        // 任务 2 - 调用 IUniswapV3Pool.flash
    }

    function uniswapV3FlashCallback(
        // 池子手续费率 x 请求借出的数量
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external {
        // 任务 3 - 检查 msg.sender 是否为池子
        // 任务 4 - 将 data 解码为 FlashCallbackData
        // 任务 5 - 从 FlashCallbackData.caller 转入手续费
        // 任务 6 - 向池子还款，金额为借款数量 + 手续费
    }
}
