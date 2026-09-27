# Lab — Ethernaut Setup Guide

Module 11 · Hack real contracts (Ethernaut) · Blockchain Security
(4BLOCKC / E4CCSN) · ÉSTIAM Paris

Ethernaut is OpenZeppelin's smart-contract wargame — each level is a real
vulnerable contract you exploit in the browser. Everything runs on a free
test network — no real money is ever used. Do this setup **before** the
lab.

## 1 · Install MetaMask

1. Install the MetaMask browser extension from metamask.io/download
   (Chrome, Brave, Firefox or Edge).
2. Create a new wallet when prompted. Write down the Secret Recovery
   Phrase and keep it offline — never share it with anyone.

> **Use a throw-away wallet.** Treat this wallet as disposable for the
> course. Never put real cryptocurrency into it — only free test ETH.

## 2 · Switch to the Sepolia test network

1. Open MetaMask → network selector (top-left) → enable *Show test
   networks* if needed.
2. Select **Sepolia**.

## 3 · Get free Sepolia test ETH

1. Go to a Sepolia faucet (e.g. the MetaMask/Infura Sepolia faucet, or
   Alchemy / QuickNode / Google Cloud's faucets if one is dry or rate-limited).
2. Connect your wallet (or paste your address) and request test ETH.
3. Wait until the test ETH shows up in MetaMask on Sepolia (usually under
   a minute).

## 4 · Open Ethernaut and connect

1. Go to ethernaut.openzeppelin.com.
2. Read Level 0 ("Hello Ethernaut") — it walks you through connecting
   your wallet and using the console.
3. Open the browser console: F12 (or right-click → Inspect) → Console.
4. Test it: type `player` and press Enter — prints your wallet address.
   Type `await getBalance(player)` to see your test-ETH balance.

## How each level works

1. Click **Get New Instance** — confirm in MetaMask (deploys your own
   copy of the level, costs a little test gas).
2. Exploit the contract from the console (or Remix).
3. Click **Submit Instance** — confirm in MetaMask. If you succeeded, the
   level turns complete.

## Your levels (each maps to a Module 11 bug)

- **Level 3 — Coin Flip** → bad randomness (compute the flip first).
- **Level 4 — Telephone** → access control via `tx.origin`.
- **Level 10 — Re-entrancy** → drain the contract.
- Stretch: **Level 5 — Token** → arithmetic underflow.

**Deliverable:** complete Coin Flip (Level 3) + one more; for each, note
the vulnerability and its one-line fix, and screenshot the "level
complete" state.

## Troubleshooting

- **No test ETH / transaction fails:** re-check the faucet step and make
  sure MetaMask is on Sepolia.
- **Wrong network warning:** switch MetaMask to Sepolia and refresh.
- **Console shows errors:** refresh, reconnect the wallet, re-check that
  `player` returns your address.
