
select simplecards,count(simplecards) from playerhands where simplecards is not null group by simplecards order by count ;


CREATE TEMPORARY TABLE handWinPct AS
	SELECT simplecards, 0 AS numWins, 0 AS numLosses
	FROM playerhands 
	WHERE simplecards IS NOT NULL
	GROUP BY simplecards;

CREATE TEMPORARY TABLE handWins AS
	SELECT simplecards, count(simplecards) AS numWins
	FROM playerhands
	WHERE winner='true'
	GROUP BY simplecards;

CREATE TEMPORARY TABLE handLosses AS
	SELECT simplecards,count(simplecards) AS numLosses
	FROM playerhands
	WHERE winner='false'
	GROUP BY simplecards;


UPDATE handWinPct
SET numWins=handWins.numWins
FROM handWins
WHERE handWinPct.simplecards = handWins.simplecards;

UPDATE handWinPct
SET numLosses=handLosses.numLosses
FROM handLosses
WHERE handWinPct.simplecards = handLosses.simplecards;


SELECT simplecards, CAST(CAST(numWins AS numeric)/CAST(numWins+numLosses AS numeric)*100.0 AS numeric(10,2)) AS winPct
FROM handWinPct
ORDER BY winPct;
