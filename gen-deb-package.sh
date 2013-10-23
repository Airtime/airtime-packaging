#/bin/sh
# Script for generating official Airtime packages

GITTAG=airtime-2.5.0
VERSION=2.5.0
SFOCUSTOM="rc1"
DLURL=https://github.com/sourcefabric/Airtime/archive/${GITTAG}-${SFOCUSTOM}.tar.gz
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${VERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/${GITTAG}-${SFOCUSTOM}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/${GITTAG}-${SFOCUSTOM}.tar.gz \
		${DLURL}
fi

#delete prev. deb package files
echo "cleaning up."
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/${GITTAG}-${SFOCUSTOM}.tar.gz || exit
cp -a $DEBDIR debian || exit

mv -vi Airtime-${GITTAG}* airtime
pwd

# FIXES for 2.5.0-rc1 #############

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

#Remove dev tools and files
rm -r airtime/dev_tools/
rm -r airtime/docs/
rm airtime/.gitignore
rm airtime/.zfproject.xml

#############################

cd ../
tar czf airtime_${VERSION}.orig.tar.gz  airtime-${VERSION}/airtime/
cd ${BUILDDEST} || exit

debuild -k174C1854 $@ || exit

ls -l ${MIRRORPATH}/airtime*deb
ls -l ${MIRRORPATH}/airtime*changes

lintian -i --pedantic ../airtime_${VERSION}*.changes | tee ../airtime-${VERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo ../airtime_${VERSION}*.changes
