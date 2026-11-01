// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";

error InvalidToken();

contract UniswapV2FlashSwap {
    IUniswapV2Pair private immutable pair;
    address private immutable token0;
    address private immutable token1;

    constructor(address _pair) {
        pair = IUniswapV2Pair(_pair);
        token0 = pair.token0();
        token1 = pair.token1();
    }

    function flashSwap(address token, uint256 amount) external {
        if (token != token0 && token != token1) {
            revert InvalidToken();
        }

        // 在此编写你的代码
        // 不要修改其他任何代码

        // 1. 确定 amount0Out 和 amount1Out
        (uint256 amount0Out, uint256 amount1Out) = (0, 0);

        // 2. 将 token 和 msg.sender 编码为 bytes
        bytes memory data;

        // 3. 调用 pair.swap
    }

    // Uniswap V2 回调
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        // 在此编写你的代码
        // 不要修改其他任何代码

        // 1. 要求 msg.sender 是 pair 合约
        // 2. 要求 sender 是本合约
        // Alice -> FlashSwap ---- to = FlashSwap ----> UniswapV2Pair
        //                    <-- sender = FlashSwap --
        // Eve ------------ to = FlashSwap -----------> UniswapV2Pair
        //          FlashSwap <-- sender = Eve --------

        // 3. 从 data 中解码 token 和 caller
        (address token, address caller) = (address(0), address(0));
        // 4. 确定借入的数量（两者中只有一个 > 0）
        uint256 amount = 0;

        // 5. 计算闪电兑换手续费和需要偿还的数量
        // fee = 借入数量 * 3 / 997 + 1（加 1 以向上取整）
        uint256 fee = 0;
        uint256 amountToRepay = 0;

        // 6. 从 caller 处收取闪电兑换手续费
        // 7. 向 Uniswap V2 交易对还款
    }
}
