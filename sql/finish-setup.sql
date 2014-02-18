
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

INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='dudehed' AND p2.name='Rcheney');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='dudehed' AND p2.name='Mulligan');

INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Bryan S. Slick' AND p2.name='Rick Brown');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Bryan S. Slick' AND p2.name='Mark-Ed Cards');

INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Aquarian' AND p2.name='Swamper Brian');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='Aquarian' AND p2.name='MartinL');

INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='cw' AND p2.name='tkp');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='cw' AND p2.name='pmppk');


/*
These next two entries are hopefully temporary:  they are not the result of a double elimination.  Instead
for some reason there is corruption in the eliminations.xml file, and it claims that both 'gerdog'
and 'winsumlosesum' were eliminated by 'winsumlosesum has: Ah Qd'.   I've contacted the wrgpt floorman
but as of yet it has not been corrected.
*/

INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='gerdog' AND p2.name='El Guapo');
INSERT INTO eliminations (playerId, hitman)  (
     SELECT p1.playerId, p2.playerId FROM players p1, players p2 WHERE p1.name='winsumlosesum' AND p2.name='El Guapo');


\echo Looking for eliminated players without hitmen:

SELECT p.name 
FROM players p left join eliminations e
ON p.playerID = e.playerId
WHERE p.eliminated=true AND e.playerId IS NULL;

\echo If any were found, see the Note in README, update sql/finish-setup.sql
