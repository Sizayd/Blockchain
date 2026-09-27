# Lab 3 — Incident Triage Report

Coursework Deliverable — ESTIAM Blockchain | Author: ZAYANI Zayd

For each incident: failed assumption, preventive control, detective
control, and the evidence a real investigation would request.

## Incident A — 51% Attack & Deep Chain Reorganization (Double Spend)

**Scenario:** a small chain's exchange credits a deposit after 6
confirmations. Hours later the deposit is no longer in the ledger and the
withdrawal has gone.

1. **Failed assumption:** that 6 block confirmations are universally
   sufficient for finality regardless of network hash rate security.
2. **Preventive control:** dynamic confirmation depth based on market
   capitalization / hash rate, or delayed withdrawals for low-security
   chains.
3. **Detective control:** automated chain reorganization monitoring
   (alerting on reorgs deeper than 2 blocks or sudden hash rate spikes).
4. **Requested evidence:** P2P node logs around the block height (to
   identify reorg depth), raw transaction hashes, block headers before
   and after the reorg, and exchange deposit/withdrawal database
   timestamps.

## Incident B — ECDSA Private Key Leak via Nonce Reuse / Bad RNG

**Scenario:** funds leave a mobile wallet. The user never shared anything.
The address had signed two transactions that week.

1. **Failed assumption:** that transaction signatures generated on the
   device never leak the underlying private key.
2. **Preventive control:** RFC 6979 deterministic nonce generation
   (k = HMAC-SHA256(privkey, message)) to prevent nonce reuse.
3. **Detective control:** automated wallet audit monitoring for identical
   r-values across outgoing transactions signed by the same public key.
4. **Requested evidence:** the raw signed hex strings of the two prior
   transactions (to check if r1 == r2), mobile wallet version/build, and
   public address.

## Incident C — Smart Contract Parameter Tampering / Front-End Injection

**Scenario:** three authorised signers approve a routine internal
transfer. The funds arrive somewhere else. Every signature verifies.

1. **Failed assumption:** that what the signers visually approved on the
   UI matches what was cryptographically encoded into the transaction
   payload.
2. **Preventive control:** WYSIWYS (What You See Is What You Sign)
   hardware wallets that parse and display target contracts and
   parameters on-device.
3. **Detective control:** simulation tools (e.g. Tenderly / Flashbots)
   pre-execution to flag destination address mismatch against a
   whitelist.
4. **Requested evidence:** the signed transaction payload (data bytes),
   ABI of the target contract, wallet logs/audit trail of the approval
   UI, and hardware wallet display logs.

## Incident D — Eclipse Attack / Isolated Node Invalidation

**Scenario:** a payment processor's node reports six confirmations for a
transaction no other node has ever seen.

1. **Failed assumption:** that an isolated node's local view of the
   blockchain reflects the global consensus of the main network.
2. **Preventive control:** peering diversification (static trusted nodes,
   multi-homed ISP connections, disabling peer discovery manipulation).
3. **Detective control:** cross-node consensus sanity checks (comparing
   local tip block hash with external public APIs like
   Etherscan/Mempool).
4. **Requested evidence:** node debug logs (`debug.log` / `getpeerinfo`),
   list of connected peer IP addresses, raw block headers received, and
   network routing logs.

## Incident E — State-Sponsored / Griefing / Consensus Sabotage Attack

**Scenario:** a chain is attacked at a cost far exceeding anything the
attacker could take from it.

1. **Failed assumption:** that all blockchain attackers act as rational
   economic actors driven purely by direct financial arbitrage/profit.
2. **Preventive control:** circuit breakers, emergency pause mechanisms,
   social consensus readiness, and Proof-of-Stake slashing penalties.
3. **Detective control:** anomalous hash rate spikes, mempool flooding,
   validator censorship metrics, and off-chain market short-position
   monitoring.
4. **Requested evidence:** network-wide telemetry data, miner/validator
   block production logs, mempool dump files, and derivative/short-position
   data on exchanges.
