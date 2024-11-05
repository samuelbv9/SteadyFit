from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from datetime import timedelta
import json
import random
import string

@csrf_exempt
def goal(request):
    """
    Fetches goal details for the current game

    Request must contain: user_id, game_code
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    game_code = request.GET.get("game_code")
    user_id = request.GET.get("user_id")

    if not game_code or not user_id:
        return HttpResponse(status=400)

    cursor = connection.cursor()

    cursor.execute("SELECT totalDistance, totalFrequency FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code, user_id))
    goal = cursor.fetchone()

    cursor.execute("SELECT exerciseType, frequency, distance FROM Games WHERE gameCode = %s", (game_code,))
    gameInfo = cursor.fetchone()

    response_data = {
                        "exerciseType": gameInfo[0],
                        "currentDistance": goal[0], # may be null
                        "currentFrequency": goal[1], # may be null
                        "totalDistance": gameInfo[2], # may be null
                        "totalFrequency": gameInfo[1] # may be null
                    }
    # for testing, inserted users, games, into db for (freq and distance) (only freq) (only distance)
    # when tested, returned null in the appropriate places

    return JsonResponse(response_data)

@csrf_exempt
def user_details(request):
    """
    Gets details related to a particular user.

    Request must contain: user_id
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)

    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    username = cursor.fetchone()[1]
    return JsonResponse({
                        "username": username,
                        "user_id": user_id
                    })

def time_ago(time):
    now = timezone.now()
    diff = now - time
    if diff.days >= 365:
        return f"{diff.days // 365} years ago"
    elif diff.days >= 1:
        return f"{diff.days} days ago"
    elif diff.seconds >= 3600:
        return f"{diff.seconds // 3600} hours ago"
    elif diff.seconds >= 60:
        return f"{diff.seconds // 60} minutes ago"
    else:
        return "just now"

@csrf_exempt
def past_games(request):
    """
    Fetches past games for a user

    Request must contain: user_id
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)

    cursor = connection.cursor()
    query = '''
        SELECT G.exerciseType, G.duration, G.betAmount, G.startDate
        FROM Games G
        JOIN GameParticipants GP ON G.gameCode = GP.gameCode
        WHERE GP.userId = %s AND G.isActive = FALSE
        ORDER BY G.startDate DESC;
    '''
    cursor.execute(query, (user_id,))
    games = cursor.fetchall()

    result = []
    for game in games:
        exercise_type, duration, bet_amount, start_date = game
        time_completed = time_ago(start_date)
        result.append({
            "exerciseType": exercise_type,
            "duration": duration,
            "betAmount": float(bet_amount),
            "completed": time_completed
        })

    return JsonResponse(result, safe=False) # listed starting with most recently finished

@csrf_exempt
def active_games(request):
    """
    Fetches current games for a user

    Request must contain: user_id
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)
    
    query = '''
        SELECT G.exerciseType, G.duration, G.betAmount, G.startDate
        FROM Games G
        JOIN GameParticipants GP ON G.gameCode = GP.gameCode
        WHERE GP.userId = %s AND G.isActive = TRUE
        ORDER BY G.startDate DESC;
    '''
    cursor.execute(query, (user_id,))
    games = cursor.fetchall()

    result = []
    for game in games:
        exercise_type, duration, bet_amount, start_date = game
        result.append({
            "exerciseType": exercise_type,
            "duration": duration,
            "betAmount": float(bet_amount),
            "startDate": start_date
        })

@csrf_exempt 
def game_details(request):
    """
    Gets all details for a specific game and its participants given a game code.

    Request must contain: game code
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    game_code = request.GET.get("game_code")
    if not game_code:
        return HttpResponse(status=400)

    cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()
    if not game:
        return HttpResponse(status=404)

    cursor.execute("SELECT * FROM GameParticipants WHERE gameCode = %s", (game_code,))
    participants = cursor.fetchall()

    response_data = {
        "gameData": game,
        "participantsData": participants
    }

    return JsonResponse(response_data)


@csrf_exempt
# needed for testing with curl
def create_game(request):
    """
    Creates a new game and adds the current user to the game.

    Request must contain: user_id, bet_amount, exercise_type,
    frequency, distance, duration, adaptive_goals, start_date

    frequncy, distance may be null
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    json_data = json.loads(request.body)

    # check for duplicate game codes
    game_code = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(8))
    # for testing, wrote "game_code = <existing game code>" on this line,
    # when testing, a different game code was returned, not the existing one, so unique game codes works
    cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))
    while cursor.fetchone() is not None:
        game_code = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(8))
        cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))

    # also tested with null values for frequency, distance
    # inserted into db correctly with nulls
    user_id, bet_amount, exercise_type, frequency, \
    distance, duration, adaptive_goals, start_date = (
        json_data.get(key) for key in [
            "user_id", "bet_amount", "exercise_type", "frequency",
            "distance", "duration", "adaptive_goals", "start_date"
        ]
    )
    # Add game to Games table
    cursor.execute("INSERT INTO Games (gameCode, betAmount, exerciseType, frequency, \
                   distance, duration, adaptiveGoals, startDate) \
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                   (game_code, bet_amount, exercise_type, frequency, distance,
                    duration, adaptive_goals, start_date))

    # Set current user as player of this game
    cursor.execute("INSERT INTO GameParticipants (gameCode, userId) VALUES (%s, %s)",
                   (game_code, user_id))

    # should we return some type of confirmation details or the game code so the frontend has some feedback?
    return JsonResponse({
                        "done": game_code, # used for testing
                    })

