##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun Aug 15 11:16:54 CEST 2021
## Last Modified: Mon Aug 23 06:06:09 CEST 2021
## Syntax:        GNU Makefile
## Filename:      nifc-humdrum-data/Makefile
## vim:           ts=3
##
## Description:   Makefile to run tasks for nifc-humdrum-data repository.
##
## Usage:
##


.PHONY: kern

KERNREPOS =  ../humdrum-chopin-first-editions  \
	../humdrum-polish-scores/pl-cz              \
	../humdrum-polish-scores/pl-kk              \
	../humdrum-polish-scores/pl-kozmzk          \
	../humdrum-polish-scores/pl-sa              \
	../humdrum-polish-scores/pl-stab            \
	../humdrum-polish-scores/pl-wn              \
	../humdrum-polish-scores/pl-wtm

TARGETDIR = kern


##############################
##
## all -- List makefile targets.
##

all:
	@echo
	@echo "Makefile targets:"
	@echo "   make kern        -- Create symbolic links to digital scores."
	@echo "   make count       -- Count the number of linked kern files."
	@echo



##############################
##
## kern -- create symbolic links to Humdrum files from data
##     repositories stored elsewhere (Add kern directories
##     KERNREPOS variable to include them in this system).
##

kern:
	bin/makeKernLinks -t $(TARGETDIR) $(KERNREPOS)
	@echo "kern directory has $$(ls kern/*.krn | wc -l | sed 's/^ +//') files"
	# Check for bad character encodings:
	-file kern/*.krn | grep -v UTF-8  | grep -v ASCII



##############################
##
## kern-verbose --
##

kv: kern-verbose
kern-verbose:
	bin/makeKernLinks -v $(KERNREPOS)
	@echo "kern directory has $$(ls kern/*.krn | wc -l | sed 's/^ +//') files"
	# Check for bad character encodings:
	-file kern/*.krn | grep -v UTF-8  | grep -v ASCII



##############################
##
## count-kern-files --
##

count: count-kern-files
count-kern-files:
	ls $(TARGETDIR)/*.krn | wc -l



##############################
##
## check-kern --
##

ck: check-kern
check-kern:
	humdrum kern/*.krn



