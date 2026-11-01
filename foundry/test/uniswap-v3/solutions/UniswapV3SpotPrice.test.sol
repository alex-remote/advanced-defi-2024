pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IUniswapV3Pool} from
    "../../../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";
import {UNISWAP_V3_POOL_USDC_WETH_500} from "../../../src/Constants.sol";
import {FullMath} from "../../../src/uniswap-v3/FullMath.sol";

contract UniswapV3SwapTest is Test {
    // token0（即 X）
    uint256 private constant USDC_DECIMALS = 1e6;
    // token1（即 Y）
    uint256 private constant WETH_DECIMALS = 1e18;
    // 1 << 96 = 2 ** 96
    uint256 private constant Q96 = 1 << 96;
    IUniswapV3Pool private immutable pool =
        IUniswapV3Pool(UNISWAP_V3_POOL_USDC_WETH_500);

    // 练习 1
    // - 获取以 USDC 计价的 WETH 价格，并以 18 位小数返回该价格
    function test_spot_price_from_sqrtPriceX96() public {
        uint256 price = 0;
        IUniswapV3Pool.Slot0 memory slot0 = pool.slot0();

        // 在此编写你的代码
        // 不要修改其他任何代码

        // P     = Y / X = WETH / USDC
        //               = 以 WETH 计价的 USDC 价格
        // 1 / P = X / Y = USDC / WETH
        //               = 以 USDC 计价的 WETH 价格

        // P 的小数精度为 1e18 / 1e6 = 1e12
        // 1 / P 的小数精度为 1e6 / 1e18 = 1e-12

        // sqrtPriceX96 * sqrtPriceX96 可能会上溢
        // 所以使用 FullMath.mulDiv 计算 uint256 * uint256 / uint256，以避免上溢

        // sqrtPriceX96 = sqrt(P) * Q96
        // sqrt(P) * Q96 * sqrt(P) * Q96
        //            96 位           96 位 = 192 位
        // 256 位 - 192 位 = 64 位
        // 2**64 / 1e18 约等于 18

        // price = sqrt(P) * Q96 * sqrt(P) * Q96 / Q96
        price = FullMath.mulDiv(slot0.sqrtPriceX96, slot0.sqrtPriceX96, Q96);
        // 1 / price = 1 / (P * Q96)
        price = 1e12 * 1e18 * Q96 / price;

        assertGt(price, 0, "price = 0");
        console2.log("price %e", price);
    }
}
