\i sql/time-note.sql

\echo
\echo This query shows the average wall clock time delta for each player,
\echo between when it became their turn and when they moved.
\echo

SELECT p.name, avg(m.wait) AS wait
FROM moves m, players p
WHERE m.playerid=p.playerid AND p.stillplaying=true
GROUP BY p.name ORDER BY wait DESC;

