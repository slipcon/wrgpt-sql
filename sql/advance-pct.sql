
CREATE TEMPORARY TABLE movepct
AS 
   SELECT players.playerId, count(moves.wait) AS numMoves, 0 AS numAdvance
   FROM players left outer join moves
   ON (moves.playerId=players.playerId) 
   WHERE players.stillplaying=true
   GROUP BY players.playerId ;


CREATE TEMPORARY TABLE movepct2
AS
   SELECT players.playerid, count(moves.wait) AS numAdvance
   FROM players left outer join moves
   ON (moves.playerId=players.playerId) 
   WHERE moves.wait='0 s' AND players.stillplaying=true
   GROUP BY players.playerId;

   
UPDATE movepct
SET numAdvance=movepct2.numAdvance
FROM movepct2
WHERE movepct.playerId = movepct2.playerId;

SELECT players.name, 
    CAST(CAST(movepct.numAdvance AS numeric)/CAST(movepct.numMoves AS numeric)*100.0 AS numeric(10,2)) AS advancePct
FROM players left outer join movepct
ON (movepct.playerId=players.playerId) 
WHERE players.stillplaying=true
ORDER BY advancePct DESC;
