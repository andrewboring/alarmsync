# alarmsync
Repo Sync script for Arch Linux Arm (ALArm).


This is a simple script to create a private, internal mirror of Arch Linux Arm repo to manage rolling updates in a more traditional fashion. It's useful when you're managing updates across a large qty of headless Raspberry Pis at customer sites and you need better control over specific OS versions. 



## Requirements

The script should be portable to any Linux/Unix-based system with Bash. 
However, it was *tested* on CentOS 7.x.

- CentOS server with sufficient space (the ARMv7 repo consumes ~20GB of storage).
- Bash
- A configured web server (Apache, Nginx) to serve the package files.


## Installation
 - Step 1: Download and copy alarmsync.sh script to some directory on your private mirror (/usr/local/bin is a good choice).
 - Step 2: Run as cron job once per day/week/month, specifying the full path to the script.
 - Step 3: ???
 - Step 4: Profit! 


## Configuration
- Set REPOPATH to your local web sserver directory, like /var/nginx/html or something.
- Set MIRROR to your preferred mirror URL (note, you'll need the full URL up to the ARCH setting)
- Set ARCH to your architecture, eg, armv7h, aarch, etc.
- Optional: change DATE to reflect your preferred date fomat. This is used for the directory structure. The default is year-month-day, without hyphens.

Your directory structure should end up looking something like this:
````
 drwxr-xr-x. 3 root root 4096 Sep  5 17:42 20180827
 drwxr-xr-x. 3 root root 4096 Aug 28 18:22 20180828
 drwxr-xr-x. 3 root root 4096 Sep  5 17:01 20180905
 lrwxrwxrwx. 1 root root   24 Sep  5 19:26 current -> /var/nginx/html/20180905
 lrwxrwxrwx. 1 root root   24 Sep  5 19:26 release -> /var/nginx/html/20180801
````

The *current* symlink should always point to the latest Arch version (newest date).   
The *release* symlink should always point to the current production release the RPis should sync with.  
The *current* symlink will always be repointed to latest Arch if a new version is found/downloaded.  
The *release* symlink can be updated using this script (see below) or manually using `ln -s`.  

## Using alarmsync
This script can be run interactively or through a scheduler like cron. It requires root/sudo privileges since you're writing to a web server directory path and the assumption is that you'll need root privs. This will be tightened up in the future so that only -s or -u options require root/sudo.


### Command line options:
```
Usage: ./alarmsync [OPTIONS]
 -h --help			Show this help.
 -l --list			List repo directory contents and links. Requires REPOPATH be set correctly. 
 -s --sync			Sync repo and update -current link. 
 -u --update [link] [date]	Update link. Supports **current** and **release** symlinks only. Date is the directory you want to link to in REPOPATH.
```

Examples:

`alarmsync.sh -s 		   # Checks mirror, syncs if needed, repoints **current** to newly created repository.`  
`alarmsync.sh -l			   # Shows current mirror snapshots, and current current / prod links.`  
`alarmsync.sh -u release 20180827   # Updates the $REPOPATH/release symlink to $REPOPATH/20180827`  

