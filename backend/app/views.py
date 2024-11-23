from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from datetime import timedelta
# from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta, date
import time
import json
import random
import string

@csrf_exempt
def goal(request):
    """
    Fetches goal details for the current game

    Request must contain: user_id, game_code

    Response format:
    {
        "exerciseType": float
        "currentDistance": float # may be null
        "currentFrequency": int # may be null
        "totalDistance": float # may be null
        "totalFrequency": float # may be null
        "weekDistanceGoal": float
        "weekFrequencyGoal": int
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    game_code = request.GET.get("game_code")
    user_id = request.GET.get("user_id")

    if not game_code or not user_id:
        return HttpResponse(status=400)

    cursor = connection.cursor()

    cursor.execute("SELECT totalDistance, totalFrequency, weekDistanceGoal, weekFrequencyGoal, weekDistance, weekFrequency FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code, user_id))
    goal = cursor.fetchone()

    cursor.execute("SELECT exerciseType, frequency, distance FROM Games WHERE gameCode = %s", (game_code,))
    gameInfo = cursor.fetchone()

    response_data = {
                        "exerciseType": gameInfo[0],
                        "currentDistance": goal[0], # total distance completed so far
                        "currentFrequency": goal[1], # total freq completed so far
                        "totalDistance": gameInfo[2], 
                        "totalFrequency": gameInfo[1], 
                        "weekDistanceGoal": goal[2], 
                        "weekFrequencyGoal": goal[3],
                        "weekDistance": goal[4],
                        "weekFrequency": goal[5]
                    }
    # for testing, inserted users, games, into db for (freq and distance) (only freq) (only distance)
    # when tested, returned null in the appropriate places

    return JsonResponse(response_data)

@csrf_exempt
def user_details(request):
    """
    Gets details related to a particular user.

    Request must contain: user_id

    Response format:
    {
        "user_id": string,
        "email": string,  # this is the main identifier for the user, name is not as relevant
        "name": string,
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)

    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user_info = cursor.fetchone()
    return JsonResponse({
                        "user_id": user_id,
                        "email": user_info[1],
                        "name": user_info[2]
                    })

def time_ago(date):
    current_date = datetime.now().date()
    diff = current_date - date
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

    Response format:
    {
        "past_games":
            [
                {
                    "exerciseType": string,
                    "duration": int,
                    "betAmount": float,
                    "completed": string
                }, ...
            ]
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)

    weekly_update()
    cursor = connection.cursor()
    query = '''
        SELECT G.gameCode, G.exerciseType, G.duration, G.betAmount, G.startDate
        FROM Games G
        JOIN GameParticipants GP ON G.gameCode = GP.gameCode
        WHERE GP.userId = %s AND G.isActive = FALSE
        ORDER BY G.startDate DESC;
    '''
    cursor.execute(query, (user_id,))
    games = cursor.fetchall()

    result = []
    if games is not None: 
        for game in games:
            game_code, exercise_type, duration, bet_amount, start_date = game
            time_completed = time_ago(start_date)
            result.append({
                "gameCode": game_code,
                "exerciseType": exercise_type,
                "duration": duration,
                "betAmount": float(bet_amount),
                "completed": time_completed
            })

    return JsonResponse({"past_games": result}) # listed starting with most recently finished

