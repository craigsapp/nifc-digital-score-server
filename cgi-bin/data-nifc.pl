#!/usr/bin/perl
#
# Programmer:    Craig Stuart Sapp <craig.stanford.edu>
# Creation Date: Sun 12 Sep 2021 07:37:36 PM PDT
# Last Modified: Tue 14 Sep 2021 07:10:38 AM PDT
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

# basedir == The location of the files for the website.
my $basedir    = "/project/data-nifc/data-nifc";

# cachedir == The absolute path to the cache directory.
my $cachedir   = "$basedir/cache";

# cachedir == The absolute path to the cache index file.
my $cacheIndex = "$cachedir/index.hmd";

# cacheDepth == The number of subdirectories before reaching individual cache directory.
my $cacheDepth = 1;

##
##############################


# Load CGI parameters into %OPTIONS:
use CGI;
my $cgi_form = new CGI;
my %OPTIONS;
$OPTIONS{"id"} = $cgi_form->param("id");
$OPTIONS{"format"} = $cgi_form->param("format");
# "f" is a shortcut for format:
if ($OPTIONS{"format"} =~ /^\s*$/) {
	$OPTIONS{"format"}  = $cgi_form->param("f");
}
splitFormatFromId();


# Return requested data:
if ($OPTIONS{"id"} eq "test") {
	# id == test :: print ENV and input parameters for debugging and development.
	sendTestPage($OPTIONS{"id"}, $OPTIONS{"format"});
} elsif ($OPTIONS{"id"} eq "random") {
	# id == random :: send a randomly selected work.
	sendRandomWork($OPTIONS{"format"});
} else {
	# ID should refer to a specific file, so return data in requested format:
	processParameters($OPTIONS{"id"}, $OPTIONS{"format"});
}


exit(0);

###########################################################################


##############################
##
## splitFormatFromId -- id.format gets divided into separate parameters.
##

sub splitFormatFromId {
	my $id = $OPTIONS{"id"};
	my $format = $OPTIONS{"format"};

	my $newformat = "";
	if ($id =~ /^([^\/]+)\/([^\/]+)$/) {
		$id = $1;
		$newformat = $2;
	} elsif ($id =~ s/\.([0-9a-zA-Z_-]+)$//) {
		$newformat = $1;
	}

	if ($newformat !~ /^\s*$/) {
		if ($format =~ /^\s*$/) {
			$format = $newformat;
		}
	}
	if ($format =~ /^\s*$/) {
		$format = "krn";
	}

	$format = cleanFormat($format);
	$id     = cleanId($id);

	$OPTIONS{"id"} = $id;
	$OPTIONS{"format"} = $format;
}



##############################
##
## processParameters -- Such as:
##     https://humdrum.nifc.pl/004-1a-COC-003.krn for kern file
##     https://humdrum.nifc.pl/004-1a-COC-003.mei for MEI file
##     https://humdrum.nifc.pl/16xx:1210.krn for kern file
##     https://humdrum.nifc.pl/16xx:1210.mei for MEI file
##

sub processParameters {
	my ($id, $format) = @_;

	errorMessage("ID is empty.") if $id =~ /^\s*$/;
	errorMessage("Strange invalid ID \"$id\".") if $id =~ /^[._-]+$/;
	errorMessage("ID \"$id\" contains invalid characters.") if $id =~ /[^a-zA-Z0-9:_-]/;

	my $md5 = getMd5($id, $cacheIndex);
	errorMessage("Entry for $id was not found.") if $md5 =~ /^[.\s]*$/;

	# cached formats
	if ($format eq "krn") {
		sendDataContent($md5, $format);
	} elsif ($format eq "mei") {
		sendDataContent($md5, $format);
	} elsif ($format eq "musicxml") {
		sendDataContent($md5, $format);
	} 

	# dynamic formats
	if ($format eq "lyrics") {
		sendDataContent($md5, $format);
	}


	errorMessage("Unknown data format: $format");
}



