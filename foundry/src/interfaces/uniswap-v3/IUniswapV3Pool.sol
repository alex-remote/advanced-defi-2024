// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);

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

    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function burn(int24 tickLower, int24 tickUpper, uint128 amount)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        );
}
