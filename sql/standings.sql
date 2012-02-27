
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

\echo 
\echo Standings for those who are at their tournament high 
\echo 
select p.name, s.bankroll
from standings s, players p
where s.bankroll = s.highbankroll
  AND s.playerid = p.playerid
ORDER BY s.bankroll DESC;

\echo 
\echo Standings for those who are at their tournament low 
\echo 
select p.name, s.bankroll
from standings s, players p
where s.bankroll = s.lowbankroll
  AND s.playerid = p.playerid
ORDER BY s.bankroll DESC;
