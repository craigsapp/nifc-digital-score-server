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

##############################
##
## Configuration variables:
##

my $basedir    = "/project/data-nifc/data-nifc";
my $cachedir   = "$basedir/cache";
my $cacheindex = "$cachedir/index.hmd";

##
##############################

# Main parameter is given in "parameters" CGI parameter:
use CGI;
my $cgi_form = new CGI;
my $parameters  = $cgi_form->param('parameters');

if ($parameters eq "test") {
	my $testpage = getTestPage($parameters);
	print "Content-Type: text/html\n\n";
	print $testpage;
	exit(0);
}

if ($parameters =~ /^([0-9a-zA-Z:_-]+)\.([0-9a-zA-Z_-]+)$/) {
	my $id = $1;
	my $format = $2;
	processSimpleParameter($id, $format);
}

errorMessage("No data format specified.");


exit(0);

###########################################################################


##############################
##
## processSimpleParameter -- Such as:
##     https://humdrum.nifc.pl/004-1a-COC-003.krn for kern file
##     https://humdrum.nifc.pl/004-1a-COC-003.mei for MEI file
##     https://humdrum.nifc.pl/16xx:1210.krn for kern file
##     https://humdrum.nifc.pl/16xx:1210.mei for MEI file
##

sub processSimpleParameter {
	my ($id, $format) = @_;

	# Remove _composer--title information for POPC-2:
	if ($id =~ /^(pl-[^_]+)_.*$/) {
		$id = $1;
	}

	# Remove any spaces around ID:
	$id =~ s/^\s+//;
	$id =~ s/\s+$//;

	# Merge aliases for .krn ending:
	$format = "krn" if $format =~ /^krn$/i;
	$format = "krn" if $format =~ /^kern$/i;
	$format = "krn" if $format =~ /^hmd$/i;
	$format = "krn" if $format =~ /^humdrum$/i;

	# Merge aliases for .mei ending:
	$format = "mei" if $format =~ /^mei$/i;

	# Merge aliases for .musicxml ending:
	$format = "musicxml" if $format =~ /^musicxml$/i;
	$format = "musicxml" if $format =~ /^xml$/i;

	errorMessage("ID is empty.") if $id =~ /^\s*$/;
	errorMessage("ID cannot contain only periods.") if $id =~ /^\.+$/;

	my $md5 = getMd5($id, $cacheindex);
	errorMessage("File for $id was not found.") if $md5 =~ /^\s*$/;

	if ($format eq "krn") {
		my $data = getDataContent($md5, "krn");
		print "Content-Type: text/plain\n\n";
		print $data;
		exit(0);
	} elsif ($format eq "mei") {
		my $data = getDataContent($md5, "mei");
	} elsif ($format eq "musicxml") {
		my $data = getDataContent($md5, "musicxml");
	} else {
		errorMessage("Unknown data format: $format");
	}
}



##############################
##
## getDataContent --
##

sub getDataContent {
	my ($md5, $format) = @_;
	errorMessage("Bad MD5 tag $md5") if $md5 !~ /^[0-9a-f]{8}$/;
	if ($format eq "krn") {

		my $cdir = getCacheSubdir($md5, 1);
		my $filename = "$cachedir/$cdir/$md5.krn";
		if (!-r $filename) {
			errorMessage("Cannot find $cdir/$md5.krn");
		}
		open(FILE, $filename) or errorMessage("Cannot read $cdir/$md5.krn");
		my $output = "";
		while (my $line = <FILE>) {
			$output .= $line;
		}
		close FILE;
		return $output;
	} elsif ($format eq "mei") {
		errorMessage("$format NOT YET IMPLEMENTED");
	} else {
		errorMessage("Unknown data format: $format");
	}
}



##############################
##
## getCacheSubdir --
##

sub getCacheSubdir {
	my ($md5, $level) = @_;
	$level = 1 if $level < 1;
	$level = 3 if $level > 3;
	my @pieces = split(//, $md5);
	my $output = "";
	for (my $i=0; $i<$level; $i++) {
		$output .= "$pieces[$i]/";
	}
	$output .= "$md5";
	return $output;
}



##############################
##
## getMd5 -- Input an ID and return an MD5 8-hex-digit code for the cache location.
##

sub getMd5 {
	my ($id, $cacheindex) = @_;
	open (FILE, $cacheindex) or errorMessage("Cannot find cache index.");
	my @headings;
	while (my $line = <FILE>) {
		next if $line =~ /^!/;
		chomp $line;
		if ($line =~ /^\*\*/) {
			my @headings = split(/\t+/, $line);
			next;
		}
		next if $line =~ /^\*/;
		next if $line =~ /^\s*$/;
		next if $line !~ /^([^\t]+).*\t($id)(\t|$)/;
		return $1;
	}
	close FILE;
	return "";
}



##############################
##
## errorMessage --
##

sub errorMessage {
	my ($message) = @_;
	print "Content-Type: text/html\n\n";
	print <<"EOT";
<html>
<head>
<title> ERROR </title>
</head>
<body>
<h1> ERROR </h1>
$message
</body>
</html>
EOT
	exit(0);
}



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
	$output .= "$parameters\n";
	$output .= "<h1> Env </h1>\n";
	$output .= "<table>\n";
	foreach my $key (sort keys %ENV) {
		$output .= "<tr>\n";
		$output .= "<td>$key</td>\n";
		$output .= "<td>$ENV{$key}</td>\n";
		$output .= "</tr>\n";
	}
	$output .= "</table>\n";
	$output .= "</body>\n";
	$output .= "</html>\n";
	return $output;
}


