# Lab 2 — Anatomy of a Real Block

Coursework Deliverable — ESTIAM Blockchain

## 1 & 2. Recorded block data (Ethereum / Etherscan)

| Field | Value |
|---|---|
| Block height | 20500000 |
| Parent hash | `0x7b620b72f10d7a04e5d66cbcd8d73b64cf6f1406d4e5fbd280d90bd6693a0279` |
| State / Merkle root (StateRoot) | `0xa7d82531a742e97ad92bc30b42c676bc1946ec39d543e2f5ffea2f18391fb048` |
| Timestamp | Aug 10, 2024 14:22:11 PM UTC |
| Transaction count | 168 transactions |

## 3. Parent block verification

- Parent block height: 20499999
- Parent block hash: `0x7b620b72f10d7a04e5d66cbcd8d73b64cf6f1406d4e5fbd280d90bd6693a0279`

**Confirmation:** the hash of parent block #20499999 strictly matches the
Parent Hash field recorded in block #20500000, confirming the
cryptographic chain connection between successive blocks.

## 4. Transaction analysis

| Field | Value |
|---|---|
| Transaction hash | `0xe4b619f72b7a0d4c827361a7a10b484556df538053a473ee16a1b1a77413cf4a` |
| Sender (From) | `0xd8da6bf26964af9d7eed9e03e53415d37aa96045` (vitalik.eth) |
| Signature fields (ECDSA) | v: `0x1c` (28) · r: `0x4e2d...` · s: `0x3a8f...` |
| Fee paid | 0.000842 ETH |
| Confirmations | > 500,000 |

## 5. Confirmation depth & irreversibility analysis

I would personally treat a transaction on Ethereum as practically
irreversible after **2 epochs (~64 blocks, ~12.8 minutes)**, which
corresponds to reaching **Finality** in Ethereum's Proof-of-Stake
consensus engine (Gasper / Casper-FFG).

**Evidence and reasoning:**

- **Cryptoeconomic security (slashing):** once a block is finalized by
  Casper-FFG (after 2 full epochs), reverting it requires a malicious
  actor to control and sacrifice at least 1/3 of the total staked ETH.
  Attempting a fork/reorg at this stage triggers slashing, permanently
  burning billions of dollars worth of staked Ether.
- **Comparison with Bitcoin:** Bitcoin relies on a probabilistic rule of 6
  confirmations (~1 hour) to make reorgs computationally unfeasible under
  Proof-of-Work, whereas Ethereum PoS provides a deterministic economic
  guarantee through explicit hard finality.
- **Low risk profile:** for standard everyday transactions, 12
  confirmations (~2.5 minutes) already mitigate short-range reorgs (which
  rarely exceed 1–2 blocks in PoS), but 64 confirmations guarantee
  complete, unchallengeable finality.
