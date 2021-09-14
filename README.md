Data server for https://humdrum.nifc.pl
===========================================

This repository contains the files for the https://humdrum.nifc.pl
website which serves data files for POPC-1 and POPC-2 projects at NIFC.

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



