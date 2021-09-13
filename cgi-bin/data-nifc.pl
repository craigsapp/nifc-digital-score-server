#!/usr/bin/perl
#
# Programmer:    Craig Stuart Sapp <craig.stanford.edu>
# Creation Date: Sun 12 Sep 2021 07:37:36 PM PDT
# Last Modified: Sun 12 Sep 2021 07:37:38 PM PDT
# Filename:      data-nifc/cgi-bin/data-nifc.pl
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

# Main parameters is given in "id" CGI parameter:
use CGI;
my $cgi_form = new CGI;
my %OPTIONS;
$OPTIONS{"id"}         = $cgi_form->param("id");
$OPTIONS{"format"}     = $cgi_form->param("format");
if ($OPTIONS{"format"} =~ /^\s*$/) {
	$OPTIONS{"format"}  = $cgi_form->param("f");
}

if ($OPTIONS{"id"} eq "test") {
	my $testpage = getTestPage($OPTIONS{"id"});
	print "Content-Type: text/html\n\n";
	print $testpage;
	exit(0);
}

if ($OPTIONS{"id"} =~ /^([0-9a-zA-Z:_-]+)\.([0-9a-zA-Z_-]+)$/) {
	my $id = $1;
	my $format = $2;
	$format = $OPTIONS{"format"} if $OPTIONS{"format"} !~ /^\s*$/;
	processSimpleParameter($id, $format);
} elsif ($OPTIONS{"id"} =~ /^([0-9a-zA-Z:_-]+)$/) {
	my $id = $1;
	my $format = $OPTIONS{"format"} if $OPTIONS{"format"} !~ /^\s*$/;
	# Send Humdrum data if no format is specified:
	$format = "krn" if $format =~ /^\s*$/;
	processSimpleParameter($id, $format);
}

my $message = <<"EOT";
<p>Problem with data request.</p>
<style>
table td:first-child { font-weight: bold; }
</style>
<table>
EOT
foreach my $key (sort keys %OPTIONS) {
$message .= <<"EOT";
<tr>
	<td>
		$key;
	</td>
	<td>
		$OPTIONS{$key};
	</td>
</tr>
EOT
}
$message .= "</table>\n";
errorMessage($message);


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
		sendDataContent($md5, "krn");
	} elsif ($format eq "mei") {
		sendDataContent($md5, "mei");
	} elsif ($format eq "musicxml") {
		sendDataContent($md5, "musicxml");
	} else {
		errorMessage("Unknown data format: $format");
	}
}



##############################
##
## sendDataContent --
##

sub sendDataContent {
	my ($md5, $format) = @_;
	errorMessage("Bad MD5 tag $md5") if $md5 !~ /^[0-9a-f]{8}$/;

	my $cdir = getCacheSubdir($md5, 1);

	if ($format eq "krn") {

		my $filename = "$cachedir/$cdir/$md5.krn";
		if (!-r $filename) {
			errorMessage("Cannot find $cdir/$md5.krn");
		}
		open(FILE, $filename) or errorMessage("Cannot read $cdir/$md5.krn");
		my $data = "";
		while (my $line = <FILE>) {
			$data .= $line;
		}
		close FILE;
		print "Content-Type: text/plain\n\n";
		print $data;
		exit(0);

	} elsif ($format eq "mei") {
		# MEI data is stored in bzip2-compressed file.  If the browser
		# accepts gzip compressed data, send the compressed form of the data;
		# otherwise, unzip and send as plain text.
		my $compressQ = 0;
		$compressQ = 1 if $ENV{'HTTP_ACCEPT_ENCODING'} =~ /\bgzip\b/;
		if (!-r "$cachedir/$cdir/$md5.mei.gz") {
			errorMessage("MEI file is missing for $OPTIONS{'id'}.\n");
		}
		if ($compressQ) {
			my $data = `cat "$cachedir/$cdir/$md5.mei.gz"`;
			print "Content-Type: text/plain\n";
			print "Content-Encoding: gzip\n";
			print "\n";
			print $data;
			exit(0);
		} else {
			my $data = `zcat "$cachedir/$cdir/$md5.mei.gz"`;
			print "Content-Type: text/plain\n\n";
			print $data;
			exit(0);
		}
	} elsif ($format eq "musicxml") {
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
## getTestPage -- Used (initially) for debugging.
##

sub getTestPage {
	my $output = <<"EOT";
<html>
<head>
<title> TITLE </title>
</head>
<body>
<h1> CGI SCRIPT PAGE </h1>
$OPTIONS{'id'}
<h1> Env </h1>
<table>
EOT

	foreach my $key (sort keys %ENV) {
		$output .= "<tr>\n";
		$output .= "<td>$key</td>\n";
		$output .= "<td>$ENV{$key}</td>\n";
		$output .= "</tr>\n";
	}
	$output .= "</table>\n</body>\n</html>\n";

	return $output;
}


