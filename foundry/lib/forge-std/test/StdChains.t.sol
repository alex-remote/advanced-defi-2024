// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "../src/Test.sol";

contract StdChainsMock is Test {
    function exposed_getChain(string memory chainAlias) public returns (Chain memory) {
        return getChain(chainAlias);
    }

    function exposed_getChain(uint256 chainId) public returns (Chain memory) {
        return getChain(chainId);
    }

    function exposed_setChain(string memory chainAlias, ChainData memory chainData) public {
        setChain(chainAlias, chainData);
    }

    function exposed_setFallbackToDefaultRpcUrls(bool useDefault) public {
        setFallbackToDefaultRpcUrls(useDefault);
    }
}

contract StdChainsTest is Test {
    function test_ChainRpcInitialization() public {
        // 在 `foundry.toml` 中指定的 RPC 应当被更新。
        assertEq(getChain(1).rpcUrl, "https://eth-mainnet.alchemyapi.io/v2/WV407BEiBmjNJfKo9Uo_55u0z0ITyCOX");
        assertEq(getChain("optimism_goerli").rpcUrl, "https://goerli.optimism.io/");
        assertEq(getChain("arbitrum_one_goerli").rpcUrl, "https://goerli-rollup.arbitrum.io/rpc/");

        // 环境变量应作为下一级回退来源
        assertEq(getChain("arbitrum_nova").rpcUrl, "https://nova.arbitrum.io/rpc");
        vm.setEnv("ARBITRUM_NOVA_RPC_URL", "myoverride");
        assertEq(getChain("arbitrum_nova").rpcUrl, "myoverride");
        vm.setEnv("ARBITRUM_NOVA_RPC_URL", "https://nova.arbitrum.io/rpc");

        // 无法覆盖在 `foundry.toml` 中定义的 RPC
        vm.setEnv("MAINNET_RPC_URL", "myoverride2");
        assertEq(getChain("mainnet").rpcUrl, "https://eth-mainnet.alchemyapi.io/v2/WV407BEiBmjNJfKo9Uo_55u0z0ITyCOX");

        // 其他 RPC 应保持不变。
        assertEq(getChain(31337).rpcUrl, "http://127.0.0.1:8545");
        assertEq(getChain("sepolia").rpcUrl, "https://sepolia.infura.io/v3/b9794ad1ddf84dfb8c34d6bb5dca2001");
    }

    // 以下划线开头命名，以表明它不打算作为普通测试运行，
    // 而是供下方的 `test_Rpcs` 测试使用。
    function _testRpc(string memory rpcAlias) internal {
        string memory rpcUrl = getChain(rpcAlias).rpcUrl;
        vm.createSelectFork(rpcUrl);
    }

    // 确保能够连接到每条链的默认 RPC URL。
    // 目前已注释掉，因为它运行缓慢且公共 RPC 不稳定，经常导致 CI 失败。
    // function test_Rpcs() public {
    //     _testRpc("mainnet");
    //     _testRpc("goerli");
    //     _testRpc("sepolia");
    //     _testRpc("optimism");
    //     _testRpc("optimism_goerli");
    //     _testRpc("arbitrum_one");
    //     _testRpc("arbitrum_one_goerli");
    //     _testRpc("arbitrum_nova");
    //     _testRpc("polygon");
    //     _testRpc("polygon_mumbai");
    //     _testRpc("avalanche");
    //     _testRpc("avalanche_fuji");
    //     _testRpc("bnb_smart_chain");
    //     _testRpc("bnb_smart_chain_testnet");
    //     _testRpc("gnosis_chain");
    //     _testRpc("moonbeam");
    //     _testRpc("moonriver");
    //     _testRpc("moonbase");
    //     _testRpc("base_goerli");
    //     _testRpc("base");
    //     _testRpc("fraxtal");
    //     _testRpc("fraxtal_testnet");
    // }

    function test_ChainNoDefault() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(string): Chain with alias \"does_not_exist\" not found.");
        stdChainsMock.exposed_getChain("does_not_exist");
    }

    function test_SetChainFirstFails() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains setChain(string,ChainData): Chain ID 31337 already used by \"anvil\".");
        stdChainsMock.exposed_setChain("anvil2", ChainData("Anvil", 31337, "URL"));
    }

    function test_ChainBubbleUp() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        stdChainsMock.exposed_setChain("needs_undefined_env_var", ChainData("", 123456789, ""));
        vm.expectRevert(
            "Failed to resolve env var `UNDEFINED_RPC_URL_PLACEHOLDER` in `${UNDEFINED_RPC_URL_PLACEHOLDER}`: environment variable not found"
        );
        stdChainsMock.exposed_getChain("needs_undefined_env_var");
    }

    function test_CannotSetChain_ChainIdExists() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        stdChainsMock.exposed_setChain("custom_chain", ChainData("Custom Chain", 123456789, "https://custom.chain/"));

        vm.expectRevert('StdChains setChain(string,ChainData): Chain ID 123456789 already used by "custom_chain".');

        stdChainsMock.exposed_setChain("another_custom_chain", ChainData("", 123456789, ""));
    }

    function test_SetChain() public {
        setChain("custom_chain", ChainData("Custom Chain", 123456789, "https://custom.chain/"));
        Chain memory customChain = getChain("custom_chain");
        assertEq(customChain.name, "Custom Chain");
        assertEq(customChain.chainId, 123456789);
        assertEq(customChain.chainAlias, "custom_chain");
        assertEq(customChain.rpcUrl, "https://custom.chain/");
        Chain memory chainById = getChain(123456789);
        assertEq(chainById.name, customChain.name);
        assertEq(chainById.chainId, customChain.chainId);
        assertEq(chainById.chainAlias, customChain.chainAlias);
        assertEq(chainById.rpcUrl, customChain.rpcUrl);
        customChain.name = "Another Custom Chain";
        customChain.chainId = 987654321;
        setChain("another_custom_chain", customChain);
        Chain memory anotherCustomChain = getChain("another_custom_chain");
        assertEq(anotherCustomChain.name, "Another Custom Chain");
        assertEq(anotherCustomChain.chainId, 987654321);
        assertEq(anotherCustomChain.chainAlias, "another_custom_chain");
        assertEq(anotherCustomChain.rpcUrl, "https://custom.chain/");
        // 验证第一条链的数据没有被覆盖
        chainById = getChain(123456789);
        assertEq(chainById.name, "Custom Chain");
        assertEq(chainById.chainId, 123456789);
    }

    function test_SetNoEmptyAlias() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains setChain(string,ChainData): Chain alias cannot be the empty string.");
        stdChainsMock.exposed_setChain("", ChainData("", 123456789, ""));
    }

    function test_SetNoChainId0() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains setChain(string,ChainData): Chain ID cannot be 0.");
        stdChainsMock.exposed_setChain("alias", ChainData("", 0, ""));
    }

    function test_GetNoChainId0() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(uint256): Chain ID cannot be 0.");
        stdChainsMock.exposed_getChain(0);
    }

    function test_GetNoEmptyAlias() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(string): Chain alias cannot be the empty string.");
        stdChainsMock.exposed_getChain("");
    }

    function test_ChainIdNotFound() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(string): Chain with alias \"no_such_alias\" not found.");
        stdChainsMock.exposed_getChain("no_such_alias");
    }

    function test_ChainAliasNotFound() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        vm.expectRevert("StdChains getChain(uint256): Chain with ID 321 not found.");

        stdChainsMock.exposed_getChain(321);
    }

    function test_SetChain_ExistingOne() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        setChain("custom_chain", ChainData("Custom Chain", 123456789, "https://custom.chain/"));
        assertEq(getChain(123456789).chainId, 123456789);

        setChain("custom_chain", ChainData("Modified Chain", 999999999, "https://modified.chain/"));
        vm.expectRevert("StdChains getChain(uint256): Chain with ID 123456789 not found.");
        stdChainsMock.exposed_getChain(123456789);

        Chain memory modifiedChain = getChain(999999999);
        assertEq(modifiedChain.name, "Modified Chain");
        assertEq(modifiedChain.chainId, 999999999);
        assertEq(modifiedChain.rpcUrl, "https://modified.chain/");
    }

    function test_DontUseDefaultRpcUrl() public {
        // 我们部署一个 mock 合约，以便正确测试 revert。
        StdChainsMock stdChainsMock = new StdChainsMock();

        // 如果默认 RPC 标志被设为 false，应当报错。
        stdChainsMock.exposed_setFallbackToDefaultRpcUrls(false);
        vm.expectRevert();
        stdChainsMock.exposed_getChain(31337);
        vm.expectRevert();
        stdChainsMock.exposed_getChain("sepolia");
    }
}
