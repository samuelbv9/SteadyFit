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

    cursor.execute("SELECT totalDistance, totalFrequency, weekDistanceGoal, weekFrequencyGoal FROM GameParticipants WHERE gameCode = %s AND userId = %s", (game_code, user_id))
    goal = cursor.fetchone()

    cursor.execute("SELECT exerciseType, frequency, distance FROM Games WHERE gameCode = %s", (game_code,))
    gameInfo = cursor.fetchone()

    response_data = {
                        "exerciseType": gameInfo[0],
                        "currentDistance": goal[0], # may be null
                        "currentFrequency": goal[1], # may be null
                        "totalDistance": gameInfo[2], # may be null
                        "totalFrequency": gameInfo[1], # may be null
                        "weekDistanceGoal": goal[2],
                        "weekFrequencyGoal": goal[3]
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
                "startDate": YYYY-MM-DD
            }, ...
    ]
    """
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()

    user_id = request.GET.get('user_id')
    if not user_id:
        return JsonResponse(status=400)
    
    query = '''
        SELECT G.gameCode, G.exerciseType, G.duration, G.betAmount, G.startDate
        FROM Games G
        JOIN GameParticipants GP ON G.gameCode = GP.gameCode
        WHERE GP.userId = %s AND G.isActive = TRUE
        ORDER BY G.startDate DESC;
    '''
    cursor.execute(query, (user_id,))
    games = cursor.fetchall()

    result = []
    for game in games:
        game_code, exercise_type, duration, bet_amount, start_date = game
        result.append({
            "gameCode": game_code,
            "exerciseType": exercise_type,
            "duration": duration,
            "betAmount": float(bet_amount),
            "startDate": start_date
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
def create_game(request):
    """
    Creates a new game and adds the current user to the game.

    Request must contain: user_id, bet_amount, exercise_type,
    frequency, distance, duration, adaptive_goals, start_date

    frequncy, distance may be null

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
    if distance is not None:
        distance = round(distance / duration, 2)
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

    Request must contain: user ID, game code

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

    if not user_id or not game_code:
        return JsonResponse({"error": "Invalid or missing user_id/game_code"}, status=400)


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
    duration = game[5]
    if distance is not None:
        distance = round(distance / duration, 2)
    if frequency is not None:
        frequency = round(frequency / duration, 2)
        
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

    cursor = connection.cursor()
    json_data = json.loads(request.body)

    user_id, game_code, activity_type, distance, duration = (
        json_data.get(key) for key in [
            "user_id", "game_code", "activity_type",
            "distance", "duration"
        ]
    )

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

    cursor.execute("UPDATE GameParticipants \
                   SET weekDistance = weekDistance + %s, \
                   weekFrequency = weekFrequency + 1, \
                   totalDistance = totalDistance + %s, \
                   totalFrequency = totalFrequency + 1 \
                   WHERE gameCode = %s AND userId = %s;",
                   (distance, distance, game_code, user_id))

    # verify activity type is the same as game_type
    if activity_type == exerciseType[0]:
        cursor.execute("INSERT INTO Activities (gameCode, userId, activity, distance, duration, timestamp) \
                        VALUES (%s, %s, %s, %s, %s, %s)",
                        (game_code, user_id, activity_type, distance, duration, current_timestamp))

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

    # verify that game code is valid + fetch game details
    game_code = request.GET.get("game_code")
    cursor.execute("SELECT isActive FROM Games WHERE gameCode = %s", (game_code,))
    game = cursor.fetchone()
    if not game:
        return HttpResponse(status=404)

    cursor.execute("SELECT timestamp FROM Activities WHERE gameCode = %s AND userId = %s ORDER BY timestamp DESC LIMIT 1", (game_code, user_id))
    timestamp_result = cursor.fetchone()
    if timestamp_result:  # Check if a timestamp was found
        timestamp = timestamp_result[0]  # Extract the timestamp from the tuple
        return JsonResponse({"timestamp": timestamp})
    else:
        return JsonResponse({"timestamp": None})  # Return None if no timestamp found


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

from app import adaptive as elo
import os
from django.conf import settings


def update_date(request):
    test_date = date(2024, 10, 31)
    # test_date += timedelta(days=1)
    weekly_update(test_date)
    return HttpResponse("Date updated successfully")  


