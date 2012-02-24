\echo 
\echo This query gives the number of times a player times out.  Note that in
\echo WRGPT, a player who times out during a hand can come back before the
\echo hand ends, and it will simply look like a fold - his timeout is not
\echo announced.  These scripts do not attempt to count those "private"
\echo timeouts
\echo 

SELECT name, timeoutcount 
FROM players
WHERE timeoutcount <> 0 AND stillplaying = true 
ORDER BY timeoutcount
