Data server for https://humdrum.nifc.pl
===========================================

This repository contains the files for the https://humdrum.nifc.pl website
that serves score data files for POPC-1 and POPC-2 projects at NIFC.  Currently
the data server is running from the URL https://data.nifc.humdrum.org .

## Primary files ##

The primary data is stored in Humdrum files.  These are initially linked (or
copied to the ./kern directory).   The `./Makefile` contains a list of the source
location for all Humdrum files to be added to the `./kern` directory.  Then 
the command:

```bash
make kern
```

Creates symbolic links from the source locations into the `./kern`
directory.  Once links to Humdrum files are in the `./kern` directory,
the caching process can begin.


## Cache preparation ##

The `./cache` directory stores a copy of the Humdrum data as well as 
derivative formats and analyses created from each file.  An MD5 checksum
is calculated for each Humdrum file to create an 8-digit ID for that file
to uniquely identify the contents.  The Humdrum file is then copied to a
subdirectory named with that ID.  All translations and analysis files
related to the Humdrum file are also placed in the same subdirectory.

Commands to prepare the Cache:

First, create an index that maps file IDs, century enumerations and SQL enumerations
that link to the MD5-derived cache ID:

```bash
cd cache
make index
```

This will read all of the files in `./kern` to create the index 
file `./cache/index-new.hmd`.

Next, copy the Humdrum files into the cache with this command:

```bash
make copy-kern
```

This will insert any new Humdrum files into the cache that are not already
in the cache.


Next, create derivative files (data translations and analyses) with the following
command:

```bash
make derivatives
```

This will create data conversion and pre-compiled analyses for each new
Humdrum file.


After derivatives have been created, the new version of the database can be
activated by typing the command:

```bash
make publish
```

This will move `./cache/index.hmd` to `./cache/index-old.hmd` and then move
`./cache/index-new.hmd` to `./cache/index.hmd`.   The file `./cache/index.hmd`
is used to map various file identifier systems to the cached version of the 
Humdrum file.

Optionally, run the command:

```bash
make purge
```

to remove older and deleted versions of the Humdrum files from the cache
system.   These files will be placed in the `./cache/purge` folder for review.


There is also a command to do all of the above steps at one time:

```bash
make update
```

## URL data access ##

Data files store in the cache can be accessed on the web via the following examples.

(Replace https://data.nifc.humdrum.org with https://humdrum.nifc.pl when the
server is placed in its final location);

<dl>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183">https://data.nifc.humdrum.org/pl-cz--iii-183</a> </dt>
<dd markdown="1"> Return Humdrum data for FileID `pl-cz--iii-183`. </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183.krn">https://data.nifc.humdrum.org/pl-cz--iii-183.krn</a> </dt>
<dd> Explicitly request Humdrum data (default behaving if no data format specified). </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183?format=krn">https://data.nifc.humdrum.org/pl-cz--iii-183?format=krn</a> </dt>
<dd> Verbose request for Humdrum data using URL parameter. </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183?format=kern">https://data.nifc.humdrum.org/pl-cz--iii-183?format=kern</a> </dt>
<dd> Alternate verbose request for Humdrum data using URL parameter. </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183.mei">https://data.nifc.humdrum.org/pl-cz--iii-183.mei</a> </dt>
<dd> Request MEI conversion of file. </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183.musicxml">https://data.nifc.humdrum.org/pl-cz--iii-183.musicxml</a> </dt>
<dd> Request MusicXML conversion of file. </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183.xml">https://data.nifc.humdrum.org/pl-cz--iii-183.xml</a> </dt>
<dd> Alternate request MusicXML conversion of file. </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183_elsner-jozef--quoniam-in-me-speravit-in-b-op-30-a.krn">https://data.nifc.humdrum.org/pl-cz--iii-183_elsner-jozef--quoniam-in-me-speravit-in-b-op-30-a.krn</a> </dt>
<dd> Full filename can be given (but from and after first `_` in filename will be ignored internally). </dd>

<dt> <a href="https://data.nifc.humdrum.org/pl-cz--iii-183_elsner-jozef--quoniam-in-me-speravit-in-b-op-30-a.musicxml">https://data.nifc.humdrum.org/pl-cz--iii-183_elsner-jozef--quoniam-in-me-speravit-in-b-op-30-a.musicxml</a> </dt>
<dd> Full filename access to MusicXML conversion. </dd>

<dt> <a href="https://data.nifc.humdrum.org/18xx:25">https://data.nifc.humdrum.org/18xx:25</a> </dt>
<dd markdown="1"> Use century ID `18xx:25` to access data. </dd>

<dt> <a href="https://data.nifc.humdrum.org/18xx:25.mei">https://data.nifc.humdrum.org/18xx:25.mei</a> </dt>
<dd> Use century ID to access MEI conversion. </dd>

<dt> <a href="https://data.nifc.humdrum.org/18xx:25?format=mei">https://data.nifc.humdrum.org/18xx:25?format=mei</a> </dt>
<dd> Use century enumeration to access MEI conversion using format parameter. </dd>

<dt> <a href="https://data.nifc.humdrum.org/1153">https://data.nifc.humdrum.org/1153</a> </dt>
<dd> Use SQL enumeration to access data. (not yet implemented) </dd>

<dt> <a href="https://data.nifc.humdrum.org/1153.krn">https://data.nifc.humdrum.org/1153.krn</a> </dt>
<dd> Use SQL enumeration to access data, with embedded format. (not yet implemented) </dd>

<dt> <a href="https://data.nifc.humdrum.org/random">https://data.nifc.humdrum.org/random</a> </dt>
<dd> Get a random Humdrum file. </dd>

<dt> <a href="https://data.nifc.humdrum.org/random.musicxml">https://data.nifc.humdrum.org/random.musicxml</a> </dt>
<dd> Get a random MusicXML conversion. </dd>

</dl>




