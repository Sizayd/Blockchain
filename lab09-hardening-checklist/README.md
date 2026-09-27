# Lab 9 — Hardening Checklist (USER / NODE / NETWORK)

Coursework Deliverable — ESTIAM Blockchain Security

## 1. USER front — treasury management gap & fix

**Gap:** keeping the startup treasury in a shared browser extension wallet
(e.g. MetaMask) creates a critical single point of failure and a massive
attack surface. Shared seed phrases across team members increase exposure
to phishing, malicious browser extensions, keylogging, and internal rogue
actions.

**One-line fix:** migrate the treasury to a Safe (Gnosis Safe)
multi-signature smart contract wallet requiring m-of-n hardware security
keys (e.g. Ledger or Trezor) for transaction signing.

## 2. NODE front — cloud server exposure gap & fix

**Gap:** running an Ethereum node on a cloud server with publicly
accessible JSON-RPC / WebSocket ports (8545 / 8546) exposes administrative
API methods (`eth_*`, `admin_*`) to the public Internet, enabling
unauthorized transaction submission, node DoS, and resource exhaustion.

**One-line fix:** bind RPC interfaces strictly to `127.0.0.1` (or an
internal VPC subnet) and enforce an NGINX reverse-proxy with
authentication, TLS, and IP whitelist filtering.

## 3. NETWORK front — peer isolation & network gap & fix

**Gap:** deploying only one isolated cloud node leaves the system
vulnerable to Eclipse attacks, BGP route hijacking, and peer isolation,
where malicious peers manipulate the node's block view — leading to
double-spend exposure or unconfirmed transaction submission.

**One-line fix:** configure static peering with trusted bootnodes, enforce
peer diversity limits, and deploy redundant node instances across
multiple cloud providers and geographical regions.

## Summary table

| Front | Gap | One-line fix |
|---|---|---|
| USER | Shared hot wallet exposure | Migrate treasury to a Safe multi-sig wallet requiring m-of-n hardware keys |
| NODE | Unrestricted public RPC access | Bind RPC to `127.0.0.1`/private VPC + NGINX auth, TLS, rate-limiting |
| NETWORK | Single node isolation & Eclipse vulnerability | Static peering with trusted bootnodes + redundant nodes across providers/regions |

## Prioritization

**Fix the USER front first.** A compromised browser-extension wallet or
shared seed phrase leads to immediate, irreversible financial drain of
the entire treasury in a single transaction. Node RPC exposure or network
isolation pose operational and data-integrity risks, but they do not
directly grant an attacker total control over signing keys. Securing the
treasury via a multi-sig hardware setup mitigates catastrophic insolvency
before addressing infrastructure-level hardening.
