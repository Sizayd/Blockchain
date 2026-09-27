"""Lab 4 - Educational Proof-of-Work blockchain.

Reconstructs the behaviour exercised on the `simple-blockchain` repo
(https://github.com/dougyoung/simple-blockchain): mine blocks against a
difficulty target, report the nonce and elapsed mining time for each
block, and detect tampering by recomputing hashes.

Usage:
    python pow_demo.py mine --difficulty 1e71 --blocks 3
    python pow_demo.py tamper
"""

import argparse
import hashlib
import time


class Block:
    def __init__(self, index: int, payload: str, previous_hash: str):
        self.index = index
        self.payload = payload
        self.previous_hash = previous_hash
        self.nonce = 0
        self.hash = ""

    def compute_hash(self) -> str:
        content = f"{self.index}{self.payload}{self.previous_hash}{self.nonce}"
        return hashlib.sha256(content.encode()).hexdigest()

    def mine(self, difficulty: float) -> float:
        """Mine the block: increment nonce until hash < target. Returns elapsed time."""
        target = int((2**256) / difficulty)
        start = time.time()
        while True:
            self.hash = self.compute_hash()
            if int(self.hash, 16) < target:
                break
            self.nonce += 1
        elapsed = time.time() - start
        return elapsed


class Blockchain:
    def __init__(self):
        genesis = Block(0, "genesis", "0" * 64)
        genesis.hash = genesis.compute_hash()
        self.chain = [genesis]

    def add_block(self, payload: str, difficulty: float):
        previous = self.chain[-1]
        block = Block(len(self.chain), payload, previous.hash)
        elapsed = block.mine(difficulty)
        self.chain.append(block)
        print(f"Block: {block.index}")
        print(f"Nonce: {block.nonce}")
        print(f"Elapsed time: {elapsed:.4f} seconds")
        return block

    def is_valid(self) -> bool:
        for i in range(1, len(self.chain)):
            current, previous = self.chain[i], self.chain[i - 1]
            if current.previous_hash != previous.hash:
                return False
            if current.hash != current.compute_hash():
                return False
        return True


def run_mine(difficulty: float, blocks: int):
    bc = Blockchain()
    for i in range(blocks):
        bc.add_block(f"block-{i + 1}-data", difficulty)


def run_tamper_test():
    bc = Blockchain()
    for i in range(3):
        bc.add_block(f"block-{i + 1}-data", difficulty=1e71)

    print(f"\nChain valid: {bc.is_valid()}")

    tampered = bc.chain[1]
    stored_hash = tampered.hash
    tampered.payload = "TAMPERED DATA"
    recalculated_hash = tampered.compute_hash()

    print(f"Stored hash:       {stored_hash}")
    print(f"Recalculated hash: {recalculated_hash}")
    print(f"Chain valid: {bc.is_valid()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    mine_p = sub.add_parser("mine")
    mine_p.add_argument("--difficulty", type=float, default=1e71)
    mine_p.add_argument("--blocks", type=int, default=3)

    sub.add_parser("tamper")

    args = parser.parse_args()
    if args.command == "mine":
        run_mine(args.difficulty, args.blocks)
    elif args.command == "tamper":
        run_tamper_test()
