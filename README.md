# Blockchain Security — ÉSTIAM 4BLOCKC / E4CCSN

**Étudiant :** Zayd ZAYANI

Coursework labs (1 to 13) and final project for the Blockchain Security
module: cryptographic hashing, block/transaction anatomy, incident triage,
consensus (PoW/PoS), privacy, static analysis (Slither), hardening,
secure deployment, real attack economics, historical CVEs, Ethernaut, and
a full smart-contract security audit.

## Structure

| Folder | Lab | Content |
|---|---|---|
| `lab01-hashing-avalanche/` | Lab 1 | SHA-256 avalanche effect, hash length vs. runtime, SHA3 vs. Keccak, Bitcoin block hash |
| `lab02-anatomy-of-a-block/` | Lab 2 | Ethereum block/transaction anatomy, parent-hash verification, finality analysis |
| `lab03-incident-triage/` | Lab 3 | 5 incident scenarios: 51% attack, key leak, front-end tampering, Eclipse attack, sabotage |
| `lab04-proof-of-work/` | Lab 4 | `pow_demo.py` — mining difficulty comparison, tamper-detection test |
| `lab05-proof-of-stake/` | Lab 5 | `pos_simulator.py` — stake-weighted proposer selection + slashing |
| `lab07-trace-privacy-transactions/` | Lab 7 | Bitcoin vs. Monero traceability, privacy primitives |
| `lab08-slither-audit/` | Lab 8 | `Vulnerable.sol` reentrancy audit + Checks-Effects-Interactions fix |
| `lab09-hardening-checklist/` | Lab 9 | USER / NODE / NETWORK hardening checklist |
| `lab10-secure-deployment-review/` | Lab 10 | Hyperledger Fabric deployment review (ops/data/infra/legal) |
| `lab11-real-attack-tools/` | Lab 11 | `double_spend_sim.py` — crypto51.app cost analysis + Nakamoto race simulation |
| `lab12-real-vulnerability-record/` | Lab 12 | CVE-2010-5139 & CVE-2018-17144 (Bitcoin Core) |
| `lab13-ethernaut/` | Lab 13 | `CoinFlipAttack.sol` / `TelephoneAttack.sol` — Ethernaut Levels 3 & 4 |
| `setup/` | — | Ethernaut setup guide (Module 11) |
| `final-project-vulnerablevault/` | Final Project | Full Slither + manual audit of `VulnerableVault.sol` (11 findings, fixed contract, slides) |

> Lab 6 was not part of the uploaded coursework and is not included here.

## Final project highlight

The final project (`final-project-vulnerablevault/`) is the flagship
deliverable: a from-scratch ETH staking vault contract seeded with 11
security findings (access control, reentrancy, weak randomness,
unchecked returns/arithmetic, and 3 pure business-logic flaws Slither
cannot detect), a fully corrected version, the raw Slither before/after
output, the full written audit report, and the presentation deck.

```bash
cd final-project-vulnerablevault
pip install slither-analyzer
solc-select install 0.8.20 && solc-select use 0.8.20
slither contracts/VulnerableVault.sol
```

See [`final-project-vulnerablevault/docs/audit-report.md`](final-project-vulnerablevault/docs/audit-report.md)
for the complete write-up.
