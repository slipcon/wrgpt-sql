
\echo 
\echo Straight tournament standings.   
\echo 
SELECT p.name, s.bankroll
FROM standings s, players p
WHERE s.playerid = p.playerid
ORDER BY s.bankroll DESC;


\echo 
\echo Standings for those who have not eliminated anyone.
\echo 
select p.name, s.bankroll
from standings s, players p
where p.playerid not in ( select distinct hitman from eliminations )
  AND s.playerid = p.playerid
ORDER BY s.bankroll DESC;
