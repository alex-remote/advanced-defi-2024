// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/StdCheats.sol";
import "../src/Test.sol";
import "../src/StdJson.sol";
import "../src/StdToml.sol";
import "../src/interfaces/IERC20.sol";

contract StdCheatsTest is Test {
    Bar test;

    using stdJson for string;

    function setUp() public {
        test = new Bar();
    }

    function test_Skip() public {
        vm.warp(100);
        skip(25);
        assertEq(block.timestamp, 125);
    }

    function test_Rewind() public {
        vm.warp(100);
        rewind(25);
        assertEq(block.timestamp, 75);
    }

    function test_Hoax() public {
        hoax(address(1337));
        test.bar{value: 100}(address(1337));
    }

    function test_HoaxOrigin() public {
        hoax(address(1337), address(1337));
        test.origin{value: 100}(address(1337));
    }

    function test_HoaxDifferentAddresses() public {
        hoax(address(1337), address(7331));
        test.origin{value: 100}(address(1337), address(7331));
    }

    function test_StartHoax() public {
        startHoax(address(1337));
        test.bar{value: 100}(address(1337));
        test.bar{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }

    function test_StartHoaxOrigin() public {
        startHoax(address(1337), address(1337));
        test.origin{value: 100}(address(1337));
        test.origin{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }

    function test_ChangePrankMsgSender() public {
        vm.startPrank(address(1337));
        test.bar(address(1337));
        changePrank(address(0xdead));
        test.bar(address(0xdead));
        changePrank(address(1337));
        test.bar(address(1337));
        vm.stopPrank();
    }

    function test_ChangePrankMsgSenderAndTxOrigin() public {
        vm.startPrank(address(1337), address(1338));
        test.origin(address(1337), address(1338));
        changePrank(address(0xdead), address(0xbeef));
        test.origin(address(0xdead), address(0xbeef));
        changePrank(address(1337), address(1338));
        test.origin(address(1337), address(1338));
        vm.stopPrank();
    }

    function test_MakeAccountEquivalence() public {
        Account memory account = makeAccount("1337");
        (address addr, uint256 key) = makeAddrAndKey("1337");
        assertEq(account.addr, addr);
        assertEq(account.key, key);
    }

    function test_MakeAddrEquivalence() public {
        (address addr,) = makeAddrAndKey("1337");
        assertEq(makeAddr("1337"), addr);
    }

    function test_MakeAddrSigning() public {
        (address addr, uint256 key) = makeAddrAndKey("1337");
        bytes32 hash = keccak256("some_message");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, hash);
        assertEq(ecrecover(hash, v, r, s), addr);
    }

    function test_Deal() public {
        deal(address(this), 1 ether);
        assertEq(address(this).balance, 1 ether);
    }

    function test_DealToken() public {
        Bar barToken = new Bar();
        address bar = address(barToken);
        deal(bar, address(this), 10000e18);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
    }

    function test_DealTokenAdjustTotalSupply() public {
        Bar barToken = new Bar();
        address bar = address(barToken);
        deal(bar, address(this), 10000e18, true);
        assertEq(barToken.balanceOf(address(this)), 10000e18);
        assertEq(barToken.totalSupply(), 20000e18);
        deal(bar, address(this), 0, true);
        assertEq(barToken.balanceOf(address(this)), 0);
        assertEq(barToken.totalSupply(), 10000e18);
    }

    function test_DealERC1155Token() public {
        BarERC1155 barToken = new BarERC1155();
        address bar = address(barToken);
        dealERC1155(bar, address(this), 0, 10000e18, false);
        assertEq(barToken.balanceOf(address(this), 0), 10000e18);
    }

    function test_DealERC1155TokenAdjustTotalSupply() public {
        BarERC1155 barToken = new BarERC1155();
        address bar = address(barToken);
        dealERC1155(bar, address(this), 0, 10000e18, true);
        assertEq(barToken.balanceOf(address(this), 0), 10000e18);
        assertEq(barToken.totalSupply(0), 20000e18);
        dealERC1155(bar, address(this), 0, 0, true);
        assertEq(barToken.balanceOf(address(this), 0), 0);
        assertEq(barToken.totalSupply(0), 10000e18);
    }

    function test_DealERC721Token() public {
        BarERC721 barToken = new BarERC721();
        address bar = address(barToken);
        dealERC721(bar, address(2), 1);
        assertEq(barToken.balanceOf(address(2)), 1);
        assertEq(barToken.balanceOf(address(1)), 0);
        dealERC721(bar, address(1), 2);
        assertEq(barToken.balanceOf(address(1)), 1);
        assertEq(barToken.balanceOf(bar), 1);
    }

    function test_DeployCode() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", bytes(""));
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
    }

    function test_DestroyAccount() public {
        // 部署一个合约，以便随后销毁它
        BarERC721 barToken = new BarERC721();
        address bar = address(barToken);
        vm.setNonce(bar, 10);
        deal(bar, 100);

        uint256 prevThisBalance = address(this).balance;
        uint256 size;
        assembly {
            size := extcodesize(bar)
        }

        assertGt(size, 0);
        assertEq(bar.balance, 100);
        assertEq(vm.getNonce(bar), 10);

        destroyAccount(bar, address(this));
        assembly {
            size := extcodesize(bar)
        }
        assertEq(address(this).balance, prevThisBalance + 100);
        assertEq(vm.getNonce(bar), 0);
        assertEq(size, 0);
        assertEq(bar.balance, 0);
    }

    function test_DeployCodeNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:Bar");
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
    }

    function test_DeployCodeVal() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", bytes(""), 1 ether);
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
        assertEq(deployed.balance, 1 ether);
    }

    function test_DeployCodeValNoArgs() public {
        address deployed = deployCode("StdCheats.t.sol:Bar", 1 ether);
        assertEq(string(getCode(deployed)), string(getCode(address(test))));
        assertEq(deployed.balance, 1 ether);
    }

    // 需要这个函数，这样我们才能调用 "this.deployCode" 而不是直接调用 "deployCode"
    function deployCodeHelper(string memory what) external {
        deployCode(what);
    }

    function test_DeployCodeFail() public {
        vm.expectRevert(bytes("StdCheats deployCode(string): Deployment failed."));
        this.deployCodeHelper("StdCheats.t.sol:RevertingContract");
    }

    function getCode(address who) internal view returns (bytes memory o_code) {
        /// @solidity memory-safe-assembly
        assembly {
            // 获取代码大小，这需要用到 assembly
            let size := extcodesize(who)
            // 分配输出字节数组——这一步也可以不用 assembly 完成
            // 即使用 o_code = new bytes(size)
            o_code := mload(0x40)
            // 包含填充在内的新 "memory end"（内存末尾）
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // 将长度存入 memory
            mstore(o_code, size)
            // 真正获取代码，这需要用到 assembly
            extcodecopy(who, add(o_code, 0x20), 0, size)
        }
    }

    function test_DeriveRememberKey() public {
        string memory mnemonic = "test test test test test test test test test test test junk";

        (address deployer, uint256 privateKey) = deriveRememberKey(mnemonic, 0);
        assertEq(deployer, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(privateKey, 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    }

    function test_BytesToUint() public pure {
        assertEq(3, bytesToUint_test(hex"03"));
        assertEq(2, bytesToUint_test(hex"02"));
        assertEq(255, bytesToUint_test(hex"ff"));
        assertEq(29625, bytesToUint_test(hex"73b9"));
    }

    function test_ParseJsonTxDetail() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        string memory json = vm.readFile(path);
        bytes memory transactionDetails = json.parseRaw(".transactions[0].tx");
        RawTx1559Detail memory rawTxDetail = abi.decode(transactionDetails, (RawTx1559Detail));
        Tx1559Detail memory txDetail = rawToConvertedEIP1559Detail(rawTxDetail);
        assertEq(txDetail.from, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        assertEq(txDetail.to, 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        assertEq(
            txDetail.data,
            hex"23e99187000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000013370000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000004"
        );
        assertEq(txDetail.nonce, 3);
        assertEq(txDetail.txType, 2);
        assertEq(txDetail.gas, 29625);
        assertEq(txDetail.value, 0);
    }

    function test_ReadEIP1559Transaction() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        uint256 index = 0;
        Tx1559 memory transaction = readTx1559(path, index);
        transaction;
    }

    function test_ReadEIP1559Transactions() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        Tx1559[] memory transactions = readTx1559s(path);
        transactions;
    }

    function test_ReadReceipt() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        uint256 index = 5;
        Receipt memory receipt = readReceipt(path, index);
        assertEq(
            receipt.logsBloom,
            hex"00000000000800000000000000000010000000000000000000000000000180000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100"
        );
    }

    function test_ReadReceipts() public view {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/broadcast.log.json");
        Receipt[] memory receipts = readReceipts(path);
        receipts;
    }

    function test_GasMeteringModifier() public {
        uint256 gas_start_normal = gasleft();
        addInLoop();
        uint256 gas_used_normal = gas_start_normal - gasleft();

        uint256 gas_start_single = gasleft();
        addInLoopNoGas();
        uint256 gas_used_single = gas_start_single - gasleft();

        uint256 gas_start_double = gasleft();
        addInLoopNoGasNoGas();
        uint256 gas_used_double = gas_start_double - gasleft();

        assertTrue(gas_used_double + gas_used_single < gas_used_normal);
    }

    function addInLoop() internal pure returns (uint256) {
        uint256 b;
        for (uint256 i; i < 10000; i++) {
            b += i;
        }
        return b;
    }

    function addInLoopNoGas() internal noGasMetering returns (uint256) {
        return addInLoop();
    }

    function addInLoopNoGasNoGas() internal noGasMetering returns (uint256) {
        return addInLoopNoGas();
    }

    function bytesToUint_test(bytes memory b) private pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number + uint256(uint8(b[i])) * (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }

    function testFuzz_AssumeAddressIsNot(address addr) external {
        // 跳过 Payable 和 NonPayable 两个枚举值
        for (uint8 i = 2; i < uint8(type(AddressType).max); i++) {
            assumeAddressIsNot(addr, AddressType(i));
        }
        assertTrue(addr != address(0));
        assertTrue(addr < address(1) || addr > address(9));
        assertTrue(addr != address(vm) || addr != 0x000000000000000000636F6e736F6c652e6c6f67);
    }

    function test_AssumePayable() external {
        // 我们部署一个 mock 版本，以便正确测试 revert。
        StdCheatsMock stdCheatsMock = new StdCheatsMock();

        // 以下调用都应 revert，因为这些地址不是 payable 的

        // VM 地址
        vm.expectRevert();
        stdCheatsMock.exposed_assumePayable(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        // Console 地址
        vm.expectRevert();
        stdCheatsMock.exposed_assumePayable(0x000000000000000000636F6e736F6c652e6c6f67);

        // Create2Deployer 地址
        vm.expectRevert();
        stdCheatsMock.exposed_assumePayable(0x4e59b44847b379578588920cA78FbF26c0B4956C);

        // 以下调用都应通过，因为这些地址是 payable 的

        // vitalik.eth 地址
        stdCheatsMock.exposed_assumePayable(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);

        // mock 的 payable 合约
        MockContractPayable cp = new MockContractPayable();
        stdCheatsMock.exposed_assumePayable(address(cp));
    }

    function test_AssumeNotPayable() external {
        // 我们部署一个 mock 版本，以便正确测试 revert。
        StdCheatsMock stdCheatsMock = new StdCheatsMock();

        // 以下调用都应通过，因为这些地址不是 payable 的

        // VM 地址
        stdCheatsMock.exposed_assumeNotPayable(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        // Console 地址
        stdCheatsMock.exposed_assumeNotPayable(0x000000000000000000636F6e736F6c652e6c6f67);

        // Create2Deployer 地址
        stdCheatsMock.exposed_assumeNotPayable(0x4e59b44847b379578588920cA78FbF26c0B4956C);

        // 以下调用都应 revert，因为这些地址是 payable 的

        // vitalik.eth 地址
        vm.expectRevert();
        stdCheatsMock.exposed_assumeNotPayable(0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045);

        // mock 的 payable 合约
        MockContractPayable cp = new MockContractPayable();
        vm.expectRevert();
        stdCheatsMock.exposed_assumeNotPayable(address(cp));
    }

    function testFuzz_AssumeNotPrecompile(address addr) external {
        assumeNotPrecompile(addr, getChain("optimism_goerli").chainId);
        assertTrue(
            addr < address(1) || (addr > address(9) && addr < address(0x4200000000000000000000000000000000000000))
                || addr > address(0x4200000000000000000000000000000000000800)
        );
    }

    function testFuzz_AssumeNotForgeAddress(address addr) external pure {
        assumeNotForgeAddress(addr);
        assertTrue(
            addr != address(vm) && addr != 0x000000000000000000636F6e736F6c652e6c6f67
                && addr != 0x4e59b44847b379578588920cA78FbF26c0B4956C
        );
    }

    function test_CannotDeployCodeTo() external {
        vm.expectRevert("StdCheats deployCodeTo(string,bytes,uint256,address): Failed to create runtime bytecode.");
        this._revertDeployCodeTo();
    }

    function _revertDeployCodeTo() external {
        deployCodeTo("StdCheats.t.sol:RevertingContract", address(0));
    }

    function test_DeployCodeTo() external {
        address arbitraryAddress = makeAddr("arbitraryAddress");

        deployCodeTo(
            "StdCheats.t.sol:MockContractWithConstructorArgs",
            abi.encode(uint256(6), true, bytes20(arbitraryAddress)),
            1 ether,
            arbitraryAddress
        );

        MockContractWithConstructorArgs ct = MockContractWithConstructorArgs(arbitraryAddress);

        assertEq(arbitraryAddress.balance, 1 ether);
        assertEq(ct.x(), 6);
        assertTrue(ct.y());
        assertEq(ct.z(), bytes20(arbitraryAddress));
    }
}

contract StdCheatsMock is StdCheats {
    function exposed_assumePayable(address addr) external {
        assumePayable(addr);
    }

    function exposed_assumeNotPayable(address addr) external {
        assumeNotPayable(addr);
    }

    // 我们部署一个 mock 版本，以便正确测试预期的 revert。
    function exposed_assumeNotBlacklisted(address token, address addr) external view {
        return assumeNotBlacklisted(token, addr);
    }
}

contract StdCheatsForkTest is Test {
    address internal constant SHIB = 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDC_BLACKLISTED_USER = 0x1E34A77868E19A6647b1f2F47B51ed72dEDE95DD;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant USDT_BLACKLISTED_USER = 0x8f8a8F4B54a2aAC7799d7bc81368aC27b852822A;

    function setUp() public {
        // `assumeNotBlacklisted` 方法的所有测试都是使用线上真实合约的 fork 测试。
        vm.createSelectFork({urlOrAlias: "mainnet", blockNumber: 16_428_900});
    }

    function test_CannotAssumeNoBlacklisted_EOA() external {
        // 我们部署一个 mock 版本，以便正确测试 revert。
        StdCheatsMock stdCheatsMock = new StdCheatsMock();
        address eoa = vm.addr({privateKey: 1});
        vm.expectRevert("StdCheats assumeNotBlacklisted(address,address): Token address is not a contract.");
        stdCheatsMock.exposed_assumeNotBlacklisted(eoa, address(0));
    }

    function testFuzz_AssumeNotBlacklisted_TokenWithoutBlacklist(address addr) external view {
        assumeNotBlacklisted(SHIB, addr);
        assertTrue(true);
    }

    function test_AssumeNoBlacklisted_USDC() external {
        // 我们部署一个 mock 版本，以便正确测试 revert。
        StdCheatsMock stdCheatsMock = new StdCheatsMock();
        vm.expectRevert();
        stdCheatsMock.exposed_assumeNotBlacklisted(USDC, USDC_BLACKLISTED_USER);
    }

    function testFuzz_AssumeNotBlacklisted_USDC(address addr) external view {
        assumeNotBlacklisted(USDC, addr);
        assertFalse(USDCLike(USDC).isBlacklisted(addr));
    }

    function test_AssumeNoBlacklisted_USDT() external {
        // 我们部署一个 mock 版本，以便正确测试 revert。
        StdCheatsMock stdCheatsMock = new StdCheatsMock();
        vm.expectRevert();
        stdCheatsMock.exposed_assumeNotBlacklisted(USDT, USDT_BLACKLISTED_USER);
    }

    function testFuzz_AssumeNotBlacklisted_USDT(address addr) external view {
        assumeNotBlacklisted(USDT, addr);
        assertFalse(USDTLike(USDT).isBlackListed(addr));
    }

    function test_dealUSDC() external {
        // 将 fork 回滚到 USDC 合约升级为在打包存储槽中存储余额的时间点
        vm.rollFork(19279215);

        uint256 balance = 100e6;
        deal(USDC, address(this), balance);
        assertEq(IERC20(USDC).balanceOf(address(this)), balance);
    }
}

contract Bar {
    constructor() payable {
        /// 供 `DEAL` STDCHEAT 测试使用
        totalSupply = 10000e18;
        balanceOf[address(this)] = totalSupply;
    }

    /// 供 `HOAX` 和 `CHANGEPRANK` STDCHEATS 测试使用
    function bar(address expectedSender) public payable {
        require(msg.sender == expectedSender, "!prank");
    }

    function origin(address expectedSender) public payable {
        require(msg.sender == expectedSender, "!prank");
        require(tx.origin == expectedSender, "!prank");
    }

    function origin(address expectedSender, address expectedOrigin) public payable {
        require(msg.sender == expectedSender, "!prank");
        require(tx.origin == expectedOrigin, "!prank");
    }

    /// 供 `DEAL` STDCHEAT 测试使用
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;
}

contract BarERC1155 {
    constructor() payable {
        /// 供 `DEALERC1155` STDCHEAT 测试使用
        _totalSupply[0] = 10000e18;
        _balances[0][address(this)] = _totalSupply[0];
    }

    function balanceOf(address account, uint256 id) public view virtual returns (uint256) {
        return _balances[id][account];
    }

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /// 供 `DEALERC1155` STDCHEAT 测试使用
    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(uint256 => uint256) private _totalSupply;
}

contract BarERC721 {
    constructor() payable {
        /// 供 `DEALERC721` STDCHEAT 测试使用
        _owners[1] = address(1);
        _balances[address(1)] = 1;
        _owners[2] = address(this);
        _owners[3] = address(this);
        _balances[address(this)] = 2;
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        address owner = _owners[tokenId];
        return owner;
    }

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
}

interface USDCLike {
    function isBlacklisted(address) external view returns (bool);
}

interface USDTLike {
    function isBlackListed(address) external view returns (bool);
}

contract RevertingContract {
    constructor() {
        revert();
    }
}

contract MockContractWithConstructorArgs {
    uint256 public immutable x;
    bool public y;
    bytes20 public z;

    constructor(uint256 _x, bool _y, bytes20 _z) payable {
        x = _x;
        y = _y;
        z = _z;
    }
}

contract MockContractPayable {
    receive() external payable {}
}
