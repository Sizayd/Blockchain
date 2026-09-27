// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal ERC20-like reward token interface used by VulnerableVault.
/// @dev transfer() returns true on success, false on failure (does NOT revert).
interface IRewardToken {
    function transfer(address to, uint256 amount) external returns (bool);
}
