import configparser
import os

# takes in quiz answers outputs appropiate starting elo.
def evaluate_apple_health(data: dict) -> int:
    pass


def create_default_config():
    """
    Creates a default config.ini file with example settings.
    """
    config = configparser.ConfigParser()

    config['General'] = {
        'starting_elo': 1200,
        'score_multiplier': 50
    }

    config['age'] = {
        '>50': -1,
        '29-50': 0,
        '16-28': 1
    }

    config['activity_level'] = {
        'never': -1,
        '1-2/week': 0,
        '3+/week': 1,
    }

    with open('quiz.ini', 'w') as configfile:
        config.write(configfile)

def read_quiz_config() -> int:
    config = configparser.ConfigParser()

    if not os.path.exists('quiz.ini'):
        print("Quiz configuration file not found. Creating a default quiz.ini...")
        create_default_config()

    config.read('quiz.ini')

    starting_elo = int(config.get('General', 'starting_elo'))
    score_multiplier = int(config.get('General', 'score_multiplier'))

    questions = {}

    for section in config.sections():
        if section == "General":
            continue

        as_dict = {}
        for answer, score in config.items(section):
            as_dict[answer] = int(score)
        
        questions[section] = as_dict

    config_values = {
        "elo": starting_elo,
        "multiplier": score_multiplier,
        "questions": questions,
    }

    return config_values

class InvalidQuestion(Exception):
    """Raised when a question is supplied that is not in the config."""
    pass

def evaluate_quiz(quiz_answers: list[tuple[str, str]]) -> int:
    config = read_quiz_config()

    elo = config['elo']
    mult = config['multiplier']
    questions = config['questions']

    score = 0

    for q, a in quiz_answers:
        if q not in questions:
            raise InvalidQuestion(f"Question '{q}' does not exist in 'quiz.ini'")
        
        score += questions[q][a]

    return elo + mult * score

# example
# starting_elo = evaluate_quiz(
#     [("age", ">50"), ("activity_level", "never"), ("intensity", "<15min")]
# )