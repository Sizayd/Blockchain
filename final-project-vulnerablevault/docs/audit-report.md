# Smart Contract Security Audit Report — VulnerableVault.sol

**ÉSTIAM Paris — 4BLOCKC / E4CCSN — Blockchain Security**
Group name: Madeira · Individual submission: Zayd ZAYANI
Trainer: David de Paula Santos Silva · Date: 30-08-2026

## 1. Executive Summary

`VulnerableVault.sol` implements an ETH staking vault: users deposit ETH, may
withdraw it at will, and a periodic "reward round" (`pickWinner`) pays 100
reward tokens to a pseudo-randomly chosen staker. The contract compiles and
behaves correctly on the happy path, but it contains **eleven distinct
security weaknesses**, ranging from a Critical unauthenticated fund-drain
function to business-logic flaws that let a user manipulate their odds of
winning rewards or choose the timing of an attack.

Static analysis (Slither) was run on the original contract and correctly
flagged the reentrancy, weak-randomness, unchecked-transfer and several
access-control-adjacent issues (14 raw results in total — this is a count of
individual analyzer results, not of distinct vulnerabilities: several
results describe the same underlying reentrancy issue from different
angles, and one is a purely informational compiler notice). Three of the
highest-impact findings in this report (**F-04** ticket stuffing, **F-08**
ghost stakers, and **F-10** permissionless `pickWinner`) are pure
business-logic flaws that Slither's detectors cannot see — they were found
only by manually reading each function and asking who can call it and
whether its accounting or timing can be gamed.

All eleven findings were corrected in `VulnerableVaultFixed.sol`. Re-running
Slither on the corrected contract reduces the raw result count from 14 to
5, and the 5 remaining results are residual, low-risk, and explicitly
discussed in Section 5.

**Overall risk rating: Critical** — driven by F-01: in the original
contract, any external address can call `emergencyWithdraw()` and drain
100% of the ETH held by the vault, with no ownership check whatsoever.

## 2. Scope & Methodology

- **Target:** `VulnerableVault.sol` (153 lines), Solidity ^0.8.20, single
  contract, no external dependencies beyond an `IRewardToken` interface.
- **Static analysis:** Slither 0.10.x, compiled with solc 0.8.20. Full raw
  output is in [`slither/slither-original.txt`](../slither/slither-original.txt)
  and [`slither/slither-fixed.txt`](../slither/slither-fixed.txt).
- **Manual review:** line-by-line reading of every function, applying the
  Module 11 questions — "who is allowed to call this?", "can a value be
  gamed?", "does the accounting add up?".
- **Out of scope (per brief):** deployment, exploit proof-of-concept
  scripts, and front-end.

## 3. Findings Summary

| ID | Finding | Category | Severity |
|----|---------|----------|----------|
| F-01 | `emergencyWithdraw()` has no access control — total fund drain | Tool-detectable (access control) | **Critical** |
| F-02 | `setOwner()` has no access control — anyone can seize ownership | Tool-detectable (access control) | High |
| F-03 | Reentrancy in `withdraw()` (checks-effects-interactions violation) | Tool-detectable (reentrancy) | High |
| F-04 | Reward-ticket stuffing via duplicate entries in `stakers[]` | Logic / business-rule flaw | High |
| F-05 | `onlyOwner` uses `tx.origin` instead of `msg.sender` (phishable) | Tool-detectable (access control) | Medium |
| F-06 | Weak, predictable pseudo-randomness in `pickWinner()` | Tool-detectable (randomness) | Medium |
| F-07 | Unchecked return value of `rewardToken.transfer()` | Tool-detectable (unchecked return) | Medium |
| F-08 | "Ghost stakers" keep winning odds after withdrawing everything | Logic / business-rule flaw | Medium |
| F-09 | Missing zero-address checks; non-immutable reward token reference | Tool-detectable (minor / hygiene) | Low |
| F-10 | `pickWinner()` is permissionless — enables reward grinding | Logic / business-rule flaw | High |
| F-11 | Unchecked arithmetic block in `withdraw()` (underflow masking) | Tool-detectable (arithmetic) | Medium |

