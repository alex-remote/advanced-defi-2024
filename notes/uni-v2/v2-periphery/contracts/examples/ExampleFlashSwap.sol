pragma solidity =0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

import '../libraries/UniswapV2Library.sol';
import '../interfaces/V1/IUniswapV1Factory.sol';
import '../interfaces/V1/IUniswapV1Exchange.sol';
import '../interfaces/IUniswapV2Router01.sol';
import '../interfaces/IERC20.sol';
import '../interfaces/IWETH.sol';

contract ExampleFlashSwap is IUniswapV2Callee {
    IUniswapV1Factory immutable factoryV1;
    address immutable factory;
    IWETH immutable WETH;

    constructor(address _factory, address _factoryV1, address router) public {
        factoryV1 = IUniswapV1Factory(_factoryV1);
        factory = _factory;
        WETH = IWETH(IUniswapV2Router01(router).WETH());
    }

    // 需要接收来自任意 V1 exchange 和 WETH 的 ETH。理想情况下可以像路由合约（Router）中那样强制校验来源，
    // 但这里做不到，因为那需要调用 v1 工厂合约（Factory），会消耗过多 gas
    receive() external payable {}

    // 通过 V2 闪电兑换（flash swap）获得代币/WETH，在 V1 上兑换成 ETH/代币，偿还 V2，剩下的全归自己！
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        address[] memory path = new address[](2);
        uint amountToken;
        uint amountETH;
        { // token{0,1} 的作用域，避免 stack too deep 错误
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        assert(msg.sender == UniswapV2Library.pairFor(factory, token0, token1)); // 确保 msg.sender 确实是一个 V2 交易对
        assert(amount0 == 0 || amount1 == 0); // 该策略是单向的
        path[0] = amount0 == 0 ? token0 : token1;
        path[1] = amount0 == 0 ? token1 : token0;
        amountToken = token0 == address(WETH) ? amount1 : amount0;
        amountETH = token0 == address(WETH) ? amount0 : amount1;
        }

        assert(path[0] == address(WETH) || path[1] == address(WETH)); // 该策略仅适用于包含 WETH 的 V2 交易对
        IERC20 token = IERC20(path[0] == address(WETH) ? path[1] : path[0]);
        IUniswapV1Exchange exchangeV1 = IUniswapV1Exchange(factoryV1.getExchange(address(token))); // 获取 V1 exchange

        if (amountToken > 0) {
            (uint minETH) = abi.decode(data, (uint)); // V1 的滑点参数，由调用者传入
            token.approve(address(exchangeV1), amountToken);
            uint amountReceived = exchangeV1.tokenToEthSwapInput(amountToken, minETH, uint(-1));
            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountToken, path)[0];
            assert(amountReceived > amountRequired); // 如果换回的 ETH 不足以偿还闪电贷则失败
            WETH.deposit{value: amountRequired}();
            assert(WETH.transfer(msg.sender, amountRequired)); // 将 WETH 归还给 V2 交易对
            (bool success,) = sender.call{value: amountReceived - amountRequired}(new bytes(0)); // 剩下的归自己！（ETH）
            assert(success);
        } else {
            (uint minTokens) = abi.decode(data, (uint)); // V1 的滑点参数，由调用者传入
            WETH.withdraw(amountETH);
            uint amountReceived = exchangeV1.ethToTokenSwapInput{value: amountETH}(minTokens, uint(-1));
            uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountETH, path)[0];
            assert(amountReceived > amountRequired); // 如果换回的代币不足以偿还闪电贷则失败
            assert(token.transfer(msg.sender, amountRequired)); // 将代币归还给 V2 交易对
            assert(token.transfer(sender, amountReceived - amountRequired)); // 剩下的归自己！（代币）
        }
    }
}