##############################
##
## sendDataContent --
##

sub sendDataContent {
	my ($md5, $format) = @_;
	errorMessage("Bad MD5 tag $md5") if $md5 !~ /^[0-9a-f]{8}$/;

	# Statically generated data formats:
	if ($format eq "krn") {
		sendHumdrumContent($md5);
	} elsif ($format eq "mei") {
		sendMeiContent($md5);
	} elsif ($format eq "musicxml") {
		sendMusicxmlContent($md5);
	}

	# Dynamically generated data formats:
	if ($format eq "lyrics") {
		sendLyricsContent($md5);
	}

	errorMessage("Unknown data format B: $format");
}



##############################
##
## sendHumdrumContent --
##

sub sendHumdrumContent {
	my ($md5) = @_;
	my $cdir = getCacheSubdir($md5, $cacheDepth);
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
}



##############################
##
## sendMeiContent --
##

sub sendMeiContent {
	my ($md5) = @_;
	my $cdir = getCacheSubdir($md5, $cacheDepth);
	my $format = "mei";
	my $mime = "text/plain";

	# MEI data is stored in gzip-compressed file.  If the browser
	# accepts gzip compressed data, send the compressed form of the data;
	# otherwise, unzip and send as plain text.
	my $compressQ = 0;
	$compressQ = 1 if $ENV{'HTTP_ACCEPT_ENCODING'} =~ /\bgzip\b/;
	if (!-r "$cachedir/$cdir/$md5.$format.gz") {
		errorMessage("MEI file is missing for $OPTIONS{'id'}.\n");
	}
	if ($compressQ) {
		my $data = `cat "$cachedir/$cdir/$md5.$format.gz"`;
		print "Content-Type: $mime\n";
		print "Content-Encoding: gzip\n";
		print "\n";
		print $data;
		exit(0);
	}

	my $data = `zcat "$cachedir/$cdir/$md5.$format.gz"`;
	print "Content-Type: $mime\n\n";
	print $data;
	exit(0);
}



##############################
##
## sendMusicxmlContent --
##

sub sendMusicxmlContent {
	my ($md5) = @_;
	my $cdir = getCacheSubdir($md5, $cacheDepth);
	my $format = "musicxml";
	my $mime = "text/plain";

	# MusicXML data is stored in gzip-compressed file.  If the browser
	# accepts gzip compressed data, send the compressed form of the data;
	# otherwise, unzip and send as plain text.
	my $compressQ = 0;
	$compressQ = 1 if $ENV{'HTTP_ACCEPT_ENCODING'} =~ /\bgzip\b/;
	if (!-r "$cachedir/$cdir/$md5.$format.gz") {
		errorMessage("MusicXML file is missing for $OPTIONS{'id'}.\n");
	}
	if ($compressQ) {
		my $data = `cat "$cachedir/$cdir/$md5.$format.gz"`;
		print "Content-Type: $mime\n";
		print "Content-Encoding: gzip\n";
		print "\n";
		print $data;
		exit(0);
	}

	my $data = `zcat "$cachedir/$cdir/$md5.$format.gz"`;
	print "Content-Type: $mime\n\n";
	print $data;
	exit(0);
}



##############################
##
## sendLyricsContent --
##

sub sendLyricsContent {
	my ($md5) = @_;
	my $cdir = getCacheSubdir($md5, $cacheDepth);
	my $command = "$cachedir/bin/lyrics -hbv \"$cachedir/$cdir/$md5.krn\"";
	my $data = `$command`;
	print "Content-Type: text/html; charset=utf-8\n";
	print "Content-Disposition: inline; filename=\"$OPTIONS{'id'}-lyrics.html\"\n";
	print "\n";
	print $data;
	exit(0);
}



##############################
##
## getCacheSubdir -- For example 63a45fe4 goes to 6/63a45fe4 when the depth is 1.
##

