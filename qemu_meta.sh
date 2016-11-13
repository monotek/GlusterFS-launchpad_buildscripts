#!/bin/bash
#
# build qemu with glusterfs support
#

if [ ! -f config ];then
    echo "config missing! create config from config.dist example before running this script!"
    exit 1
fi

#config
OS_VERSION="$1"
GLUSTER_VERSION="$2"
PACKAGE="qemu"

. "config"

#script
if [ -z ${OS_VERSION} ] || [ -z ${GLUSTER_VERSION} ]; then
    echo -e "need os and gluster version! \nUsage: $0 trusty 3.6.2"
    exit 1
fi

export DEBFULLNAME=${DEBFULLNAME}

export DEBEMAIL=${DEBEMAIL}

test -d ${PACKAGEDIR} && rm -r ${PACKAGEDIR}

mkdir -p ${PACKAGEDIR}

cd ${PACKAGEDIR}

sudo cp /etc/apt/sources.list.${OS_VERSION} /etc/apt/sources.list

sudo apt-get update

apt-get source ${PACKAGE}/${OS_VERSION}

cd $(find ${PACKAGEDIR} -maxdepth 1 -mindepth 1 -type d -name "*${PACKAGE}*")/debian

debchange -l ${PACKAGE_IDENTIFIER} ${DEBCOMMENT} -D ${OS_VERSION}

cp control control.org

#sed 's#\#\#--enable-glusterfs todo#\# --enable-glusterfs\n glusterfs-common,#g' < control.org > control
sed 's#\#\#--enable-glusterfs todo#\# --enable-glusterfs\n glusterfs-common,\n libacl1-dev,#g' < control.org > control

rm control.org

if [ "${LAUNCHPAD_UPLOAD}" == "yes" ]; then
    debuild -S

    dput ppa:${PPA_OWNER}/${PPA} $(find ${PACKAGEDIR} -name ${PACKAGE}*gluster*_source.changes | sort | tail -n 1)
else
    debuild -us -uc -i -I
fi

