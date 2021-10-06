##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun Sep 12 06:50:13 PDT 2021
## Last Modified: Wed 22 Sep 2021 09:55:10 PM PDT
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
	@echo "See the Makefile's contents for other possible targets"
	@echo



##############################
##
## update -- Install new files, create derivative files and then
##     publish the new files when everything is ready.  And finally
##     purge old files from cache and generate music search indexes.
##
## Steps to update the cache are:
##
## 0. First you should place updated files in the ../kern directory (see
##                 ../Makefile for this process).
## 1. cache-index: Creates cache-index-new.hmd based on files in ../kern .
## 2. copy-kern:   Copy ../kern files into cache directories (based on the
##                 MD5 checksum of the files).
## 3. derivatives: Calculate data conversions and analyses of the original
##                 Humdrum file.
## 4. indexes-new: Create browsing indexes for website(s).
## 5. publish:     Move cache-index-new.hmd to cache-index.hmd
## 6. purge:       Move unused cached files to the purged directory.  You can
##                 Examine them to see if the should be purged, and if so,
##                 the command "make erase-purged" will delete them.
## 7. cache-thema: Create repertory-wide music search indexes.
##

update: cache-index copy-kern derivatives indexes-new publish purge cache-thema



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

erase-purged: erase-purge
erase-purge:
	rm -rf purged/*



##############################
##
## clean-index: Remove old cache index.
##

clean-index:
	rm -f cache-index-old.hmd



##############################
##
## clean --
##

clean: clean-index erase-purge



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

indexes-new: popc2-browse-index-new lyrics-index-new
indexes: popc2-browse-index lyrics-index

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


lyrics-index-new:
	@mkdir -p indexes
	-rm -f indexes/popc2-lyrics-index.txt.gz
	bin/makeLyricsIndex -i cache-index-new.hmd > indexes/popc2-lyrics-index.txt
	(cd indexes; gzip popc2-lyrics-index.txt)

lyrics-index:
	@mkdir -p indexes
	-rm -f indexes/popc2-lyrics-index.txt.gz
	bin/makeLyricsIndex -i cache-index.hmd > indexes/popc2-lyrics-index.txt
	(cd indexes; gzip popc2-lyrics-index.txt)


composer-index:
	-rm -f indexes/popc2-composer-index.aton.gz
	-rm -f indexes/popc2-composer-index.json.gz
	wget "https://script.google.com/macros/s/AKfycby5J8xq1V8bNpA567Kw3yiQ5EcfS3EvMDRZTrogBxfrL5Q93fSJhACZ42FuhuRoESkZSQ/exec?format=aton" -O indexes/popc2-composer-index.aton
	wget "https://script.google.com/macros/s/AKfycby5J8xq1V8bNpA567Kw3yiQ5EcfS3EvMDRZTrogBxfrL5Q93fSJhACZ42FuhuRoESkZSQ/exec?format=aton" -O indexes/popc2-composer-index.json
	(cd indexes; gzip popc2-composer-index.aton)
	(cd indexes; gzip popc2-composer-index.json)


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
##   wordlist:  Generate word list from lyrics in file.
##

generate-all:
	bin/makeDerivatives

regenerate-all:
	bin/makeDerivatives -f

missing-all:
	@bin/listMissingDerivatives -mcf

erase-all: erase-mei erase-musicxml erase-thema erase-wordlist


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
	bin/makeDerivatives -v -d musicxml

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
	bin/makeDerivatives -v -d thema

regenerate-thema:
	bin/makeDerivatives -f -d thema

missing-thema:
	@bin/listMissingDerivatives -d thema -mcf

erase-thema:
	bin/eraseDerivatives -d thema
	rm indexes/thema-pitch.txt.gz



##############################
##
## Lyrics word list
##

generate-wordlist:
	bin/makeDerivatives -v -d wordlist

regenerate-wordlist:
	bin/makeDerivatives -f -d wordlist

missing-wordlist:
	@bin/listMissingDerivatives -d wordlist -mcf

erase-wordlist:
	bin/eraseDerivatives -d wordlist


#
# Do "make cache-thema" after purging old entries from the cache:
# (do not do at derivative generation step that individual
# work thema files are created).
#

thema-cache: cache-thema
cache-thema:
	-rm -f indexes/thema-pitch.txt.gz
	cat ?/*/*-pitch.thema > indexes/thema-pitch.txt
	gzip indexes/thema-pitch.txt



###########################################################################
##
## Data preparations that do not use the makeDerivatives system:
##

##############################
##
## Download metadata from the POPC-2 Google spreadsheet --
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



