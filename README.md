# virtualbox-exporter
Automatic export of multiple VirtualBox virtual machines.

Export multiple VirtualBox virtual machines into separate OVF archive files
(one per appliance).  It accepts virtual machines with spaces in their names.
VirtualBox itself is queried for the list of available VMs and so by default
every VM will be exported in turn.

Use the 'exclude' array (in the script) if you want to exlude some of the
virtual machines.

After each VM/appliance is exported, an MD5 hash is computed for convenience.
Capture the script output to preserve those hashes, e.g.

```./vbox-export-all.sh 2>&1 | tee export.log```



