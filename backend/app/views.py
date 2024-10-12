from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
import random
import string

def goal(request):
    """
    Fetches goal details for the current game

    Request must contain: user_id, game_code
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    json_data = json.loads(request.body)
    game_code = json_data["game_code"]
    user_id = json_data["user_id"]

    cursor.execute("SELECT totalDistance, totalFrequency FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code,user_id))
    goal = cursor.fetchone()
    cursor.execute("SELECT exerciseType, frequency, duration, FROM Games WHERE gamecode = %s", (game_code))
    gameInfo = cursor.fetchone()
    response_data = {
                        "exerciseType": gameInfo[0],
                        "currentDistance": goal[0],
                        "currentFrequency": goal[1], 
                        "totalDistance": gameInfo[2],
                        "totalFrequency": gameInfo[1]
                    }

    return JsonResponse(response_data)

def past_games(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    pass

def active_games(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    pass


def create_game(request):
    """
    Creates a new game and adds the current user to the game.

    Request must contain: user_id, bet_amount, exercise_type,
    frequency, distance, duration, adaptive_goals, start_date
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    json_data = json.loads(request.body)

    game_code = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(8))
    while cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,)).fetchall():
        game_code = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(8))

    user_id, bet_amount, exercise_type, frequency, \
    distance, duration, adaptive_goals, start_date = (
        json_data.get(key) for key in [
            "user_id", "bet_amount", "exercise_type", "frequency",
            "distance", "duration", "adaptive_goals", "start_date"
        ]
    )

    # Add game to Games table
    cursor.execute("INSERT INTO Games (betAmount, exerciseType, frequency, \
                   distance, duration, adaptiveGoals, startDate) \
                   VALUES (%s, %s, %s, %s, %s, %s, %s)",
                   (bet_amount, exercise_type, frequency, distance,
                    duration, adaptive_goals, start_date))

    # Set current user as player of this game
    cursor.execute("INSERT INTO GameParticipants (gameCode, userID) VALUES (%s, %s)",
                   (game_code, user_id))

    return JsonResponse({})


def join_game(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    pass

def goal_status(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    pass

def bet_details(request):
    """
    Shows current status for all bets in a game.
    Request must contain game_code.
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    json_data = json.loads(request.body)
    game_code = json_data["game_code"]

    cursor.execute("SELECT userID, balance FROM GameParticipants WHERE gameCode = %s", (game_code,))
    participants = cursor.fetchall()
    response_data = [
        {"userID": row[0], "balance": row[1]}
        for row in participants
    ]

    return JsonResponse(response_data)
