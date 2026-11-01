// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";

error InsufficientProfit();

contract UniswapV2Arb1 {
    struct SwapParams {
        // 执行第一次兑换的路由合约 - 用 tokenIn 换 tokenOut
        address router0;
        // 执行第二次兑换的路由合约 - 用 tokenOut 换 tokenIn
        address router1;
        // 第一次兑换的输入代币
        address tokenIn;
        // 第一次兑换的输出代币
        address tokenOut;
        // 第一次兑换的输入数量
        uint256 amountIn;
        // 如果利润低于此最小值，则回滚（revert）本次套利
        uint256 minProfit;
    }

    function _swap(SwapParams memory params)
        private
        returns (uint256 amountOut)
    {
        // 在 router 0 上兑换
        IERC20(params.tokenIn).approve(address(params.router0), params.amountIn);

        address[] memory path = new address[](2);
        path[0] = params.tokenIn;
        path[1] = params.tokenOut;

        uint256[] memory amounts = IUniswapV2Router02(params.router0)
            .swapExactTokensForTokens({
            amountIn: params.amountIn,
            amountOutMin: 0,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        // 在 router 1 上兑换
        IERC20(params.tokenOut).approve(address(params.router1), amounts[1]);

        path[0] = params.tokenOut;
        path[1] = params.tokenIn;

        amounts = IUniswapV2Router02(params.router1).swapExactTokensForTokens({
            amountIn: amounts[1],
            amountOutMin: params.amountIn,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        amountOut = amounts[1];
    }

    // 练习 1
    // - 在 router0 和 router1 之间执行套利
    // - 从 msg.sender 拉取 tokenIn
    // - 将 amountIn + 利润发回给 msg.sender
    function swap(SwapParams calldata params) external {
        // 在此编写你的代码
        // 不要修改其他任何代码
        IERC20(params.tokenIn).transferFrom(
            msg.sender, address(this), params.amountIn
        );
        uint256 amountOut = _swap(params);
        if (amountOut - params.amountIn < params.minProfit) {
            revert InsufficientProfit();
        }
        IERC20(params.tokenIn).transfer(msg.sender, amountOut);
    }

    // 练习 2
    // - 使用闪电兑换（flash swap）在 router0 和 router1 之间执行套利
    // - 通过闪电兑换从 pair 借入 tokenIn
    // - 将利润发回给 msg.sender
    /**
     * @param pair 用于闪电兑换并借入 tokenIn 的交易对合约地址
     * @param isToken0 若要借入的代币是 pair 的 token0，则为 true
     * @param params 兑换参数
     */
    function flashSwap(address pair, bool isToken0, SwapParams calldata params)
        external
    {
        // 在此编写你的代码
        // 不要修改其他任何代码
        bytes memory data = abi.encode(msg.sender, pair, params);

        IUniswapV2Pair(pair).swap({
            amount0Out: isToken0 ? params.amountIn : 0,
            amount1Out: isToken0 ? 0 : params.amountIn,
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
        // 注意：任何人都可以调用
        (address caller, address pair, SwapParams memory params) =
            abi.decode(data, (address, address, SwapParams));

        uint256 amountOut = _swap(params);

        uint256 fee = ((params.amountIn * 3) / 997) + 1;
        uint256 amountToRepay = params.amountIn + fee;

        uint256 profit = amountOut - amountToRepay;
        if (profit < params.minProfit) {
            revert InsufficientProfit();
        }
        IERC20(params.tokenIn).transfer(address(pair), amountToRepay);
        IERC20(params.tokenIn).transfer(caller, profit);
    }
}
