// Wrapper contract for NSTART that truncates decimals from 24 decimals to 18 decimals. Required for compatibility with Balancer contracts.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract WNSTART is ERC20 {
    using SafeERC20 for IERC20;

    /**
     * @notice Scale factor betwen wNSTART and NSTART
     * @dev Divide by SCALE_FACTOR for NSTART -> wNSTART, i.e. 1e24 NSTART == 1e18 wNSTART
     * @dev Multiply by SCALE_FACTOR for wNSTART -> NSTART, i.e. 1e18 wNSTART == 1e24 NSTART
     */
    uint256 constant public SCALE_FACTOR = 1e6;
    address constant public NSTART = 0x06aEBB0f3D9eBe9829E1B67bD3dd608F711D3412;

    constructor() ERC20("Wrapped NSTART", "wNSTART") {}

    /**
     * @notice Wrap NSTART into wNSTART
     * @dev Deposit NSTART, mint wNSTART
     * @param amount Amount of NSTART to wrap
     */
    function deposit(uint256 amount) external {
        // Don't strictly need this require statement as ERC20.sol involves balance checks. However without this require statement, using amount < 1e6 would succeed even if msg.sender has no NSTART, because we zero out the least significant 6 digits before calling safeTransferFrom.
        require(IERC20(NSTART).balanceOf(msg.sender) >= amount, "insufficient NSTART balance");
        // Zero out least significant 6 digits (implicit refund of least significant 6 digits of NSTART)
        IERC20(NSTART).safeTransferFrom(msg.sender, address(this), amount / SCALE_FACTOR * SCALE_FACTOR);
        // Truncate by least significant 6 digits
        _mint(msg.sender, amount / SCALE_FACTOR);
    }

    /**
     * @notice Unwrap wNSTART into NSTART
     * @dev Burn wNSTART, withdraw NSTART
     * @param amount Amount of wNSTART to unwrap
     */
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        // Pad by least significant 6 digits
        IERC20(NSTART).safeTransfer(msg.sender, amount * SCALE_FACTOR);
    }
}
