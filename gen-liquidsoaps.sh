#!/bin/bash
VERSION=2.1.0
SFOCUSTOM="-rc1b"
LIQUIDSOAP_VERSION=1.0.0
LIQUIDSOAP_CUSTOM="sfo-7"
MIRRORPATH=/tmp

mkdir -p ${MIRRORPATH}/liquidsoap/bin/
cp -r liquidsoap/* ${MIRRORPATH}/liquidsoap/

tar -xzf ${MIRRORPATH}/airtime-${VERSION}${SFOCUSTOM}.tar.gz -C ${MIRRORPATH}
cp -a ${MIRRORPATH}/airtime-${VERSION}/python_apps/pypo/liquidsoap_bin/*_* ${MIRRORPATH}/liquidsoap/bin/

cd ${MIRRORPATH}/liquidsoap

if test ! \( -d bin \
	-a -f bin/liquidsoap_squeeze_amd64 \
	-a -f bin/liquidsoap_squeeze_i386  \
	-a -f bin/liquidsoap_lucid_amd64 \
	-a -f bin/liquidsoap_lucid_i386  \
	-a -f bin/liquidsoap_maverick_amd64 \
	-a -f bin/liquidsoap_maverick_i386  \
	-a -f bin/liquidsoap_natty_amd64 \
	-a -f bin/liquidsoap_natty_i386  \
	-a -f bin/liquidsoap_oneiric_amd64 \
	-a -f bin/liquidsoap_oneiric_i386 \
	-a -f bin/liquidsoap_precise_amd64 \
	-a -f bin/liquidsoap_precise_i386 \) \
	; then
echo "ERROR: liquidsoap binaries not present in ${MIRRORPATH}/liquidsoap/bin/"
#echo " `pwd`/bin"
#echo
#echo "# mkdir /tmp/airt; cd /tmp/airt"
#echo "# wget http://apt.sourcefabric.org/misc/airtime_2.0.0-1_amd64.deb"
#echo "# ar p airtime_2.0.0-1_amd64.deb data.tar.gz | tar xvz"
#echo "# cp -a var/lib/airtime/tmp/python_apps/pypo/liquidsoap_bin \\"
#echo " `pwd`/bin"
exit 1
fi

function set_dist {
  DIST=$1
	ed debian/changelog << EOF
1,1s/) [^;]*;/) ${DIST};/
1,1s/~[^-]*~/~${DIST}~/
wq
EOF
head -n1 debian/changelog
}

COMMON_OPTS="-rfakeroot -uc -b"

for dist in lucid maverick natty oneiric precise squeeze; do
	set_dist $dist
	pbuilder-dist $dist i386 build ${MIRRORPATH}/liquidsoap_${LIQUIDSOAP_VERSION}~${dist}~${LIQUIDSOAP_CUSTOM}.dsc
	pbuilder-dist $dist amd64 build ${MIRRORPATH}/liquidsoap_${LIQUIDSOAP_VERSION}~${dist}~${LIQUIDSOAP_CUSTOM}.dsc
	#sudo DIST=$dist ARCH=amd64 pdebuild --pbuilder cowbuilder --debbuildopts "-b" # || exit
	#sudo DIST=$dist ARCH=i386 linux32 pdebuild --pbuilder cowbuilder --debbuildopts "-b" # || exit
	#dpkg-buildpackage $COMMON_OPTS -ai386  || exit
	#dpkg-buildpackage $COMMON_OPTS -aamd64 || exit
	#mkdir ../lqs_$dist
	#mv -v ../liquidsoap_1.0.0~*sfo*_*.* ../lqs_$dist || exit
done

cd ..

CHANGES=`ls -t ~/pbuilder/*_result/liquidsoap_${LIQUIDSOAP_VERSION}~${dist}~${LIQUIDSOAP_CUSTOM}_*.changes | head -n 12`
#CHANGES=`ls -t lqs*/*.changes | head -n 10`
#CHANGES=`ls -t /var/cache/pbuilder/result/liquidsoap_*changes | head -n 10`

ls -l $CHANGES

echo 'debsign -k174C1854 `ls -t ~/pbuilder/*_result/liquidsoap_*changes | head -n 12`' # dj
#echo "debsign -k4F952B42 $CHANGES" # rg
#echo 'debsign -k174C1854 `ls -t /var/cache/pbuilder/result/liquidsoap_*changes | head -n 10`' # sfo
