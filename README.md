# About

1. Create a basic AA on Ethereum
2. Create a basic AA on zkSync
3. Deploy, and send a userOp / transaction through them
   1. Not going to send an AA to Ethereum
   2. But we will send an AA tx to zksync

## Deploy on Arbitrum Sepolia

```bash
export ACCOUNT_ADDRESS=$(cast wallet address --account myaccount)

forge script script/DeployMinimal.s.sol:DeployMinimal --rpc-url $ARBITRUM_SEPOLIA_RPC_URL --account myaccount \
--sender $ACCOUNT_ADDRESS --broadcast --verify ```

## Send a UserOp on Arbitrum Sepolia

```bash
forge script script/SendPackedUserOp.s.sol --rpc-url $ARBITRUM_SEPOLIA_RPC_URL --account myaccount --broadcast \
--verify ```

forge create src/zksync/ZkMinimalAccount.sol:ZkMinimalAccount --rpc-url https://sepolia.era.zksync.dev --chain 300 --account myaccount --broadcast --zksync --system-mode=true --verify --verifier zksync