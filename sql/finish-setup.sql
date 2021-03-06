
UPDATE players 
SET stillplaying=false 
WHERE playerid IN (
   SELECT p.playerid 
   FROM players p left join standings s 
   ON p.playerId = s.playerId 
   WHERE p.eliminated=false AND s.playerId IS NULL
   );


/*
INSERT INTO playerhands (
   SELECT DISTINCT playerid,handid FROM moves
   );
   */


/* Need to insert eliminations where there are double hits - the query
   will look like:
   
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Eliminated Player' AND p2.name='Hit Man 1');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Eliminated Player' AND p2.name='Hit Man 2');

     */



\echo Looking for eliminated players without hitmen:

SELECT p.name 
FROM players p left join eliminations e
ON p.playerID = e.playerId
WHERE p.eliminated=true AND e.playerId IS NULL;

\echo If any were found, see the Note in README, update sql/finish-setup.sql
