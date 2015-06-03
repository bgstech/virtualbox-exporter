# virtualbox-exporter
Automatic export of multiple VirtualBox virtual machines.

Export multiple VirtualBox virtual machines into separate OVF archive files
(one per appliance).  It accepts virtual machines with spaces in their names.
VirtualBox itself is queried for the list of available VMs and so by default
every VM will be exported in turn.

Run without arguments to export every available virtual machine in turn.  You
can use either optional exclude mechanism (or both!) by uncommenting the
appropriate block in the script:

* "Exclude Block #1" will skip any virtual machine if a file sharing that name
(with a .ova extension) already exists (this is not enabled by default)

* "Exclude Block #2" will exclude any virtual machines listed in the
exclude.list file in the current workding directory.  See the comments in that
file for example entries (this IS enabled by default)

After each VM/appliance is exported, an MD5 hash is computed for convenience,
and written to a 'checksum.txt' file.

