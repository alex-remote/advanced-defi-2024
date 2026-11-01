// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {IWETH} from "../../../src/interfaces/IWETH.sol";
import {ISwapRouter} from "../../../src/interfaces/uniswap-v3/ISwapRouter.sol";
import {
    DAI,
    WETH,
    WBTC,
    UNISWAP_V3_SWAP_ROUTER_02
} from "../../../src/Constants.sol";

contract UniswapV3SwapTest is Test {
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private wbtc = IERC20(WBTC);
    ISwapRouter private router = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);
    uint24 private constant POOL_FEE = 3000;

    function setUp() public {
        deal(DAI, address(this), 1000 * 1e18);
        dai.approve(address(router), type(uint256).max);
    }

    // 练习 1
    // - 在手续费为 0.3% 的 DAI/WETH 池子上用 1000 DAI 兑换 WETH
    // - 将 WETH 从 Uniswap V3 发送到本合约
    function test_exactInputSingle() public {
        uint256 wethBefore = weth.balanceOf(address(this));

        // 在此编写你的代码
        // 调用 router.exactInputSingle
        uint256 amountOut = router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: POOL_FEE,
                recipient: address(this),
                amountIn: 1000 * 1e18,
                amountOutMinimum: 1,
                sqrtPriceLimitX96: 0
            })
        );

        uint256 wethAfter = weth.balanceOf(address(this));

        console2.log("WETH amount out %e", amountOut);
        assertGt(amountOut, 0);
        assertEq(wethAfter - wethBefore, amountOut);
    }

    // 练习 2
    // 用 1000 DAI 兑换 WETH，再将 WETH 兑换为 WBTC
    // - 在手续费为 0.3% 的池子上将 DAI 兑换为 WETH
    // - 在手续费为 0.3% 的池子上将 WETH 兑换为 WBTC
    // - 将 WBTC 从 Uniswap V3 发送到本合约
    // 注意：WBTC 有 8 位小数
    function test_exactInput() public {
        // 在此编写你的代码
        // 调用 router.exactInput
        bytes memory path =
            abi.encodePacked(DAI, uint24(3000), WETH, uint24(3000), WBTC);

        uint256 amountOut = router.exactInput(
            ISwapRouter.ExactInputParams({
                path: path,
                recipient: address(this),
                amountIn: 1000 * 1e18,
                amountOutMinimum: 1
            })
        );

        console2.log("WBTC amount out %e", amountOut);
        assertGt(amountOut, 0);
        assertEq(wbtc.balanceOf(address(this)), amountOut);
    }

    // 练习 3
    // - 在手续费为 0.3% 的 DAI/WETH 池子上用最多 1000 DAI 换取恰好 0.1 WETH
    // - 将 WETH 从 Uniswap V3 发送到本合约
    function test_exactOutputSingle() public {
        uint256 wethBefore = weth.balanceOf(address(this));

        // 在此编写你的代码
        // 调用 router.exactOutputSingle
        uint256 amountIn = router.exactOutputSingle(
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: POOL_FEE,
                recipient: address(this),
                amountOut: 0.1 * 1e18,
                amountInMaximum: 1000 * 1e18,
                sqrtPriceLimitX96: 0
            })
        );

        uint256 wethAfter = weth.balanceOf(address(this));

        console2.log("DAI amount in %e", amountIn);
        assertLe(amountIn, 1000 * 1e18);
        assertEq(wethAfter - wethBefore, 0.1 * 1e18);
    }

    // 练习 4
    // 用最多 1000 DAI 换取恰好 0.01 WBTC
    // - 在手续费为 0.3% 的池子上将 DAI 兑换为 WETH
    // - 在手续费为 0.3% 的池子上将 WETH 兑换为 WBTC
    // - 将 WBTC 从 Uniswap V3 发送到本合约
    // 注意：WBTC 有 8 位小数
    function test_exactOutput() public {
        // 在此编写你的代码
        // 调用 router.exactOutput
        bytes memory path =
            abi.encodePacked(WBTC, uint24(3000), WETH, uint24(3000), DAI);

        uint256 amountIn = router.exactOutput(
            ISwapRouter.ExactOutputParams({
                path: path,
                recipient: address(this),
                amountOut: 0.001 * 1e8, // 降低输出数量
                amountInMaximum: 1000 * 1e18
            })
        );

        console2.log("DAI amount in %e", amountIn);
        assertLe(amountIn, 1000 * 1e18);
        assertEq(wbtc.balanceOf(address(this)), 0.01 * 1e8);
    }
}
