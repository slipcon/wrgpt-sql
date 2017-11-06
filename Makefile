
export DATABASE:=wrgpt27
export DATADIR:=data

all:
	@echo Nothing to do

createdb:
	@psql -q -c '\q' ${DATABASE} > /dev/null 2>&1 || createdb ${DATABASE}

dropdb:
	@psql -q -c '\q' ${DATABASE} > /dev/null 2>&1 ; \
	if [ "$$?" -eq "0" ]; then \
	    dropdb ${DATABASE} ; \
	fi

reload: dropdb createdb
	@psql ${DATABASE} < ./sql/tables.sql
	@./scripts/loadAll.sh

sync:
	@mkdir -p ${DATADIR}/
	@mkdir -p ${DATADIR}/history
	@mkdir -p ${DATADIR}/hands
	@cd ${DATADIR} && rsync -avz --delete elvis.wrgpt.org::wrgpthistory history/.
	@cd ${DATADIR} && rsync -avz --delete elvis.wrgpt.org::wrgpthands hands/.
	@cd ${DATADIR} && rm -f standings.xml eliminations.xml
	@cd ${DATADIR} && wget http://www.wrgpt.org/stats/standings.xml
	@cd ${DATADIR} && wget http://www.wrgpt.org/stats/eliminations.xml
	@cd ${DATADIR} && grep -q -w '&' standings.xml || true && sed 's/ \& / \&amp; /' standings.xml > foo.xml && mv foo.xml standings.xml

clean:
	@rm -rf ${DATADIR} *.txt hitgraph.png scripts/player-time-hist.sh

everything: sync reload stats graph

scripts/player-time-hist.sh:	scripts/player-time-hist.sh.in
	@echo "Generating scripts/player-time-hist.sh..."
	@sed 's/__DATABASE__/${DATABASE}/g' < scripts/player-time-hist.sh.in > scripts/player-time-hist.sh
	@chmod 755 scripts/player-time-hist.sh

hist:	scripts/player-time-hist.sh
	@if [ -z "${PLAYER}" ]; then \
	   echo "Usage: make hist PLAYER=\"Player Name\"" ; \
	else \
	   ./scripts/player-time-hist.sh ${PLAYER} ; \
	fi



stats:
	@echo "Generating reports..."
	@psql -q ${DATABASE} < sql/advance-pct.sql > advance-pct.txt
	@psql -q ${DATABASE} < sql/count-advance.sql > count-advance.txt
	@psql -q ${DATABASE} < sql/count-hands.sql > count-hands.txt
	@psql -q ${DATABASE} < sql/timeoutcount.sql > timeoutcount.txt
	@psql -q ${DATABASE} < sql/time-wait-avg.sql > time-wait-avg.txt
	@psql -q ${DATABASE} < sql/time-wait-total.sql > time-wait-total.txt
	@psql -q ${DATABASE} < sql/standings.sql > standings.txt
	@psql -q ${DATABASE} < sql/hand-extremes.sql > hand-extremes.txt
	@psql -q ${DATABASE} < sql/hand-frequency.sql > hand-frequency.txt
	@psql -q ${DATABASE} < sql/table-wait-avg.sql > table-wait-avg.txt
	@psql -q ${DATABASE} < sql/back-to-back-moves-wait.sql > back-to-back-moves-wait.txt

graph:
	@echo "Generating hit graph..."	
	@./scripts/hitgraph.pl | ccomps -x | dot | gvpack | neato -n2 -Tpng > hitgraph.png 
