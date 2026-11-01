// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";

error InsufficientProfit();

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
        (uint112 reserve0, uint112 reserve1,) =
            IUniswapV2Pair(pair0).getReserves();

        // 提示 - 使用 getAmountOut 计算要借入的 amountOut
        uint256 amountOut = isZeroForOne
            ? getAmountOut(amountIn, reserve0, reserve1)
            : getAmountOut(amountIn, reserve1, reserve0);

        bytes memory data = abi.encode(
            FlashSwapData({
                caller: msg.sender,
                pair0: pair0,
                pair1: pair1,
                isZeroForOne: isZeroForOne,
                amountIn: amountIn,
                amountOut: amountOut,
                minProfit: minProfit
            })
        );

        IUniswapV2Pair(pair0).swap({
            amount0Out: isZeroForOne ? 0 : amountOut,
            amount1Out: isZeroForOne ? amountOut : 0,
            to: address(this),
            data: data
        });
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0Out,
        uint256 amount1Out,
        bytes calldata data
    ) external {
        // 在此编写你的代码
        // 不要修改其他任何代码

        // 注意 - 任何人都可以调用

        FlashSwapData memory params = abi.decode(data, (FlashSwapData));

        // 闪电兑换的输入代币和输出代币
        address token0 = IUniswapV2Pair(params.pair0).token0();
        address token1 = IUniswapV2Pair(params.pair0).token1();
        (address tokenIn, address tokenOut) =
            params.isZeroForOne ? (token0, token1) : (token1, token0);

        (uint112 reserve0, uint112 reserve1,) =
            IUniswapV2Pair(params.pair1).getReserves();

        uint256 amountOut = params.isZeroForOne
            ? getAmountOut(params.amountOut, reserve1, reserve0)
            : getAmountOut(params.amountOut, reserve0, reserve1);

        IERC20(tokenOut).transfer(params.pair1, params.amountOut);

        IUniswapV2Pair(params.pair1).swap({
            amount0Out: params.isZeroForOne ? amountOut : 0,
            amount1Out: params.isZeroForOne ? 0 : amountOut,
            to: address(this),
            data: ""
        });

        // 注意 - 无需计算闪电兑换手续费
        IERC20(tokenIn).transfer(params.pair0, params.amountIn);

        uint256 profit = amountOut - params.amountIn;
        if (profit < params.minProfit) {
            revert InsufficientProfit();
        }
        IERC20(tokenIn).transfer(params.caller, profit);
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
