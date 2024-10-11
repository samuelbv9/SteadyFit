CREATE TABLE Users (
    userId       UUID PRIMARY KEY,
    name         VARCHAR(255) NOT NULL
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
    isActive      BOOLEAN DEFAULT TRUE
);

CREATE TABLE GameParticipants (
    gameCode       VARCHAR(20) NOT NULL,
    userId         UUID NOT NULL,
    totalDistance  DECIMAL(10, 2) DEFAULT 0,
    totalFrequency INTEGER DEFAULT 0,
    amountGained   DECIMAL(10, 2) DEFAULT 0,
    amountLost     DECIMAL(10, 2) DEFAULT 0,
    balance        DECIMAL(10, 2) GENERATED ALWAYS AS (amountGained - amountLost) STORED,
    PRIMARY KEY (gameCode, userId),
    FOREIGN KEY (gameCode) REFERENCES Games(gameCode) ON DELETE CASCADE,
    FOREIGN KEY (userId) REFERENCES Users(userId) ON DELETE CASCADE
);
