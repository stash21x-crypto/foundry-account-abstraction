// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {MinimalAccount} from "src/ethereum/MinimalAccount.sol";

/// @notice Deploys a sample account, signs a UserOperation, and submits it to the EntryPoint.
contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;

    uint256 constant MINIMAL_ACCOUNT_FUND = 0.001 ether;
    error SendPackedUserOp__FundingFailed();

    /// @notice Deploys and funds a new account, then submits one sample operation.
    function run() public returns (MinimalAccount, PackedUserOperation memory) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);
        (bool success,) = payable(address(minimalAccount)).call{value: MINIMAL_ACCOUNT_FUND}("");
        if (!success) {
            revert SendPackedUserOp__FundingFailed();
        }
        vm.stopBroadcast();

        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, minimalAccount.owner(), 0, hex"");
        PackedUserOperation memory userOp =
            generateSignedUserOperation(executeCallData, config, address(minimalAccount));

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = userOp;

        vm.startBroadcast();
        IEntryPoint(config.entryPoint).handleOps(ops, payable(minimalAccount.owner()));
        vm.stopBroadcast();

        console2.log("MinimalAccount deployed at:", address(minimalAccount));
        console2.log("EntryPoint:", config.entryPoint);

        return (minimalAccount, userOp);
    }

    function generateSignedUserOperation(
        bytes memory callData,
        HelperConfig.NetworkConfig memory config,
        address minimalAccount
    ) public view returns (PackedUserOperation memory) {
        // 1. Generate the unsigned data
        uint256 nonce = vm.getNonce(minimalAccount) - 1;
        PackedUserOperation memory userOp = _generateUnsignedUserOperation(callData, minimalAccount, nonce);

        // 2. Get the userOp Hash
        bytes32 userOpHash = IEntryPoint(config.entryPoint).getUserOpHash(userOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        // 3. Sign it
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        if (block.chainid == 31337) {
            (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(digest);
        }
        userOp.signature = abi.encodePacked(r, s, v); // Note the order
        return userOp;
    }

    function _generateUnsignedUserOperation(bytes memory callData, address sender, uint256 nonce)
        internal
        view
        returns (PackedUserOperation memory)
    {
        uint128 verificationGasLimit = 500_000;
        uint128 callGasLimit = 100_000;
        uint128 preVerificationGas = 100_000;
        uint128 maxPriorityFeePerGas = 1 gwei;
        uint128 maxFeePerGas = uint128(block.basefee) + maxPriorityFeePerGas;
        return PackedUserOperation({
            sender: sender,
            nonce: nonce,
            initCode: hex"",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: preVerificationGas,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}
