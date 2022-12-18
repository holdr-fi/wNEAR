# wNEAR wrapper token for NEAR on Aurora network

Fork of WETH contract to wrap NEAR on Aurora network.

Issue is that Balancer is not compatible with tokens with >18 decimals, and NEAR has 24 decimals. We require NEAR to be the main pairing token for liquidity pool.

# Tests

Unit tests written in both Hardhat and Foundry frameworks. Using Foundry framework for fuzzing support.

Hardhat test `npx hardhat test`

Foundry test of mock contracts with fuzzing `forge test --match-contract MOCK_WNEAR_Test -vvv`

Foundry test of production contract with Aurora fork and fuzzing `forge test --match-contract NEAR_Aurora_Fork_Test --fork-url https://mainnet.aurora.dev --fork-block-number 80931300 -vvv`