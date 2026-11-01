// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.33;

interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function tickSpacing() external view returns (int24);
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    struct Tick {
        uint128 liquidityGross;
        int128 liquidityNet;
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
        int56 tickCumulativeOutside;
        uint160 secondsPerLiquidityOutsideX128;
        uint32 secondsOutside;
        bool initialized;
    }

    function ticks(int24 tick) external view returns (Tick memory);

    struct Slot0 {
        // 当前价格
        uint160 sqrtPriceX96;
        // 当前 tick
        int24 tick;
        // observations 数组中最近一次更新的索引
        uint16 observationIndex;
        // 当前正在存储的观测值（observation）的最大数量
        uint16 observationCardinality;
        // 下一个要存储的观测值最大数量，在 observations.write 中触发
        uint16 observationCardinalityNext;
        // 当前的协议手续费，表示为提取时所收取兑换手续费的百分比
        // 以整数分母 (1/x)% 的形式表示
        uint8 feeProtocol;
        // 池子是否被锁定
        bool unlocked;
    }

    function slot0() external view returns (Slot0 memory);
    function liquidity() external view returns (uint128);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}
