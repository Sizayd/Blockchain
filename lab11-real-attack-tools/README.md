# Lab 11 — Real Attack Tools

## Part A — Price of a real 51% attack (crypto51.app)

crypto51.app shows the live theoretical cost of a 51% attack on various
cryptocurrencies, calculated from network hashrate and NiceHash rental
price.

**Cost of attacking Bitcoin:** ~$2,042,310 for a 1-hour attack (831,288
PH/s in SHA-256). Bitcoin's hashrate is far too high to be rented — its
"NiceHash-able" column sits at 0%.

**Cheapest coin to attack:** several micro-caps show an attack cost
rounded to $0/h (Satoxcoin, Frencoin, Halcyon, Mooncoin, Orbitcoin,
Kerrigan-X11, 01coin...) — their hashrate is so low that renting enough
power costs almost nothing. The cheapest with a non-zero cost is **Stohn
Coin (SOH)**, at roughly $1 for one hour of attack.

| Coin | Algorithm | 1h attack cost | NiceHash-able |
|---|---|---|---|
| Bitcoin (BTC) | SHA-256 | $2,042,310 | 0% |
| Stohn Coin (SOH) | Scrypt | ~$1 | 630,064% |
| Frencoin (FREN) | KawPow | ~$0 | 35,660% |
| Satoxcoin (SATOX) | KawPow | ~$0 | 52,256% |
| 01coin (ZOC) | NeoScrypt | ~$0 | 9,244,536% |

**One-line insight:** for almost every small cryptocurrency (except BTC,
BCH and ETC, under 2%), the NiceHash-able percentage vastly exceeds
100% — up to 9,244,536% for 01coin — meaning anyone can rent, in a few
clicks and for a few dollars, far more than the network's entire hashing
power, making the attack trivial and immediate without owning any
hardware.

## Part B — Double-spend simulator (`double_spend_sim.py`)

Simulates the Nakamoto race between the honest chain and a secret chain
mined by the attacker, over 20,000 trials per power level, for three
confirmation depths Z (1, 6, 12).

**Step 5 — vary attacker power:** the script sweeps attacker power from
10% to 60% in steps of 5% (`for pct in range(10, 61, 5)`).

**Step 6 — vary confirmation depth Z:** the script reruns the whole
simulation for three confirmation depths (Z = 1, 6, 12) to compare their
effect on success rate.

### Example results — success rate vs. attacker power

| Attacker power | Z = 1 conf. | Z = 6 conf. | Z = 12 conf. |
|---|---|---|---|
| 10% | 1.3% | 0.0% | 0.0% |
| 20% | 6.2% | 0.0% | 0.0% |
| 30% | 18.6% | 0.2% | 0.0% |
| 40% | 44.0% | 5.6% | 0.5% |
| 45% | 66.8% | 24.5% | 7.2% |
| 50% | 96.1% | 86.8% | 75.2% |
| 55% | 100.0% | 100.0% | 100.0% |
| 60% | 100.0% | 100.0% | 100.0% |

### Is the threshold exactly 50%?

- **No** — the success rate increases progressively well before 50%
  (from ~35-40% with few confirmations), and is never zero below 50%: the
  attacker can get lucky even at low power.
- **At exactly 50%,** success is still not guaranteed (75.2% to 96.1%
  depending on Z): only beyond 50% does the attack become a near
  certainty (100% from 55%).
- **The number of confirmations Z is the real lever of defence:** at
  equal power, going from Z=1 to Z=12 drops the success rate sharply
  (e.g. at 45% power: 66.8% → 7.2%).

"51%" therefore describes a success probability that climbs steeply
around half of network power, not a hard, binary line at exactly 50%.

## Deliverable summary

- **Cheapest coin to attack:** Stohn Coin (SOH), ~$1 for 1h (several
  other micro-caps round to $0).
- **NiceHash-able insight:** for almost all small cryptocurrencies, the
  rentable percentage exceeds 100% (up to millions of %), making the
  attack trivial and near-free.
- **Success vs. hash power:** success climbs continuously around 50% (no
  sharp threshold) and depends heavily on the number of confirmations Z
  chosen by the merchant.

## Run it

```bash
python double_spend_sim.py
```
