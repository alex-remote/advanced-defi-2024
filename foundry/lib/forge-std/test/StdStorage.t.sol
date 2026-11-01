// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/StdStorage.sol";
import "../src/Test.sol";

contract StdStorageTest is Test {
    using stdStorage for StdStorage;

    StorageTest internal test;

    function setUp() public {
        test = new StorageTest();
    }

    function test_StorageHidden() public {
        assertEq(uint256(keccak256("my.random.var")), stdstore.target(address(test)).sig("hidden()").find());
    }

    function test_StorageObvious() public {
        assertEq(uint256(0), stdstore.target(address(test)).sig("exists()").find());
    }

    function test_StorageExtraSload() public {
        assertEq(16, stdstore.target(address(test)).sig(test.extra_sload.selector).find());
    }

    function test_StorageCheckedWriteHidden() public {
        stdstore.target(address(test)).sig(test.hidden.selector).checked_write(100);
        assertEq(uint256(test.hidden()), 100);
    }

    function test_StorageCheckedWriteObvious() public {
        stdstore.target(address(test)).sig(test.exists.selector).checked_write(100);
        assertEq(test.exists(), 100);
    }

    function test_StorageCheckedWriteSignedIntegerHidden() public {
        stdstore.target(address(test)).sig(test.hidden.selector).checked_write_int(-100);
        assertEq(int256(uint256(test.hidden())), -100);
    }

    function test_StorageCheckedWriteSignedIntegerObvious() public {
        stdstore.target(address(test)).sig(test.tG.selector).checked_write_int(-100);
        assertEq(test.tG(), -100);
    }

    function test_StorageMapStructA() public {
        uint256 slot =
            stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(0).find();
        assertEq(uint256(keccak256(abi.encode(address(this), 4))), slot);
    }

    function test_StorageMapStructB() public {
        uint256 slot =
            stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).find();
        assertEq(uint256(keccak256(abi.encode(address(this), 4))) + 1, slot);
    }

    function test_StorageDeepMap() public {
        uint256 slot = stdstore.target(address(test)).sig(test.deep_map.selector).with_key(address(this)).with_key(
            address(this)
        ).find();
        assertEq(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(5)))))), slot);
    }

    function test_StorageCheckedWriteDeepMap() public {
        stdstore.target(address(test)).sig(test.deep_map.selector).with_key(address(this)).with_key(address(this))
            .checked_write(100);
        assertEq(100, test.deep_map(address(this), address(this)));
    }

    function test_StorageDeepMapStructA() public {
        uint256 slot = stdstore.target(address(test)).sig(test.deep_map_struct.selector).with_key(address(this))
            .with_key(address(this)).depth(0).find();
        assertEq(
            bytes32(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(6)))))) + 0),
            bytes32(slot)
        );
    }

    function test_StorageDeepMapStructB() public {
        uint256 slot = stdstore.target(address(test)).sig(test.deep_map_struct.selector).with_key(address(this))
            .with_key(address(this)).depth(1).find();
        assertEq(
            bytes32(uint256(keccak256(abi.encode(address(this), keccak256(abi.encode(address(this), uint256(6)))))) + 1),
            bytes32(slot)
        );
    }

    function test_StorageCheckedWriteDeepMapStructA() public {
        stdstore.target(address(test)).sig(test.deep_map_struct.selector).with_key(address(this)).with_key(
            address(this)
        ).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(100, a);
        assertEq(0, b);
    }

    function test_StorageCheckedWriteDeepMapStructB() public {
        stdstore.target(address(test)).sig(test.deep_map_struct.selector).with_key(address(this)).with_key(
            address(this)
        ).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.deep_map_struct(address(this), address(this));
        assertEq(0, a);
        assertEq(100, b);
    }

    function test_StorageCheckedWriteMapStructA() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 100);
        assertEq(b, 0);
    }

    function test_StorageCheckedWriteMapStructB() public {
        stdstore.target(address(test)).sig(test.map_struct.selector).with_key(address(this)).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.map_struct(address(this));
        assertEq(a, 0);
        assertEq(b, 100);
    }

    function test_StorageStructA() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basic.selector).depth(0).find();
        assertEq(uint256(7), slot);
    }

    function test_StorageStructB() public {
        uint256 slot = stdstore.target(address(test)).sig(test.basic.selector).depth(1).find();
        assertEq(uint256(7) + 1, slot);
    }

    function test_StorageCheckedWriteStructA() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(0).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 100);
        assertEq(b, 1337);
    }

    function test_StorageCheckedWriteStructB() public {
        stdstore.target(address(test)).sig(test.basic.selector).depth(1).checked_write(100);
        (uint256 a, uint256 b) = test.basic();
        assertEq(a, 1337);
        assertEq(b, 100);
    }

    function test_StorageMapAddrFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).find();
        assertEq(uint256(keccak256(abi.encode(address(this), uint256(1)))), slot);
    }

    function test_StorageMapAddrRoot() public {
        (uint256 slot, bytes32 key) =
            stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).parent();
        assertEq(address(uint160(uint256(key))), address(this));
        assertEq(uint256(1), slot);
        slot = stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).root();
        assertEq(uint256(1), slot);
    }

    function test_StorageMapUintFound() public {
        uint256 slot = stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).find();
        assertEq(uint256(keccak256(abi.encode(100, uint256(2)))), slot);
    }

    function test_StorageCheckedWriteMapUint() public {
        stdstore.target(address(test)).sig(test.map_uint.selector).with_key(100).checked_write(100);
        assertEq(100, test.map_uint(100));
    }

    function test_StorageCheckedWriteMapAddr() public {
        stdstore.target(address(test)).sig(test.map_addr.selector).with_key(address(this)).checked_write(100);
        assertEq(100, test.map_addr(address(this)));
    }

    function test_StorageCheckedWriteMapBool() public {
        stdstore.target(address(test)).sig(test.map_bool.selector).with_key(address(this)).checked_write(true);
        assertTrue(test.map_bool(address(this)));
    }

    function testFuzz_StorageCheckedWriteMapPacked(address addr, uint128 value) public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.read_struct_lower.selector).with_key(addr)
            .checked_write(value);
        assertEq(test.read_struct_lower(addr), value);

        stdstore.enable_packed_slots().target(address(test)).sig(test.read_struct_upper.selector).with_key(addr)
            .checked_write(value);
        assertEq(test.read_struct_upper(addr), value);
    }

    function test_StorageCheckedWriteMapPackedFullSuccess() public {
        uint256 full = test.map_packed(address(1337));
        // 保留高 128 位，将低 128 位设为 1337
        full = (full & (uint256((1 << 128) - 1) << 128)) | 1337;
        stdstore.target(address(test)).sig(test.map_packed.selector).with_key(address(uint160(1337))).checked_write(
            full
        );
        assertEq(1337, test.read_struct_lower(address(1337)));
    }

    function testFail_StorageConst() public {
        // vm.expectRevert(abi.encodeWithSignature("NotStorage(bytes4)", bytes4(keccak256("const()"))));
        stdstore.target(address(test)).sig("const()").find();
    }

    function testFuzz_StorageNativePack(uint248 val1, uint248 val2, bool boolVal1, bool boolVal2) public {
        stdstore.enable_packed_slots().target(address(test)).sig(test.tA.selector).checked_write(val1);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tB.selector).checked_write(boolVal1);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tC.selector).checked_write(boolVal2);
        stdstore.enable_packed_slots().target(address(test)).sig(test.tD.selector).checked_write(val2);

        assertEq(test.tA(), val1);
        assertEq(test.tB(), boolVal1);
        assertEq(test.tC(), boolVal2);
        assertEq(test.tD(), val2);
    }

    function test_StorageReadBytes32() public {
        bytes32 val = stdstore.target(address(test)).sig(test.tE.selector).read_bytes32();
        assertEq(val, hex"1337");
    }

    function test_StorageReadBool_False() public {
        bool val = stdstore.target(address(test)).sig(test.tB.selector).read_bool();
        assertEq(val, false);
    }

    function test_StorageReadBool_True() public {
        bool val = stdstore.target(address(test)).sig(test.tH.selector).read_bool();
        assertEq(val, true);
    }

    function test_StorageReadBool_Revert() public {
        vm.expectRevert("stdStorage read_bool(StdStorage): Cannot decode. Make sure you are reading a bool.");
        this.readNonBoolValue();
    }

    function readNonBoolValue() public {
        stdstore.target(address(test)).sig(test.tE.selector).read_bool();
    }

    function test_StorageReadAddress() public {
        address val = stdstore.target(address(test)).sig(test.tF.selector).read_address();
        assertEq(val, address(1337));
    }

    function test_StorageReadUint() public {
        uint256 val = stdstore.target(address(test)).sig(test.exists.selector).read_uint();
        assertEq(val, 1);
    }

    function test_StorageReadInt() public {
        int256 val = stdstore.target(address(test)).sig(test.tG.selector).read_int();
        assertEq(val, type(int256).min);
    }

    function testFuzzPacked(uint256 val, uint8 elemToGet) public {
        // 该函数尝试各种不同的打包存储槽，shifts 表示被打包的元素
        // 数量。Shiftsizes 是每个元素的大小，即 8 表示 8 位的数据类型，16 == 16 位，以此类推。
        // 两者结合决定了存储槽的打包方式。若完全随机化，将很难避开全局拒绝次数上限
        // 并保证性能。

        // 改变 shifts 的数量
        for (uint256 i = 1; i < 5; i++) {
            uint256 shifts = i;

            elemToGet = uint8(bound(elemToGet, 0, shifts - 1));

            uint256[] memory shiftSizes = new uint256[](shifts);
            for (uint256 j; j < shifts; j++) {
                shiftSizes[j] = 8 * (j + 1);
            }

            test.setRandomPacking(val);

            uint256 leftBits;
            uint256 rightBits;
            for (uint256 j; j < shiftSizes.length; j++) {
                if (j < elemToGet) {
                    leftBits += shiftSizes[j];
                } else if (elemToGet != j) {
                    rightBits += shiftSizes[j];
                }
            }

            // 可能还有一些右侧的位未被计入
            leftBits += 256 - (leftBits + shiftSizes[elemToGet] + rightBits);
            // 先清除左侧的位，再清除右侧的位并重新对齐
            uint256 expectedValToRead = (val << leftBits) >> (leftBits + rightBits);

            uint256 readVal = stdstore.target(address(test)).enable_packed_slots().sig(
                "getRandomPacked(uint8,uint8[],uint8)"
            ).with_calldata(abi.encode(shifts, shiftSizes, elemToGet)).read_uint();

            assertEq(readVal, expectedValToRead);
        }
    }

    function testFuzzPacked2(uint256 nvars, uint256 seed) public {
        // 要生成的随机变量的数量。
        nvars = bound(nvars, 1, 20);

        // 在下面的循环中生成值时，该值会逐渐减少。
        uint256 bitsRemaining = 256;

        // 为每个变量生成随机的值和大小。
        uint256[] memory vals = new uint256[](nvars);
        uint256[] memory sizes = new uint256[](nvars);
        uint256[] memory offsets = new uint256[](nvars);

        for (uint256 i = 0; i < nvars; i++) {
            // 生成随机的值和大小。
            offsets[i] = i == 0 ? 0 : offsets[i - 1] + sizes[i - 1];

            uint256 nvarsRemaining = nvars - i;
            uint256 maxVarSize = bitsRemaining - nvarsRemaining + 1;
            sizes[i] = bound(uint256(keccak256(abi.encodePacked(seed, i + 256))), 1, maxVarSize);
            bitsRemaining -= sizes[i];

            uint256 maxVal;
            uint256 varSize = sizes[i];
            assembly {
                // mask = (1 << varSize) - 1
                maxVal := sub(shl(varSize, 1), 1)
            }
            vals[i] = bound(uint256(keccak256(abi.encodePacked(seed, i))), 0, maxVal);
        }

        // 将所有值打包进存储槽。
        for (uint256 i = 0; i < nvars; i++) {
            stdstore.enable_packed_slots().target(address(test)).sig("getRandomPacked(uint256,uint256)").with_key(
                sizes[i]
            ).with_key(offsets[i]).checked_write(vals[i]);
        }

        // 验证读取到的数据一致。
        for (uint256 i = 0; i < nvars; i++) {
            uint256 readVal = stdstore.enable_packed_slots().target(address(test)).sig(
                "getRandomPacked(uint256,uint256)"
            ).with_key(sizes[i]).with_key(offsets[i]).read_uint();

            uint256 retVal = test.getRandomPacked(sizes[i], offsets[i]);

            assertEq(readVal, vals[i]);
            assertEq(retVal, vals[i]);
        }
    }
}

