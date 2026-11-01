// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";

contract UniswapV2Arb2 {
    struct FlashSwapData {
        // flashSwap 的调用者（即 flashSwap 内部的 msg.sender）
        address caller;
        // 进行闪电兑换的交易对
        address pair0;
        // 进行普通兑换的交易对
        address pair1;
        // 若闪电兑换为输入 token0、输出 token1，则为 true
        bool isZeroForOne;
        // 用于偿还闪电兑换的输入数量
        uint256 amountIn;
        // 通过闪电兑换借入的数量
        uint256 amountOut;
        // 如果利润低于此最小值，则回滚（revert）
        uint256 minProfit;
    }

    // 练习 1
    // - 通过闪电兑换借入 tokenOut
    /**
     * @param pair0 进行闪电兑换的交易对合约
     * @param pair1 进行普通兑换的交易对合约
     * @param isZeroForOne 若闪电兑换为输入 token0、输出 token1，则为 true
     * @param amountIn 用于偿还闪电兑换的输入数量
     * @param minProfit 本次套利必须达到的最低利润
     */
    function flashSwap(
        address pair0,
        address pair1,
        bool isZeroForOne,
        uint256 amountIn,
        uint256 minProfit
    ) external {
        // 在此编写你的代码
        // 不要修改其他任何代码

        // 提示 - 使用 getAmountOut 计算要借入的 amountOut
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0Out,
        uint256 amount1Out,
        bytes calldata data
    ) external {
        // 在此编写你的代码
        // 不要修改其他任何代码
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
