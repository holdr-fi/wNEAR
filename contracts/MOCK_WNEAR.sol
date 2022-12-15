// Mock WNEAR contract for testnet

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MOCK_WNEAR is ERC20 {
    using SafeERC20 for IERC20;

    /**
     * @notice Scale factor betwen wNEAR and hNEAR
     * @dev Divide by SCALE_FACTOR for NEAR -> wNEAR, i.e. 1e24 NEAR == 1e18 wNEAR
     * @dev Multiply by SCALE_FACTOR for wNEAR -> NEAR, i.e. 1e18 wNEAR == 1e24 NEAR
     */
    uint256 constant public SCALE_FACTOR = 1e6;
    address immutable public NEAR;

    constructor(address _NEAR) ERC20("Wrapped NEAR", "wNEAR") {
        NEAR = _NEAR;
    }

    /**
     * @notice Wrap NEAR into wNEAR
     * @dev Deposit NEAR, mint wNEAR
     * @param amount Amount of NEAR to wrap
     */
    function deposit(uint256 amount) external {
        // Don't strictly need this require statement as ERC20.sol involves balance checks. However without this require statement, using amount < 1e6 would succeed even if msg.sender has no NEAR, because we zero out the least significant 6 digits before calling safeTransferFrom.
        require(IERC20(NEAR).balanceOf(msg.sender) >= amount, "insufficient NEAR balance");
        // Zero out least significant 6 digits
        IERC20(NEAR).safeTransferFrom(msg.sender, address(this), amount / SCALE_FACTOR * SCALE_FACTOR);
        // Truncate by least significant 6 digits
        _mint(msg.sender, amount / SCALE_FACTOR);
    }

    /**
     * @notice Unwrap wNEAR into NEAR
     * @dev Burn wNEAR, withdraw NEAR
     * @param amount Amount of wNEAR to unwrap
     */
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        // Pad by least significant 6 digits
        IERC20(NEAR).safeTransfer(msg.sender, amount * SCALE_FACTOR);
    }
}
