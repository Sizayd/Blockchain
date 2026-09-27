// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title VulnerableFixed
/// @notice Same contract as Vulnerable.sol, with withdraw() rewritten to
///         follow the Checks-Effects-Interactions pattern (Lab 8 fix).
contract VulnerableFixed {
    address public immutable owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        // Effects: update the balance before the external call.
        balances[msg.sender] = 0;

        // Interaction: send the ETH after updating the balance.
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "transfer failed");
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
