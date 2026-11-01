// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {IWETH} from "../../../src/interfaces/IWETH.sol";
import {IUniswapV2Router02} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import {
    DAI,
    WETH,
    UNISWAP_V2_ROUTER_02,
    UNISWAP_V2_PAIR_DAI_WETH,
    SUSHISWAP_V2_ROUTER_02,
    SUSHISWAP_V2_PAIR_DAI_WETH
} from "../../../src/Constants.sol";
import {UniswapV2Arb2} from "./UniswapV2Arb2.sol";

// 测试 Uniswap 与 Sushiswap 之间的套利
// 在 Uniswap 上买入 WETH，在 Sushiswap 上卖出。
// 对于 flashSwap，从 DAI/MKR 交易对借入 DAI
contract UniswapV2Arb2Test is Test {
    IUniswapV2Router02 private constant uni_router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Router02 private constant sushi_router =
        IUniswapV2Router02(SUSHISWAP_V2_ROUTER_02);
    IERC20 private constant dai = IERC20(DAI);
    IWETH private constant weth = IWETH(WETH);
    address constant user = address(11);

    UniswapV2Arb2 private arb;

    function setUp() public {
        arb = new UniswapV2Arb2();

        // 准备 - Uniswap 上的 WETH 比 Sushiswap 上便宜
        deal(address(this), 100 * 1e18);

        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(uni_router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uni_router.swapExactTokensForTokens({
            amountIn: 10 * 1e18,
            amountOutMin: 1,
            path: path,
            to: user,
            deadline: block.timestamp
        });
    }

    function test_flashSwap() public {
        uint256 bal0 = dai.balanceOf(user);
        vm.prank(user);
        arb.flashSwap(
            UNISWAP_V2_PAIR_DAI_WETH,
            SUSHISWAP_V2_PAIR_DAI_WETH,
            true,
            10000 * 1e18,
            1
        );
        uint256 bal1 = dai.balanceOf(user);

        assertGe(bal1, bal0, "no profit");
        assertEq(dai.balanceOf(address(arb)), 0, "DAI balance of arb != 0");
        console2.log("profit", bal1 - bal0);
    }
}
