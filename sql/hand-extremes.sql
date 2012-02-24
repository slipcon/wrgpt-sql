\echo
\echo This report shows the fastest and slowest 10 completed hands.
\echo

select t.round, t.tablenum, h.handnum, h.endtime-h.starttime as duration
from hands h, tables t
where h.inprogress='f' and h.tableid=t.tableid
order by duration limit 10;

select t.round, t.tablenum, h.handnum, h.endtime-h.starttime as duration
from hands h, tables t
where h.inprogress='f' and h.tableid=t.tableid
order by duration desc limit 10;
