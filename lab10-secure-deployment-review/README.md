# Lab 10 — Secure Deployment Review (Hyperledger Fabric)

**Scenario:** a logistics consortium is about to launch a Hyperledger
Fabric network. Their plan: store shipment records including driver names
and ID numbers directly on-chain; one company holds all admin keys; nodes
run on one cloud account; "we'll check compliance after launch."

## Analysis across the four pillars

### 1. OPERATIONS — the key setup problem

**Gap:** a single company holds all administration keys for the network.
In a consortium meant to be decentralized, this recreates a single point
of trust: that company alone can certify new members, revoke identities,
change channel policy, or alter governance — with no oversight from other
members.

**Fix:** distribute administration roles per Fabric's MSP (Membership
Service Provider) model: each consortium organization manages its own CA
and identities. Critical decisions (channel policy changes,
adding/removing a member) require a multi-organization signature
(collective approval policy), with keys stored in HSMs and a regular
key-rotation policy.

### 2. DATA — the GDPR landmine

**Gap:** storing driver names and ID numbers directly on-chain is a GDPR
landmine — a blockchain is immutable by design, yet GDPR grants a right
to erasure and rectification (Art. 17). Once personal data is written to
the ledger, it can no longer be technically deleted or corrected.

**Fix:** never put personal data in cleartext on-chain. Store identifying
data off-chain (a regular database or Fabric's Private Data Collections),
and only put a hash or an encrypted reference on-chain. Apply data
minimization; encrypt any personal data genuinely needed, with decryption
keys managed off-chain (allowing "effective erasure" by destroying the
key).

### 3. INFRASTRUCTURE — the single point of failure

**Gap:** all network nodes run on a single cloud account. This defeats the
purpose of a decentralized consortium network: an outage, account
suspension, misconfiguration, or compromise at that provider can bring
down the entire network (peers, orderers, CA) in one incident.

**Fix:** each consortium member should host its own nodes on its own
infrastructure/cloud account, ideally across different providers and
regions. The ordering service should also be distributed across multiple
organizations (e.g. multi-org Raft) so no single actor can interrupt
consensus.

### 4. LEGAL — the wrong compliance timing

**Gap:** "we'll check compliance after launch" reverses the correct legal
order: GDPR requires data protection by design (Art. 25), and for a
high-risk processing activity like this one (identity data, immutability),
a Data Protection Impact Assessment (DPIA, Art. 35) is required before
any processing takes place.

**Fix:** carry out a DPIA and full legal review before launch, involve a
DPO from the design phase onward, and obtain formal compliance sign-off
before going into production.

## Most urgent gap: DATA

The OPERATIONS and INFRASTRUCTURE gaps are serious but reversible: key
governance can be reconfigured, nodes redeployed onto distributed
infrastructure after the fact, without losing any data. The LEGAL gap is
a process problem that can still be fixed as long as nothing is yet in
production.

The DATA gap becomes irreversible the moment the first transaction is
written: once a driver's name or ID number is recorded on an immutable
ledger, it can no longer be deleted or corrected — even if the company
changes its mind or receives a GDPR erasure request. Fixing this after
launch requires forking the chain or abandoning its history — a massive
technical and legal cost — whereas fixing it before launch (off-chain +
hash) costs almost nothing. This is the only one of the four gaps that
**must** be addressed before a single transaction is ever written.
