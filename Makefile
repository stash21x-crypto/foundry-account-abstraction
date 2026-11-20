.DEFAULT_GOAL := help

.PHONY: help build test fmt fmt-check clean anvil require-deploy-config deploy-arbitrum-sepolia send-userop-arbitrum-sepolia

help:
	@echo "Available targets:"
	@echo "  build                       Compile contracts"
	@echo "  test                        Run the test suite"
	@echo "  fmt                         Format Solidity files"
	@echo "  fmt-check                   Check Solidity formatting"
	@echo "  clean                       Remove Foundry build artifacts"
	@echo "  anvil                       Start a local Anvil node"
	@echo "  deploy-arbitrum-sepolia     Deploy MinimalAccount to Arbitrum Sepolia"
	@echo "  send-userop-arbitrum-sepolia Deploy an account and send a UserOperation"

build:
	forge build

test:
	forge test

fmt:
	forge fmt

fmt-check:
	forge fmt --check

clean:
	forge clean

anvil:
	anvil

require-deploy-config:
	@test -n "$(ARBITRUM_SEPOLIA_RPC_URL)" || { echo "Set ARBITRUM_SEPOLIA_RPC_URL" >&2; exit 1; }
	@test -n "$(ACCOUNT)" || { echo "Set ACCOUNT to a configured Foundry account name" >&2; exit 1; }
	@test -n "$(ACCOUNT_ADDRESS)" || { echo "Set ACCOUNT_ADDRESS to the account address" >&2; exit 1; }

deploy-arbitrum-sepolia: require-deploy-config
	forge script script/DeployMinimal.s.sol:DeployMinimal \
		--rpc-url "$(ARBITRUM_SEPOLIA_RPC_URL)" \
		--account "$(ACCOUNT)" \
		--sender "$(ACCOUNT_ADDRESS)" \
		--broadcast

send-userop-arbitrum-sepolia: require-deploy-config
	forge script script/SendPackedUserOp.s.sol:SendPackedUserOp \
		--rpc-url "$(ARBITRUM_SEPOLIA_RPC_URL)" \
		--account "$(ACCOUNT)" \
		--sender "$(ACCOUNT_ADDRESS)" \
		--broadcast
