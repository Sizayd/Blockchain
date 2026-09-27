// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IRewardToken.sol";

/// @title VulnerableVault
/// @notice ETH staking vault: users deposit ETH, may withdraw it at will, and a
///         periodic "reward round" (pickWinner) pays 100 reward tokens to a
///         pseudo-randomly chosen staker.
/// @dev INTENTIONALLY VULNERABLE — teaching contract for the Module 11 audit
///      (ESTIAM 4BLOCKC / E4CCSN). Do NOT deploy to a real network.
///      See VulnerableVaultFixed.sol for the corrected version and
///      docs/audit-report.md for the full findings (F-01 .. F-11).
contract VulnerableVault {
    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------
    event Deposited(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);
    event OwnerChanged(address indexed newOwner);
    event RewardPaid(address indexed winner, uint256 amount);

    // ---------------------------------------------------------------------
    // State
    // ---------------------------------------------------------------------
    address public owner;

    // F-09: plain state variable, never reassigned after the constructor,
    // but not declared immutable (missed gas / hygiene optimisation).
    IRewardToken public rewardToken;

    mapping(address => uint256) public balances;

    uint256 public totalStaked;
    address[] public stakers;

    uint256 public lastRewardTime;
    uint256 public constant REWARD_INTERVAL = 1 days;
    uint256 public constant REWARD_AMOUNT = 100;

    // F-09: constructor does not reject the zero address for _rewardToken.
    constructor(address _rewardToken) {
        owner = msg.sender;
        rewardToken = IRewardToken(_rewardToken);
        lastRewardTime = block.timestamp;
    }

    // F-05: authenticates tx.origin instead of msg.sender (phishable).
    // Note: in this original contract the modifier is defined but not yet
    // applied to setOwner() or emergencyWithdraw() — see F-01 / F-02.
    modifier onlyOwner() {
        require(tx.origin == owner, "not owner");
        _;
    }

    /// @notice Deposit ETH into the vault.
    /// @dev F-04: pushes msg.sender onto `stakers` on every call, with no
    ///      check for an existing entry — lets an attacker "stuff" the
    ///      reward lottery with many cheap 1-wei deposits.
    function deposit() external payable {
        require(msg.value > 0, "zero deposit");
        stakers.push(msg.sender);
        balances[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw part or all of the caller's staked ETH.
    /// @dev F-03: violates checks-effects-interactions — the external call
    ///      happens before `balances`/`totalStaked` are updated, enabling
    ///      reentrancy. F-11: the later decrement is wrapped in `unchecked`,
    ///      so a reentrant call that pushes the balance below zero wraps
    ///      around instead of reverting. F-08: never removes the caller
    ///      from `stakers[]`, so a "ghost staker" keeps its lottery odds
    ///      after withdrawing everything.
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient balance");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "transfer failed");

        unchecked {
            balances[msg.sender] -= amount;
            totalStaked -= amount;
        }

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Direct ETH transfers are treated as deposits.
    receive() external payable {
        stakers.push(msg.sender);
        balances[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Pick a pseudo-random staker and pay out the reward.
    /// @dev F-06: weak, predictable randomness (timestamp + blockhash +
    ///      array length). F-07: ignores the boolean return value of
    ///      rewardToken.transfer(). F-10: permissionless — combined with
    ///      F-06, lets an attacker "grind" for a favourable outcome by
    ///      reverting whenever they are not the winner.
    function pickWinner() external {
        require(block.timestamp >= lastRewardTime + REWARD_INTERVAL, "too soon");
        require(stakers.length > 0, "no stakers");

        uint256 rand = uint256(
            keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), stakers.length))
        );
        uint256 winnerIndex = rand % stakers.length;
        address winner = stakers[winnerIndex];

        lastRewardTime = block.timestamp;

        rewardToken.transfer(winner, REWARD_AMOUNT);
        emit RewardPaid(winner, REWARD_AMOUNT);
    }

    /// @notice Change the contract owner.
    /// @dev F-02: no access control at all — anyone can seize ownership.
    function setOwner(address newOwner) external {
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    /// @notice Emergency rescue of the vault's entire ETH balance.
    /// @dev F-01 (CRITICAL): no access control whatsoever — any address can
    ///      call this and drain 100% of the vault's ETH in one transaction.
    function emergencyWithdraw(address payable to) external {
        uint256 bal = address(this).balance;
        (bool sent, ) = to.call{value: bal}("");
        require(sent, "rescue failed");
    }
}