contract StorageTest {
    uint256 public exists = 1;
    mapping(address => uint256) public map_addr;
    mapping(uint256 => uint256) public map_uint;
    mapping(address => uint256) public map_packed;
    mapping(address => UnpackedStruct) public map_struct;
    mapping(address => mapping(address => uint256)) public deep_map;
    mapping(address => mapping(address => UnpackedStruct)) public deep_map_struct;
    UnpackedStruct public basic;

    uint248 public tA;
    bool public tB;

    bool public tC = false;
    uint248 public tD = 1;

    struct UnpackedStruct {
        uint256 a;
        uint256 b;
    }

    mapping(address => bool) public map_bool;

    bytes32 public tE = hex"1337";
    address public tF = address(1337);
    int256 public tG = type(int256).min;
    bool public tH = true;
    bytes32 private tI = ~bytes32(hex"1337");

    uint256 randomPacking;

    constructor() {
        basic = UnpackedStruct({a: 1337, b: 1337});

        uint256 two = (1 << 128) | 1;
        map_packed[msg.sender] = two;
        map_packed[address(uint160(1337))] = 1 << 128;
    }

    function read_struct_upper(address who) public view returns (uint256) {
        return map_packed[who] >> 128;
    }

    function read_struct_lower(address who) public view returns (uint256) {
        return map_packed[who] & ((1 << 128) - 1);
    }

    function hidden() public view returns (bytes32 t) {
        bytes32 slot = keccak256("my.random.var");
        /// @solidity memory-safe-assembly
        assembly {
            t := sload(slot)
        }
    }

    function const() public pure returns (bytes32 t) {
        t = bytes32(hex"1337");
    }

    function extra_sload() public view returns (bytes32 t) {
        // 触发对槽 `tE` 的读取，并发起一次 staticcall，确保编译器不会把这次 SLOAD 优化掉
        assembly {
            pop(staticcall(gas(), sload(tE.slot), 0, 0, 0, 0))
        }
        t = tI;
    }

    function setRandomPacking(uint256 val) public {
        randomPacking = val;
    }

    function _getMask(uint256 size) internal pure returns (uint256 mask) {
        assembly {
            // mask = (1 << size) - 1
            mask := sub(shl(size, 1), 1)
        }
    }

    function setRandomPacking(uint256 val, uint256 size, uint256 offset) public {
        // 根据值的大小生成掩码
        uint256 mask = _getMask(size);
        // 将即将设置的字中对应的所有位清零
        uint256 cleanedWord = randomPacking & ~(mask << offset);
        // 将 val 放到清理后的字中的正确位置
        randomPacking = cleanedWord | val << offset;
    }

    function getRandomPacked(uint256 size, uint256 offset) public view returns (uint256) {
        // 根据值的大小生成掩码
        uint256 mask = _getMask(size);
        // 移位使各位处于正确位置，并用 mask 将其余位清零
        return (randomPacking >> offset) & mask;
    }

    function getRandomPacked(uint8 shifts, uint8[] memory shiftSizes, uint8 elem) public view returns (uint256) {
        require(elem < shifts, "!elem");
        uint256 leftBits;
        uint256 rightBits;

        for (uint256 i; i < shiftSizes.length; i++) {
            if (i < elem) {
                leftBits += shiftSizes[i];
            } else if (elem != i) {
                rightBits += shiftSizes[i];
            }
        }

        // 可能还有一些右侧的位未被计入
        leftBits += 256 - (leftBits + shiftSizes[elem] + rightBits);

        // 先清除左侧的位，再清除右侧的位并重新对齐
        return (randomPacking << leftBits) >> (leftBits + rightBits);
    }
}
