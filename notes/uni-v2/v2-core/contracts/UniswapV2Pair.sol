pragma solidity =0.5.16;

import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2ERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Callee.sol';

contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // 共用一个存储槽，可通过 getReserves 访问
    uint112 private reserve1;           // 共用一个存储槽，可通过 getReserves 访问
    uint32  private blockTimestampLast; // 共用一个存储槽，可通过 getReserves 访问

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1，取最近一次流动性事件刚结束时的值

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = msg.sender;
    }

    // 部署时由 factory 调用一次
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // 这一检查已足够
        token0 = _token0;
        token1 = _token1;
    }

    // 更新储备量，并在每个区块的首次调用时更新价格累加器
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // 有意允许上溢
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // 注意：TWAP - 时间加权平均价格
            // * 永远不会上溢，而 + 有意允许上溢
            //                                                       224 位              32 位 = 256 位
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // 如果开启了手续费，则铸造相当于 sqrt(k) 增长量 1/6 的流动性
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        // 注意：在添加 / 移除流动性时才铸造手续费，以节省兑换时的 gas
        // 注意：目前在 ETH 主网上未开启
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // 节省 gas
        if (feeOn) {
            if (_kLast != 0) {
                // 注意：xy = k = L^2，所以 sqrt(xy) = sqrt(k) = L
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                // 注意：L1 > L0
                if (rootK > rootKLast) {
                    // T * (L1 - L0)
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    // L1 * 5 + L0
                    uint denominator = rootK.mul(5).add(rootKLast);
                    // 注意：获取兑换手续费中 1 / 6 的数学推导
                    //        L1 - L0
                    // s = ------------- * T
                    //     5 * L1 + L0 
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // 这个底层函数应当由执行了重要安全检查的合约来调用
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // 节省 gas
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        // 注意：转入数量通过与内部余额作差计算得出
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // 节省 gas；必须在此处定义，因为 totalSupply 可能在 _mintFee 中被更新
        if (_totalSupply == 0) {
            // 注意：池子价值函数 f(x, y) = sqrt(xy) = L
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            // 注意：防御金库通胀攻击（vault inflation attack）
           _mint(address(0), MINIMUM_LIQUIDITY); // 永久锁定最初的 MINIMUM_LIQUIDITY 个代币
        } else {
            // 注意：s = min(dx * T / x0, dy * T / y0)
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        // 注意：用于协议手续费，xy = L^2 或 xy = k
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 和 reserve1 已是最新值
        emit Mint(msg.sender, amount0, amount1);
    }

    // 这个底层函数应当由执行了重要安全检查的合约来调用
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // 节省 gas
        address _token0 = token0;                                // 节省 gas
        address _token1 = token1;                                // 节省 gas
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        // 注意：从本合约中销毁
        uint liquidity = balanceOf[address(this)];

        // 注意：协议手续费
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // 节省 gas；必须在此处定义，因为 totalSupply 可能在 _mintFee 中被更新
        // 注意：
        // dx = s * x0 / T
        // dy = s * y0 / T
        amount0 = liquidity.mul(balance0) / _totalSupply; // 使用余额可确保按比例分配
        amount1 = liquidity.mul(balance1) / _totalSupply; // 使用余额可确保按比例分配
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 和 reserve1 已是最新值
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // 这个底层函数应当由执行了重要安全检查的合约来调用
    // 注意：参数中没有输入数量
    // 注意：data 用于闪电兑换（flash swap）
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        // 注意：代币的内部余额
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // 节省 gas
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        // 注意：stack too deep（栈过深）问题
        { // _token{0,1} 的作用域，避免 stack too deep 错误
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        // 注意：先转出
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // 乐观地转出代币
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // 乐观地转出代币
        // 注意：msg.sender 可以执行位于 to 地址的合约
        if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        // 注意：计算转入数量
        // 实际余额 - (内部余额 - 转出数量)
        // 实际余额 = 转账前的实际余额 - 转出数量
        // 实际余额 > 新的内部余额 ? 余额增加了 -> 转入数量 > 0 : 0
        // 注意：示例
        // 转入 = token 0，转出 = token 1
        // amount0Out = 0
        // amount1Out = 100
        // 转入数量 = 10 个 token 0
        // balance0 = 1010 
        // reserve0 = 1000
        //                1010       1000     -  0           1010     - (1000 - 0) = 10
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // reserve{0,1}Adjusted 的作用域，避免 stack too deep 错误
        // 注意：
        // amount0In = 0 -> balance0Adjusted = balance0
        // amount0In > 0 -> balance0Adjusted = balance0 * 1000 - 3 * amount0In
        // balance0Adjusted / 1000 = balance0 - 3 / 1000 * amountIn
        // balance0Adjusted = balance0 * 1000 - amount0In * 3
        // balance0Adjusted / 1000 = balance0 - amount0In * 3 / 1000
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        // 注意：
        // (x0 + dx * (1- f))(y0 - dy) >= x0 * y0
        // balance0Adjusted / 1000 * balance1Adjusted / 1000 = 
        // balance 0 adjusted * balance 1 adjusted
        // --------------------------------------- >= reserve 0 * reserve 1
        //               1000 ** 2
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // 强制让余额与储备量一致
    function skim(address to) external lock {
        address _token0 = token0; // 节省 gas
        address _token1 = token1; // 节省 gas
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // 强制让储备量与余额一致
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}
