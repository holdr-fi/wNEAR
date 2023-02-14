// Wrapper contract for META that truncates decimals from 24 decimals to 18 decimals. Required for compatibility with Balancer contracts.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract WMETA is ERC20 {
    using SafeERC20 for IERC20;

    /**
     * @notice Scale factor betwen wMETA and META
     * @dev Divide by SCALE_FACTOR for META -> wMETA, i.e. 1e24 META == 1e18 wMETA
     * @dev Multiply by SCALE_FACTOR for wMETA -> META, i.e. 1e18 wMETA == 1e24 META
     */
    uint256 constant public SCALE_FACTOR = 1e6;
    address constant public META = 0xc21Ff01229e982d7c8b8691163B0A3Cb8F357453;

    constructor() ERC20("Wrapped META", "wMETA") {}

    /**
     * @notice Wrap META into wMETA
     * @dev Deposit META, mint wMETA
     * @param amount Amount of META to wrap
     */
    function deposit(uint256 amount) external {
        // Don't strictly need this require statement as ERC20.sol involves balance checks. However without this require statement, using amount < 1e6 would succeed even if msg.sender has no META, because we zero out the least significant 6 digits before calling safeTransferFrom.
        require(IERC20(META).balanceOf(msg.sender) >= amount, "insufficient META balance");
        // Zero out least significant 6 digits (implicit refund of least significant 6 digits of META)
        IERC20(META).safeTransferFrom(msg.sender, address(this), amount / SCALE_FACTOR * SCALE_FACTOR);
        // Truncate by least significant 6 digits
        _mint(msg.sender, amount / SCALE_FACTOR);
    }

    /**
     * @notice Unwrap wMETA into META
     * @dev Burn wMETA, withdraw META
     * @param amount Amount of wMETA to unwrap
     */
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        // Pad by least significant 6 digits
        IERC20(META).safeTransfer(msg.sender, amount * SCALE_FACTOR);
    }
}
