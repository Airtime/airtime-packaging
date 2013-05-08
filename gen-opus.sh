#!/bin/bash

# Packaging script for Opus binaries.
# Please download the orig.tar.gz tarball of opus source and diff.gz
# from Debian experimental to $MIRRORPATH before running this script.
# http://packages.debian.org/source/experimental/opus

OPUS_VERSION="1.0.1"
OPUS_CUSTOM="-1"
MIRRORPATH=/tmp

# Function to set the correct distro name in the package changelog and apply the Debian packaging diff

function set_dist {
  DIST=$1

# Clean up previous build

rm -rf ${MIRRORPATH}/opus/

# Create the temporary build directory and change to it

mkdir -p ${MIRRORPATH}/opus/
cd ${MIRRORPATH}/opus/

# Unpack the source tarball and the Debian packaging diff

tar -xvzf ${MIRRORPATH}/opus_${OPUS_VERSION}.orig.tar.gz
cp ${MIRRORPATH}/opus_${OPUS_VERSION}${OPUS_CUSTOM}.diff.gz ${MIRRORPATH}/opus/
gunzip ${MIRRORPATH}/opus/opus_${OPUS_VERSION}${OPUS_CUSTOM}.diff.gz

# Replace experimental with the name of the distro we are building for...

sed -i "s/(${OPUS_VERSION}${OPUS_CUSTOM}) experimental;/(${OPUS_VERSION}~${DIST}~sfo${OPUS_CUSTOM}) ${DIST};/" ${MIRRORPATH}/opus/opus_${OPUS_VERSION}${OPUS_CUSTOM}.diff

# ...then check the result

grep "(${OPUS_VERSION}~${DIST}~sfo${OPUS_CUSTOM}) ${DIST};" ${MIRRORPATH}/opus/opus_${OPUS_VERSION}${OPUS_CUSTOM}.diff

# Patch the upstream source with the Debian packaging changes, then close the function

patch -p0 < ${MIRRORPATH}/opus/opus_${OPUS_VERSION}${OPUS_CUSTOM}.diff
}

# Use these lines to build for various distros

for dist in lucid precise squeeze wheezy; do
	set_dist $dist
        dpkg-source -b opus-${OPUS_VERSION}
	pbuilder-dist $dist i386 build opus_${OPUS_VERSION}~${dist}~sfo${OPUS_CUSTOM}.dsc
	pbuilder-dist $dist amd64 build opus_${OPUS_VERSION}~${dist}~sfo${OPUS_CUSTOM}.dsc
done

CHANGES=`ls -t ~/pbuilder/*_result/opus_${OPUS_VERSION}*.changes | head -n 8`

ls -l $CHANGES

# Prompt user to sign the 8 newest packages with the Sourcefabric key

echo 'debsign -k174C1854 `ls -t ~/pbuilder/*_result/opus_${OPUS_VERSION}*changes | head -n 8`'