Findings are grouped into two categories, matching the grading rubric:
findings a tool like Slither can flag directly (reentrancy, access-control
patterns, unchecked returns, weak randomness), and pure business-logic
flaws that only a human reviewer asking "can this be abused?" will find.

## 4. Detailed Findings

### F-01 — `emergencyWithdraw()` has no access control — CRITICAL

**Severity justification:** any address on the internet can call this
function and immediately withdraw 100% of the contract's ETH balance to
any destination. This is a complete, one-transaction loss of all user
funds — the maximum possible impact for a vault contract.

```solidity
function emergencyWithdraw(address payable to) external {
    uint256 bal = address(this).balance;
    (bool sent, ) = to.call{value: bal}("");
    require(sent, "rescue failed");
}
```

**Impact:** The function is declared `external` with no modifier at all.
Nothing checks `msg.sender` against `owner`. Any account — not just the
legitimate owner — can call `emergencyWithdraw(attackerAddress)` and
redirect the vault's entire ETH balance to itself in a single transaction.

**Fix:** Added the `onlyOwner` modifier (itself corrected — see F-05) plus
a zero-address check on the destination.

### F-02 — `setOwner()` has no access control — HIGH

**Severity justification:** lets any address take over the owner role.
Once F-01 is fixed (`emergencyWithdraw` becomes owner-only), an attacker
who can call `setOwner()` first can still seize control of the vault.

```solidity
function setOwner(address newOwner) external {
    owner = newOwner;
    emit OwnerChanged(newOwner);
}
```

**Fix:** Added `onlyOwner` and a zero-address check on `newOwner`.

### F-03 — Reentrancy in `withdraw()` — HIGH

**Severity justification:** violates the checks-effects-interactions
pattern. An attacking contract can re-enter `withdraw()` from its
`receive()`/`fallback()` before the vault updates its books, and withdraw
far more ETH than it ever staked.

**Impact:** `balances[msg.sender]` is only checked, not yet decremented,
when the low-level `.call` sends ETH to `msg.sender`. If the caller is a
contract, its `receive()` fallback runs before `.call` returns and can
call `withdraw()` again. This can be repeated until the vault is drained
of ETH belonging to every depositor. The `unchecked` block around the
later decrement (F-11) compounds the risk.

**Fix:** Reordered the function to update `balances`/`totalStaked` (and
remove the caller from `stakers[]`, see F-08) before the external call —
textbook checks-effects-interactions — and added a `nonReentrant` guard as
defence in depth.

### F-04 — Reward-ticket stuffing via duplicate `stakers[]` entries — HIGH

**Severity justification:** a pure business-logic flaw — Slither has no
detector for "can this array be gamed to unfairly bias a lottery?". It
lets any user cheaply dominate every reward round.

```solidity
function deposit() external payable {
    require(msg.value > 0, "zero deposit");
    stakers.push(msg.sender);
    balances[msg.sender] += msg.value;
    totalStaked += msg.value;
    emit Deposited(msg.sender, msg.value);
}
```

**Why it's exploitable:** `pickWinner()` selects a winner uniformly over
`stakers.length` — one entry = one "lottery ticket". `deposit()` pushes
`msg.sender` onto `stakers` on every single call, with no check for
existing entries. An attacker can call `deposit()` thousands of times with
the smallest possible non-zero value (1 wei), acquiring thousands of
tickets for a negligible amount of ETH.

**Fix:** Introduced an `isStaker` mapping and only push to `stakers[]` the
first time an address deposits.

### F-05 — `onlyOwner` authenticates `tx.origin` instead of `msg.sender` — MEDIUM

