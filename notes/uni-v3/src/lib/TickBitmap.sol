// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

import {IUniswapV3Pool} from "../interfaces/uni-v3/IUniswapV3Pool.sol";
import {BitMath} from "./BitMath.sol";

library TickBitmap {
    function position(int24 tick)
        internal
        pure
        returns (int16 wordPos, uint8 bitPos)
    {
        wordPos = int16(tick >> 8);
        bitPos = uint8(int8(tick % 256));
    }

    function nextInitializedTickWithinOneWord(
        IUniswapV3Pool pool,
        int24 tick,
        int24 tickSpacing,
        bool lte
    ) internal view returns (int24 next, bool initialized) {
        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--; // 向负无穷方向取整

        if (lte) {
            (int16 wordPos, uint8 bitPos) = position(compressed);
            // 当前 bitPos 及其右侧的所有位全为 1
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = pool.tickBitmap(wordPos) & mask;

            // 如果当前 tick 及其右侧没有已初始化的 tick，则返回该字（word）中最右侧的 tick
            initialized = masked != 0;
            // 可能发生上溢/下溢，但外部已通过同时限制 tickSpacing 和 tick 加以防止
            next = initialized
                ? (compressed
                        - int24(
                            uint24(bitPos - BitMath.mostSignificantBit(masked))
                        )) * tickSpacing
                : (compressed - int24(uint24(bitPos))) * tickSpacing;
        } else {
            // 从下一个 tick 所在的字开始，因为当前 tick 的状态无关紧要
            (int16 wordPos, uint8 bitPos) = position(compressed + 1);
            // bitPos 及其左侧的所有位全为 1
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = pool.tickBitmap(wordPos) & mask;

            // 如果当前 tick 左侧没有已初始化的 tick，则返回该字中最左侧的 tick
            initialized = masked != 0;
            // 可能发生上溢/下溢，但外部已通过同时限制 tickSpacing 和 tick 加以防止
            next = initialized
                ? (compressed
                        + 1
                        + int24(
                            uint24(BitMath.leastSignificantBit(masked) - bitPos)
                        )) * tickSpacing
                : (compressed + 1 + int24(uint24(type(uint8).max - bitPos)))
                    * tickSpacing;
        }
    }
}
