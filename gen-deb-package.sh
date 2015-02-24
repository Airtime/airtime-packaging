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

#Remove Python bytecode etc.
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/anyjson/tests/test_implementations.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/argparse/argparse.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/configobj/._configobj.py
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/configobj/._setup.py
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/configobj/._validate.py
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/configobj/configobj.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/mutagen/mutagen/__init__.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/mutagen/mutagen/_util.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/poster/poster/__init__.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/poster/poster/encode.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/poster/poster/streaminghttp.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/pytz/pytz/__init__.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/pytz/pytz/exceptions.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/pytz/pytz/tzfile.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/pytz/pytz/tzinfo.pyc
rm airtime/python_apps/python-virtualenv/airtime_virtual_env.pybundle_FILES/build/wsgiref/ez_setup/__init__.pyc

#Remove Python 2.6 egg
rm airtime/python_apps/python-virtualenv/3rd_party/setuptools-0.6c11-py2.6.egg

#Fix executable bits
chmod +x airtime/python_apps/media-monitor/bin/airtime-media-monitor
chmod +x airtime/python_apps/media-monitor/install/sysvinit/airtime-media-monitor
chmod +x airtime/python_apps/pypo/install/sysvinit/airtime-liquidsoap
chmod +x airtime/python_apps/pypo/install/sysvinit/airtime-playout

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
