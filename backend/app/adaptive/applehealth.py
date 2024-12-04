import math

def InitEloAppleHealth(VO2max, RH):
    """
    Calculates the initial ELO (skill level) for a player based on their VO2 max
    and resting heart rate, using a weighted equation.

    The function standardizes the inputs (VO2 max and resting heart rate) to ensure 
    they are normalized relative to their respective population averages and 
    standard deviations. It then uses these standardized values to compute an 
    ELO score, with an average of 1200 for the population.

    Parameters:
    - VO2max (float): The user's VO2 max value (in mL/kg/min).
    - RH (float): The user's resting heart rate (in beats per minute).

    Returns:
    - float: The calculated initial ELO score.

    Notes:
    - VO2 max is positively correlated with fitness, so higher values increase ELO.
    - Resting heart rate is negatively correlated with fitness, so lower values increase ELO.
    - The weights (wVO2 and wRH) control the relative importance of VO2 max and resting heart rate.
    - Assumptions about population averages and standard deviations are derived 
      from cited health statistics:
      - VO2 max: mean = 33.35, std dev = 3.77.
      - Resting heart rate: mean = 65.5, std dev = 7.7.
    """
    mean_elo = 1200
    
    # Statistics for VO2 max (mean and standard deviation)
    avgVO2 = 33.35
    stdVO2 = 3.77
    
    # Statistics for resting heart rate (mean and standard deviation)
    avgRH = 65.5
    stdRH = 7.7

    def standardize(value, mean, std_dev):
        """
        Standardizes a value by converting it to a z-score.

        Parameters:
        - value (float): The value to standardize.
        - mean (float): The mean of the dataset.
        - std_dev (float): The standard deviation of the dataset.

        Returns:
        - float: The standardized z-score.
        """
        if std_dev == 0:
            raise ValueError("Standard deviation cannot be zero.")
        return (value - mean) / std_dev

    # Weights for VO2 max and resting heart rate in the ELO equation
    wVO2 = 100
    wRH = 50
    
    # Get z-score values for calculation
    zVO2 = standardize(VO2max, avgVO2, stdVO2)
    zRH = standardize(RH, avgRH, stdRH)
    
    # Calculate initial ELO
    initialELO = mean_elo + wVO2 * zVO2 - wRH * zRH
    
    return initialELO