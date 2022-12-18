# wNEAR wrapper token for NEAR on Aurora network

Fork of WETH contract to wrap NEAR on Aurora network.

Issue is that Balancer is not compatible with tokens with >18 decimals, and NEAR has 24 decimals. We require NEAR to be the main pairing token for liquidity pool.

# Tests

Unit tests written in both Hardhat and Foundry frameworks. Using Foundry framework for fuzzing support.

Hardhat test `npx hardhat test`

Foundry test `forge test -vvv`