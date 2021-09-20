##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun Aug 15 11:16:54 CEST 2021
## Last Modified: Sun 19 Sep 2021 09:01:44 AM PDT
## Syntax:        GNU Makefile
## Filename:      Makefile
## vim:           ts=3
##
## Description:   Makefile to run tasks for nifc-humdrum-data repository.
##
## Usage:         Type "make" to see list of common make targets.  To update everything,
##                type "make update" if the server has already been set up.
##


.PHONY: kern


# KERNREPOS: This is a list of all of the directories where Humdrum files
# are located that should be incorporated into this data server for the
# files.
KERNREPOS =  ../humdrum-chopin-first-editions  \
	../humdrum-polish-scores/pl-cz              \
	../humdrum-polish-scores/pl-kk              \
	../humdrum-polish-scores/pl-kozmzk          \
	../humdrum-polish-scores/pl-sa              \
	../humdrum-polish-scores/pl-stab            \
	../humdrum-polish-scores/pl-wn              \
	../humdrum-polish-scores/pl-wtm


# TARGETDIR: The directory into which symbolic links to Humdrum files in the
# KERNREPOS directory list are located.
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
	@echo "   make update      -- Run \"make kern\" then update cache."
	@echo



##############################
##
## update -- Prepare kern directory, then update cache files.
##    The files in the ../humdrum-polish-scores repository should
##    be up to date before running this command. (and humdrum-chopin-first-editions)
##

update: kern
	(cd cache; make update)



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



