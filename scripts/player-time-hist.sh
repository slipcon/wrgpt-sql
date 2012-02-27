#!/bin/bash

sed "s/%USER%/$*/g"  << EOF | psql wrgpt21
SELECT       EXTRACT(hour FROM m.movetime) AS hour,
       repeat('*'::text,COUNT(EXTRACT(hour from m.movetime))::int) AS count
FROM moves m, players p
WHERE m.playerid=p.playerid AND m.wait != '00:00:00' AND p.name='%USER%'
GROUP BY hour ORDER BY hour;
EOF



