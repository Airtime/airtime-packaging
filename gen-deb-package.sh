#/bin/sh
# Script for generating official Airtime packages

VERSION=2.4.0
SFOCUSTOM="ga"
#DLURL=http://sourceforge.net/projects/airtime/files/${VERSION}/airtime-${VERSION}-${SFOCUSTOM}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${VERSION}/
DEBDIR=`pwd`/debian

#if [ ! -f ${MIRRORPATH}/airtime-${VERSION}-${SFOCUSTOM}.tar.gz ]; then
#	curl -L \
#		-o ${MIRRORPATH}/airtime-${VERSION}-${SFOCUSTOM}.tar.gz \
#		${DLURL}
#fi

#delete prev. deb package files
echo "cleaning up."
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/airtime-${VERSION}-${SFOCUSTOM}.tar.gz || exit
cp -r ${MIRRORPATH}/airtime-${VERSION}-${SFOCUSTOM} .
cp -a $DEBDIR debian || exit

mv -vi airtime-${VERSION}* airtime
pwd

# FIXES for 2.4.0 #############

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE
rm airtime/airtime_mvc/library/soundcloud-api/README.md

#Remove phing library
rm -r airtime/airtime_mvc/library/phing/

#Remove ZFDebug
rm -r airtime/airtime_mvc/library/ZFDebug/

#Strip un-needed install scripts
rm -r airtime/install_full/

#Strip snapshot generation files
rm airtime/gen-snapshot.sh
rm -r airtime/debian/

#Fix executable bit
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/dataTables.ColReorder.js
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/dataTables.ColVis.js

#############################

cd ../
tar czf airtime_${VERSION}.orig.tar.gz  airtime-${VERSION}/airtime/
cd ${BUILDDEST} || exit

debuild -k174C1854 $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes

lintian -i --pedantic ${BUILDDEST}/../airtime_${VERSION}*.changes | tee /tmp/airtime-${VERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo /tmp/airtime_${VERSION}*.changes
