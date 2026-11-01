# Forge 标准库 • [![CI status](https://github.com/foundry-rs/forge-std/actions/workflows/ci.yml/badge.svg)](https://github.com/foundry-rs/forge-std/actions/workflows/ci.yml)

Forge 标准库（Forge Standard Library）是一组实用的合约和库，供 [Forge 和 Foundry](https://github.com/foundry-rs/foundry) 使用。它借助 Forge 的 cheatcode（作弊码）让编写测试更简单、更快捷，同时改善了 cheatcode 的使用体验（UX）。

**在 [📖 Foundry Book（Forge-Std 指南）](https://book.getfoundry.sh/forge/forge-std.html) 中学习如何使用 Forge-Std。**

## 安装

```bash
forge install foundry-rs/forge-std
```

## 合约
### stdError

这是一个用于处理错误（error）和回滚（revert）的辅助合约。在 Forge 中，它对 `expectRevert` cheatcode 尤其有用，因为它提供了所有编译器内置的错误。

所有错误码请参见合约源码本身。

#### 使用示例

```solidity

import "forge-std/Test.sol";

contract TestContract is Test {
    ErrorsTest test;

    function setUp() public {
        test = new ErrorsTest();
    }

    function testExpectArithmetic() public {
        vm.expectRevert(stdError.arithmeticError);
        test.arithmeticError(10);
    }
}

contract ErrorsTest {
    function arithmeticError(uint256 a) public {
        uint256 a = a - 100;
    }
}
```

### stdStorage

由于为了获得不错的使用体验而做了大量重载，这个合约相当庞大。它主要是对 `record` 和 `accesses` 这两个 cheatcode 的封装。它*总是*能够在不知道存储布局的情况下，找到并写入与某个特定变量相关联的存储槽。其中一个_重大_的限制是：虽然可以找到打包（packed）存储变量所在的槽，但我们无法安全地写入该变量。如果用户尝试写入一个打包槽，执行会抛出错误，除非该槽尚未初始化（`bytes32(0)`）。

它的工作原理是记录一次函数调用期间所有的 `SLOAD` 和 `SSTORE`。如果只读取或写入了单个槽，就直接返回该槽。否则，我们会在幕后逐个遍历并检查每个槽（假设用户传入了 `depth` 参数）。如果变量是一个结构体（struct），你可以传入 `depth` 参数，它基本上就是字段的深度。

即：
```solidity
struct T {
    // depth 0
    uint256 a;
    // depth 1
    uint256 b;
}
```

#### 使用示例

```solidity
import "forge-std/Test.sol";

contract TestContract is Test {
    using stdStorage for StdStorage;

    Storage test;

    function setUp() public {
        test = new Storage();
    }

    function testFindExists() public {
        // 假设我们想找到 public 变量 `exists`
        // 所在的槽。我们只需把函数选择器
        // 传给 `find` 命令
        uint256 slot = stdstore.target(address(test)).sig("exists()").find();
        assertEq(slot, 0);
    }

    function testWriteExists() public {
        // 假设我们想写入 public 变量 `exists`
        // 所在的槽。我们只需把函数选择器
        // 传给 `checked_write` 命令
        stdstore.target(address(test)).sig("exists()").checked_write(100);
        assertEq(test.exists(), 100);
    }

    // 它支持任意的存储布局，例如基于 assembly 的存储位置
    function testFindHidden() public {
        // `hidden` 是某个 bytes 的随机哈希，逐个遍历槽是
        // 找不到它的。而我们的机制可以
        // 另外，你也可以用选择器代替字符串
        uint256 slot = stdstore.target(address(test)).sig(test.hidden.selector).find();
        assertEq(slot, uint256(keccak256("my.random.var")));
    }

    // 如果目标是一个 mapping，你必须传入执行查找所需的键
    // 即：
    function testFindMapping() public {
        uint256 slot = stdstore
            .target(address(test))
            .sig(test.map_addr.selector)
            .with_key(address(this))
            .find();
        // 在 `Storage` 构造函数中，我们在 map 里把这个地址的值写为 1
        // 所以当我们加载该槽时，期望它的值为 1
        assertEq(uint(vm.load(address(test), bytes32(slot))), 1);
    }

    // 如果目标是一个结构体，你可以指定字段深度：
    function testFindStruct() public {
        // 注意：看 depth 参数 —— 0 表示第 0 个字段，1 表示第 1 个字段，以此类推。
        uint256 slot_for_a_field = stdstore
            .target(address(test))
            .sig(test.basicStruct.selector)
            .depth(0)
            .find();

        uint256 slot_for_b_field = stdstore
            .target(address(test))
            .sig(test.basicStruct.selector)
            .depth(1)
            .find();

        assertEq(uint(vm.load(address(test), bytes32(slot_for_a_field))), 1);
        assertEq(uint(vm.load(address(test), bytes32(slot_for_b_field))), 2);
    }
}

// 一个复杂的存储合约
contract Storage {
    struct UnpackedStruct {
        uint256 a;
        uint256 b;
    }

    constructor() {
        map_addr[msg.sender] = 1;
    }

    uint256 public exists = 1;
    mapping(address => uint256) public map_addr;
    // mapping(address => Packed) public map_packed;
    mapping(address => UnpackedStruct) public map_struct;
    mapping(address => mapping(address => uint256)) public deep_map;
    mapping(address => mapping(address => UnpackedStruct)) public deep_map_struct;
    UnpackedStruct public basicStruct = UnpackedStruct({
        a: 1,
        b: 2
    });

    function hidden() public view returns (bytes32 t) {
        // 一个藏得极深的存储槽
        bytes32 slot = keccak256("my.random.var");
        assembly {
            t := sload(slot)
        }
    }
}
```

### stdCheats

这是对各种 cheatcode 的封装，这些 cheatcode 需要封装一下才能对开发者更友好。目前只有与 `prank` 相关的函数。一般来说，用户可能会以为 `prank` 时会给地址打入 ETH，但出于安全原因并非如此。需要明确的是，`hoax` 函数只应用于余额可以被改写的地址，因为原有余额会被覆盖。如果某个地址已经有 ETH，你应该直接使用 `prank`。如果你想显式地修改余额，直接使用 `deal` 即可。如果两者都想做，那么 `hoax` 也正适合你。


#### 使用示例：
```solidity

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

// 继承 stdCheats
contract StdCheatsTest is Test {
    Bar test;
    function setUp() public {
        test = new Bar();
    }

    function testHoax() public {
        // 我们调用 `hoax`，它会给目标地址
        // 发送 eth，然后调用 `prank`
        hoax(address(1337));
        test.bar{value: 100}(address(1337));

        // 它有重载版本，允许你指定用多少 eth
        // 来初始化该地址
        hoax(address(1337), 1);
        test.bar{value: 1}(address(1337));
    }

    function testStartHoax() public {
        // 我们调用 `startHoax`，它会给目标地址
        // 发送 eth，然后调用 `startPrank`
        //
        // 它同样有重载版本，你可以指定 eth 数量
        startHoax(address(1337));
        test.bar{value: 100}(address(1337));
        test.bar{value: 100}(address(1337));
        vm.stopPrank();
        test.bar(address(this));
    }
}

contract Bar {
    function bar(address expectedSender) public payable {
        require(msg.sender == expectedSender, "!prank");
    }
}
```

### Std 断言（Std Assertions）

包含各种断言。

### `console.log`

用法与 [Hardhat](https://hardhat.org/hardhat-network/reference/#console-log) 的格式相同。
推荐像下面这样使用 `console2.sol`，因为它会在 Forge 的 trace 中显示解码后的日志。

```solidity
// 通过 Test.sol 间接导入
import "forge-std/Test.sol";
// 或者直接导入
import "forge-std/console2.sol";
...
console2.log(someValue);
```

如果你需要与 Hardhat 兼容，就必须改用标准的 `console.sol`。
由于 `console.sol` 中的一个 bug，使用 `uint256` 或 `int256` 类型的日志在 Forge 的 trace 中无法被正确解码。

```solidity
// 通过 Test.sol 间接导入
import "forge-std/Test.sol";
// 或者直接导入
import "forge-std/console.sol";
...
console.log(someValue);
```

## 许可证

Forge 标准库以 [MIT](LICENSE-MIT) 或 [Apache 2.0](LICENSE-APACHE) 许可证提供，可任选其一。
