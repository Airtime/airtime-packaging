#!/bin/bash

# Packaging script for Liquidsoap binaries. See https://wiki.sourcefabric.org/display/CC/Packaging+Liquidsoap
# Please download the tarball of Liquidsoap binaries to $MIRRORPATH before running this script

LIQUIDSOAP_VERSION=1.1.1
LIQUIDSOAP_CUSTOM="sfo-1"
MIRRORPATH=/tmp

# Copy the packaging files into the temporary build directory

mkdir -p ${MIRRORPATH}/liquidsoap/bin/
cp -r liquidsoap/* ${MIRRORPATH}/liquidsoap/

# Unpack the Liquidsoap binaries from the tarball

tar -xvzf /tmp/liquidsoap-${LIQUIDSOAP_VERSION}.tar.gz -C ${MIRRORPATH}/liquidsoap/bin/

cd ${MIRRORPATH}/

# Test that the Liquidsoap binaries are all present

if test ! \( -d liquidsoap/bin \
	-a -f liquidsoap/bin/liquidsoap_lucid_amd64 \
	-a -f liquidsoap/bin/liquidsoap_lucid_i386 \
	-a -f liquidsoap/bin/liquidsoap_precise_amd64 \
	-a -f liquidsoap/bin/liquidsoap_precise_i386 \
        -a -f liquidsoap/bin/liquidsoap_quantal_amd64 \
        -a -f liquidsoap/bin/liquidsoap_quantal_i386 \
        -a -f liquidsoap/bin/liquidsoap_raring_amd64 \
        -a -f liquidsoap/bin/liquidsoap_raring_i386 \
        -a -f liquidsoap/bin/liquidsoap_squeeze_amd64 \
        -a -f liquidsoap/bin/liquidsoap_squeeze_i386 \
        -a -f liquidsoap/bin/liquidsoap_wheezy_amd64 \
        -a -f liquidsoap/bin/liquidsoap_wheezy_i386 \) \
	; then
echo "ERROR: liquidsoap binaries not present in ${MIRRORPATH}/liquidsoap/bin/"
exit 1
fi

# Use these lines to build for Debian squeeze

        dpkg-source -b liquidsoap
        pbuilder-dist squeeze build liquidsoap_${LIQUIDSOAP_VERSION}~squeeze~${LIQUIDSOAP_CUSTOM}.dsc
        pbuilder-dist squeeze i386 build liquidsoap_${LIQUIDSOAP_VERSION}~squeeze~${LIQUIDSOAP_CUSTOM}.dsc

# Set the correct distro name in the package changelog

function set_dist {
  DIST=$1
	ed liquidsoap/debian/changelog << EOF
1,1s/) [^;]*;/) ${DIST};/
1,1s/~[^-]*~/~${DIST}~/
wq
EOF
head -n1 liquidsoap/debian/changelog
}

# Use these lines to build for other distros

#for dist in lucid precise quantal raring wheezy; do
#	set_dist $dist
#	dpkg-source -b liquidsoap
#	pbuilder-dist $dist build liquidsoap_${LIQUIDSOAP_VERSION}~${dist}~${LIQUIDSOAP_CUSTOM}.dsc
#	pbuilder-dist $dist i386 build liquidsoap_${LIQUIDSOAP_VERSION}~${dist}~${LIQUIDSOAP_CUSTOM}.dsc
#done

CHANGES=`ls -t ~/pbuilder/*_result/liquidsoap_*.changes | head -n 12`

ls -l $CHANGES

# Prompt user to sign the 12 newest packages with the Sourcefabric key

echo 'debsign -k174C1854 `ls -t ~/pbuilder/*_result/liquidsoap_*changes | head -n 12`'
