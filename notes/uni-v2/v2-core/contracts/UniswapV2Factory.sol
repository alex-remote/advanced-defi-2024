pragma solidity =0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        // 注意：按地址对代币排序
        // address <-> 20 字节十六进制数 <-> 160 位整数
        // 0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97 <-> 412311598482915581890913355723629879470649597847
        // address(1), address(2)
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // 只检查一个方向就足够了
        // 注意：创建代码（creation code）= 运行时代码（runtime code）+ 构造函数参数
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        // 注意：使用 create2 部署 - 参见 UniswapV2Library.pairFor
        // 注意：create2 地址 <- keccak256(创建字节码) <- 构造函数参数
        // create2 地址 = keccak256(0xff, deployer, salt, keccak256(创建字节码))
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            // 注意：pair = address(new UniswapV2Pair{salt: salt}());
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        // 注意：调用 initialize 来初始化合约，从而无需构造函数参数
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // 同时填充反方向的映射
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
