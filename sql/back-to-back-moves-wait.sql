\echo
\echo This report shows players who make two consecutive moves during a hand,
\echo for example where they call a bet pre-flop and are first to act 
\echo post-flop.  In these cases, the player should reasonably know that they
\echo will be first to act - and should check their email quickly.
\echo This report lists the worst offenders of wall-clock duration between
\echo their own moves.
\echo

select p.name, t.round, t.tablenum, h.handnum, m.wait
from moves m, moves n, hands h, tables t, players p
where m.moveid=n.moveid+1 and m.playerid=n.playerid and m.handid=n.handid
and m.handid=h.handid and t.tableid=h.tableid  and p.playerid=m.playerid
order by wait desc limit 20;


\echo
\echo  Same report, for current round:
\echo


select p.name, t.round, t.tablenum, h.handnum, m.wait
from moves m, moves n, hands h, tables t, players p
where m.moveid=n.moveid+1 and m.playerid=n.playerid and m.handid=n.handid
and m.handid=h.handid and t.tableid=h.tableid  and p.playerid=m.playerid
and t.round=(select chr(max(ascii(round))) from tables)
order by wait desc limit 20;

