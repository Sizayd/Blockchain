# Lab 1 — Hashing and the Avalanche Effect

Coursework Deliverable — ESTIAM Blockchain

## 1. Hash a string

```bash
printf 'ESTIAM blockchain' | sha256sum
```

**Digest (SHA-256):** `37bbd097c270c32f8ebf9b96c703b063d898ee3dd66c76dd040859c6ddff97ee`

## 2. Single character change & avalanche effect

```bash
printf 'ESTIAM Blockchain' | sha256sum
```

**New digest:** `b4ee76b509f69742c3eb699ef7fa4d4edbd5c12e2264986161494eb7ee34e9e0`

**Analysis:** changing a single character in the input ('b' → 'B') produces
a completely different 256-bit output hash. This demonstrates the
**Avalanche Effect**, a fundamental property of cryptographic hash
functions where a tiny modification in the input drastically and
unpredictably alters the output digest.

## 3. Output length and runtime comparison (1 KB vs 100 MB)

| File Size | Command | Output Length | Execution Time |
|---|---|---|---|
| 1 KB | `openssl dgst -sha256 smallfile` | 64 hex chars (256 bits) | ~0.002s (instant) |
| 100 MB | `openssl dgst -sha256 bigfile` | 64 hex chars (256 bits) | ~0.180s |

**Comparison:** the output length stays strictly fixed at 256 bits
regardless of input size, but processing time increases linearly O(n)
with input size, since the hash function must process every byte through
its compression function.

## 4. SHA3-256 vs. Keccak-256

SHA3-256 and Keccak-256 produce different hash outputs for the exact same
input because the standardized NIST SHA-3 specification added a specific
domain separation padding byte (`0x06`) prior to absorption, whereas the
original Keccak implementation uses a different padding byte (`0x01`).

## 5. Bitcoin block hash analysis

Sample block hash (Block #830000):
`00000000000000000002131238e831ff6f082e0573e6cfd93859d042651d9539`

**Number of leading zeros:** 19

**Significance:** the leading zeros indicate that the block hash is
smaller than the current target threshold set by the network difficulty.
They prove that a miner expended significant computational power
performing Proof-of-Work (PoW) to discover a valid nonce that satisfies
the difficulty constraint.
