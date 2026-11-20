// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig is Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address entryPoint;
        address account;
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ARBITRUM_ONE_CHAIN_ID = 42161;
    uint256 constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant ENTRY_POINT_V09 = 0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108;
    address constant BURNER_WALLET = 0x4024677f0a75544f7081d3fc5D8F58046d7dfB6d;
    // address constant FOUNDRY_DEFAULT_WALLET = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
        networkConfigs[ARBITRUM_ONE_CHAIN_ID] = getArbitrumConfig();
        networkConfigs[ARBITRUM_SEPOLIA_CHAIN_ID] = getArbitrumConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getEthSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: ENTRY_POINT_V09, account: getConfiguredAccount()});
    }

    function getArbitrumConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: ENTRY_POINT_V09, account: getConfiguredAccount()});
    }

    function geZkSyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
    }

    function getConfiguredAccount() internal view returns (address) {
        return vm.envOr("ACCOUNT_ADDRESS", BURNER_WALLET);
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        // deploy mocks
        console2.log("Deploying mocks...");
        vm.startBroadcast(ANVIL_DEFAULT_ACCOUNT);
        address entryPoint = deployCode("lib/account-abstraction/contracts/core/EntryPoint.sol:EntryPoint");
        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({entryPoint: entryPoint, account: ANVIL_DEFAULT_ACCOUNT});

        return localNetworkConfig;
    }
}
