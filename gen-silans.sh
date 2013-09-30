#!/bin/bash

# Packaging script for Silan binaries.

SILAN_VERSION="0.3.2"
SILAN_CUSTOM="-1"
MIRRORPATH=/tmp

# Clean up previous builds

rm -rf ${MIRRORPATH}/silan/

# Create the temporary build directory and copy the debian directory to it

mkdir -p ${MIRRORPATH}/silan/
cp -r silan/* ${MIRRORPATH}/silan/

# Download the package
cd ${MIRRORPATH}
wget https://github.com/x42/silan/archive/v${SILAN_VERSION}.zip
cd silan/

# Set the correct distro name in the package changelog

function set_dist {
  DIST=$1

sed -i "s/unstable/${DIST}/g" silan-${SILAN_VERSION}/debian/changelog
sed -i "1s/${SILAN_VERSION}${SILAN_CUSTOM}/${SILAN_VERSION}~${DIST}~sfo${SILAN_CUSTOM}/g" silan-${SILAN_VERSION}/debian/changelog
head -n1 debian/changelog
}

# Use these lines to build for various distros

for dist in quantal raring saucy squeeze wheezy; do
#for dist in precise lucid; do
        rm -rf silan-${SILAN_VERSION}
	unzip ../v${SILAN_VERSION}.zip
        cp -r debian silan-${SILAN_VERSION}
	set_dist $dist
	dpkg-source -b silan-${SILAN_VERSION}
	pbuilder-dist $dist i386 build silan_${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}.dsc
	pbuilder-dist $dist amd64 build --binary-arch silan_${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}.dsc
done

CHANGES=`ls -t ~/pbuilder/*_result/silan_*.changes | head -n 14`

ls -l $CHANGES

# Prompt user to sign the 14 newest packages with the Sourcefabric key

echo 'debsign -k174C1854 `ls -t ~/pbuilder/*_result/silan_*changes | head -n 14`'
