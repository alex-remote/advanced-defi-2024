// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {TickMath} from "../../../src/uniswap-v3/TickMath.sol";
import {FullMath} from "../../../src/uniswap-v3/FullMath.sol";
import {IUniswapV3Pool} from
    "../../../src/interfaces/uniswap-v3/IUniswapV3Pool.sol";

error InvalidToken();

contract UniswapV3Twap {
    IUniswapV3Pool public immutable pool;
    address public immutable token0;
    address public immutable token1;

    constructor(address _pool) {
        pool = IUniswapV3Pool(_pool);
        token0 = pool.token0();
        token1 = pool.token1();
    }

    // 复制自
    // https://github.com/Uniswap/v3-periphery/blob/0.8/contracts/libraries/OracleLibrary.sol
    /// @notice 给定一个 tick 和代币数量，计算兑换可得到的代币数量
    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // 如果自乘时不会上溢，则以更高的精度计算 quoteAmount
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 =
                FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    function getTwapAmountOut(address tokenIn, uint128 amountIn, uint32 dt)
        external
        view
        returns (uint256 amountOut)
    {
        // 任务 1 - 要求 tokenIn 为 token0 或 token1
        if (tokenIn != token0 && tokenIn != token1) {
            revert InvalidToken();
        } // 任务 2 - 为 tokenOut 赋值
        address tokenOut = tokenIn == token0 ? token1 : token0;

        // 任务 3 - 用 dt 和 0 填充 timeDeltas
        uint32[] memory timeDeltas = new uint32[](2);
        timeDeltas[0] = dt;
        timeDeltas[1] = 0;

        // 任务 4 - 调用 pool.observe
        // 注意：使用 int56 是因为 tick * time = int24 * uint32
        (int56[] memory tickCumulatives,) = pool.observe(timeDeltas);

        // 任务 5 - 计算 tickCumulativeDelta
        int56 tickCumulativeDelta = tickCumulatives[1] - tickCumulatives[0];

        // 任务 6 - 计算平均 tick
        // int56 / uint32 = int24
        int24 tick = int24(tickCumulativeDelta / int56(uint56(dt)));

        // 始终向负无穷方向取整
        if (
            tickCumulativeDelta < 0
                && (tickCumulativeDelta % int56(uint56(dt)) != 0)
        ) {
            tick--;
        }

        // 任务 7 - 调用 getQuoteAtTick
        return getQuoteAtTick(tick, amountIn, tokenIn, tokenOut);
    }
}
