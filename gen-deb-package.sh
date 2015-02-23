#/bin/sh
# Script for generating official Airtime packages

GITTAG=airtime-2.5.2-rc1
VERSION=2.5.2
SFOCUSTOM=""
DLURL=https://github.com/sourcefabric/Airtime/archive/${GITTAG}${SFOCUSTOM}.tar.gz
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${VERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/${GITTAG}${SFOCUSTOM}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/${GITTAG}${SFOCUSTOM}.tar.gz \
		${DLURL}
fi

#delete prev. deb package files
echo "cleaning up."
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/${GITTAG}${SFOCUSTOM}.tar.gz || exit

echo "setting the version..."
sed -i "s:NEWVERSION=.*:NEWVERSION=\"$VERSION\":" $DEBDIR/postinst

cp -a $DEBDIR debian || exit

mv -vi Airtime-${GITTAG}* airtime
pwd

# FIXES for 2.5.2 #############

# these are all moved to debian/copyright
rm airtime/airtime_mvc/library/php-amqplib/CREDITS
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/README.md
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE
rm airtime/airtime_mvc/library/soundcloud-api/README.md
rm airtime/python_apps/pypo/pypo/LICENSE

#Remove phing library
rm -r airtime/airtime_mvc/library/phing/

#Remove ZFDebug
rm -r airtime/airtime_mvc/library/ZFDebug/

#Remove dev tools and files
rm -r airtime/dev_tools/
rm -r airtime/docs/
rm airtime/.gitignore
rm airtime/.zfproject.xml

#Remove Propel docs and tests
rm -r airtime/airtime_mvc/library/propel/contrib
rm -r airtime/airtime_mvc/library/propel/docs
rm -r airtime/airtime_mvc/library/propel/test
rm airtime/airtime_mvc/library/propel/INSTALL
rm airtime/airtime_mvc/library/propel/WHATS_NEW

#Fix permissions
chmod -x airtime/installer/lib/requirements-ubuntu-trusty.apt
chmod -x airtime/installer/lib/requirements-ubuntu-precise.apt
chmod +x airtime/python_apps/pypo/bin/pyponotify

#Remove Mutagen patches
#rm -r airtime/python_apps/python-virtualenv/patches/mutagen

#############################

#Uncomment to build an orig tarball for a new upstream release
cd ../
tar czf airtime_${VERSION}.orig.tar.gz  airtime-${VERSION}/airtime/
cd ${BUILDDEST} || exit

#Build a signed package with the Sourcefabric key
debuild -k174C1854 $@ || exit

ls -l ${MIRRORPATH}/airtime*deb
ls -l ${MIRRORPATH}/airtime*changes

lintian -i --pedantic ../airtime_${VERSION}*.changes | tee ../airtime-${VERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo ../airtime_${VERSION}*.changes
