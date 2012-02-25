
CREATE TEMPORARY TABLE handcount AS
	SELECT players.name, count(playerhands.handid) AS count
	FROM players left outer join playerhands
	ON (playerhands.playerId=players.playerId) 
	WHERE players.stillplaying=true
	GROUP BY players.name ORDER BY count;

\echo
\echo This report shows the number of hands seen by player, across each
\echo table that the player has been at so far.
\echo

SELECT * FROM handcount;

SELECT avg(count) FROM handcount;


