// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./IRewardToken.sol";

/// @title VulnerableVaultFixed
/// @notice Corrected version of VulnerableVault.sol. All 11 findings from
///         docs/audit-report.md are addressed; one residual, low-risk item
///         (F-06, weak on-chain randomness) is kept and documented rather
///         than "fixed" for real — production deployments must replace it
///         with an external verifiable randomness source (e.g. Chainlink
///         VRF).
contract VulnerableVaultFixed {
    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------
    event Deposited(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);
    event OwnerChanged(address indexed newOwner);
    event RewardPaid(address indexed winner, uint256 amount);
    event RewardPaymentFailed(address indexed winner, uint256 amount);

    // ---------------------------------------------------------------------
    // State
    // ---------------------------------------------------------------------
    address public owner;

    // F-09: reward token reference is never reassigned after construction —
    // now declared immutable (gas saving + documents the intent).
    IRewardToken public immutable rewardToken;

    mapping(address => uint256) public balances;
    // F-04 / F-08: tracks whether an address currently holds a stakers[]
    // entry, so membership stays consistent with real, current stake.
    mapping(address => bool) public isStaker;

    uint256 public totalStaked;
    address[] public stakers;

    uint256 public lastRewardTime;
    uint256 public constant REWARD_INTERVAL = 1 days;
    uint256 public constant REWARD_AMOUNT = 100;

    // F-03 / F-11: minimal reentrancy guard (defence in depth, on top of
    // the checks-effects-interactions reorder below).
    bool private locked;
    modifier nonReentrant() {
        require(!locked, "reentrant call");
        locked = true;
        _;
        locked = false;
    }

    // F-09: constructor now rejects the zero address for _rewardToken.
    constructor(address _rewardToken) {
        require(_rewardToken != address(0), "zero reward token");
        owner = msg.sender;
        rewardToken = IRewardToken(_rewardToken);
        lastRewardTime = block.timestamp;
    }

    // F-05: authenticates msg.sender instead of tx.origin — the standard,
    // non-phishable pattern. Now actually applied to setOwner and
    // emergencyWithdraw (F-01 / F-02).
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    /// @notice Deposit ETH into the vault.
    /// @dev F-04 fix: only pushed onto `stakers` the first time an address
    ///      deposits, so every address holds exactly one "ticket"
    ///      regardless of how many times it tops up its stake.
    function deposit() external payable {
        require(msg.value > 0, "zero deposit");

        if (!isStaker[msg.sender]) {
            isStaker[msg.sender] = true;
            stakers.push(msg.sender);
        }

        balances[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Withdraw part or all of the caller's staked ETH.
    /// @dev F-03 fix: checks-effects-interactions — balances/totalStaked
    ///      (and the F-08 stakers[] membership) are updated BEFORE the
    ///      external call, plus a nonReentrant guard as defence in depth.
    ///      F-11 fix: no more `unchecked` block — Solidity's default
    ///      checked arithmetic reverts loudly instead of wrapping silently.
    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "insufficient balance");

        balances[msg.sender] -= amount;
        totalStaked -= amount;

        // F-08 fix: remove the caller from stakers[] (swap-and-pop) once
        // its balance reaches exactly zero, so lottery membership always
        // reflects real, current stake.
        if (balances[msg.sender] == 0 && isStaker[msg.sender]) {
            _removeStaker(msg.sender);
        }

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Direct ETH transfers are treated as deposits.
    receive() external payable {
        if (!isStaker[msg.sender]) {
            isStaker[msg.sender] = true;
            stakers.push(msg.sender);
        }
        balances[msg.sender] += msg.value;
        totalStaked += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Pick a staker and pay out the reward. Owner-only (F-10 fix).
    /// @dev F-06 (residual, documented): still uses on-chain
    ///      timestamp/blockhash randomness for this teaching exercise
    ///      (with address(this) added to the hash to block trivial
    ///      cross-contract precomputation). A production deployment MUST
    ///      replace this with Chainlink VRF or an equivalent verifiable
    ///      randomness source. F-07 fix: the boolean result of
    ///      rewardToken.transfer() is now checked and branched on.
    function pickWinner() external onlyOwner nonReentrant {
        require(block.timestamp >= lastRewardTime + REWARD_INTERVAL, "too soon");
        require(stakers.length > 0, "no stakers");

        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, blockhash(block.number - 1), stakers.length, address(this))
            )
        );
        uint256 winnerIndex = rand % stakers.length;
        address winner = stakers[winnerIndex];

        lastRewardTime = block.timestamp;

        bool ok = rewardToken.transfer(winner, REWARD_AMOUNT);
        if (ok) {
            emit RewardPaid(winner, REWARD_AMOUNT);
        } else {
            emit RewardPaymentFailed(winner, REWARD_AMOUNT);
        }
    }

    /// @notice Change the contract owner. Owner-only, non-zero (F-02 fix).
    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    /// @notice Emergency rescue of the vault's entire ETH balance.
    /// @dev F-01 fix (was CRITICAL): now owner-only, non-zero destination,
    ///      and reentrancy-guarded.
    function emergencyWithdraw(address payable to) external onlyOwner nonReentrant {
        require(to != address(0), "zero destination");
        uint256 bal = address(this).balance;
        (bool sent, ) = to.call{value: bal}("");
        require(sent, "rescue failed");
    }

    /// @dev O(1) swap-and-pop removal from the stakers[] array (F-08 fix).
    function _removeStaker(address staker) private {
        isStaker[staker] = false;
        uint256 length = stakers.length;
        for (uint256 i = 0; i < length; i++) {
            if (stakers[i] == staker) {
                stakers[i] = stakers[length - 1];
                stakers.pop();
                break;
            }
        }
    }
}
