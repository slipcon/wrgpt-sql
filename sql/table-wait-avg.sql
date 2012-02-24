\echo
\echo This report shows the average wall-clock wait time by table for 
\echo the current round.
\echo 

SELECT t.round, t.tablenum, avg(m.wait) AS wait
FROM moves m, tables t, hands h
WHERE t.broken=false AND m.handid=h.handid AND h.tableid=t.tableid
GROUP BY t.round, t.tablenum ORDER BY wait DESC;