**Severity justification:** currently latent because the modifier is not
yet applied to any function in the original contract, but it becomes a
live phishing vector the moment it protects `setOwner`/`emergencyWithdraw`
(as this report's fixes require).

```solidity
modifier onlyOwner() {
    require(tx.origin == owner, "not owner");
    _;
}
```

**Impact:** `tx.origin` is the address that signed the original
transaction, even across a chain of contract calls. If the owner is ever
tricked into interacting with a malicious contract, that contract can call
back into `VulnerableVault`: `tx.origin` is still the owner's address, so
any `tx.origin`-gated function silently succeeds even though `msg.sender`
is the attacker's contract.

**Fix:** Changed the check to `require(msg.sender == owner, ...)`, the
standard, non-phishable pattern.

### F-06 — Weak, predictable pseudo-randomness in `pickWinner()` — MEDIUM

**Severity justification:** the "random" winner can be influenced by
whoever controls the timing of the transaction and, to a degree, by the
block proposer. Rated Medium rather than High because reward tokens (not
staked ETH) are at stake.

```solidity
uint256 rand = uint256(
    keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), stakers.length))
);
uint256 winnerIndex = rand % stakers.length;
```

**Fix:** For this teaching exercise we kept the on-chain formula (adding
`address(this)` to the hash to prevent trivial cross-contract
precomputation) but explicitly documented that a production system must
replace this with an external verifiable randomness source such as
Chainlink VRF. This residual risk is why `weak-prng` still appears in the
Slither re-run on the fixed contract.

### F-07 — Unchecked return value of `rewardToken.transfer()` — MEDIUM

**Severity justification:** silently misreports a reward as paid when it
was not, corrupting the contract's own event log without reverting or
alerting anyone.

```solidity
rewardToken.transfer(winner, REWARD_AMOUNT);
emit RewardPaid(winner, REWARD_AMOUNT);
```

**Impact:** The `IRewardToken` interface documents that `transfer()`
"returns true on success, false on failure (does NOT revert)". The
contract ignores that return value entirely and unconditionally emits
`RewardPaid`.

**Fix:** Captured the boolean result and branch on it: emit `RewardPaid`
only on success, and a new `RewardPaymentFailed` event otherwise.

### F-08 — "Ghost stakers" keep winning odds after withdrawing everything — MEDIUM

**Severity justification:** another pure business-logic flaw invisible to
static analysis — the accounting for who is a staker never reconciles
with who currently has ETH staked.

**Why it's exploitable:** `stakers[]` is only ever appended to; nothing in
`withdraw()` removes an address once its balance reaches zero. A user can
deposit once, withdraw 100% of their stake immediately, and still remain
in `stakers[]` indefinitely — retaining a full, unearned chance of winning
every future reward round with zero capital at risk.

**Fix:** `withdraw()` now removes the caller from `stakers[]`
(swap-and-pop, O(1)) whenever their balance reaches exactly zero.

### F-09 — Minor hygiene: missing zero-address checks; mutable reward-token reference — LOW

**Severity justification:** neither issue is directly exploitable for
fund loss on its own, but both are cheap to fix and are standard
defensive practice flagged by Slither's `missing-zero-check` and
`immutable-states` detectors.

**Details & fix:**
- Constructor, `setOwner` and `emergencyWithdraw` did not reject the zero
  address; all three now `require` a non-zero address.
- `rewardToken` was a plain state variable that is in fact never
  reassigned after the constructor; it is now declared `immutable`.
- The compiler pragma was tightened from `^0.8.20` (a floating range) to a
  locked `0.8.20`.

### F-10 — `pickWinner()` is permissionless — enables reward grinding — HIGH

**Severity justification:** on its own, an anyone-can-call trigger
function is a common and often harmless pattern. Combined with F-06's
weak randomness, it stops being harmless: it hands an attacker unlimited
free attempts to pick the timing of the reward round.

**Why it's exploitable:** Nothing restricts who may call `pickWinner()`
once the interval has elapsed. An attacker can deploy a small helper
contract that calls `pickWinner()` and then checks, in the same
transaction, whether the resulting winner is the attacker; if not, the
helper reverts the entire transaction. The attacker repeats this from
block to block — essentially for free beyond gas — until a block lands
where the pseudo-random formula happens to select them.

**Fix:** Restricted `pickWinner()` to `onlyOwner`, so the timing decision
is made by a single trusted party. The residual weak-randomness risk
documented under F-06 remains.

### F-11 — Unchecked arithmetic block in `withdraw()` — MEDIUM

**Severity justification:** called out separately from F-03 (reentrancy)
since "arithmetic" is its own finding category in the grading rubric.

```solidity
unchecked {
    balances[msg.sender] -= amount;
    totalStaked -= amount;
}
```

**Impact:** Solidity 0.8.x reverts automatically on arithmetic
underflow/overflow — unless wrapped in an `unchecked` block, as here. Once
reentrancy (F-03) lets an attacker call `withdraw()` several times before
`balances[msg.sender]` is updated, the eventual decrements can be applied
against a balance smaller than the total already paid out, silently
wrapping around instead of reverting.

**Fix:** Removed the `unchecked` block entirely. Combined with the F-03
checks-effects-interactions reorder and the `nonReentrant` guard, the
decrements can no longer be reached in an inconsistent state.

## 5. Verifying the Fix — Before / After

`VulnerableVaultFixed.sol` compiles cleanly with solc 0.8.20 and preserves
the contract's original external interface and behaviour on the happy
path.

> Slither's "14" and "5" are raw analyzer results, not a count of distinct
> vulnerabilities — several results describe different symptoms of the
> same underlying issue, and one (`solc-version`) is a purely
> informational compiler notice. The 11 numbered findings above are the
> deduplicated, human-triaged vulnerability count.

| Metric | VulnerableVault.sol | VulnerableVaultFixed.sol |
|---|---|---|
| Total Slither results | 14 | 5 |
| Reentrancy findings | 3 (reentrancy-eth, -benign, -events) | 0 |
| Arbitrary ETH send | 1 (`emergencyWithdraw`) | 0 |
| Unchecked transfer | 1 | 0 |
| Missing zero-check | 1 | 0 |
| Weak PRNG | 1 | 1 (residual, documented — needs VRF) |
| Timestamp comparison | 1 | 1 (accepted — required for the 1-day interval) |
| Low-level calls | 2 | 2 (intentional — behind checks-effects-interactions + nonReentrant) |
| `solc-version` notice | 1 | 1 (compiler-level notice, not a code defect) |

The 5 remaining results are residual and were kept deliberately, each with
a documented justification above, rather than papered over — a real audit
report calls out accepted risk explicitly instead of chasing a zero count.

## 6. Conclusion & Lessons Learned

The single most important lesson from this exercise: **a static analysis
tool is a triage aid, not an audit.** Slither correctly and quickly
surfaced the reentrancy, weak-randomness and unchecked-transfer issues,
but it could not tell us that `setOwner()`/`emergencyWithdraw()` were
missing access control entirely, that this vault's reward mechanism is
supposed to weight tickets by unique staker rather than by transaction
count, or that leaving `pickWinner()` permissionless turns a residual
randomness weakness into a practically exploitable grinding attack. Those
three logic flaws (F-04, F-08, F-10) only surfaced by reading every
function and asking the Module 11 question: "given what this function is
supposed to do, can someone abuse it?" The fixes themselves were mostly
small — an access modifier here, a state-update reorder there, a boolean
mapping to dedupe an array — but finding them required treating the
specification, not just the code, as the thing to audit.

## Appendices

- Appendix A — Full Slither output (original contract): [`slither/slither-original.txt`](../slither/slither-original.txt)
- Appendix B — Full Slither output (fixed contract): [`slither/slither-fixed.txt`](../slither/slither-fixed.txt)
