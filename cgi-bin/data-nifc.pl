#!/usr/bin/perl
#
# Programmer:    Craig Stuart Sapp <craig.stanford.edu>
# Creation Date: Sun 12 Sep 2021 07:37:36 PM PDT
# Last Modified: Sun 12 Sep 2021 07:37:38 PM PDT
# Filename:      data-nifc.pl
# Syntax:        perl 5
# vim:           ts=3
#
# Description:   Data server for https://humdrum.nifc.pl
#

use strict;

use CGI;
my $cgi_form = new CGI;

my $testpage = getTestPage();

print "Content-Type: text/html\n\n";
print $testpage;


exit(0);

###########################################################################

##############################
##
## getTestPage --
##

sub getTestPage {
	my $output;
	$output .= "<html>\n";
	$output .= "<head>\n";
	$output .= "<title> TITLE </title>\n";
	$output .= "</head>\n";
	$output .= "<body>\n";
	$output .= "<h1> CGI SCRIPT PAGE </h1>\n";
	$output .= "</body>\n";
	$output .= "</html>\n";
	return $output;
}


