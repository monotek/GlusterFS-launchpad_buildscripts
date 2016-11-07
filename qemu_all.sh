#!/bin/bash
#
# build qemu with glusterfs support for all os versions
#

if [ ! -f config.yml ];then

    echo "config.yml missing! create config.yml from config.yml.dist example before running this script!"

    exit 1

fi

#config
OS_VERSIONS="$(grep os-version < config.yml | sed 's/os-version: //')"
GLUSTER_VERSIONS="$(grep glusterfs-version < config.yml | sed 's/glusterfs-version: //')"

for OS in ${OS_VERSIONS}; do
    for GLUSTER in ${GLUSTER_VERSIONS}; do
	
	echo -e "\n#######################\nbuild glusterfs version ${GLUSTER} for OS ${OS}\n#######################\n"
	
	/bin/bash qemu_meta.sh ${OS} ${GLUSTER}

    done

done
