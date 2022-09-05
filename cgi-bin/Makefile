##
## Programmer:    Craig Stuart Sapp <craig@ccrma.stanford.edu>
## Creation Date: Sun 12 Sep 2021 07:42:54 PM PDT
## Last Modified: Sun 12 Sep 2021 07:42:56 PM PDT
## Filename:      ...data-nifc/cgi-bin/Makefile
## Syntax:        GNU makefile
##
## Description: This Makefile automates cgi-bin script installing.
##

CGIBIN = /var/www/cgi-bin

all:
	rm $(CGIBIN)/data-nifc
	cp data-nifc.pl $(CGIBIN)/data-nifc
	chmod 0755	$(CGIBIN)/data-nifc
	# semanage fcontext -a -t httpd_sys_script_exec_t /var/www/cgi-bin/data-nifc
	restorecon /var/www/cgi-bin/data-nifc




