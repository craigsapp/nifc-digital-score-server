##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun Sep 12 06:50:13 PDT 2021
## Last Modified: Sat 18 Sep 2021 06:44:11 PM PDT
## Syntax:        GNU Makefile
## Filename:      cache/Makefile
## vim:           ts=3
##
## Description:   Makefile to run cache tasks for nifc-humdrum-data repository.
##
##


##############################
##
## all -- List makefile targets that can be done with this makefile.
##

all:
	@echo
	@echo "First prepare files in ../kern directory before updating cache."
	@echo
	@echo "Minimal usage: \"make update\" then \"make erase-purge\"."
	@echo
	@echo "make update      == Make: index copy-kern derivatives publish purge."
	@echo "make index       == Create cache index."
	@echo "make copy-kern   == Copy files from kern directory to cache using index-new.hmd."
	@echo "make recopy-kern == Copy files from kern directory to cache using index.hmd."
	@echo "make derivatives == Run analyses for new files."
	@echo "make publish     == Activate the index for the new set of files. (Move index-new.hmd to index.hmd)"
	@echo "make purge       == Remove files no longer in index."
	@echo "make erase-purge == Remove files from purged directory."
	@echo "make erase-cache == Remove all files from cache."
	@echo



##############################
##
## update -- Install new files, create derivative files and then
##     publish the new files when everything is ready.  And finally
##     purge old files from cache.
##

update: index copy-kern derivatives publish purge



##############################
##
## index -- Create new cache index.  Reads files from ../kern and
##      creates an index of various IDs for each file.  The index
##      is stored in a temporary file with a "-new" prefix so that
##      the old set of files can be served while new files are
##      prepared.
##

index:
	bin/makeIndex > index-new.hmd



##############################
##
## copy-kern -- Copy kern files into cache.
##

ck: copy-kern
kern: copy-kern
copy: copy-kern
copy-kern:
	bin/copyKernToCache -i index-new.hmd

rk: recopy-kern
recopy: recopy-kern
recopy-kern:
	bin/copyKernToCache -i index.hmd



##############################
##
## derivatives --
##

derivative: derivatives
derivatives: regenerate-spreadsheet-new
	bin/makeDerivatives



##############################
##
## publish -- Publish new data files.
##

publish:
	-mv index.hmd index-old.hmd
	mv index-new.hmd index.hmd



##############################
##
## purge -- Remove old content from cache (stored in "purged" directory for review).
##

purge:
	bin/purgeCache



##############################
##
## erase-purge -- Delete purged files.
##

erase-purge:
	rm -rf purged/*



##############################
##
## erase-cache -- Remove all contents from cache.
##

super-clean: erase-cache
make ec: erase-cache
erase-cache:
	rm -f ?


##############################
##
## Indexes:
##

indexes: popc2-browse-index

popc2-browse-index:
	@mkdir -p indexes
	-rm -f indexes/popc2-browse-index.aton.gz
	-rm -f indexes/popc2-browse-index.json.gz
	bin/makePopc2Index > indexes/popc2-browse-index.aton
	(cd indexes; aton2json popc2-browse-index.aton | sed 's/^{"ENTRY"://; s/}[]]}$$/}]/' > popc2-browse-index.json)
	(cd indexes; gzip popc2-browse-index.json)
	(cd indexes; gzip popc2-browse-index.aton)



##############################
##
## Derivatives:
##

generate-all:
	bin/makeDerivatives

regenerate-all:
	bin/makeDerivatives -f

missing-all:
	@bin/listMissingDerivatives -mcf

erase-all: erase-mei erase-musicxml


##############################

generate-mei:
	bin/makeDerivatives -d mei

regenerate-mei:
	bin/makeDerivatives -f -d mei

missing-mei:
	@bin/listMissingDerivatives -d mei -mcf

erase-mei:
	bin/eraseDerivatives -d mei


##############################

generate-musicxml:
	bin/makeDerivatives -d musicxml

regenerate-musicxml:
	bin/makeDerivatives -f -d musicxml

missing-musicxml:
	@bin/listMissingDerivatives -d musicxml -mcf

erase-musicxml:
	bin/eraseDerivatives -d musicxml

##############################

generate-spreadsheet-new: regenerate-spreadsheet-new

generate-spreadsheet: regenerate-spreadsheet

#regenerate-spreadsheet: erase-spreadsheet
regenerate-spreadsheet:
	bin/makeSpreadsheetInfo

#regenerate-spreadsheet-new: erase-spreadsheet
regenerate-spreadsheet-new:
	bin/makeSpreadsheetInfo -i index-new.hmd

erase-spreadsheet:
	rm ?/*/*-spreadsheet.aton



