
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


INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Dave Kalagher' AND p2.name='Penguintopia');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Dave Kalagher' AND p2.name='Marcia Kim');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='craig martin' AND p2.name='PorkFat');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='craig martin' AND p2.name='BobW');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='JAFO' AND p2.name='Snake');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='JAFO' AND p2.name='Troy McCormick');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='thePerl' AND p2.name='ROSSBOSS');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='thePerl' AND p2.name='Luigi Barone');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Lisa C' AND p2.name='SurfingJerry');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Lisa C' AND p2.name='Mr. Flintstone');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Zanotti' AND p2.name='Nikadai');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Zanotti' AND p2.name='Jan-Erik Brundell');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Craig N. Boyle' AND p2.name='bmv021');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Craig N. Boyle' AND p2.name='Sketch22');

\echo Looking for eliminated players without hitmen:

SELECT p.name 
FROM players p left join eliminations e
ON p.playerID = e.playerId
WHERE p.eliminated=true AND e.playerId IS NULL;

\echo If any were found, see the Note in README, update sql/finish-setup.sql