@csrf_exempt
def active_games(request):
    """
    Fetches current games for a user

    Request must contain: user_id

    Response format:
    [
        "active_games":
            {
                "gameCode": string,
                "exerciseType": string,
                "duration": int,
                "betAmount": float,
                "startDate": YYYY-MM-DD,
                "weekDistance": float,
                "weekDistanceGoal": float,
                "weekFrequency": int,
                "weekDistanceGoal": int
            }, ...
    ]
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    weekly_update()

    cursor = connection.cursor()

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)
    
    query = '''
        SELECT G.gameCode, G.exerciseType, G.duration, G.betAmount, G.startDate, GP.weekDistance, GP.weekDistanceGoal, GP.weekFrequency, GP.weekFrequencyGoal
        FROM Games G
        JOIN GameParticipants GP ON G.gameCode = GP.gameCode
        WHERE GP.userId = %s AND G.isActive = TRUE
        ORDER BY G.startDate DESC;
    '''
    cursor.execute(query, (user_id,))
    games = cursor.fetchall()

    result = []
    for game in games:
        game_code, exercise_type, duration, bet_amount, start_date, weekDistance, weekDistanceGoal, weekFrequency, weekFrequencyGoal = game
        result.append({
            "gameCode": game_code,
            "exerciseType": exercise_type,
            "duration": duration,
            "betAmount": float(bet_amount),
            "startDate": start_date,
            "weekDistance": float(weekDistance),
            "weekDistanceGoal": float(weekDistanceGoal),
            "weekFrequency": weekFrequency,
            "weekFrequencyGoal": weekFrequencyGoal
        })

    return JsonResponse({"active_games": result})

@csrf_exempt 
def game_details(request):
    """
    Gets all details for a specific game and its participants given a game code.

    Request must contain: game code

    Response format:
    {
        "gameData": 
            {
                gameCode: string,
                betAmount: float,
                exerciseType: string,
                frequency: int,
                distance: float,
                duration: int,
                adaptiveGoals: bool,
                startDate: YYYY-MM-DD,
                lastUpdated: int,
                isActive: boolean
            }
        "participantsData":
            [
                {
                        gameCode: string, 
                        userId: string,
                        amountGained: float,
                        amountLost: float,
                        balance: float, (amountGained - amountLost),
                        totalDistance: float,
                        weekDistance: float,
                        weekDistanceGoal: float,
                        totalFrequency: int,
                        weekFrequency: int,
                        weekFrequencyGoal: int
                }, ...
            ]
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    game_code = request.GET.get("game_code")
    if not game_code:
        return HttpResponse(status=400)

    weekly_update()
    cursor = connection.cursor()
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
def create_game(request):
    """
    Creates a new game and adds the current user to the game.

    Request must contain: user_id, bet_amount, exercise_type,
    frequency, distance, duration, adaptive_goals, start_date, password

    frequncy, distance, password may be null

    Response format:
    {
        "done": string (this is the game code, we did it this way for testing but lmk if smth else is more useful)
    }
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
    distance, duration, adaptive_goals, start_date, password = (
        json_data.get(key) for key in [
            "user_id", "bet_amount", "exercise_type", "frequency",
            "distance", "duration", "adaptive_goals", "start_date", "password"
        ]
    )
    # Add game to Games table
    cursor.execute("INSERT INTO Games (gameCode, betAmount, exerciseType, frequency, \
                   distance, duration, adaptiveGoals, startDate, password) \
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)",
                   (game_code, bet_amount, exercise_type, frequency, distance,
                    duration, adaptive_goals, start_date, password))

    # Set current user as player of this game
    cursor.execute("INSERT INTO GameParticipants (gameCode, userId, weekDistanceGoal, weekFrequencyGoal) VALUES (%s, %s, %s, %s)",
                   (game_code, user_id, distance, frequency))
    
    connection.commit()

    return JsonResponse({
                        "done": game_code, # used for testing
                    })

@csrf_exempt
def join_game(request):
    """
    Adds a user to a game with a valid game code.

    Request must contain: user ID, game code, password (password may be null)

    Response format:
    {
        "game_code": string,
        "user_id": string
    }
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    json_data = json.loads(request.body)

    user_id = json_data.get("user_id")
    game_code = json_data.get("game_code")
    password = json_data.get("password")

    if not user_id or not game_code:
        return JsonResponse({"error": "Invalid or missing user_id/game_code"}, status=400)

    cursor.execute("SELECT password FROM Games WHERE gameCode = %s", (game_code,))
    db_pass = cursor.fetchone()
    if db_pass:
        if db_pass[0] != password:
            return JsonResponse({"error": "Incorrect password"}, status=400)


    # verify that user id is valid
    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        return HttpResponse(status=400)

    # verify that game code is valid + fetch game details
    cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()
    if not game:
        return HttpResponse(status=404)

    # add user to GameParticipants with default values
    frequency = game[3]
    distance = game[4]
    try:
        cursor.execute("""
            INSERT INTO GameParticipants 
            (gameCode, userId, weekDistanceGoal, weekFrequencyGoal) 
            VALUES (%s, %s, %s, %s)
            """, 
            (game_code, user_id, distance, frequency))
        connection.commit()
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

    return JsonResponse({
                        "game_code": game_code,
                        "user_id": user_id
                    })

@csrf_exempt
def add_workout(request):
    """
    Adds a completed workout to a user's workout list

    Request must contain: user ID, Game code, Activity Type, Distance, Duration

    Response format:
    {
        "activity_type": string,
        "distance": float,
        "duration": int
    }
    OR, if there is an error:
    {
        "error": "uploaded wrong activity so nothing was done",
        "activityUploaded": string,
        "exerciseType": string
    }
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)

    user_id, game_code, activity_type, distance, duration = (
        json_data.get(key) for key in [
            "user_id", "game_code", "activity_type",
            "distance", "duration"
        ]
    )

    weekly_update()
    cursor = connection.cursor()

    # verify that user id is valid
    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        return HttpResponse(status=400)

    # verify that game code is valid + fetch game details
    cursor.execute("SELECT exerciseType FROM Games WHERE gameCode = %s", (game_code,))
    exerciseType = cursor.fetchone()
    if not exerciseType:
        return HttpResponse(status=400)

    current_timestamp = timezone.now()

    # verify activity type is the same as game_type
    if activity_type == exerciseType[0]:
        cursor.execute("INSERT INTO Activities (gameCode, userId, activity, distance, duration, timestamp) \
                        VALUES (%s, %s, %s, %s, %s, %s)",
                        (game_code, user_id, activity_type, distance, duration, current_timestamp))

        cursor.execute("UPDATE GameParticipants \
                SET weekDistance = weekDistance + %s, \
                weekFrequency = weekFrequency + 1, \
                totalDistance = totalDistance + %s, \
                totalFrequency = totalFrequency + 1 \
                WHERE gameCode = %s AND userId = %s;",
                (distance, distance, game_code, user_id))

        return JsonResponse({
            "activity_type": activity_type,
            "distance": distance,
            "duration": duration
        })
    else:
        return JsonResponse({
            "error": "uploaded wrong activity so nothing was done",
            "activityUploaded": activity_type,
            "exerciseType": exerciseType[0]
        })

    connection.commit()

    return JsonResponse({
        "activity_type": activity_type,
        "distance": distance,
        "duration": duration
    })

@csrf_exempt
def last_upload(request):
    """
    Get timestamp for last time workout was uploaded in certain game

    Request must contain: userID, gameCode

    Response format:
    {
        "timestamp": timestamp
    }
    """

    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    # verify that user id is valid
    user_id = request.GET.get("user_id")
    cursor.execute("SELECT * FROM Users WHERE userId = %s", (user_id,))
    user = cursor.fetchone()
    if not user:
        return HttpResponse(status=400)

    # verify that game code is valid + fetch start date for game
    game_code = request.GET.get("game_code")
    cursor.execute("SELECT startDate FROM Games WHERE gameCode = %s", (game_code,))
    startDate = cursor.fetchone()
    if not startDate:
        return HttpResponse(status=404)

    cursor.execute("SELECT timestamp FROM Activities WHERE gameCode = %s AND userId = %s ORDER BY timestamp DESC LIMIT 1", (game_code, user_id))
    timestamp_result = cursor.fetchone()
    if timestamp_result:  # Check if a timestamp was found
        timestamp = timestamp_result[0]  # Extract the timestamp from the tuple
        return JsonResponse({"timestamp": timestamp})
    else:
        startDate = startDate[0]
        startDate = datetime.combine(startDate, datetime.min.time())  # Set time to 00:00:00
        time_component = timedelta(hours=0, minutes=0, seconds=0, milliseconds=0)
        full_timestamp = startDate + time_component
        # Format the datetime object to the desired ISO 8601 string with milliseconds
        timestamp_str = full_timestamp.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]  # Remove extra microsecond digits
        return JsonResponse({"timestamp": timestamp_str})  # Return game start date if no timestamp is found

@csrf_exempt
def goal_status(request):
    """
    Gets the progress of a user towards their goal in a certain game.

    Request must contain: user ID, game code

    Response format:
    {
        "totalExpectedDistance": float,
        "totalCompletedDistance": float,
        "totalExpectedFrequency": int,
        "totalCompletedFrequency": int,
        "weeklyExpectedDistance": float,
        "weeklyCompletedDistance": float,
        "weeklyExpectedFrequency": int,
        "weeklyCompletedFrequency": int
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    weekly_update()

    cursor = connection.cursor()
    user_id = request.GET.get("user_id")
    game_code = request.GET.get("game_code")

    cursor.execute("SELECT * FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()

    cursor.execute("SELECT * FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code, user_id))
    goal = cursor.fetchone()

    if game[4] and game[5]:
        weekly_distance = game[4] / game[5]
    else:
        weekly_distance = None

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

    Response format:
    {
        bet_details: 
            [
                {
                    "userId": string,
                    "balance": float,
                    "amountGained": float,
                    "amountLost": float
                }, ...
            ]
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    weekly_update()

    cursor = connection.cursor()
    game_code = request.GET.get("game_code")

    if not game_code:
        return HttpResponse(status=400)
    

    cursor.execute("SELECT userId, balance, amountGained, amountLost FROM GameParticipants WHERE gameCode = %s", (game_code,))
    participants = cursor.fetchall()
    response_data = [
        {
            "userId": row[0], 
            "balance": row[1],
            "amountGained": row[2],
            "amountLost": row[3]
        }
        for row in participants
    ]

    return JsonResponse({"bet_details": response_data})

@csrf_exempt
def personal_bet_details(request):
    """
    Shows current status for personal bets in a game.
    Request must contain game_code and user_id.

    Response format:
    {
        bet_details: {
            "balance": float,
            "amountGained": float,
            "amountLost": float
        }
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    game_code = request.GET.get("game_code")

    if not game_code:
        return HttpResponse(status=400)

    user_id = request.GET.get("user_id")

    weekly_update()
    cursor = connection.cursor()
    cursor.execute("SELECT balance, amountGained, amountLost FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code, user_id))
    participants = cursor.fetchone()

    cursor.execute("SELECT betAmount FROM Games WHERE gameCode = %s", (game_code,))
    betAmt = cursor.fetchone()

    response_data = { 
            "initialBet": float(betAmt[0]),         
            "balance": float(participants[0]),
            "amountGained": float(participants[1]),
            "amountLost": float(participants[2])
        }

    return JsonResponse(response_data)


@csrf_exempt
def create_user(request):
    """
    Gets user ID from firebase and pushes to postgresql db. Adds user to ELO table
    and initializes their scores.

    Request must contain: email, user_id

    Response format:
    {
        "done": string (this is the user id, we did it this way for testing but lmk if smth else is more useful)
    }
    """
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)

    user_id, username = (
        json_data.get(key) for key in [
            "user_id", "username"
        ]
    )

    if not username or not user_id:
        return HttpResponse(status=400)

    cursor = connection.cursor()
    cursor.execute("INSERT INTO Users (userID, email) VALUES (%s, %s)",
                   (user_id, username))
    cursor.execute("INSERT INTO UserEloRatings (userId) VALUES (%s)", (user_id,))

    connection.commit()

    return JsonResponse({
                        "done": user_id,
                    })

def get_activity_type(request):
    """
    Gets activity_type for a certain game
    Request must contain: game_code

    Response format:
    {
        "exercise_type": string
    }
    """
    if request.method != 'GET':
        return HttpResponse(status=404)
    # Use query parameters for GET requests
    game_code = request.GET.get("game_code")
    if not game_code:
        return HttpResponse(status=400)
    
    cursor = connection.cursor()
    cursor.execute("SELECT exerciseType FROM Games WHERE gamecode = %s", (game_code,))
    result = cursor.fetchone()
    
    if result is None:
        return HttpResponse(status=404)
    # Fetch the exercise_type from result tuple
    exercise_type = result[0] if result else None
    return JsonResponse({
        "exercise_type" : exercise_type
    })

from app.adaptive.elo import create_challenge, serialize_challenge_to_csv, deserialize_challenge_from_csv
import os
from django.conf import settings


# def update_date(request):
#     test_date = date(2024, 12, 1)
#     # test_date += timedelta(days=1)
#     r = weekly_update(test_date)
#     return JsonResponse(r)  


def weekly_update():
    challenges = {
    "running": {
        "file": "running_challenge.csv",
        "name": "Running Challenge",
        "default_vars": {
            "distance": [0, 0.1, 1, 3, 6, 10]  # miles
        },
        "get_challenge_tuple": lambda d, f: (d,), # (distance, frequency) -> challenge_params
        "get_generic_tuple": lambda d: (d, None)  # challenge_params - > (distance, frequency)
    },
    "walking": {
        "file": "walking_challenge.csv",
        "name": "Walking Challenge",
        "default_vars": {
            "distance": [0, 0.1, 1, 3, 6, 10]  # miles
        },
        "get_challenge_tuple": lambda d, f: (d,),
        "get_generic_tuple": lambda d: (d, None)
    },
    "swimming": {
        "file": "swimming_challenge.csv",
        "name": "Swimming Challenge",
        "default_vars": {
            "distance": [0, 0.1, 0.5, 1, 3, 5]  # miles
        },
        "get_challenge_tuple": lambda d, f: (d,),
        "get_generic_tuple": lambda d: (d, None)
    },
    "strengthTraining": {
        "file": "strength_challenge.csv",
        "name": "Strength Training Challenge",
        "default_vars": {
            "frequency": [0, 1, 2, 3, 5, 8, 12]  # times a week
        },
        "get_challenge_tuple": lambda d, f: (f,),
        "get_generic_tuple": lambda f: (None, f)
    },
    "cycling": {
        "file": "cycling_challenge.csv",
        "name": "Cycling Challenge",
        "default_vars": {
            "distance": [0, 1, 3, 5, 8, 13, 21, 34, 54]  # Miles
        },
        "get_challenge_tuple": lambda d, f: (d,),
        "get_generic_tuple": lambda d: (d, None)
    }
}
    # get the current date
    current_date = datetime.now().date()
    # current_date = date(2024, 12, 1)
    # current_date = date
    result = []
    
    # get all active games
    cursor = connection.cursor()
    query = '''
        SELECT G.gameCode, G.startDate, G.lastUpdated, G.betAmount, G.duration, G.adaptiveGoals, G.exerciseType
        FROM Games G
        WHERE G.isActive = TRUE
    '''
    cursor.execute(query)
    games = cursor.fetchall()

    for game in games:
        # start_date is of type datetime.date
        game_code, start_date, last_updated, bet_amount, duration, adaptive_goals, exercise_type = game
        # check if a week has passed
        weeks_elapsed = (current_date - start_date).days // 7

        # if a week has passed, do updates
        if weeks_elapsed > last_updated:
            # change game's last updated week # to current week #
            new_last_updated = weeks_elapsed
            query = '''
                    UPDATE Games
                    SET lastUpdated = %s
                    WHERE gameCode = %s
                    ''' 
            cursor.execute(query, (new_last_updated, game_code))

            # get all users in each game 
            query = ''' SELECT GP.userId, GP.weekDistanceGoal, GP.weekFrequencyGoal, GP.weekDistance, GP.weekFrequency, GP.amountGained, GP.amountLost
                        FROM GameParticipants GP
                        WHERE GP.gameCode = %s
                    '''
            cursor.execute(query, (game_code,))
            participants = cursor.fetchall()

            # get challenge data if already exists, else create challenge 
            challenge_settings = challenges[exercise_type]
            challenge_file_loc = challenge_settings['file']

            if os.path.exists(challenge_file_loc):
                challenge = deserialize_challenge_from_csv(challenge_file_loc)
            else:
                challenge = create_challenge(
                    challenge_settings['name'],
                    challenge_settings['default_vars']
                )
                
            # store the winners and losers of each game for this week
            losers = []
            winners = []

            for p in participants:
                user_id, week_distance_goal, week_freq_goal, week_distance, week_frequency, amount_gained, amount_lost = p

                # get all winners and all losers for updating amountGained and amountLost later
                # cant do it now bc we need all winners, all losers for calculations
                failed_distance = False
                failed_freq = False

                if week_distance is not None and week_distance_goal is not None: 
                    if week_freq_goal is not None:
                        week_distance_goal = week_distance_goal * week_freq_goal
                    if week_distance < week_distance_goal: 
                        failed_distance = True

                if week_frequency is not None and week_freq_goal is not None: 
                    if week_frequency < week_freq_goal:
                        failed_freq = True

                if failed_distance or failed_freq:
                    losers.append(user_id)
                    result.append({
                            "loser": user_id,
                            "weekdistance": week_distance,
                            "week_distance_goal": week_distance_goal,
                            "weekfreq": week_frequency,
                            "weekfreqgoal": week_freq_goal
                            })

                if not failed_distance and not failed_freq:
                    winners.append(user_id)
                    result.append({
                        "winner": user_id,
                        "weekdistance": week_distance,
                        "week_distance_goal": week_distance_goal,
                        "weekfreq": week_frequency,
                        "weekfreqgoal": week_freq_goal
                        })
            
                # get user's elo score for this exercise type
                elo_type = exercise_type + "Elo"
                query = f''' SELECT {elo_type}
                            FROM UserEloRatings 
                            WHERE userId = %s
                        '''
                cursor.execute(query, (user_id,))
                elo_score = cursor.fetchone()[0]

                bounded_values = challenge.bound_values(
                    challenge_settings['get_challenge_tuple'](float(week_distance), float(week_frequency))
                )
                # for i in bounded_values:
                #     if i is None:
                #         continue
                #         # don't run compare elo

                # call elo function to get user's new elo score using this weeks data
                new_elo, _ = challenge.compare_elo(
                    player_elo=float(elo_score),
                    challenge_values=bounded_values,
                    outcome= 1.0 if not (failed_distance or failed_freq) else 0.0
                )

                # update user's elo score in db 
                query = f'''
                    UPDATE UserEloRatings
                    SET {elo_type} = %s
                    WHERE userId = %s
                '''
                cursor.execute(query, (new_elo, user_id))
                

                # use elo function to update a user's goal if the game is adaptive
                if adaptive_goals:
                    new_challenges = challenge.get_nearest_challenges(new_elo)
                    best_challenge = new_challenges[0]
                    challenge_params = best_challenge[1]
                    g_t = challenge_settings['get_generic_tuple'](challenge_params)
                    query = '''
                        UPDATE GameParticipants
                        SET weekDistanceGoal = %s
                        WHERE gameCode = %s AND userId = %s
                    '''
                    cursor.execute(query, (g_t[0], game_code, user_id))

                # update weekDistance, weekFrequency to be 0 for each user in game
                query = '''
                    UPDATE GameParticipants
                    SET weekDistance = 0, weekFrequency = 0
                    WHERE gameCode = %s AND userId = %s
                '''
                cursor.execute(query, (game_code, user_id))
        
            # add updates to challenge to csv file
            serialize_challenge_to_csv(challenge, challenge_file_loc)


            # use winners and losers to update balances for each player in each game
            # rounding isn't perfect (shown in example), should probably fix
            weekly_amount = round(bet_amount / duration, 2) # 250 / 4 = 62.5
            split_amount = round(len(losers) * weekly_amount, 2) # 62.5 * 3 = 187.5
            if len(winners) > 0:
                split_amount = round(split_amount / len(winners), 2)
            else:
                split_amount = 0  
                # 187.5 / 4 = 46.875 = 46.88 ------> (46.88 * 4 = 187.52) ------> 187.52 > original split_amount (187.5)

            for p in participants:
                user_id = p[0]
                gained = p[5]
                lost = p[6]
                if user_id in losers:
                    new_amount_lost = lost + weekly_amount
                    query = '''
                        UPDATE GameParticipants
                        SET amountLost = %s
                        WHERE gameCode = %s AND userId = %s
                    '''
                    cursor.execute(query, (new_amount_lost, game_code, user_id))

                elif user_id in winners:
                    new_amount_gained = gained + split_amount
                    query = '''
                        UPDATE GameParticipants
                        SET amountGained = %s
                        WHERE gameCode = %s AND userId = %s
                    '''
                    cursor.execute(query, (new_amount_gained, game_code, user_id))
    
        # check if the game has ended, update to not active if so
        if weeks_elapsed >= duration:
            query = '''
                    UPDATE Games
                    SET isActive = FALSE
                    WHERE gameCode = %s
                    '''
            cursor.execute(query, (game_code, ))

    # commit db changes
    connection.commit()

    return ({"result": result}) 

