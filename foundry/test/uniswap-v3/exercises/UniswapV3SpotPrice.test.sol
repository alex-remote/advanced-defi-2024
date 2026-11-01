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

        // sqrtPriceX96 * sqrtPriceX96 可能会上溢
        // 所以使用 FullMath.mulDiv 计算 uint256 * uint256 / uint256，以避免上溢

        assertGt(price, 0, "price = 0");
        console2.log("price %e", price);
    }
}