def weekly_update(date):
    # get the current date
    # current_date = datetime.now().date()
    current_date = date
    
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
            new_last_updated = last_updated + 1
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
            challenge_settings = settings.challenges[exercise_type]
            challenge_file_loc = challenge_settings['file']

            if os.path.exists(challenge_file_loc):
                challenge = elo.deserialize_challenge_from_csv(challenge_file_loc)
            else:
                challenge = elo.create_challenge(
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
                failed_distance = false
                failed_freq = false
                
                if week_distance is not None and week_distance_goal is not None: 
                    if week_distance < week_distance_goal: 
                        losers.append(user_id)
                        failed_distance = true

                if week_frequency is not None and week_freq_goal is not None: 
                    if week_frequency < week_freq_goal:
                        losers.append(user_id)
                        failed_freq = true

                if failed_distance == false and failed_freq == false
                    winners.append(user_id)
            
                # get user's elo score for this exercise type
                elo_type = exercise_type + "Elo"
                query = ''' SELECT %s
                    FROM UserEloRatings 
                    WHERE userId = %s
                '''
                cursor.execute(query, (elo_type, user_id))
                elo_score = cursor.fetchone()[0]

                bounded_values = challenge.bound_values(
                    challenge_settings['get_challenge_tuple'](week_distance, week_frequency)
                )
                # for i in bounded_values:
                #     if i is None:
                #         continue
                #         # don't run compare elo

                # call elo function to get user's new elo score using this weeks data
                new_elo, _ = challenge.compare_elo(
                    player_elo=elo_score,
                    challenge=bounded_values,
                    outcome= 1.0 if not (week_distance < week_distance_goal or week_frequency < week_freq_goal) else 0.0
                )

                # update user's elo score in db 
                query = '''
                    UPDATE UserEloRatings
                    SET %s = %s 
                    WHERE userId = %s
                '''
                cursor.execute(query, (elo_type, new_elo, user_id))
                

                # use elo function to update a user's goal if the game is adaptive
                if adaptive_goals:
                    new_challenges = challenge.get_nearest_challenges(new_elo)
                    best_challenge = new_challenges[0]
                    challenge_params = best_challenge[1]
                    g_t = challenge_settings['get_generic_tuple'](challenge_params)
                    query = '''
                        UPDATE GameParticipants
                        SET weekDistanceGoal = %s, weekFrequencyGoal = %s
                        WHERE gameCode = %s AND userId = %s
                    '''
                    cursor.execute(query, (g_t[0], g_t[1], game_code, user_id))

                # update weekDistance, weekFrequency to be 0 for each user in game
                query = '''
                    UPDATE GameParticipants
                    SET weekDistance = 0, weekFrequency = 0
                    WHERE gameCode = %s AND userId = %s
                '''
                cursor.execute(query, (game_code, user_id))
        
            # add updates to challenge to csv file
            elo.serialize_challenge_to_csv(challenge, challenge_file_loc)


            # use winners and losers to update balances for each player in each game
            # rounding isn't perfect (shown in example), should probably fix
            weekly_amount = round(bet_amount / duration, 2) # 250 / 4 = 62.5
            split_amount = round(len(losers) * weekly_amount, 2) # 62.5 * 3 = 187.5
            split_amount = round(split_amount / len(winners), 2) # 187.5 / 4 = 46.875 = 46.88 ------> (46.88 * 4 = 187.52) ------> 187.52 > original split_amount (187.5)

            for p in participants:
                user_id = p[0]
                amount_gained = p[5]
                amount_lost = p[6]
                if user_id in losers:
                    new_amount_lost = amount_lost + weekly_amount
                    query = '''
                        UPDATE GameParticipants
                        SET amountLost = %s
                        WHERE gameCode = %s AND userId = %s
                    '''
                    cursor.execute(query, (new_amount_lost, game_code, user_id))

                elif user_id in winners:
                    new_amount_gained = amount_gained + split_amount
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


#def update_caller():
    

def update():
    cursor = connection.cursor()
    query = '''
        SELECT G.gameCode, G.startDate, G.lastUpdated, G.betAmount, G.duration, G.adaptiveGoals, G.exerciseType
        FROM Games G
        WHERE G.isActive = TRUE
    '''
    cursor.execute(query)
    games = cursor.fetchall()

    for game in games:
        game_code, start_date, last_updated, bet_amount, duration, adaptive_goals, exercise_type = game

        # change game's last updated week # to current week #
        new_last_updated = last_updated + 1
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
        challenge_settings = settings.challenges[exercise_type]
        challenge_file_loc = challenge_settings['file']

        if os.path.exists(challenge_file_loc):
            challenge = elo.deserialize_challenge_from_csv(challenge_file_loc)
        else:
            challenge = elo.create_challenge(
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
            if week_distance < week_distance_goal or week_frequency < week_freq_goal:
                losers.append(user_id)
            else:
                winners.append(user_id)

            # get user's elo score for this exercise type
            elo_type = exercise_type + "Elo"
            query = ''' SELECT %s
                FROM UserEloRatings 
                WHERE userId = %s
            '''
            cursor.execute(query, (elo_type, user_id))
            elo_score = cursor.fetchone()[0]

            bounded_values = challenge.bound_values(
                challenge_settings['get_challenge_tuple'](week_distance, week_frequency)
            )
            # for i in bounded_values:
            #     if i is None:
            #         continue
            #         # don't run compare elo

            # call elo function to get user's new elo score using this weeks data
            new_elo, _ = challenge.compare_elo(
                player_elo=elo_score,
                challenge=bounded_values,
                outcome= 1.0 if not (week_distance < week_distance_goal or week_frequency < week_freq_goal) else 0.0
            )

            # update user's elo score in db 
            query = '''
                UPDATE UserEloRatings
                SET %s = %s 
                WHERE userId = %s
            '''
            cursor.execute(query, (elo_type, new_elo, user_id))
            

            # use elo function to update a user's goal if the game is adaptive
            if adaptive_goals:
                new_challenges = challenge.get_nearest_challenges(new_elo)
                best_challenge = new_challenges[0]
                challenge_params = best_challenge[1]
                g_t = challenge_settings['get_generic_tuple'](challenge_params)
                query = '''
                    UPDATE GameParticipants
                    SET weekDistanceGoal = %s, weekFrequencyGoal = %s
                    WHERE gameCode = %s AND userId = %s
                '''
                cursor.execute(query, (g_t[0], g_t[1], game_code, user_id))

            # update weekDistance, weekFrequency to be 0 for each user in game
            query = '''
                UPDATE GameParticipants
                SET weekDistance = 0, weekFrequency = 0
                WHERE gameCode = %s AND userId = %s
            '''
            cursor.execute(query, (game_code, user_id))

        # add updates to challenge to csv file
        elo.serialize_challenge_to_csv(challenge, challenge_file_loc)


        # use winners and losers to update balances for each player in each game
        # rounding isn't perfect (shown in example), should probably fix
        weekly_amount = round(bet_amount / duration, 2) # 250 / 4 = 62.5
        split_amount = round(len(losers) * weekly_amount, 2) # 62.5 * 3 = 187.5
        split_amount = round(split_amount / len(winners), 2) # 187.5 / 4 = 46.875 = 46.88 ------> (46.88 * 4 = 187.52) ------> 187.52 > original split_amount (187.5)

        for p in participants:
            user_id = p[0]
            amount_gained = p[5]
            amount_lost = p[6]
            if user_id in losers:
                new_amount_lost = amount_lost + weekly_amount
                query = '''
                    UPDATE GameParticipants
                    SET amountLost = %s
                    WHERE gameCode = %s AND userId = %s
                '''
                cursor.execute(query, (new_amount_lost, game_code, user_id))

            elif user_id in winners:
                new_amount_gained = amount_gained + split_amount
                query = '''
                    UPDATE GameParticipants
                    SET amountGained = %s
                    WHERE gameCode = %s AND userId = %s
                '''
                cursor.execute(query, (new_amount_gained, game_code, user_id))
        
        
        

    # scheduler = BackgroundScheduler()

    # # schedule to run at the end of everyday
    # scheduler.add_job(job, 'interval', days=1, start_date='2024-11-06 23:59:00')
    # scheduler.start()

    # try:
    #     while True:
    #         time.sleep(60)  # Sleep to keep the scheduler running
    # except (KeyboardInterrupt, SystemExit):
    #     scheduler.shutdown()
