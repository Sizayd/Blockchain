"""Lab 5 - Stake, Vote, and Get Slashed (Proof of Stake simulator).

Simulates a stake-weighted block proposer selection across N rounds,
with a slashing rule: a dishonest validator that "equivocates" (signs two
blocks at the same height) has its entire stake destroyed and is ejected
from the validator set.
"""

import random


class Validator:
    def __init__(self, name: str, stake: int, honest: bool = True):
        self.name = name
        self.stake = stake
        self.rewards = 0
        self.honest = honest
        self.slashed = False
        self.chosen_count = 0


class ProofOfStakeSimulator:
    def __init__(self, validators, block_reward: int = 10):
        self.validators = validators
        self.block_reward = block_reward

    def active_validators(self):
        return [v for v in self.validators if not v.slashed]

    def pick_proposer(self) -> Validator:
        active = self.active_validators()
        total_stake = sum(v.stake for v in active)
        pick = random.uniform(0, total_stake)
        cumulative = 0
        for v in active:
            cumulative += v.stake
            if pick <= cumulative:
                return v
        return active[-1]

    def run(self, rounds: int = 20):
        print("=" * 70)
        print("STARTING VALIDATOR SET")
        print("=" * 70)
        for v in self.validators:
            tag = "" if v.honest else "  (Cheater)"
            print(f"  {v.name:<8} stake={v.stake:>4} rewards={v.rewards:>4}{tag}")

        for round_number in range(1, rounds + 1):
            proposer = self.pick_proposer()
            proposer.chosen_count += 1

            if not proposer.honest and not proposer.slashed:
                # A dishonest validator attempts to equivocate the first
                # time it is chosen: sign two blocks at the same height.
                print(
                    f"Round {round_number:>2}: {proposer.name} is proposer -> "
                    "tries to sign TWO blocks (cheating!)"
                )
                print(
                    f"    !!! SLASHING {proposer.name}: signed two blocks at the "
                    "same height (equivocation)."
                )
                print(
                    f"    !!! Its stake of {proposer.stake} is DESTROYED and it "
                    "is EJECTED from the validator set."
                )
                proposer.stake = 0
                proposer.slashed = True
                continue

            proposer.rewards += self.block_reward
            print(f"Round {round_number:>2}: {proposer.name} proposes a block and earns {self.block_reward} reward.")

        self.print_results()

    def print_results(self):
        print()
        print("=" * 70)
        print("RESULTS")
        print("=" * 70)
        active = self.active_validators()
        total_stake = sum(v.stake for v in active)

        print("How often each validator was chosen (should track stake):")
        for v in self.validators:
            if v.slashed:
                share = "(ejected)"
            else:
                share = f"{100 * v.stake / total_stake:.0f}%"
            print(f"  {v.name:<8} chosen {v.chosen_count:>2} times   stake share now: {share}")

        print("\nFinal state of each validator:")
        for v in self.validators:
            if v.slashed:
                print(f"  {v.name:<8} SLASHED")
            else:
                print(f"  {v.name:<8} stake={v.stake:>4} rewards={v.rewards:>4}")


if __name__ == "__main__":
    random.seed(42)

    validators = [
        Validator("Alice", 100),
        Validator("Bob", 50),
        Validator("Carol", 25),
        Validator("Dave", 75, honest=True),   # Modification A: honest validator
        Validator("Mallory", 60, honest=False),  # Modification B: cheater
    ]

    sim = ProofOfStakeSimulator(validators)
    sim.run(rounds=20)
