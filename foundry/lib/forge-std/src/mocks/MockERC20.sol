// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import {IERC20} from "../interfaces/IERC20.sol";

/// @notice 这是 ERC20 标准的模拟（mock）合约，仅用于测试，不应当用于生产环境。
/// @dev Fork 自：https://github.com/transmissions11/solmate/blob/0384dbaaa4fcb5715738a9254a7c0a4cb62cf458/src/tokens/ERC20.sol
contract MockERC20 is IERC20 {
    /*//////////////////////////////////////////////////////////////
                            元数据存储
    //////////////////////////////////////////////////////////////*/

    string internal _name;

    string internal _symbol;

    uint8 internal _decimals;

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC20 存储
    //////////////////////////////////////////////////////////////*/

    uint256 internal _totalSupply;

    mapping(address => uint256) internal _balanceOf;

    mapping(address => mapping(address => uint256)) internal _allowance;

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return _balanceOf[owner];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowance[owner][spender];
    }

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 存储
    //////////////////////////////////////////////////////////////*/

    uint256 internal INITIAL_CHAIN_ID;

    bytes32 internal INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               初始化
    //////////////////////////////////////////////////////////////*/

    /// @dev 用于记录合约是否已初始化的布尔值。
    bool private initialized;

    /// @dev 由于不同 solc 版本对构造函数可见性的要求和语法各不相同，为了屏蔽各版本下的构造函数警告，
    /// 我们添加了一个只能调用一次的初始化函数。
    function initialize(string memory name_, string memory symbol_, uint8 decimals_) public {
        require(!initialized, "ALREADY_INITIALIZED");

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        INITIAL_CHAIN_ID = _pureChainId();
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();

        initialized = true;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 逻辑
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _balanceOf[msg.sender] = _sub(_balanceOf[msg.sender], amount);
        _balanceOf[to] = _add(_balanceOf[to], amount);

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        uint256 allowed = _allowance[from][msg.sender]; // 为有限额度的授权节省 gas。

        if (allowed != ~uint256(0)) _allowance[from][msg.sender] = _sub(allowed, amount);

        _balanceOf[from] = _sub(_balanceOf[from], amount);
        _balanceOf[to] = _add(_balanceOf[to], amount);

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 逻辑
    //////////////////////////////////////////////////////////////*/

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        public
        virtual
    {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        address recoveredAddress = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            ),
            v,
            r,
            s
        );

        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

        _allowance[recoveredAddress][spender] = value;

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return _pureChainId() == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256("1"),
                _pureChainId(),
                address(this)
            )
        );
    }

    /*//////////////////////////////////////////////////////////////
                        内部铸造/销毁逻辑
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        _totalSupply = _add(_totalSupply, amount);
        _balanceOf[to] = _add(_balanceOf[to], amount);

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        _balanceOf[from] = _sub(_balanceOf[from], amount);
        _totalSupply = _sub(_totalSupply, amount);

        emit Transfer(from, address(0), amount);
    }

    /*//////////////////////////////////////////////////////////////
                        内部安全数学运算逻辑
    //////////////////////////////////////////////////////////////*/

    function _add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ERC20: addition overflow");
        return c;
    }

    function _sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "ERC20: subtraction underflow");
        return a - b;
    }

    /*//////////////////////////////////////////////////////////////
                                辅助函数
    //////////////////////////////////////////////////////////////*/

    // 我们采用 `_viewChainId` 与 `_pureChainId` 这种复杂的方式，是为了确保在 forge-std
    // 支持的任何 solidity 版本中访问 chain ID 时都不会出现编译器警告。我们
    // 不能简单地在普通的 view 或 pure 函数中访问 chain ID，因为 solc 的 View Pure
    // Checker 在 0.8.0 中把 `chainid` 从 pure 改成了 view。
    function _viewChainId() private view returns (uint256 chainId) {
        // 由于 `block.chainid` 是在 0.8.0 中才引入的，这里需要使用内联汇编。
        assembly {
            chainId := chainid()
        }

        address(this); // 消除旧版 Solc 中的警告。
    }

    function _pureChainId() private pure returns (uint256 chainId) {
        function() internal view returns (uint256) fnIn = _viewChainId;
        function() internal pure returns (uint256) pureChainId;
        assembly {
            pureChainId := fnIn
        }
        chainId = pureChainId();
    }
}
