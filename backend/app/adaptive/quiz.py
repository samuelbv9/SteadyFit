import configparser
import os


def create_default_config():
    """
    Creates a default config.ini file with example settings.
    """
    config = configparser.ConfigParser()

    # General settings
    config['General'] = {
        'starting_elo': 1200,
        'score_multiplier': 50
    }

    # Example quiz questions
    config['physical_activity_per_week'] = {
        '0 days': -1,
        '1-2 days': 0,
        '3-4 days': 1,
        '5-6 days': 2,
        '7 days': 3
    }

    config['work_related_activity'] = {
        'Yes, mostly sedentary with little physical activity': -1,
        'Yes, moderately active (some walking or standing)': 0,
        'Yes, very active (heavy physical labor)': 1,
        'No': 0
    }

    config['transportation_related_activity'] = {
        'Mostly by car or public transportation': -1,
        'Often walk or bike': 1,
        'Mix of walking/biking and car/public transportation': 0
    }

    config['recreational_related_activity'] = {
        '0 days': -1,
        '1-2 days': 0,
        '3-4 days': 1,
        '5-6 days': 2,
        '7 days': 3
    }

    config['sedentary_related_activity'] = {
        'Less than 2 hours': 2,
        '2-4 hours': 1,
        '4-6 hours': 0,
        '6-8 hours': -1,
        'More than 8 hours': -2
    }

    config['physical_activity_intensity'] = {
        'Mostly light (e.g., walking at a casual pace)': 0,
        'Mostly moderate (e.g., brisk walking, biking)': 1,
        'Mostly vigorous (e.g., running, heavy lifting)': 2,
        'N/a': 0
    }

    # Write to quiz.ini
    with open('quiz.ini', 'w') as configfile:
        config.write(configfile)


def read_quiz_config() -> dict:
    """
    Reads the quiz.ini file and returns a dictionary with configuration values.
    If the file doesn't exist, a default one is created.
    """
    config = configparser.ConfigParser()

    if not os.path.exists('quiz.ini'):
        print("Quiz configuration file not found. Creating a default quiz.ini...")
        create_default_config()

    config.read('quiz.ini')

    try:
        starting_elo = int(config.get('General', 'starting_elo'))
        score_multiplier = int(config.get('General', 'score_multiplier'))
    except (configparser.NoSectionError, configparser.NoOptionError):
        raise ValueError("Missing required 'General' section or keys in quiz.ini")

    # Parse question sections into a dictionary
    questions = {}
    for section in config.sections():
        if section == "General":
            continue
        questions[section] = {
            answer: int(score) for answer, score in config.items(section)
        }

    return {
        "elo": starting_elo,
        "multiplier": score_multiplier,
        "questions": questions
    }


class InvalidQuestion(Exception):
    """Raised when a question is supplied that is not in the config."""
    pass


def evaluate_quiz(quiz_answers: list[tuple[str, str]]) -> int:
    """
    Evaluates the quiz answers and calculates the resulting ELO score.

    :param quiz_answers: List of tuples containing question and answer pairs.
    :return: Calculated ELO score.
    """
    config = read_quiz_config()

    elo = config['elo']
    mult = config['multiplier']
    questions = config['questions']

    score = 0
    for q, a in quiz_answers:
        if q not in questions:
            raise InvalidQuestion(f"Question '{q}' does not exist in 'quiz.ini', these are the questions{questions}")
        if a not in questions[q]:
            raise InvalidQuestion(f"Answer '{a}' is not valid for question '{q}'")

        score += questions[q][a]

    return elo + mult * score



