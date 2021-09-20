##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun Sep 12 06:50:13 PDT 2021
## Last Modified: Sat 18 Sep 2021 06:44:11 PM PDT
## Syntax:        GNU Makefile
## Filename:      cache/Makefile
## vim:           ts=3:nowrap
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
	@echo "make cache-index == Create main cache index (cache-index-new.hmd)."
	@echo "make copy-kern   == Copy files from kern directory to cache using cache-index-new.hmd."
	@echo "make recopy-kern == Copy files from kern directory to cache using cache-index.hmd."
	@echo "make derivatives == Run analyses for new files."
	@echo "make indexes     == Create cached indexes before publication."
	@echo "make indexes-new == Create cached indexes before publication."
	@echo "make publish     == Activate the index for the new set of files. (Move cache-index-new.hmd to cache-index.hmd)"
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

update: cache-index copy-kern derivatives indexes-new publish purge



##############################
##
## cache-index -- Create new cache index.  Reads files from ../kern and
##      creates an index of various IDs for each file.  The index
##      is stored in a temporary file with a "-new" prefix so that
##      the old set of files can be served while new derivative files
##      and indexes are prepared.
##

index: cache-index
cache-index:
	bin/makeCacheIndex > cache-index-new.hmd



##############################
##
## copy-kern -- Copy kern files into cache.
##

ck: copy-kern
kern: copy-kern
copy: copy-kern
copy-kern:
	bin/copyKernToCache -i cache-index-new.hmd

rk: recopy-kern
recopy: recopy-kern
recopy-kern:
	bin/copyKernToCache -i cache-index.hmd



##############################
##
## publish -- Publish new data files.
##

publish:
	-mv cache-index.hmd cache-index-old.hmd
	mv cache-index-new.hmd cache-index.hmd



##############################
##
## purge -- Remove old content from cache (stored in "purged" directory for review).
##

purge:
	bin/purgeCache
	@echo
	@echo Purged entries:
	-ls purged
	@echo
	@echo "Check purged directory contents and then type"
	@echo "\"make erase-purge\" if the purged contents should be deleted"



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
## Indexes:  -new targets should be run before "make publish", and non-new
##     versions should be run after "make publish".  The difference
##     is related to which index file is read for preparing the indexes.
##

indexes-new: popc2-browse-index-new
indexes: popc2-browse-index

popc2-browse-index-new:
	@mkdir -p indexes
	-rm -f indexes/popc2-browse-index.aton.gz
	-rm -f indexes/popc2-browse-index.json.gz
	bin/makePopc2Index -i cache-index-new.hmd > indexes/popc2-browse-index.aton
	(cd indexes; aton2json popc2-browse-index.aton | sed 's/^{"ENTRY"://; s/}[]]}$$/}]/' > popc2-browse-index.json)
	(cd indexes; gzip popc2-browse-index.json)
	(cd indexes; gzip popc2-browse-index.aton)

popc2-browse-index:
	@mkdir -p indexes
	-rm -f indexes/popc2-browse-index.aton.gz
	-rm -f indexes/popc2-browse-index.json.gz
	bin/makePopc2Index -i cache-index.hmd > indexes/popc2-browse-index.aton
	(cd indexes; aton2json popc2-browse-index.aton | sed 's/^{"ENTRY"://; s/}[]]}$$/}]/' > popc2-browse-index.json)
	(cd indexes; gzip popc2-browse-index.json)
	(cd indexes; gzip popc2-browse-index.aton)



##############################
##
## derivatives --
##

derivative: derivatives
derivatives: other-derivatives
	bin/makeDerivatives

other-derivatives: regenerate-spreadsheet-new



##############################
##
## Generate all derivatives in the makeDerivatives system:
##   mei:       Convert Humdrum files to MEI files.
##   musicxml:  Convert Humdrum files to MusicXML files.
##   thema:     Generate thema search indexes.
##

generate-all:
	bin/makeDerivatives

regenerate-all:
	bin/makeDerivatives -f

missing-all:
	@bin/listMissingDerivatives -mcf

erase-all: erase-mei erase-musicxml erase-thema


##############################
##
## MEI conversions.
##

generate-mei:
	bin/makeDerivatives -d mei

regenerate-mei:
	bin/makeDerivatives -f -d mei

missing-mei:
	@bin/listMissingDerivatives -d mei -mcf

erase-mei:
	bin/eraseDerivatives -d mei


##############################
##
## MusicXML conversions.
##

generate-musicxml:
	bin/makeDerivatives -d musicxml

regenerate-musicxml:
	bin/makeDerivatives -f -d musicxml

missing-musicxml:
	@bin/listMissingDerivatives -d musicxml -mcf

erase-musicxml:
	bin/eraseDerivatives -d musicxml



##############################
##
## Thema search indexes.
##

generate-thema:
	bin/makeDerivatives -d thema
	cat */*/*-pitch.thema > indexes/thema-pitch.txt
	gzip indexes/thema-pitch.txt

regenerate-thema:
	bin/makeDerivatives -f -d thema
	cat */*/*-pitch.thema > indexes/thema-pitch.txt
	gzip indexes/thema-pitch.txt

missing-thema:
	@bin/listMissingDerivatives -d thema -mcf

erase-thema:
	bin/eraseDerivatives -d thema
	rm indexes/thema-pitch.txt.gz


###########################################################################
##
## Data preparations that do not use the makeDerivatives system:
##

##############################
##
## Download metadata from the --
##

generate-spreadsheet-new: regenerate-spreadsheet-new

generate-spreadsheet: regenerate-spreadsheet

#regenerate-spreadsheet: erase-spreadsheet
regenerate-spreadsheet:
	bin/makeSpreadsheetInfo

#regenerate-spreadsheet-new: erase-spreadsheet
regenerate-spreadsheet-new:
	bin/makeSpreadsheetInfo -i cache-index-new.hmd

erase-spreadsheet:
	rm ?/*/*-spreadsheet.aton



