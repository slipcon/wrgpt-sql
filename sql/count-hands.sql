
SELECT players.name, count(playerhands.handid) AS count
FROM players left outer join playerhands
ON (playerhands.playerId=players.playerId) 
WHERE players.stillplaying=true
GROUP BY players.name ORDER BY count

