pragma solidity >=0.5.0;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

import "./SafeMath.sol";

library UniswapV2Library {
    using SafeMath for uint;

    // 返回排序后的代币地址，用于处理按此顺序排序的交易对所返回的值
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // 在不进行任何外部调用的情况下计算交易对的 CREATE2 地址
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                // 注意：salt（盐值）
                keccak256(abi.encodePacked(token0, token1)),
                // 注意：keccak256(creation bytecode)，即合约创建字节码的哈希
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // 初始化代码哈希（init code hash）
            ))));
    }

    // 获取并排序交易对的储备量
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        // 注意：token 0 < token 1
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // 给定某资产的数量和交易对的储备量，返回另一种资产的等值数量
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        // 注意：
        // dy = dx * y0 / x0
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // 给定某资产的输入数量和交易对的储备量，返回另一种资产的最大输出数量
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        // 注意：
        // x = 输入代币（token in）
        // y = 输出代币（token out）
        //       dx * 0.997 * x0
        // dy = -----------------
        //       x0 + dx * 0.997

        // 注意：
        // dx * 997
        uint amountInWithFee = amountIn.mul(997);
        // dx * 997 * y0
        uint numerator = amountInWithFee.mul(reserveOut);
        // x0 * 1000 + dx * 997
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        //          dx * 997 * y0
        // dy = ----------------------
        //       x0 * 1000 + dx * 997
        // 
        //        dx * 997 / 1000 * y0
        //    = -----------------------
        //        x0 + dx * 997 / 1000
        amountOut = numerator / denominator;
    }

    // 给定某资产的输出数量和交易对的储备量，返回所需的另一种资产的输入数量
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        // x0 * dy * 1000
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        // (y0 - dy) * 997 
        uint denominator = reserveOut.sub(amountOut).mul(997);
        // 注意：
        // (x0 + dx * (1 - f))(y0 - dy) = x0 * y0
        //       x0 * dy       1
        // dx = --------- * -------
        //       y0 - dy     1 - f
        //       x0 * dy * 1000
        // dx = ----------------- 
        //      (y0 - dy) * 997
        // 注意：向上取整
        amountIn = (numerator / denominator).add(1);
    }

    // 对任意数量的交易对执行链式 getAmountOut 计算
    // 注意：amounts[0] = amountIn
    //       amounts[n - 1] = 最终输出数量
    //       amounts[i] = 中间各步的输出数量
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;

        // 注意：示例
        // --- 输入 ---
        // amountIn = 1e18
        // path = [WETH, DAI, MKR]
        // --- 输出 ---
        // WETH    1000000000000000000 (1 * 1e18)
        // DAI  2500339748620145970214 (2500.3397... * 1e18)
        // MKR     1242766501542703043 (1.2427... * 1e18)

        // --- 执行过程 ---
        // amounts = [0, 0, 0]
        // amounts = [1000000000000000000, 0, 0]

        // for 循环
        // i = 0
        // path[i] = WETH, path[i + 1] = DAI
        // amounts[i] = 1000000000000000000
        // amounts[i + 1] = 2500339748620145970214
        // amounts = [1000000000000000000, 2500339748620145970214, 0]

        // i = 1
        // path[i] = DAI, path[i + 1] = MKR
        // amounts[i] = 2500339748620145970214
        // amounts[i + 1] = 1242766501542703043
        // amounts = [1000000000000000000, 2500339748620145970214, 1242766501542703043]

        // 注意：
        //   i | path[i]   | path[i + 1]
        //   0 | path[0]   | path[1]
        //   1 | path[1]   | path[2]
        //   2 | path[2]   | path[3]
        // n-2 | path[n-2] | path[n-1]
        for (uint i; i < path.length - 1; i++) {
            // 注意：reserves = 交易对合约内部记录的代币余额
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            // 注意：用上一步的输出作为本步的输入
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // 对任意数量的交易对执行链式 getAmountIn 计算
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;

        // --- 输入 ---
        // amountOut = 1e18
        // path = [WETH, DAI, MKR]
        // --- 输出 ---
        // WETH     804555560756014274 (0.8045... * 1e18)
        // DAI  2011892163724115442026 (2011.892... * 1e18)
        // MKR     1000000000000000000 (1 * 1e18)

        // --- 执行过程 ---
        // amounts = [0, 0, 0]
        // amounts = [0, 0, 1000000000000000000]

        // for 循环
        // i = 2
        // path[i - 1] = DAI, path[i] = MKR
        // amounts[i] = 1000000000000000000
        // amounts[i - 1] = 2011892163724115442026
        // amounts = [0, 2011892163724115442026, 1000000000000000000]

        // i = 1
        // path[i - 1] = WETH, path[i] = DAI
        // amounts[i] = 2011892163724115442026
        // amounts[i - 1] = 804555560756014274
        // amounts = [804555560756014274, 2011892163724115442026, 1000000000000000000]

        // 注意：
        // i     | 输出数量       | 输入数量
        // n - 1 | amounts[n - 1] | amounts[n - 2]
        // n - 2 | amounts[n - 2] | amounts[n - 3]
        // ...
        // 2     | amounts[2]     | amounts[1] 
        // 1     | amounts[1]     | amounts[0]
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
