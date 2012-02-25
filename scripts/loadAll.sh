#!/bin/sh

directory=$DATADIR/history

for i in `ls -1 $directory/*.history ` ; do
	./scripts/load.pl $i
done

perl ./scripts/standings.pl

psql $DATABASE < ./sql/finish-setup.sql
