#!/bin/bash

# Packaging script for building Silan binaries.

SILAN_VERSION="0.3.2"
SILAN_CUSTOM="-1"
MIRRORPATH=/tmp

# Clean up previous builds

rm -rf ${MIRRORPATH}/silan/

# Create the temporary build directory and copy the debian directory to it

mkdir -p ${MIRRORPATH}/silan/
cp -r silan/* ${MIRRORPATH}/silan/

# Download the package if it's not there already

cd ${MIRRORPATH}

if [ ! -f ${MIRRORPATH}/v${SILAN_VERSION}.zip ]; then
 wget https://github.com/x42/silan/archive/v${SILAN_VERSION}.zip
fi

cd silan/

# Set the correct distro name in the package changelog

function set_dist {

sed -i "s/unstable/${dist}/g" silan-${SILAN_VERSION}/debian/changelog
sed -i "1s/${SILAN_VERSION}${SILAN_CUSTOM}/${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}/g" silan-${SILAN_VERSION}/debian/changelog
head -n1 debian/changelog

if [ "$dist" = 'lucid' ]; then
sed -i "s/8/7/" silan-${SILAN_VERSION}/debian/compat
sed -i "s/debhelper (>= 8)/debhelper (>= 7)/" silan-${SILAN_VERSION}/debian/control
fi
}

# Use these lines to build for various distros

for dist in lucid precise quantal raring saucy squeeze wheezy; do
        rm -rf silan-${SILAN_VERSION}
	unzip ../v${SILAN_VERSION}.zip
        cp -r debian silan-${SILAN_VERSION}
	set_dist $dist
	dpkg-source -b silan-${SILAN_VERSION}
	pbuilder-dist ${dist} i386 build silan_${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}.dsc
	pbuilder-dist ${dist} amd64 build --binary-arch silan_${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}.dsc
done

CHANGES=`ls -t ~/pbuilder/*_result/silan_*.changes | head -n 14`

ls -l $CHANGES

# Prompt user to sign the 14 newest packages with the Sourcefabric key

echo 'debsign -k174C1854 `ls -t ~/pbuilder/*_result/silan_*changes | head -n 14`'
