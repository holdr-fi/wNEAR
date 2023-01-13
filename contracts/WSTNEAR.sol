// Wrapper contract for stNEAR that truncates decimals from 24 decimals to 18 decimals. Required for compatibility with Balancer contracts.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract WSTNEAR is ERC20 {
    using SafeERC20 for IERC20;

    /**
     * @notice Scale factor betwen wstNEAR and stNEAR
     * @dev Divide by SCALE_FACTOR for stNEAR -> wstNEAR, i.e. 1e24 stNEAR == 1e18 wstNEAR
     * @dev Multiply by SCALE_FACTOR for wstNEAR -> stNEAR, i.e. 1e18 wstNEAR == 1e24 stNEAR
     */
    uint256 constant public SCALE_FACTOR = 1e6;
    address constant public stNEAR = 0x07F9F7f963C5cD2BBFFd30CcfB964Be114332E30;

    constructor() ERC20("Wrapped stNEAR", "wstNEAR") {}

    /**
     * @notice Wrap stNEAR into wstNEAR
     * @dev Deposit stNEAR, mint wstNEAR
     * @param amount Amount of stNEAR to wrap
     */
    function deposit(uint256 amount) external {
        // Don't strictly need this require statement as ERC20.sol involves balance checks. However without this require statement, using amount < 1e6 would succeed even if msg.sender has no stNEAR, because we zero out the least significant 6 digits before calling safeTransferFrom.
        require(IERC20(stNEAR).balanceOf(msg.sender) >= amount, "insufficient stNEAR balance");
        // Zero out least significant 6 digits (implicit refund of least significant 6 digits of stNEAR)
        IERC20(stNEAR).safeTransferFrom(msg.sender, address(this), amount / SCALE_FACTOR * SCALE_FACTOR);
        // Truncate by least significant 6 digits
        _mint(msg.sender, amount / SCALE_FACTOR);
    }

    /**
     * @notice Unwrap wstNEAR into stNEAR
     * @dev Burn wstNEAR, withdraw stNEAR
     * @param amount Amount of wstNEAR to unwrap
     */
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        // Pad by least significant 6 digits
        IERC20(stNEAR).safeTransfer(msg.sender, amount * SCALE_FACTOR);
    }
}
