// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IStableSwap3Pool} from
    "../../../src/interfaces/curve/IStableSwap3Pool.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {DAI, USDC, USDT, CURVE_3POOL} from "../../../src/Constants.sol";

contract CurveV1SwapTest is Test {
    IStableSwap3Pool private constant pool = IStableSwap3Pool(CURVE_3POOL);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant usdc = IERC20(USDC);
    IERC20 private constant usdt = IERC20(USDT);

    function setUp() public {
        deal(DAI, address(this), 1e6 * 1e18);
        dai.approve(address(pool), type(uint256).max);
    }

    // 练习 1
    // 调用 get_dy_underlying，计算将
    // 1,000,000 DAI 兑换为 USDC 可得到的 USDC 数量
    function test_get_dy_underlying() public {
        // 计算从 DAI 兑换到 USDC 的数量
        // 在此编写你的代码
        uint256 dy = 0;

        console2.log("dy %e", dy);
        assertGt(dy, 0, "dy = 0");
    }

    // 练习 2
    // 调用 exchange，将 1,000,000 DAI 兑换为 USDC
    function test_exchange() public {
        // 将 DAI 兑换为 USDC
        // 在此编写你的代码

        uint256 bal = usdc.balanceOf(address(this));
        console2.log("USDC balance %e", bal);
        assertGt(bal, 0, "USDC balance = 0");
    }
}
