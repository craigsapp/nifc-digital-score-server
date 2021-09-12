##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun Sep 12 06:50:13 PDT 2021
## Last Modified: Sun Sep 12 06:50:17 PDT 2021
## Syntax:        GNU Makefile
## Filename:      nifc-humdrum-data/Makefile
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
	@echo "make update      == Make index copy-kern do-analyses publish purge."
	@echo "make index       == Create cache index."
	@echo "make copy-kern   == Copy files from kern directory to cache."
	@echo "make derivatives == Run analyses for new files."
	@echo "make publish     == Activate the index for the new set of files."
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
## index -- Create new cache index.
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
	bin/copyKernToCache



##############################
##
## derivatives -- 
##

derivatives:
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
	rm -rf purge/*



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
## Derivatives:
##

generate-mei:
	bin/makeDerivatives -d mei

regenerate-mei:
	bin/makeDerivatives -f -d mei




