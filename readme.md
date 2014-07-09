#About
This repo was shared in response to someone with an immediate need for using MODS with Omeka--it's an unmodified version of what I use day-to-day at work. As such, it isn't yet very well documented and may not be terribly friendly to customization. 

##Individual scripts

**config.rb** -- configuration options for _nalmd.rb_

**download-MODS.rb** -- given a textfile with Fedora PIDs, downloads the MODS datastream

**location.rb and person.rb** -- classes required for Omeka and IA CSV conversions.

**mods_to_ia.rb** -- converts MODS XML files into a CSV file suitable for Internet Archive scan batches.

**mods_to_omeka-csv.rb** -- converts MODS XML files into a CSV file suitable for Omeka's CSVImport plugin.

**nalmd.rb** -- command line execution for individual scripts.

**os.rb** -- gets the current directory.

**rename_by_id.rb** -- renames MODS XML files based on the value of <identifier>

##Configuration
change the hash values in **config.rb** to set the URL for your Fedora repository, Omeka import directory, etc.

##Usage
All scripts were written in Ruby 2.0.0.

The easiest way to use these scripts is to place them in an easy to reference top-level directory on your hard drive. I use C:\utils. The scripts can then be called from the command line in any directory via 

```
c:\utils\nalmd.rb [options]
```

Each option will execute the referenced script in a loop. 

```
    -g, --getmods                    For a given textfile of Fedora PIDS,
                                        download the MODS datastream.

    -r, --rename                     For a given directory of MODS XML files,
                                        rename the files by <identifier>

    -i, --iacsv                      For a given directory of MODS XML files,
                                        create an Internet Archive batch CSV.

    -o, --omeka                      For a given directory of MODS XML files,
                                        create CSV file for use with Omeka's CSV Import.

    -h, --help                       Display this screen.
```

