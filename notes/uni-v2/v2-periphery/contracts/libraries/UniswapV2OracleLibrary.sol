pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

// 为需要计算平均价格的预言机提供辅助方法的库
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // 辅助函数，返回限定在 uint32 范围内（即 [0, 2**32 - 1]）的当前区块时间戳
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // 使用反事实（counterfactual）推算累计价格，以节省 gas 并避免调用 sync。
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // 如果距交易对上次更新已经过去了一段时间，则模拟计算累计价格值
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // 此处减法溢出是预期行为
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // 此处加法溢出是预期行为
            // 反事实推算（counterfactual）
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // 反事实推算（counterfactual）
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}
