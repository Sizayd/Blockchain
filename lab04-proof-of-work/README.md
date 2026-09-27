# Lab 4 — Proof of Work

**Objective:** run an educational blockchain node in Python 3, observe the
Proof of Work (PoW) mechanism, compare mining time at different difficulty
levels, display the nonce and elapsed mining time for each mined block,
and test the effect of tampering with an existing block.

**Original exercise:** cloned `simple-blockchain` from GitHub
(`git clone https://github.com/dougyoung/simple-blockchain`), executed with
`python run.py` on Windows CMD. `pow_demo.py` in this folder reproduces
the same mining/tamper-detection behaviour as a self-contained script.

## Modification A — display nonce and elapsed time

The `generate_block()` function was modified to record the start time of
mining. When a valid nonce is found, the program prints the block number,
nonce, and elapsed mining time, e.g.:

```
Block: 3
Nonce: 787922
Elapsed time: 14.0502 seconds
```

## Mining difficulty comparison

A smaller difficulty value makes the PoW condition harder to satisfy.
Mining time increases significantly as difficulty increases.

| Difficulty | Block | Nonce | Mining time |
|---|---|---|---|
| 1e72 (easy) | 1 | 9,938 | 0.2993 s |
| 1e71 | 3 | 787,922 | 14.0502 s |
| 1e70 (hard) | 1 | 23,068,545 | 487.3108 s (> 8 min) |

## Modification B — 10–30 second mining target

Difficulty `1e71` produced a block within the required 10–30 second
range: Block 3 was mined with nonce `787922` in `14.0502` seconds.

## Tamper test

A test blockchain with three mined blocks first validates successfully
(`Chain valid: True`). The payload of block 1 is then changed to
`"TAMPERED DATA"`.

| Tamper test | Result |
|---|---|
| Before tampering | `Chain valid: True` |
| Modified block | Block 1 — payload changed to `"TAMPERED DATA"` |
| Stored hash | `0000764c97ea4b85675ed859052f1af8b4ca07e9ead1eea24dbf1adea77d0d9f` |
| Recalculated hash | `4dbe27dc01765a1240aab1a7f968bdcc1dc72e0c4bcfd05b0be492be30618a47` |
| After tampering | `Chain valid: False` |

After the modification, the stored hash of block 1 no longer matches the
recalculated hash, so validation detects the tampering.

## Conclusion

Proof of Work requires increasingly more computational effort as difficulty
increases. The tamper test demonstrates the importance of cryptographic
hashing: changing the data of an existing block changes its hash, so a
mismatch between the stored and recalculated hash reveals the modification
and invalidates the chain.

## Run it

```bash
python pow_demo.py mine --difficulty 1e5 --blocks 3   # quick demo
python pow_demo.py tamper                              # tamper-detection demo
```