sub getCacheSubdir {
	my ($md5, $depth) = @_;
	$depth = 1 if $depth < 1;
	$depth = 3 if $depth > 3;
	my @pieces = split(//, $md5);
	my $output = "";
	for (my $i=0; $i<$depth; $i++) {
		$output .= "$pieces[$i]/";
	}
	$output .= "$md5";
	return $output;
}



##############################
##
## getMd5 -- Input an ID and return an MD5 8-hex-digit cache ID.
##

sub getMd5 {
	my ($id, $cacheIndex) = @_;
	open (FILE, $cacheIndex) or errorMessage("Cannot find cache index.");
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
		close FILE;
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
## sendTestPage -- Used for debugging.
##

sub sendTestPage {
	my ($id, $format) = @_;

	print "Content-Type: text/html\n\n";
	print <<"EOT";
<html>
<head>
<title> INFO </title>
</head>
<body>
<h1> INFO </h1>
<ul>
<li> id: $id </li>
<li> format: $format </li>
</ul>
<h1> ENV </h1>
<table>
EOT

	foreach my $key (sort keys %ENV) {
		print "<tr>\n";
		print "<td>$key</td>\n";
		print "<td>$ENV{$key}</td>\n";
		print "</tr>\n";
	}
	print "</table>\n</body>\n</html>\n";
	exit(0);
}



##############################
##
## sendRandomWork -- The URL:
##      https://humdrum.nifc.pl/random
##   will return random kern data.  Also, specific format can be given:
##      https://humdrum.nifc.pl/random.krn
##   and random data translations
##      https://humdrum.nifc.pl/random.mei
##      https://humdrum.nifc.pl/random.musicxml
##      https://humdrum.nifc.pl/random?format=krn
##      https://humdrum.nifc.pl/random?format=mei
##      https://humdrum.nifc.pl/random?format=musicxml
##
##  Loading random file into VHV:
##      https://verovio.humdrum.org/?file=https://data.nifc.humdrum.org/random
##

sub sendRandomWork {
	my ($format) = @_;
	my @list = getMd5List($cacheIndex);
	if (@list == 0) {
		errorMessage("Cannot find MD5 list");
	}
	my $randIndex =  int(rand(@list));
	my $md5 = $list[$randIndex];
	sendDataContent($md5, $format);
}



##############################
##
## getMd5List --
##

sub getMd5List {
	my ($cacheIndex) = @_;
	open (FILE, $cacheIndex) or errorMessage("Cannot find cache index.");
	my @headings;
	my @output;
	my $md5index = -1;
	while (my $line = <FILE>) {
		next if $line =~ /^!/;
		chomp $line;
		if ($line =~ /^\*\*/) {
			my @headings = split(/\t+/, $line);
			for (my $i=0; $i<@headings; $i++) {
				$md5index = $i if $headings[$i] eq "**md5";
			}
			next;
		}
		next if $line =~ /^\*/;
		next if $line =~ /^\s*$/;
		next if $md5index < 0;
		my @data = split(/\t+/, $line);
		$output[@output] = $data[$md5index];
	}
	close FILE;
	return @output;
}



##############################
##
## cleanFormat -- Change aliases to primary forms.
##

sub cleanFormat {
	my ($format) = @_;

	# Remove any surrounding spaces
	$format =~ s/^\s+//;
	$format =~ s/\s+$//;

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

	return $format;
}



##############################
##
## cleanId -- Remove format information and optional _composer--work from POPC-2 filename-based IDs.
##

sub cleanId {
	my ($id) = @_;

	# Remove any spaces around ID:
	$id =~ s/^\s+//;
	$id =~ s/\s+$//;

	# Remove any format appendix
	$id =~ s/\.[a-zA-Z0-9_-]+$//;

	# Remove _composer--title information for POPC-2:
	if ($id =~ /^(pl-[^_]+)_.*$/) {
		$id = $1;
	}

	return $id;
}



