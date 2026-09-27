# Lab 6 — Read a Multisig + Design a Quorum

Coursework Deliverable — ESTIAM Blockchain

## Steps 1 & 2 — Multisig identification, owners & threshold policy

**Target smart contract:** GnosisDAO Safe (Governance Safe)
**Ethereum mainnet address:** `0x0DA0C3e52C977Ed3cBc641fF02DD271c3ED55aFe`
**Etherscan:** `https://etherscan.io/address/0x0DA0C3e52C977Ed3cBc641fF02DD271c3ED55aFe#readProxyContract`

### On-chain reading & verification proofs

- `getThreshold()` → returns **m = 3** (exactly 3 signatures required to
  execute any transaction).
- `getOwners()` → returns an array of **n = 6** owner EOA addresses:

| # | Owner EOA address |
|---|---|
| 1 | `0x849D52316331967b6fF1358e1E41D0e513EC99aF` |
| 2 | `0x19B91B4871e8B68C1C89F3b8FEaB1a8Ac0c94665` |
| 3 | `0x31a2933C402eC07817D50FE6fA4FA618035D4379` |
| 4 | `0x6e3bE11A0C16C97816dD0039A5D5515234F70b6C` |
| 5 | `0x937F9E0124aA20aF87123A8C6CEE78641EbA468a` |
| 6 | `0xEf65050C7738B124B5C1B920409A6b83b1B37d0E` |

**Policy summary:** 3-of-6 multisig. Moving treasury funds requires m = 3
valid ECDSA signatures out of n = 6 registered owner keys.

## Step 3 — Executed transaction analysis & confirmations count

**Function call analysed:** `execTransaction(...)`

**On-chain signature proof:** when executing a transaction, the Safe
smart contract parses the concatenated signatures passed in the `bytes`
parameter, recovers signer public-key addresses using `ecrecover`, and
verifies that at least 3 distinct addresses match the registered
`getOwners()` list.

**Confirmations carried:** exactly 3 valid owner confirmations,
fulfilling the on-chain threshold requirement.

## Step 4 — Startup treasury quorum design (3 founders + 1 CFO)

**Proposed quorum:** 3-of-4 multisig.

**Justification:** a 3-of-4 threshold ensures that no two colluding
individuals (two founders, or one founder and the CFO) can unilaterally
execute transactions, while guaranteeing operational continuity if any
single key is lost or unavailable.

### Quorum dynamics breakdown

| Scenario / Combination | Signatures collected | Threshold met (3/4)? | Outcome |
|---|---|---|---|
| Single rogue individual (e.g. CFO alone or 1 founder alone) | 1/4 | No | Blocked — unilateral execution impossible. |
| Two colluding individuals (e.g. 2 founders, or 1 founder + CFO) | 2/4 | No | Blocked — collusion prevented; requires a 3rd approval. |
| All 3 founders (without CFO) | 3/4 | Yes | Approved — full founder consensus allows business operations to proceed. |
| 2 founders + 1 CFO | 3/4 | Yes | Approved — normal executive transaction processing. |
| 1 key lost/unavailable | 3/4 remaining | Yes | Operational continuity — the remaining 3 key holders can execute transactions and rotate the lost key. |

## Step 5 — Threat task: key loss vs. key theft

- **If 1 key is lost:** operational activity continues without
  interruption. The remaining 3 key holders can still satisfy the 3-of-4
  quorum threshold to execute transactions and immediately sign a Safe
  proposal to swap the lost key for a new address.
- **If 1 key is stolen:** treasury assets remain secure. An attacker
  holding 1 compromised key cannot execute any transaction alone (stuck at
  1/3 signatures needed within the 3-of-4 policy). The 3 remaining
  legitimate owners can immediately initiate and execute a transaction to
  revoke the compromised key address.

## Step 6 — Threshold Signature Scheme (TSS) privacy analysis

**What TSS hides:** yes — TSS hides the multisig structure entirely from
outside observers, because off-chain threshold cryptography generates a
single standard ECDSA signature, making the transaction on-chain look
like an ordinary single-key transfer and concealing key identities,
quorum threshold, and participant participation.
