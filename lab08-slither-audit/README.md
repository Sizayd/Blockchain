# Lab 8 — Audit a Solidity Contract with Slither

**Objective:** audit `Vulnerable.sol` with Slither, triage the findings,
identify the reentrancy vulnerability, fix `withdraw()` with the
Checks-Effects-Interactions pattern, and verify the fix with a second scan.

**Environment:** Windows, Python 3.14.5, Slither 0.11.6, Solidity compiler
0.8.36+commit.8a079791.Windows.msvc, 102 detectors.

> PATH fix needed for `solc` to be found by Slither:
> `set "PATH=%APPDATA%\Python\Python314\Scripts;%PATH%"`

## Initial findings & triage

| Detector | Triage | Severity | Reason |
|---|---|---|---|
| `reentrancy-eth` | Real vulnerability | High | External ETH call occurs before `balances[msg.sender]` is cleared. |
| `solc-version` | Real finding | Low / Informational | `^0.8.0` is broad and includes compiler versions with known issues. |
| `low-level-calls` | Real warning | Low | A low-level call can execute code in the recipient and requires careful handling. |
| `immutable-states` | Real finding / quality | Informational | `owner` could be declared immutable. |

## Fix — Checks-Effects-Interactions

`withdraw()` was rewritten so the state update happens **before** the
external interaction (see `contracts/VulnerableFixed.sol`).

## Verification after the fix

```
INFO:Slither:Vulnerable.sol analyzed (1 contracts with 102 detectors), 3 result(s) found
```

| Finding | Before | After |
|---|---|---|
| `reentrancy-eth` | Present | **Gone** |
| `solc-version` | Present | Present |
| `low-level-calls` | Present | Present |
| `immutable-states` | Present | Present |

## Conclusion

The audit identified four initial findings. The most important issue was
the real reentrancy vulnerability in `withdraw()`. The function was fixed
using Checks-Effects-Interactions by setting the user's balance to zero
before making the external ETH transfer. The second Slither run confirmed
the `reentrancy-eth` finding disappeared, reducing the reported results
from four to three. One-sentence takeaway: Slither detects suspicious code
patterns, but a human reviewer is still needed to understand the
contract's intended behavior and judge the security impact in context.

## Reproduce

```bash
pip install slither-analyzer
slither contracts/Vulnerable.sol
slither contracts/VulnerableFixed.sol
```
