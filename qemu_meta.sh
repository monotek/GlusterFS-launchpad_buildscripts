#!/bin/bash
#
# build qemu with glusterfs support
#

if [ ! -f config.yml ];then

    echo "config.yml missing! create config.yml from config.yml.dist example before running this script!"

    exit 1

fi

#config
OS_VERSION="$1"
GLUSTER_VERSION="$2"
BUILD_DIR="$(grep build-dir < config.yml | sed 's/build-dir: //')"
PACKAGE="qemu"
PACKAGE_IDENTIFIER="glusterfs${GLUSTER_VERSION}${OS_VERSION}"
PPA="qemu-glusterfs-$(echo ${GLUSTER_VERSION} | cut -c 1-3)"
PPA_OWNER="$(grep ppa-owner < config.yml | sed 's/ppa-owner: //')"
PACKAGEDIR="${BUILD_DIR}/${PPA}/"
DEBFULLNAME="$(grep name < config.yml | sed 's/name: //')"
DEBEMAIL="$(grep email < config.yml | sed 's/email: //')"
DEBCOMMENT="with glusterfs ${GLUSTER_VERSION} support"

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

#debuild -us -uc -i -I

debuild -S

dput ppa:${PPA_OWNER}/${PPA} $(find ${PACKAGEDIR} -name qemu*gluster*_source.changes | sort | tail -n 1)

