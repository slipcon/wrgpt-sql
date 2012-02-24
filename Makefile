
export DATABASE:=wrgpt21
export DATADIR:=data

all:
	@echo Nothing to do

createdb:
	@psql -q -c '\q' ${DATABASE} > /dev/null 2>&1 || createdb ${DATABASE}

dropdb:
	@psql -q -c '\q' ${DATABASE} > /dev/null 2>&1 ; \
	if [[ "$$?" -eq "0" ]]; then \
	    dropdb ${DATABASE} ; \
	fi

reload: dropdb createdb
	@psql ${DATABASE} < ./sql/tables.sql
	@./loadAll.sh

sync:
	@mkdir -p ${DATADIR}/
	@mkdir -p ${DATADIR}/history
	@mkdir -p ${DATADIR}/hands
	@cd ${DATADIR} && rsync -avz elvis.wrgpt.org::wrgpthistory history/.
	@cd ${DATADIR} && rsync -avz elvis.wrgpt.org::wrgpthands hands/.
	@cd ${DATADIR} && rm -f ${DATADIR}/standings.xml ${DATADIR}/eliminations.xml
	@cd ${DATADIR} && wget http://www.wrgpt.org/stats/standings.xml
	@cd ${DATADIR} && wget http://www.wrgpt.org/stats/eliminations.xml
	@cd ${DATADIR} && grep -q -w '&' standings.xml || true && sed 's/ \& / \&amp; /' standings.xml > foo.xml && mv foo.xml standings.xml

clean:
	@rm -rf ${DATADIR}
