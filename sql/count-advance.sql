
SELECT players.name, count(moves.wait) AS count
FROM players left outer join moves
ON (moves.playerId=players.playerId) 
WHERE moves.wait='0 s' AND players.stillplaying=true
GROUP BY players.name ORDER BY count

