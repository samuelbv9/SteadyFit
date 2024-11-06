CREATE TABLE Users (
    userId       VARCHAR(255) PRIMARY KEY,
    email        VARCHAR(255) NOT NULL DEFAULT 'default@example.com',    
    name         VARCHAR(255)
);

CREATE TABLE Games (
    gameCode      VARCHAR(20) PRIMARY KEY,
    betAmount     DECIMAL(10, 2) NOT NULL,
    exerciseType  VARCHAR(50) NOT NULL,
    frequency     INTEGER,
    distance      DECIMAL(10, 2),
    duration      INTEGER NOT NULL,
    adaptiveGoals BOOLEAN NOT NULL,
    startDate     DATE NOT NULL,
    lastUpdated   INT NOT NULL DEFAULT 0,
    isActive      BOOLEAN DEFAULT TRUE
);

CREATE TABLE GameParticipants (
    gameCode            VARCHAR(20) NOT NULL,
    userId              VARCHAR(255) NOT NULL,
    amountGained        DECIMAL(10, 2) DEFAULT 0,
    amountLost          DECIMAL(10, 2) DEFAULT 0,
    balance             DECIMAL(10, 2) GENERATED ALWAYS AS (amountGained - amountLost) STORED,
    totalDistance       DECIMAL(10, 2) DEFAULT 0,
    weekDistance        DECIMAL(10, 2) DEFAULT 0,
    weekDistanceGoal    DECIMAL(10, 2) DEFAULT 0,
    totalFrequency      INTEGER DEFAULT 0,
    weekFrequency       INTEGER DEFAULT 0,
    weekFrequencyGoal   INTEGER DEFAULT 0
    PRIMARY KEY (gameCode, userId),
    FOREIGN KEY (gameCode) REFERENCES Games(gameCode) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES Users(userId) ON DELETE CASCADE
);

CREATE TABLE Activities (
    gameCode       VARCHAR(20) NOT NULL,
    userId         VARCHAR(255) NOT NULL,
    activity       VARCHAR(20) NOT NULL,
    distance       DECIMAL(10, 2) DEFAULT 0,
    duration       INTEGER DEFAULT 0,
    timestamp      TIMESTAMP NOT NULL, 
    PRIMARY KEY (gameCode, userId, timestamp),
    FOREIGN KEY (gameCode) REFERENCES Games(gameCode) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES Users(userId) ON DELETE CASCADE
);

CREATE TABLE UserEloRatings (
    userId      VARCHAR(255) NOT NULL,
    walkingElo  INT DEFAULT 1200,
    runningElo  INT DEFAULT 1200,
    swimmingElo INT DEFAULT 1200,
    cyclingElo  INT DEFAULT 1200,
    strengthTrainingElo INT DEFAULT 1200,
    PRIMARY KEY (userId),
    FOREIGN KEY (userId) REFERENCES Users(userId) ON DELETE CASCADE
);