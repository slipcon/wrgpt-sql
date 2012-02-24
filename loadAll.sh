#!/bin/sh

directory=$DATADIR/history

for i in `ls -1 $directory/*.history ` ; do
	./load.pl $i
done

perl standings.pl

psql $DATABASE < sql/finish-setup.sql
