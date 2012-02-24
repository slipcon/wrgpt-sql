CREATE TABLE tables (
   tableId serial UNIQUE,
   round char,
   tablenum integer,
   broken boolean,
   PRIMARY KEY (round, tablenum)
);

CREATE TABLE hands (
   handId SERIAL PRIMARY KEY,
   tableId integer REFERENCES tables (tableId),
   handnum integer,
   startTime timestamp with time zone,
   endTime timestamp with time zone,
   inProgress boolean,
   board text
);

CREATE TABLE players (
   playerId SERIAL PRIMARY KEY,
   name text UNIQUE,
   timeoutCount integer,
   stillPlaying boolean,
   eliminated boolean
);

CREATE TABLE moves (
   moveId SERIAL PRIMARY KEY,
   playerId integer REFERENCES players (playerId),
   handId integer REFERENCES hands (handId),
   moveTime timestamp with time zone,
   wait interval
);


CREATE TABLE playerHands (
   playerId integer REFERENCES players (playerId),
   handId integer REFERENCES hands (handId),
   cards text,
   showdown boolean,
   PRIMARY KEY (playerId, handId)
);


CREATE TABLE standings (
   playerId integer REFERENCES players (playerId) PRIMARY KEY,
   tableId integer REFERENCES tables (tableId),
   bankroll integer,
   highbankroll integer,
   lowbankroll integer
);

CREATE TABLE eliminations (
   playerId integer REFERENCES players (playerId),
   hitman integer REFERENCES players (playerId),
   PRIMARY KEY ( playerId, hitman )
);
