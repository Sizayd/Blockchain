# Lab 13 — Hack Real Contracts (Ethernaut)

Ethernaut is OpenZeppelin's smart-contract wargame: each level is a real
vulnerable contract, deployed on the Sepolia testnet, exploited from the
browser (console or Remix). Deliverable: complete Coin Flip (Level 3) plus
one additional level, with the vulnerability, one-line fix, and a "level
complete" screenshot for each.

**Environment:** MetaMask (throw-away wallet), Sepolia testnet, Sepolia
test ETH via a faucet, ethernaut.openzeppelin.com, browser console (F12),
Remix IDE. Workflow per level: *Get New Instance → exploit → Submit
Instance*.

## Level 3 — Coin Flip

**Vulnerability:** the contract derives its result from the previous
block's hash (`blockhash(block.number - 1)`) divided by a known constant
`FACTOR`. Fully deterministic and readable by anyone before the call.

**Attack:** `contracts/CoinFlipAttack.sol` reproduces the exact same
calculation, within the same transaction as the call to `flip()`,
guaranteeing both read the same blockhash. Deployed via Remix (Injected
Provider — MetaMask) with the Coin Flip instance address as the
constructor argument, then `attack()` is called repeatedly until
`consecutiveWins()` reaches 10.

**Fix:** use a secure, verifiable randomness source such as Chainlink VRF
instead of block data.

## Level 4 — Telephone

**Vulnerability:** the contract only allows the owner to change if
`tx.origin != msg.sender`. A direct wallet call always has
`tx.origin == msg.sender`. Routing the call through an intermediate
contract makes `tx.origin` (the wallet) differ from `msg.sender` (the
intermediate contract), satisfying the condition.

**Attack:** `contracts/TelephoneAttack.sol` — the entire exploit fits in
the constructor: on deployment it calls `changeOwner` while acting as the
intermediary.

**Verification:**
```
await contract.owner() → <player address>
player                  → <player address>
```
Both addresses match: the player's wallet has become the contract's owner.

**Fix:** use `msg.sender` rather than `tx.origin` for any authorization
check.

## Results summary

| Level | Vulnerability | Exploit | One-line fix |
|---|---|---|---|
| 3 — Coin Flip | Predictable randomness (blockhash + known constant) | Reproduce the blockhash calculation in an attack contract, call `flip()` | Use Chainlink VRF instead of block data |
| 4 — Telephone | `tx.origin` access-control flaw | Intermediate contract so `tx.origin` (wallet) ≠ `msg.sender` (contract) | Use `msg.sender` rather than `tx.origin` |

## Quick reference — browser console

```js
player                          // your connected wallet
await getBalance(player)        // Sepolia test-ETH balance
contract.address                // current Ethernaut instance address
await contract.consecutiveWins() // Coin Flip progress
await contract.owner()          // Telephone owner
```

## Conclusion

Coin Flip demonstrates why blockchain-derived values such as a blockhash
should never serve as a source of randomness for security-sensitive
decisions. Telephone demonstrates why `tx.origin` should never be used for
authorization: an intermediate contract can always make `msg.sender`
different from `tx.origin`. Both levels show how a seemingly minor design
assumption becomes an exploitable smart-contract vulnerability.
