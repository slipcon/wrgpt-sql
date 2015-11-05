\i sql/time-note.sql

\echo
\echo This query shows the average wall clock time delta for each player,
\echo between when it became their turn and when they moved.
\echo

SELECT p.name, avg(m.wait) AS wait
FROM moves m, players p
WHERE m.playerid=p.playerid AND p.stillplaying=true
GROUP BY p.name ORDER BY wait DESC;

\echo
\echo This query shows the average wall clock time delta for each player,
\echo including eliminated players, between when it became their turn and,
\echo when they moved.
\echo

SELECT p.name, avg(m.wait) AS wait
FROM moves m, players p
WHERE m.playerid=p.playerid 
GROUP BY p.name ORDER BY wait DESC;



\echo
\echo
\echo  Same query, but excluding advance moves (e.g time delta of zero)
\echo

SELECT p.name, avg(m.wait) AS wait
FROM moves m, players p
WHERE m.playerid=p.playerid AND p.stillplaying=true AND m.wait != '0 s'
GROUP BY p.name ORDER BY wait DESC;

\echo
\echo
\echo  Same query, sorted by table
\echo

SELECT p.name, avg(m.wait) AS wait, max(t.round) AS round , max(t.tablenum) AS tablenum
FROM moves m, players p, standings s, tables t
WHERE m.playerid=p.playerid AND p.stillplaying=true AND s.playerid=p.playerid AND t.tableid=s.tableid
GROUP BY p.name ORDER BY tablenum ;