@csrf_exempt
def join_game(request):
    """
    Adds a user to a game with a valid game code.

    Request must contain: user ID, game code
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    # verify that user id is valid
    user_id = request.POST.get("user_id")
    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        return HttpResponse(status=400)

    # verify that game code is valid + fetch game details
    game_code = request.POST.get("game_code")
    cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()
    if not game:
        return HttpResponse(status=404)

    # add user to GameParticipants with default values
    cursor.execute("INSERT INTO GameParticipants (gameCode, userId) VALUES (%s, %s)",
                   (game_code, user_id))

    return JsonResponse({
                        "game_code": game_code,
                        "user_id": user_id
                    })

def add_workout(request):
    """
    Adds a completed workout to a user's workout list

    Request must contain: user ID, Game code, Activity Type, Distance, Duration
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    # verify that user id is valid
    user_id = request.POST.get("user_id")
    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        return HttpResponse(status=400)

    # verify that game code is valid + fetch game details
    game_code = request.POST.get("game_code")
    cursor.execute("SELECT isActive FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()
    if not game:
        return HttpResponse(status=404)

    activity_type = request.POST.get("activity_type")
    distance = request.POST.get("distance")
    duration = request.POST.get("duration")

    cursor.execute("INSERT INTO Activities (gameCode, userId, activity, distance, duration) \
                    VALUES (%s, %s, %s, %s, %s)", (game_code, user_id, activity_type, distance, duration))

    cursor.execute("UPDATE GameParticipants \
                   SET weekDistance = weekDistance + %s, \
                   weekFrequency = weekFrequency + 1 \
                   totalDistance = totalDistance + %s, \
                   totalFrequency = totalFrequency + 1 \
                   WHERE gameCode = %s AND userId = %s;",
                   (distance, distance, game_code, user_id))

    return JsonResponse({
        "activity_type": activity_type,
        "distance": distance,
        "duration": duration
    })

def last_upload(request):
    """
    Get timestamp for last time workout was uploaded in certain game

    Request must contain: userID, gameCode
    """

    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    # verify that user id is valid
    user_id = request.POST.get("user_id")
    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        return HttpResponse(status=400)

    # verify that game code is valid + fetch game details
    game_code = request.POST.get("game_code")
    cursor.execute("SELECT isActive FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()
    if not game:
        return HttpResponse(status=404)

    cursor.execute("SELECT timestamp FROM Activities WHERE gameCode = %s AND userId = %s ORDER BY timestamp DESC LIMIT 1")
    timestamp = cursor.fetchall()
    return JsonResponse({
        "timestamp": timestamp
    })



def goal_status(request):
    """
    Gets the progress of a user towards their goal in a certain game.

    Request must contain: user ID, game code
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    user_id = request.GET.get("user_id")
    game_code = request.GET.get("game_code")

    cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()

    cursor.execute("SELECT * FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code, user_id))
    goal = cursor.fetchone()

    weekly_distance = game[4] / game[5]

    return JsonResponse({
        "totalExpectedDistance": game[4],
        "totalCompletedDistance": goal[2],
        "totalExpectedFrequency": game[3],
        "totalCompletedFrequency": goal[3],
        "weeklyExpectedDistance": weekly_distance,
        "weeklyCompletedDistance": goal[7],
        "weeklyExpectedFrequency": game[3],
        "weeklyCompletedFrequency": goal[8]
    })


@csrf_exempt
def bet_details(request):
    """
    Shows current status for all bets in a game.
    Request must contain game_code.
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    game_code = request.GET.get("game_code")

    if not game_code:
        return HttpResponse(status=400)

    cursor.execute("SELECT userId, balance FROM GameParticipants WHERE gameCode = %s", (game_code,))
    participants = cursor.fetchall()
    response_data = [
        {"userId": row[0], "balance": row[1]}
        for row in participants
    ]

    return JsonResponse(response_data, safe=False)  # safe = false : not returning dict


@csrf_exempt
def create_user(request):
    """
    Gets user ID from firebase and pushes to postgresql db. Adds user to ELO table
    and initializes their scores.

    Request must contain: email, user_id
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    username = request.POST.get("email")
    user_id = request.POST.get("user_id")
    if not username or not user_id:
        return HttpResponse(status=400)

    cursor = connection.cursor()
    cursor.execute("INSERT INTO Users (userID, email) VALUES (%s, %s)",
                   (user_id, username))
    cursor.execute("INSERT INTO UserEloRatings (userId) VALUES (%s)", (user_id,))

    return JsonResponse({
                        "done": user_id,
                    })


def weekly_update():
    # get the current date
    current_date = datetime.now().date()

    # get all active games
    cursor = connection.cursor()
    query = '''
        SELECT G.gameCode, G.startDate
        FROM Games G
        WHERE G.isActive = TRUE
    '''
    cursor.execute(query)
    games = cursor.fetchall()

    # iterate through the games and check if a week has passed since startDate
    for game in games:
        game_code, start_date, last_updated = game
        
        # check if a week has passed
        weeks_elapsed = (current_date - start_date).days // 7

        # if a week has passed, do updates
        if weeks_elapsed > last_updated:
            # Perform your update logic here (e.g., increment totals, adjust balance, etc.)
            # Example: increment totalFrequency or totalDistance
            new_total_distance = total_distance + calculate_distance(user_id, game_code)  # Implement your own logic
            new_total_frequency = total_frequency + calculate_frequency(user_id, game_code)  # Implement your own logic
            
            # Update the database with the new stats
            update_query = '''
                UPDATE GameParticipants
                SET totalDistance = %s, totalFrequency = %s
                WHERE gameCode = %s AND userId = %s
            '''
            cursor.execute(update_query, [new_total_distance, new_total_frequency, game_code, user_id])
    
    connection.commit()

while True:
    weekly_update()
    time.sleep(86400)  
