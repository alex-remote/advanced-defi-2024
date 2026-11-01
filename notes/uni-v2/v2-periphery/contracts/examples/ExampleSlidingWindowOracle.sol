pragma solidity =0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/lib/contracts/libraries/FixedPoint.sol';

import '../libraries/SafeMath.sol';
import '../libraries/UniswapV2Library.sol';
import '../libraries/UniswapV2OracleLibrary.sol';

// 滑动窗口预言机，利用在一个窗口内收集的观测值（observation）提供过去
// `windowSize` 时长内的移动平均价格，精度为 `windowSize / granularity`
// 注意：这是一个单例预言机，每组所需参数只需部署一次，这一点
// 不同于简单预言机——后者必须为每个交易对各部署一次。
contract ExampleSlidingWindowOracle {
    using FixedPoint for *;
    using SafeMath for uint;

    struct Observation {
        uint timestamp;
        uint price0Cumulative;
        uint price1Cumulative;
    }

    address public immutable factory;
    // 计算移动平均所覆盖的期望时间长度，例如 24 小时
    uint public immutable windowSize;
    // 每个交易对存储的观测值数量，即该窗口内存储多少个价格观测值。
    // granularity 从 1 开始增大时，需要更频繁地更新，但移动平均也会更精确。
    // 平均值的计算区间长度落在以下范围内：
    //   [windowSize - (windowSize / granularity) * 2, windowSize]
    // 例如，若窗口大小为 24 小时、granularity 为 24，预言机将返回以下
    //   时间段内的平均价格：
    //   [now - [22 hours, 24 hours], now]
    uint8 public immutable granularity;
    // 该值可由 granularity 和 windowSize 推出，属于冗余，但为了节省 gas 和提供信息而存储。
    uint public immutable periodSize;

    // 从交易对地址到该交易对价格观测值列表的映射
    mapping(address => Observation[]) public pairObservations;

    constructor(address factory_, uint windowSize_, uint8 granularity_) public {
        require(granularity_ > 1, 'SlidingWindowOracle: GRANULARITY');
        require(
            (periodSize = windowSize_ / granularity_) * granularity_ == windowSize_,
            'SlidingWindowOracle: WINDOW_NOT_EVENLY_DIVISIBLE'
        );
        factory = factory_;
        windowSize = windowSize_;
        granularity = granularity_;
    }

    // 返回给定时间戳对应的观测值索引
    function observationIndexOf(uint timestamp) public view returns (uint8 index) {
        uint epochPeriod = timestamp / periodSize;
        return uint8(epochPeriod % granularity);
    }

    // 返回相对于当前时间最早一个纪元（epoch，位于窗口起点）的观测值
    function getFirstObservationInWindow(address pair) private view returns (Observation storage firstObservation) {
        uint8 observationIndex = observationIndexOf(block.timestamp);
        // 不存在溢出问题。即使 observationIndex + 1 溢出，结果仍然是 0。
        uint8 firstObservationIndex = (observationIndex + 1) % granularity;
        firstObservation = pairObservations[pair][firstObservationIndex];
    }

    // 更新当前时间戳对应观测值的累计价格。每个观测值在每个纪元周期内
    // 最多更新一次。
    function update(address tokenA, address tokenB) external {
        address pair = UniswapV2Library.pairFor(factory, tokenA, tokenB);

        // 用空的观测值填充数组（仅首次调用时）
        for (uint i = pairObservations[pair].length; i < granularity; i++) {
            pairObservations[pair].push();
        }

        // 获取当前周期的观测值
        uint8 observationIndex = observationIndexOf(block.timestamp);
        Observation storage observation = pairObservations[pair][observationIndex];

        // 我们只希望每个周期（即 windowSize / granularity）提交一次更新
        uint timeElapsed = block.timestamp - observation.timestamp;
        if (timeElapsed > periodSize) {
            (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
            observation.timestamp = block.timestamp;
            observation.price0Cumulative = price0Cumulative;
            observation.price1Cumulative = price1Cumulative;
        }
    }

    // 给定一个周期起点和终点的累计价格以及周期长度，计算平均价格，
    // 并以“给定输入数量能得到多少输出数量”的形式表示
    function computeAmountOut(
        uint priceCumulativeStart, uint priceCumulativeEnd,
        uint timeElapsed, uint amountIn
    ) private pure returns (uint amountOut) {
        // 溢出是预期行为。
        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulativeEnd - priceCumulativeStart) / timeElapsed)
        );
        amountOut = priceAverage.mul(amountIn).decode144();
    }

    // 使用以下时间范围内的移动平均价格，返回给定代币的输入数量所对应的输出数量，时间
    // 范围为 [now - [windowSize, windowSize - periodSize * 2], now]
    // 必须已经针对时间戳 `now - windowSize` 所对应的桶（bucket）调用过 update
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut) {
        address pair = UniswapV2Library.pairFor(factory, tokenIn, tokenOut);
        Observation storage firstObservation = getFirstObservationInWindow(pair);

        uint timeElapsed = block.timestamp - firstObservation.timestamp;
        require(timeElapsed <= windowSize, 'SlidingWindowOracle: MISSING_HISTORICAL_OBSERVATION');
        // 理论上不应发生。
        require(timeElapsed >= windowSize - periodSize * 2, 'SlidingWindowOracle: UNEXPECTED_TIME_ELAPSED');

        (uint price0Cumulative, uint price1Cumulative,) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        (address token0,) = UniswapV2Library.sortTokens(tokenIn, tokenOut);

        if (token0 == tokenIn) {
            return computeAmountOut(firstObservation.price0Cumulative, price0Cumulative, timeElapsed, amountIn);
        } else {
            return computeAmountOut(firstObservation.price1Cumulative, price1Cumulative, timeElapsed, amountIn);
        }
    }
}
