// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";

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

    // 练习 1
    // - 在 router0 和 router1 之间执行套利
    // - 从 msg.sender 拉取 tokenIn
    // - 将 amountIn + 利润发回给 msg.sender
    function swap(SwapParams calldata params) external {
        // 在此编写你的代码
        // 不要修改其他任何代码
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
}
