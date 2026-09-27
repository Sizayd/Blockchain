// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Vulnerable
/// @notice Minimal deposit/withdraw contract used as the Slither audit
///         target for Lab 8. INTENTIONALLY VULNERABLE — reentrancy in
///         withdraw(). Do not deploy to a real network.
contract Vulnerable {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev Vulnerable: the external ETH transfer happens BEFORE the
    ///      user's balance is cleared, allowing reentrancy.
    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "transfer failed");

        balances[msg.sender] = 0;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
