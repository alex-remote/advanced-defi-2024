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
--match-path test/curve-v2/exercises/CurveV2AddLiquidity.test.sol -vvv
*/

contract CurveV2AddLiquidityTest is Test {
    ITriCrypto private constant pool = ITriCrypto(CURVE_TRI_CRYPTO);
    IERC20 private constant usdc = IERC20(USDC);
    IERC20 private constant wbtc = IERC20(WBTC);
    IERC20 private constant weth = IERC20(WETH);

    function setUp() public {
        deal(USDC, address(this), 1e3 * 1e6);
        usdc.approve(address(pool), type(uint256).max);
    }

    // 练习 1
    // 调用 add_liquidity
    // 向池子合约添加 1,000 USDC 的流动性
    function test_add_liquidity() public {
        // 在此编写你的代码

        uint256 lpBal = pool.balanceOf(address(this));
        assertGt(lpBal, 0, "lp = 0");
    }
}
