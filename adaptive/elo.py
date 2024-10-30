import math
import csv
from typing import Dict, List, Tuple
from itertools import product


class Challenge:
    def __init__(self, name: str, vars: Dict[str, List[float]], inital_elo: int = 1200):
        self.name = name
        self.vars = vars
        self.elos = {}
        self.limits = {var: (min(values), max(values)) for var, values in vars.items()}

        # Generate all possible combinations of values
        _, values = zip(*vars.items())
        for combination in product(*values):
            self.elos[combination] = inital_elo
    
    def get_nearest_challenges(self, rating: float) -> List[tuple]:
        s_list = [(abs(rating - v), v, tuple(k)) for k, v in self.elos.items()]
        s_list = sorted(s_list, key=lambda x: x[0])

        return [(tup[1], tuple(tup[2])) for tup in s_list]

    def probability(self, rating1: float, rating2: float) -> float:
        return 1.0 / (1 + math.pow(10, (rating1 - rating2) / 400.0))

    def elo_rating_update(
        self, Ra: float, Rb: float, outcome: float, K: int = 32
    ) -> tuple[float, float]:
        Pb = self.probability(Ra, Rb)
        Pa = self.probability(Rb, Ra)
        Ra = Ra + K * (outcome - Pa)
        Rb = Rb + K * ((1 - outcome) - Pb)
        return Ra, Rb

    def check_limits(self, challenge_values: Tuple) -> bool:
        for value, (_, (min_val, max_val)) in zip(
            challenge_values, self.limits.items()
        ):
            if not (min_val <= value <= max_val):
                return False
        return True

    def get_elo(self, challenge_values: Tuple) -> float:
        if not self.check_limits(challenge_values):
            raise ValueError(
                "One or more challenge values are outside the allowed range."
            )

        if challenge_values in self.elos:
            return self.elos[challenge_values]

        # Prepare for interpolation
        dimensions = len(challenge_values)
        keys = list(self.vars.keys())
        bounds = [(None, None) for _ in range(dimensions)]

        # Find bounds for interpolation
        for idx in range(dimensions):
            var_name = keys[idx]
            var_values = self.vars[var_name]
            target = challenge_values[idx]

            lower_bound = max([v for v in var_values if v <= target], default=None)
            upper_bound = min([v for v in var_values if v >= target], default=None)

            if lower_bound is None or upper_bound is None:
                raise ValueError(
                    "Cannot interpolate ELO for the given challenge values"
                )

            bounds[idx] = (lower_bound, upper_bound)

        # Perform n-dimensional interpolation
        combs = product(
            *[(low, high) if low != high else (low,) for low, high in bounds]
        )
        interpolated_elo = 0.0

        for comb in combs:
            weights = 1.0
            for idx in range(dimensions):
                if bounds[idx][0] != bounds[idx][1]:
                    if comb[idx] == bounds[idx][0]:
                        weights *= (bounds[idx][1] - challenge_values[idx]) / (
                            bounds[idx][1] - bounds[idx][0]
                        )
                    else:
                        weights *= (challenge_values[idx] - bounds[idx][0]) / (
                            bounds[idx][1] - bounds[idx][0]
                        )

            comb_with_values = tuple(
                bounds[idx][0] if comb[idx] == bounds[idx][0] else bounds[idx][1]
                for idx in range(dimensions)
            )
            interpolated_elo += weights * self.elos[comb_with_values]

        return interpolated_elo

    def compare_elo(
        self, player_elo: float, challenge_values: Tuple, outcome: float
    ) -> Tuple[float, float]:
        if not self.check_limits(challenge_values):
            raise ValueError(
                "One or more challenge values are outside the allowed range."
            )

        # Check if the input directly hits a known value
        if challenge_values in self.elos:
            challenge_elo = self.elos[challenge_values]
            new_player_elo, new_challenge_elo = self.elo_rating_update(
                player_elo, challenge_elo, outcome
            )
            self.elos[challenge_values] = new_challenge_elo
            return new_player_elo, new_challenge_elo

        # If not directly on discrete values, prepare for interpolation
        dimensions = len(challenge_values)
        keys = list(self.vars.keys())
        bounds = [(None, None) for _ in range(dimensions)]

        # Find bounds for interpolation
        for idx in range(dimensions):
            var_name = keys[idx]
            var_values = self.vars[var_name]
            target = challenge_values[idx]

            lower_bound = max([v for v in var_values if v <= target], default=None)
            upper_bound = min([v for v in var_values if v >= target], default=None)

            if lower_bound is None or upper_bound is None:
                raise ValueError(
                    "Cannot interpolate ELO for the given challenge values"
                )

            bounds[idx] = (lower_bound, upper_bound)

        # Calculate weights and perform interpolation
        combs = list(product(
            *[(low, high) if low != high else (low,) for low, high in bounds]
        ))
        weights = {}
        total_weight = 0.0

        # First pass: calculate all weights
        for comb in combs:
            weight = 1.0
            for idx in range(dimensions):
                if bounds[idx][0] != bounds[idx][1]:
                    if comb[idx] == bounds[idx][0]:
                        weight *= (bounds[idx][1] - challenge_values[idx]) / (
                            bounds[idx][1] - bounds[idx][0]
                        )
                    else:
                        weight *= (challenge_values[idx] - bounds[idx][0]) / (
                            bounds[idx][1] - bounds[idx][0]
                        )

            comb_with_values = tuple(
                bounds[idx][0] if comb[idx] == bounds[idx][0] else bounds[idx][1]
                for idx in range(dimensions)
            )
            weights[comb_with_values] = weight
            total_weight += weight

        # Normalize weights and calculate interpolated ELO
        interpolated_elo = 0.0
        for comb, weight in weights.items():
            normalized_weight = weight / total_weight
            interpolated_elo += normalized_weight * self.elos[comb]

        # Calculate new ELOs
        new_player_elo, new_interpolated_elo = self.elo_rating_update(
            player_elo, interpolated_elo, outcome
        )
        
        # Calculate the ELO change
        elo_change = new_interpolated_elo - interpolated_elo
        
        # Distribute the ELO change according to the normalized weights
        for comb, weight in weights.items():
            normalized_weight = weight / total_weight
            self.elos[comb] += elo_change * normalized_weight

        return new_player_elo, interpolated_elo

    def __str__(self) -> str:
        elo_str = "\n".join(f"{combo}: {elo}" for combo, elo in self.elos.items())
        return f"Challenge: {self.name}\nVariables: {self.vars}\nElos:\n{elo_str}"


