# Foundry Account Abstraction

![Smart Contract Development](https://img.shields.io/badge/Focus-Smart%20Contract%20Development-blue)
![Education](https://img.shields.io/badge/Learning-Cyfrin%20Updraft-orange)
![License](https://img.shields.io/badge/License-MIT%20License-yellow)

Example account-abstraction contracts and scripts for Ethereum-compatible networks and zkSync Era.

- `MinimalAccount` is an ERC-4337 account that validates signatures through an EntryPoint.
- `ZkMinimalAccount` implements zkSync Era's native account interface and transaction validation.

## Project-specific work

I used the Cyfrin Updraft course as a starting point, then adapted the implementation to this project's networks, dependencies, and test setup instead of treating the walkthrough as production-ready code:

- Built separate account implementations for ERC-4337 on EVM chains and zkSync Era's native transaction flow.
- Added chain-aware EntryPoint/account configuration, including a locally deployed EntryPoint for Anvil and explicit supported-chain handling.
- Implemented the packed UserOperation construction, signing, funding, and submission flow for the Ethereum account.
- Restricted `validateUserOp` to the configured EntryPoint. The regression test checks that another caller cannot trigger account prefunding.
- Added a bounds check before converting a zkSync transaction recipient to `address`, preventing silent truncation of values wider than 160 bits.
- Made the local EntryPoint artifact reference deterministic so the Ethereum test suite works after a clean Foundry build.
- Added focused tests, NatSpec on key contract/script entry points, and Makefile targets for common development tasks.

These are project-specific adaptations and hardening changes; the zkSync deployment workflow is not complete, and the local tests do not replace testing against a zkSync node.

## Requirements

- [Foundry](https://book.getfoundry.sh/) (`forge`, `cast`, and `anvil`)
- GNU Make
- Git

Clone the repository with its dependencies:

```bash
git clone --recurse-submodules <repository-url>
cd foundry-account-abstraction
```

If you already cloned without submodules, initialize them with:

```bash
git submodule update --init --recursive
```

## Build and test

```bash
make          # Show available targets
make build    # Compile contracts
make test     # Run tests
make fmt      # Format Solidity files
make fmt-check
```

The current test suite has eight tests across both account implementations, run with Foundry's local EVM. `make anvil` starts a local node for manual development.

## Arbitrum Sepolia

The Ethereum account scripts use the EntryPoint configured in `script/HelperConfig.s.sol`. Configure a Foundry keystore account and set its address and an Arbitrum Sepolia RPC URL before broadcasting:

```bash
export ARBITRUM_SEPOLIA_RPC_URL="https://..."
export ACCOUNT="myaccount"
export ACCOUNT_ADDRESS="$(cast wallet address --account "$ACCOUNT")"
```

Deploy `MinimalAccount`:

```bash
make deploy-arbitrum-sepolia
```

Deploy an account and submit a sample UserOperation:

```bash
make send-userop-arbitrum-sepolia
```

The UserOperation script deploys a new account for that run and funds it with `0.001 ETH`; the broadcasting account needs enough Arbitrum Sepolia ETH to cover transaction costs. Keep RPC credentials and private keys out of source control.

The deployment helper also has configurations for Ethereum Sepolia and Arbitrum One. The Makefile's deployment targets are specifically set up for Arbitrum Sepolia.

## zkSync Era

`src/zksync/ZkMinimalAccount.sol` and its tests demonstrate the zkSync native account flow. A zkSync deployment and transaction workflow is not currently wired into the project scripts or network configuration; the Arbitrum Makefile targets do not deploy this contract.

## Project layout

```text
src/ethereum/       ERC-4337 MinimalAccount
src/zksync/         zkSync Era ZkMinimalAccount
script/             Deployment, configuration, and UserOperation scripts
test/               Ethereum and zkSync account tests
lib/                Git submodule dependencies
```

## Acknowledgements

Built following the [Cyfrin Updraft](https://updraft.cyfrin.io/) Foundry DeFi course by Patrick Collins.

---

## License

[MIT]
