#!/bin/bash

# Packaging script for Silan binaries.
# Please download the tarball of Silan source to $MIRRORPATH before running this script.

SILAN_VERSION="0.3.0"
SILAN_CUSTOM="-1"
MIRRORPATH=/tmp

# Clean up previous builds

rm -rf ${MIRRORPATH}/silan/

# Create the temporary build directory

mkdir -p ${MIRRORPATH}/silan/

# Unpack the Silan source from the tarball

tar -xvzf ${MIRRORPATH}/silan_${SILAN_VERSION}${SILAN_CUSTOM}.tar.gz -C ${MIRRORPATH}/silan/

cd ${MIRRORPATH}/silan/

# Set the correct distro name in the package changelog

function set_dist {
  DIST=$1

sed -i "s/unstable/${DIST}/g" silan-${SILAN_VERSION}/debian/changelog
sed -i "1s/${SILAN_VERSION}${SILAN_CUSTOM}/${SILAN_VERSION}~${DIST}~sfo${SILAN_CUSTOM}/g" silan-${SILAN_VERSION}/debian/changelog
head -n1 silan-${SILAN_VERSION}/debian/changelog
}

# Use these lines to build for various distros

#for dist in lucid natty oneiric precise quantal squeeze wheezy; do
for dist in lucid; do
	set_dist $dist
	dpkg-source -b silan-${SILAN_VERSION}
	pbuilder-dist $dist i386 build silan_${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}.dsc
	pbuilder-dist $dist amd64 build silan_${SILAN_VERSION}~${dist}~sfo${SILAN_CUSTOM}.dsc
done

CHANGES=`ls -t ~/pbuilder/*_result/silan_*.changes | head -n 14`

ls -l $CHANGES

# Prompt user to sign the 14 newest packages with the Sourcefabric key

echo 'debsign -k174C1854 `ls -t ~/pbuilder/*_result/silan_*changes | head -n 14`'
