##Individual scripts

**config.rb** -- configuration options for _nalmd.rb_

**csv_to_mods.rb** -- converts a CSV file with collection, box, and folder numbers and generates basic MODS records for boxes and folders. Zips the files for batch upload to Islandora.

**csv_to_mods_detailed.rb** -- converts a CSV file with dates, titles, and box/folder numbers and generates more detailed MODS records for boxes and folders. Zips the files for batch upload to Islandora.

**download-MODS.rb** -- given a textfile with Fedora PIDs, downloads the MODS datastream

**identifier.rb** -- converts single digit numbers to three digit numbers, generates folder and item identifiers, outputs results to originalfilename_output.csv (see test.csv and test_output.csv)

**identifier_number-only.rb** -- updated to work with data from the item count spreadsheet, rather than the container list.

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

