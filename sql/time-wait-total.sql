\i sql/time-note.sql 

SELECT p.name, sum(m.wait) AS wait 
FROM moves m, players p
WHERE m.playerid=p.playerid AND p.stillplaying=true
GROUP BY p.name ORDER BY wait DESC;

