#!/bin/bash
#
# Export multiple VirtualBox virtual machines into separate OVF archive files
# (one per appliance).  It accepts virtual machines with spaces in their names.
# VirtualBox itself is queried for the list of available VMs and so by default
# every VM will be exported in turn.  Uncomment and edit the "exclude" array
# variable below if you want to exlude some of the virtual machines.
#
# After each VM/appliance is exported, an MD5 hash is computed for convenience.
# The hash is displayed on the console as well as appended to a 'checksum.txt'
# file in the current directory (this file is created if necessary)
#
# Uncomment "Exclude Block #1" to automatically exclude virtual machines for
# which a filename of the same name already exists.
# Uncomment "Exclude Block #2" to also exclude named virtual machines listed
# one per line in a separate 'exclude.list' file.  You can elect to use neither,
# one, or both of these exclude blocks. 
#
# Requires:
#	VirtualBox's 'vboxmanage' command
#	md5sum (Linux) or md5 (OS X) command
#
# Version: 1.0
#
# Brian Sheehan
# June 3 2015
# bgstech.com


# Only newlines are field separators 
IFS=$'\n'

# Initialize an empty exclude list array
declare -a exclude

## -- Exclude Block #1 BEGIN --
## Use this for loop to exclude any virtual machines for which an exported
## archive file already exists in the current directory
#for e in $(ls -1 | grep '\.ova$' | sed 's/\.ova$//'); do
#  exclude[${#exclude[*]}]="$e"
#done
## -- Exclude Block #1 END --

## -- Exclude Block #2 BEGIN --
## Use this block to omit any virtual machines listed (one per line) in
## a separate 'exclude.list' file which should reside in the current
## working directory
if [ -f exclude.list ]; then
  for e in $(grep -v '^#' exclude.list | grep -v '^\s*$' | sed 's/\.ova$//'); do
    exclude[${#exclude[*]}]="$e"
  done
fi
## -- Exclude Block #2 END --

# Loop over each available virtual machine
for m in $(vboxmanage list vms); do

    # Strip out the machine name, remove quotes
    mach=`echo $m | sed 's/ {.*//;s/"//g'`

    # Check if named virtual machine is in our list of machines to omit
    do_skip=0
    for ex in "${exclude[@]}"; do
        if [ "$ex" == "$mach" ]; then
            do_skip=1
            break
        fi
    done
    if [ $do_skip -eq 1 ]; then
        echo "SKIPPING:  $mach"
        continue
    fi

    # Export the machine into an OVA file of the same name
    echo "Exporting: $mach ..."
    vboxmanage export "$mach" --output "$mach.ova" --ovf10

    # Provide an MD5 checksum of the output file for later comparison.  We
    # try to use 'md5 -r' first (OS X) and if that fails use 'md5sum'.  Comment
    # this block out if you need to save some time.
    if [ "$(which md5)" == "" ]; then
       md5sum "$mach.ova" >> checksum.txt
    else
       md5 -r "$mach.ova" >> checksum.txt
    fi
    echo ""
done

