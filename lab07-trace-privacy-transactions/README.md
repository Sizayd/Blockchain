# Lab 7 — Trace Privacy: Bitcoin vs. Monero

Coursework Deliverable — ESTIAM Blockchain Security

## Step 1 — Bitcoin transaction analysis (mempool.space)

Inspecting a standard transaction on a public Bitcoin block explorer, all
operational metadata is fully transparent and pseudonymous:

- **Sender address(es):** the exact input address(es) spending the UTXOs
  are clearly visible.
- **Recipient address(es):** the exact destination address(es) (and any
  change output address) are fully displayed.
- **Amount transferred:** the exact BTC value (and fiat equivalent), plus
  the exact mining fee paid, is completely readable on-chain.

## Steps 2 & 3 — Monero transaction analysis & comparison (xmrchain.net)

Privacy primitives alter the visible parameters:

- **Ring members (sender obfuscation):** instead of a single input
  address, the explorer displays a list of ring members (e.g. ring size
  16: 1 real input + 15 decoy UTXOs). Outsiders cannot distinguish the
  true spender.
- **Stealth output (recipient obfuscation):** the recipient's real public
  wallet address is never published on-chain; a unique, one-time
  cryptographic Stealth Address output is created per transaction.
- **Hidden amount (confidential transactions):** the value displays as
  Confidential/Encrypted — transferred XMR and change amounts are
  concealed via Pedersen Commitments.

| Data element | Bitcoin (mempool.space) | Monero (xmrchain.net) |
|---|---|---|
| Sender identity | Fully visible (public input UTXO addresses) | Hidden (blended inside ring members / decoys) |
| Recipient identity | Fully visible (public output addresses) | Hidden (replaced by a one-time stealth address) |
| Transacted amount | Fully visible (exact satoshi/BTC value) | Hidden (encrypted via RingCT / Bulletproofs) |

## Step 4 — The three privacy primitives, what they hide

- **Ring Signatures (RingCT):** hide the real sender by mixing the real
  input UTXO with 15 decoy outputs.
- **Stealth Addresses:** hide the recipient's public wallet address by
  forcing payments onto a single-use, dynamically derived public key.
- **RingCT / Bulletproofs+:** hide the numerical amount transferred using
  zero-knowledge range proofs and cryptographic commitments, while still
  letting nodes verify input/output equality.

## Step 5 — Attacker view: how each primitive can be weakened

| Primitive | Vulnerability / weakness factor | Attacker exploitation vector |
|---|---|---|
| Ring Signatures | Small ring size / decoy analysis | If ring sizes are too small or known outputs are identified (zero-mix), statistical age-based analysis can isolate the real spender. |
| Stealth Addresses | Key reuse & off-chain metadata | Published payment IDs/view keys, or leaked metadata (IP logs, timestamp correlation, exchange KYC records), can link stealth outputs to real entities. |
| RingCT / Bulletproofs | Range proof implementation bugs | Complex zero-knowledge range proofs can contain implementation flaws (integer overflows, side-channel timing leaks) compromising amount confidentiality. |

## Step 6 — Is "private" the same as "untraceable"?

No. **"Private"** means transaction details (addresses, amounts) are
hidden from public view on-chain. **"Untraceable"** implies that no
heuristic, statistical analysis, or off-chain metadata (network timing, IP
logging, exchange KYC entry/exit points) can ever correlate and link the
transaction flow back to a real-world entity. Privacy is a property of
the on-chain data; traceability depends on everything surrounding it too.
