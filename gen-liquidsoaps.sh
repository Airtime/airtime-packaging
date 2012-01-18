#!/bin/bash
cd liquidsoap

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
	-a -f bin/liquidsoap_oneiric_i386 \) \
	; then
echo "ERROR: liquidsoap binaries not present in"
echo " `pwd`/bin"
echo 
echo "# mkdir /tmp/airt; cd /tmp/airt"
echo "# wget http://apt.sourcefabric.org/misc/airtime_2.0.0-1_amd64.deb"
echo "# ar p airtime_2.0.0-1_amd64.deb data.tar.gz | tar xvz" 
echo "# cp -a var/lib/airtime/tmp/python_apps/pypo/liquidsoap_bin \\"
echo " `pwd`/bin"
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

for dist in lucid maverick natty oneiric squeeze; do
	set_dist $dist
	dpkg-buildpackage $COMMON_OPTS -ai386  || exit
	dpkg-buildpackage $COMMON_OPTS -aamd64 || exit
	mkdir ../lqs_$dist 
	mv -v ../liquidsoap_1.0.0~*sfo*_*.* ../lqs_$dist || exit
done

cd ..

CHANGES=`ls -t lqs*/*.changes | head -n 10`
ls -l $CHANGES
#echo "debsign -k4F952B42 $CHANGES" # rg
echo "debsign -k174C1854 $CHANGES" # sfo
