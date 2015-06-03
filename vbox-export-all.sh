#!/bin/bash
#
# Export multiple VirtualBox virtual machines into separate OVF archive files
# (one per appliance).  It accepts virtual machines with spaces in their names.
# VirtualBox itself is queried for the list of available VMs and so by default
# every VM will be exported in turn.  Uncomment and edit the "exclude" array
# variable below if you want to exlude some of the virtual machines.
#
# After each VM/appliance is exported, an MD5 hash is computed for convenience.
# Capture the script output to preserve those hashes, e.g.
#
#    ./vbox-export-all.sh 2>&1 | tee export.log
#
# Version: 1.0
#
# Requires:
#	VirtualBox's 'vboxmanage' command
#	md5sum (Linux) or md5 (OS X) command
#
# Brian Sheehan
# Jun 3rd 2015
# bgstech.com


# Only newlines are field separators 
IFS=$'\n'

# List of machines to exclude from the process.  Each one should be in
# double-quotes. Leave this line commented out if you want every virtual
# machine exported.
#declare -a exclude=("CentOS 3.7 x86_64" "FreeBSD 7.1 i386")

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
    md5_cmd='md5 -r'
    if [ "$(which md5)" == "" ]; then
        md5_cmd=md5sum
    fi
    $md5_cmd "$mach.ova"
    echo ""
done

