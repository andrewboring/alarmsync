#!/bin/bash

REPOPATH=/var/nginx/html
MIRROR=http://upstream.example.com
#MIRROR=http://fl.us.mirror.archlinuxarm.org
ARCH=armv7h
DATE=$(date +%Y%m%d)


# Local constructed paths should look like this:
# ${REPOPATH}/current/${ARCH}
# ${REPOPATH}/${DATE}/${ARCH}
# /var/nginx/html/current/armv7
# /var/nginx/html/20180828/armv7

# Remote paths should look like::
# ${MIRROR/${ARCH}
# http://upstream.a10g.com/archv7h

check_mirror() {
	REMOTE=$(curl -sS ${MIRROR}/${ARCH}/sync)
	LOCAL=$(cat ${REPOPATH}/current/${ARCH}/sync)
 	if [ "$REMOTE" = "$LOCAL" ]; then
		echo "No new updates."
		return 0
	else
		echo "Updates available."
		return 1
	fi
}


sync_mirror() {
	if [ ! -d ${REPOPATH}/${DATE} ];then
		mkdir ${REPOPATH}/${DATE}
	else
		echo "${REPOPATH}/${DATE} already exists. Skipping creation."
	fi 
	cd ${REPOPATH}/${DATE}
 	wget -N -nv -nH --max-redirect=1 --wait=0 --no-parent -R "index.html*" --mirror ${MIRROR}/${ARCH}/
	MSTATUS=$?
	if [ "$MSTATUS" != 0 ]; then
		echo "Sync Failed. Wget error code: ${MSTATUS}."
		return 1
	fi 
}

update_link() {
	echo "Removing old -current link..."
	rm -f ${REPOPATH}/current || echo "Cannot remove -current link. $?"
	echo "Repointing -current to ${DATE}..."
	ln -s ${REPOPATH}/${DATE} ${REPOPATH}/current
}

sync () {
	check_mirror
	UPDATENOW=$?
	if [ $UPDATENOW = 1 ]; then
		sync_mirror
		if [ $? = 0 ]; then
			update_link
		else
			echo "No links updated."
		fi	
	fi
}

usage () {
	echo "Usage: alarmsync [OPTIONS]"
	echo ""
	echo " -h --help			Show this help."
	echo " -l --list			List repo directory."
	echo " -s --sync			Sync repo end update -current link."
	echo " -u --update [link] [date]	Update link."
	echo ""
}

list_repo () {
	ls -l ${REPOPATH}
}

update () {
	echo "Updating ${LINK} to point to ${NPATH}"
	# The next three variables are useful for debugging. Uncomment if needed."
	#echo ${REPOPATH}
	#echo ${NPATH}
	#echo ${LINK}
        rm -f ${REPOPATH}/${LINK} || echo "Cannot remove ${LINK}. $?"
        ln -s ${REPOPATH}/${NPATH} ${REPOPATH}/${LINK} || echo "Cannot create ${LINK}. $?"
	list_repo	
}


###############
#  Main Script
###############

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi


while [ "$1" != "" ]; do
	case $1 in 
		-s | --sync )	sync
				;;
		-u | --update-link )
				shift
				LINK=$1
				NPATH=$2
				update
				shift
				;;
		-l | --list )	list_repo	
				;;
		-h | --help ) 	usage
				exit 
				;;
		* ) 		usage
				exit 1
				;;
	esac
	shift
done


