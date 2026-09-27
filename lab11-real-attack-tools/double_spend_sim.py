"""Lab 11 - Double-spend simulator (Nakamoto race).

Monte Carlo simulation of the classic Bitcoin double-spend race: an
attacker with hash power `power` (vs. the honest network's `1 - power`)
tries to catch up from `confirmations` (Z) blocks behind. Each trial
simulates a biased random walk (attacker mines the next block with
probability `power`) until either the attacker's private chain catches up
to the honest chain's length (success) or a generous step cap is reached
(treated as failure - negligible probability beyond that point).
"""

import random


def simulate_race(power: float, confirmations: int, max_steps: int = 200_000) -> bool:
    """Run a single race. Returns True if the attacker catches up."""
    honest_len = confirmations  # honest chain already has a Z-block head start
    attacker_len = 0

    for _ in range(max_steps):
        if random.random() < power:
            attacker_len += 1
        else:
            honest_len += 1

        if attacker_len >= honest_len:
            return True

    return False


def success_rate(power: float, confirmations: int, trials: int = 20_000) -> float:
    wins = sum(1 for _ in range(trials) if simulate_race(power, confirmations))
    return wins / trials


def run_experiment(confirmations: int, trials: int = 20_000):
    print(f"\n--- Confirmations Z = {confirmations} ---")
    for pct in range(10, 61, 5):
        power = pct / 100
        rate = success_rate(power, confirmations=confirmations, trials=trials)
        print(pct, "%", "->", round(rate * 100, 1), "%")


if __name__ == "__main__":
    for z in (1, 6, 12):
        run_experiment(confirmations=z, trials=20_000)
