# Final Project — VulnerableVault Smart Contract Security Audit

ÉSTIAM Paris — 4BLOCKC / E4CCSN — Blockchain Security
Group: Madeira · Individual submission: Zayd ZAYANI

Full Slither + manual audit of an intentionally vulnerable ETH staking
vault: 11 findings identified (4 tool-detectable categories, 3 pure
business-logic flaws, misc. hygiene), all fixed in `VulnerableVaultFixed.sol`.

## Structure

```
contracts/
├── IRewardToken.sol          # Minimal reward-token interface
├── VulnerableVault.sol       # Original, vulnerable contract (audit target)
└── VulnerableVaultFixed.sol  # Corrected contract (11 findings resolved)
slither/
├── slither-original.txt      # Appendix A — raw Slither output (14 results)
└── slither-fixed.txt         # Appendix B — raw Slither output (5 residual)
docs/
├── audit-report.md           # Full audit report (this is the source of truth)
└── FinalProject_Audit_Report_VulnerableVault_original.pdf
presentation/
├── Presentation_VulnerableVault_Audit.pptx
└── Presentation_VulnerableVault_Audit.pdf
```

## Running the audit yourself

```bash
pip install slither-analyzer
solc-select install 0.8.20 && solc-select use 0.8.20

slither contracts/VulnerableVault.sol
slither contracts/VulnerableVaultFixed.sol
```

See [`docs/audit-report.md`](docs/audit-report.md) for the full write-up:
executive summary, methodology, the 11 findings (F-01 to F-11) with
vulnerable code / impact / fix for each, and the before/after Slither
comparison.
