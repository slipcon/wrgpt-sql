
select simplecards,count(simplecards) from playerhands where simplecards is not null group by simplecards order by count ;
