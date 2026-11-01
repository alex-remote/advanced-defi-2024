// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {ITriCrypto} from "../../../src/interfaces/curve/ITriCrypto.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {USDC, WBTC, WETH, CURVE_TRI_CRYPTO} from "../../../src/Constants.sol";

/*
forge test \
--evm-version cancun \
--fork-url $FORK_URL \
--match-test test_get_dy \
--match-path test/curve-v2/exercises/CurveV2Swap.test.sol -vvv
*/

contract CurveV2SwapTest is Test {
    ITriCrypto private constant pool = ITriCrypto(CURVE_TRI_CRYPTO);
    IERC20 private constant usdc = IERC20(USDC);
    IERC20 private constant wbtc = IERC20(WBTC);
    IERC20 private constant weth = IERC20(WETH);

    function setUp() public {
        deal(WETH, address(this), 1e18);
        weth.approve(address(pool), type(uint256).max);
    }

    // 练习 1
    // 调用 get_dy，计算将
    // 1 WETH 兑换为 USDC 可得到的 USDC 数量
    function test_get_dy() public {
        // 计算从 WETH 兑换到 USDC 的数量
        // 在此编写你的代码
        uint256 dy = 0;

        console2.log("dy %e", dy);
        assertGt(dy, 0, "dy = 0");
    }

    // 练习 2
    // 调用 exchange，将 1 WETH 兑换为 USDC
    function test_exchange() public {
        // 将 WETH 兑换为 USDC
        // 在此编写你的代码

        uint256 bal = usdc.balanceOf(address(this));
        console2.log("USDC balance %e", bal);
        assertGt(bal, 0, "USDC balance = 0");
    }
}