def serialize_challenge_to_csv(challenge: Challenge, filename: str):
    """
    Serialize a Challenge object to a CSV file.
    """
    with open(filename, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)

        # Write challenge name
        writer.writerow(["name", challenge.name])

        # Write variables
        writer.writerow(["variables"])
        for var, values in challenge.vars.items():
            writer.writerow([var] + values)

        # Write ELO ratings
        writer.writerow(["elo_ratings"])
        for combination, elo in challenge.elos.items():
            writer.writerow(list(combination) + [elo])


def deserialize_challenge_from_csv(filename: str) -> Challenge:
    """
    Deserialize a Challenge object from a CSV file.
    """
    with open(filename, "r", newline="") as csvfile:
        reader = csv.reader(csvfile)

        # Read challenge name
        _, name = next(reader)

        # Read variables
        next(reader)  # Skip 'variables' row
        vars: Dict[str, List[float]] = {}
        for row in reader:
            if row[0] == "elo_ratings":
                break
            vars[row[0]] = [float(val) for val in row[1:]]

        # Create Challenge object
        challenge = Challenge(name, vars)

        # Read ELO ratings
        for row in reader:
            combination = tuple(float(val) for val in row[:-1])
            elo = float(row[-1])
            challenge.elos[combination] = elo

        return challenge


def create_challenge(name: str, vars: Dict[str, List[float]]) -> Challenge:
    return Challenge(name, vars)
