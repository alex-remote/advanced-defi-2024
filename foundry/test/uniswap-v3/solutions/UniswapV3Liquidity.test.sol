// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {IWETH} from "../../../src/interfaces/IWETH.sol";
import {INonfungiblePositionManager} from
    "../../../src/interfaces/uniswap-v3/INonfungiblePositionManager.sol";
import {
    UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER,
    DAI,
    WETH
} from "../../../src/Constants.sol";

struct Position {
    uint96 nonce;
    address operator;
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint128 liquidity;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
}

contract UniswapV3LiquidityTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    INonfungiblePositionManager private constant manager =
        INonfungiblePositionManager(UNISWAP_V3_NONFUNGIBLE_POSITION_MANAGER);

    // 0.3%
    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = 887272;
    // DAI/WETH 池子，手续费档位 3000
    uint24 private constant POOL_FEE = 3000;
    int24 private constant TICK_SPACING = 60;

    function setUp() public {
        deal(DAI, address(this), 3000 * 1e18);
        deal(WETH, address(this), 3 * 1e18);

        weth.approve(address(manager), type(uint256).max);
        dai.approve(address(manager), type(uint256).max);
    }

    function mint() private returns (uint256 tokenId) {
        (tokenId,,,) = manager.mint(
            INonfungiblePositionManager.MintParams({
                token0: DAI,
                token1: WETH,
                fee: POOL_FEE,
                tickLower: MIN_TICK / TICK_SPACING * TICK_SPACING,
                tickUpper: MAX_TICK / TICK_SPACING * TICK_SPACING,
                amount0Desired: 1000 * 1e18,
                amount1Desired: 1e18,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );
    }

    function getPosition(uint256 tokenId)
        private
        view
        returns (Position memory)
    {
        (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = manager.positions(tokenId);

        Position memory position = Position({
            nonce: nonce,
            operator: operator,
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidity: liquidity,
            feeGrowthInside0LastX128: feeGrowthInside0LastX128,
            feeGrowthInside1LastX128: feeGrowthInside1LastX128,
            tokensOwed0: tokensOwed0,
            tokensOwed1: tokensOwed1
        });

        return position;
    }

    // 练习 1
    // 向手续费为 0.3% 的 DAI/WETH 池子添加流动性，铸造一个新的头寸（position）。
    // - 可以自由选择价格区间
    // - tick 必须能被池子的 tick 间距（tick spacing）整除
    // - 本测试合约已获得 3000 DAI 和 3 WETH。可投入任意数量的代币，
    //   只要不超过本合约的余额即可。
    // - 将 NFT（代表该头寸的所有权）的接收者设置为本合约。
    function test_mint() public {
        // 在此编写你的代码
        int24 tickLower = MIN_TICK / TICK_SPACING * TICK_SPACING;
        int24 tickUpper = MAX_TICK / TICK_SPACING * TICK_SPACING;

        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) =
        manager.mint(
            INonfungiblePositionManager.MintParams({
                token0: DAI,
                token1: WETH,
                fee: POOL_FEE,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: 1000 * 1e18,
                amount1Desired: 1e18,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );

        console2.log("Amount 0 added %e", amount0);
        console2.log("Amount 1 added %e", amount1);

        assertEq(manager.ownerOf(tokenId), address(this));

        Position memory position = getPosition(tokenId);
        assertEq(position.token0, DAI);
        assertEq(position.token1, WETH);
        assertGt(position.liquidity, 0);
    }

    // 练习 2
    // 为 token id = `tokenId` 的头寸增加流动性。
    // 本合约最初获得了 3000 DAI 和 3 WETH。
    // 其中部分代币已用于铸造新的头寸。
    // 可使用任意不超过合约余额的代币数量。
    function test_increaseLiquidity() public {
        uint256 tokenId = mint();
        Position memory p0 = getPosition(tokenId);

        // 在此编写你的代码
        (uint256 liquidityDelta, uint256 amount0, uint256 amount1) = manager
            .increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: 500 * 1e18,
                amount1Desired: 1e18,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        console2.log("Amount 0 added %e", amount0);
        console2.log("Amount 1 added %e", amount1);

        Position memory p1 = getPosition(tokenId);
        assertGt(p1.liquidity, p0.liquidity);
        assertGt(liquidityDelta, 0);
    }

    // 练习 3
    // 为 token id = `tokenId` 的头寸减少流动性。
    // - 减少的流动性数量不能超过该头寸的流动性。
    function test_decreaseLiquidity() public {
        uint256 tokenId = mint();
        Position memory p0 = getPosition(tokenId);

        // 在此编写你的代码
        (uint256 amount0, uint256 amount1) = manager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: p0.liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        console2.log("Amount 0 decreased %e", amount0);
        console2.log("Amount 1 decreased %e", amount1);

        Position memory p1 = getPosition(tokenId);
        assertEq(p1.liquidity, 0);
        assertGt(p1.tokensOwed0, 0);
        assertGt(p1.tokensOwed1, 0);
    }

    // 练习 4
    // 通过调用 collect() 从头寸中移除全部流动性（包括手续费）
    // - 减少 token id = `tokenId` 的头寸的全部流动性
    // - 将代币从 NonFungiblePositionManager 转入本合约，
    //   方法是调用 collect()
    function test_collect() public {
        uint256 tokenId = mint();
        Position memory p0 = getPosition(tokenId);

        // 在此编写你的代码
        manager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: p0.liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            })
        );

        (uint256 amount0, uint256 amount1) = manager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        console2.log("--- collect ---");
        console2.log("Amount 0 collected %e", amount0);
        console2.log("Amount 1 collected %e", amount1);

        Position memory p1 = getPosition(tokenId);

        assertEq(p1.liquidity, 0);
        assertEq(p1.tokensOwed0, 0);
        assertEq(p1.tokensOwed1, 0);
    }
}
