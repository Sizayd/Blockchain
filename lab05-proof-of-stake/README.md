# Lab 5 — Stake, Vote, and Get Slashed (Proof of Stake)

Coursework Deliverable — ESTIAM Blockchain

`pos_simulator.py` runs a stake-weighted proposer-selection simulation
across 20 rounds, with validators Alice (100), Bob (50), Carol (25), Dave
(75, honest — Modification A) and Mallory (60, cheater — Modification B).

## Example run — slashing a cheater

```
======================================================================
STARTING VALIDATOR SET
======================================================================
  Alice    stake= 100 rewards=   0
  Bob      stake=  50 rewards=   0
  Carol    stake=  25 rewards=   0
  Dave     stake=  75 rewards=   0
  Mallory  stake=  60 rewards=   0  (Cheater)
Round  1: Carol proposes a block and earns 10 reward.
Round  2: Alice proposes a block and earns 10 reward.
Round  3: Mallory is proposer -> tries to sign TWO blocks (cheating!)
    !!! SLASHING Mallory: signed two blocks at the same height (equivocation).
    !!! Its stake of 60 is DESTROYED and it is EJECTED from the validator set.
Round  4: Dave proposes a block and earns 10 reward.
...
Round 20: Alice proposes a block and earns 10 reward.

======================================================================
RESULTS
======================================================================
How often each validator was chosen (should track stake):
  Alice    chosen 8 times   stake share now: 40%
  Bob      chosen 3 times   stake share now: 20%
  Carol    chosen 2 times   stake share now: 10%
  Dave     chosen 6 times   stake share now: 30%
  Mallory  chosen 1 times   stake share now: (ejected)

Final state of each validator:
  Alice    stake= 100 rewards=  80
  Bob      stake=  50 rewards=  30
  Carol    stake=  25 rewards=  20
  Dave     stake=  75 rewards=  60
  Mallory  SLASHED
```

## PoW vs. PoS security comparison

Proof of Work renders cheating irrational by forcing attackers to expend
unrecoverable external resources (electricity and specialized mining
hardware) to outcompute the network. In contrast, Proof of Stake enforces
honesty through internal economic penalties, where detectable cheating
triggers programmatic slashing that instantly destroys the attacker's
locked capital and ejects them from future consensus participation.

## Step-by-step execution summary

- **Steps 1 & 2 (stake-weighted proposer selection):** ran the simulator
  across multiple rounds. Selection probability directly matches validator
  stake proportions (e.g. Alice with 100 stake selected ~40% of the time,
  Carol with 25 stake selected ~10%).
- **Step 3 / Modification A (honest validator):** added Dave (stake=75,
  honest=True). Over 20 rounds Dave is selected proportional to his ~30%
  active stake share and accumulates rewards cleanly.
- **Steps 4 & 5 / Modification B & slashing rule:** added Mallory
  (stake=60, honest=False). Upon being selected, Mallory attempts to
  equivocate (sign two blocks at the same height). The slashing function
  triggers immediately, setting Mallory's stake to 0 and permanently
  removing her from subsequent proposer selection.

## Run it

```bash
python pos_simulator.py
```
