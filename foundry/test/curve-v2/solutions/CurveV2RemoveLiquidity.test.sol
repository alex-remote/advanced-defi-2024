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
--match-test test_remove_liquidity \
--match-path test/curve-v2/solutions/CurveV2RemoveLiquidity.test.sol -vvv
*/

contract CurveV2RemoveLiquidityTest is Test {
    ITriCrypto private constant pool = ITriCrypto(CURVE_TRI_CRYPTO);
    IERC20 private constant usdc = IERC20(USDC);
    IERC20 private constant wbtc = IERC20(WBTC);
    IERC20 private constant weth = IERC20(WETH);

    function setUp() public {
        deal(USDC, address(this), 1e3 * 1e6);
        usdc.approve(address(pool), type(uint256).max);

        uint256[3] memory amounts = [uint256(1e3 * 1e6), uint256(0), uint256(0)];
        pool.add_liquidity({
            amounts: amounts,
            min_lp: 1,
            use_eth: false,
            receiver: address(this)
        });
    }

    // 练习 1
    // 调用 remove_liquidity
    // 获取本合约持有的 TriCrypto LP 余额，并
    // 取出全部 LP，换回全部 3 种代币（USDC、WBTC、WETH）
    function test_remove_liquidity() public {
        // Foundry 的 bug？初始余额 > 0
        uint256 wethBalBefore = weth.balanceOf(address(this));

        // 在此编写你的代码
        uint256 lpBal = pool.balanceOf(address(this));

        uint256[3] memory minAmounts = [uint256(1), uint256(1), uint256(1)];
        pool.remove_liquidity({
            lp: lpBal,
            min_amounts: minAmounts,
            use_eth: false,
            receiver: address(this),
            claim_admin_fees: false
        });

        assertEq(pool.balanceOf(address(this)), 0, "3CRV balance > 0");

        uint256 bal = 0;

        bal = usdc.balanceOf(address(this));
        assertGt(bal, 0, "USDC balance = 0");
        console2.log("USDC balance %e", bal);

        bal = wbtc.balanceOf(address(this));
        assertGt(bal, 0, "WBTC balance = 0");
        console2.log("WBTC balance %e", bal);

        bal = weth.balanceOf(address(this));
        assertGt(bal, wethBalBefore, "WETH balance = 0");
        console2.log("WETH balance %e", bal - wethBalBefore);
    }

    // 练习 2
    // 调用 remove_liquidity_one_coin
    // 获取本合约持有的 TriCrypto LP 余额，并
    // 取出全部 LP，只换回单一代币（USDC）
    function test_remove_liquidity_one_coin() public {
        // Foundry 的 bug？初始余额 > 0
        uint256 wethBalBefore = weth.balanceOf(address(this));

        // 在此编写你的代码
        uint256 lpBal = pool.balanceOf(address(this));
        pool.remove_liquidity_one_coin({
            lp: lpBal,
            i: 0,
            min_amount: 1,
            use_eth: false,
            receiver: address(this)
        });

        assertEq(pool.balanceOf(address(this)), 0, "3CRV balance > 0");

        uint256 bal = 0;

        bal = usdc.balanceOf(address(this));
        assertGt(bal, 0, "USDC balance = 0");
        console2.log("USDC balance %e", bal);

        bal = wbtc.balanceOf(address(this));
        assertEq(bal, 0, "WBTC balance > 0");
        console2.log("WBTC balance %e", bal);

        bal = weth.balanceOf(address(this));
        assertEq(bal, wethBalBefore, "WETH balance > 0");
        console2.log("WETH balance %e", bal - wethBalBefore);
    }
}
