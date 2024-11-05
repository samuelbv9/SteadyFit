import numpy as np
import math, random
from elo import Challenge, create_challenge

import matplotlib.pyplot as plt

distance_challenge = create_challenge(
    "Distance Challenge", {"distance": [100, 1000, 10000, 100000]}
)

def probability(rating1: float, rating2: float) -> float:
    return 1.0 / (1 + math.pow(10, (rating1 - rating2) / 400.0))

# test 1:
# underlying true elo for challenge, testing that challenges correctly converge to true elo
# players also have true elo, but they're not being tested.
# true elo is stated elo for players

# test 2:
# underlying true elo for players, testing that players correctly converge to true elo
# challenges also have true elo, they're not being tested.
# true elo is stated elo for challenged

# //////////////
# /// TEST 1 ///
# //////////////
# underlying true elo for challenge, testing that challenges correctly converge to true elo
# players also have true elo, but they're not being tested.
# true elo is stated elo for players

variables = [100, 200, 300, 400, 500, 600, 700]
true_elos = [500, 800, 1100, 1300, 1500, 1800, 2100]

test_1_challenge = create_challenge(
    "Test One Challenge", {"var": variables}
)

challenge_elos_history = {var: [] for var in variables}
# generate num players
for i in range(1, 500):
    
    player_elo = np.random.normal(loc=1200, scale=400)

    test_vars = []
    test_elos = []

    for _ in range(len(variables)):
        t_v = random.randrange(min(variables), max(variables))

        test_vars.append(t_v)

        for i in range(len(variables)-1):
            if variables[i] <= t_v <= variables[i+1]:
                proportion = (t_v - variables[i]) / (variables[i+1] - variables[i])
                interpolated_elo = true_elos[i] + proportion * (true_elos[i+1] - true_elos[i])
                test_elos.append(interpolated_elo)
                break

    # testing the bookends, which aren't sufficiently tested by the random sampling.
    test_vars.append(variables[0])
    test_elos.append(true_elos[0])
    test_vars.append(variables[len(variables)-1])
    test_elos.append(true_elos[len(true_elos)-1])

    cd = zip(test_vars, test_elos)
    for test_var, true_elo in cd:
        p = probability(player_elo, true_elo)
        w = random.random() > p

        test_1_challenge.compare_elo(player_elo=player_elo, challenge_values=(test_var,), outcome=w)
    
    for var in variables:
        challenge_elos_history[var].append(test_1_challenge.get_elo((var,)))

print(test_1_challenge.get_nearest_challenges(400))
print(test_1_challenge.get_nearest_challenges(900))
print(test_1_challenge.get_nearest_challenges(1200))
print(test_1_challenge.get_nearest_challenges(1900))

plt.figure(figsize=(12, 6))

# Plot ELO progression for each variable
for var, true_elo in zip(variables, true_elos):
    elos = challenge_elos_history[var]
    plt.plot(elos, label=f'Variable {var} (True ELO: {true_elo})', alpha=0.7)
    plt.axhline(y=true_elo, linestyle='--', alpha=0.3)

plt.title('Challenge ELO Progression Over Time')
plt.xlabel('Number of Comparisons')
plt.ylabel('ELO Rating')
plt.legend()
plt.grid(True, alpha=0.3)

plt.show()


# //////////////
# /// TEST 2 ///
# //////////////
test_2_challenge = test_1_challenge

players = []

NUM_PLAYERS = 8
for _ in range(NUM_PLAYERS):
    players.append({
        "true_elo": np.random.normal(loc=1200, scale=400),
        "curr_elo": 1200,
        "elo_history": [1200]
    })

for i in range(1, 500):

    for plr in players:
        var = random.randrange(min(variables), max(variables))
        var_elo = test_2_challenge.get_elo((var,))

        p = probability(plr['true_elo'], var_elo)
        w = random.random() > p

        npe, _ = test_2_challenge.compare_elo(player_elo=plr['curr_elo'], challenge_values=(var,), outcome=w)

        plr['curr_elo'] = npe
        plr['elo_history'].append(npe)

plt.figure(figsize=(12, 6))

# Plot ELO progression for each player
for i, plr in enumerate(players):
    plt.plot(
        plr['elo_history'], 
        label=f'Player {i+1} (True ELO: {plr["true_elo"]:.0f})', 
        alpha=0.7
    )
    plt.axhline(y=plr['true_elo'], linestyle='--', alpha=0.3)

plt.title('Player ELO Progression Over Time')
plt.xlabel('Number of Comparisons')
plt.ylabel('ELO Rating')
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()