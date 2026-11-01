// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice 将 `amountIn` 数量的一种代币兑换为尽可能多的另一种代币
    /// @return amountOut 收到的代币数量
    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice 沿指定路径将 `amountIn` 数量的一种代币兑换为尽可能多的另一种代币
    /// @return amountOut 收到的代币数量
    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice 用尽可能少的一种代币兑换 `amountOut` 数量的另一种代币
    /// @return amountIn 输入代币的数量
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice 沿指定路径（反向）用尽可能少的一种代币兑换 `amountOut` 数量的另一种代币
    /// @return amountIn 输入代币的数量
    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}
