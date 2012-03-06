#/bin/sh

VERSION=2.0.2
SFOCUSTOM="-3"
DEBVERSION=2.0.2
DLURL=http://sourceforge.net/projects/airtime/files/${VERSION}${SFOCUSTOM}/airtime-${VERSION}${SFOCUSTOM}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${DEBVERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}${SFOCUSTOM}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}${SFOCUSTOM}.tar.gz \
		${DLURL}
fi

#delete prev. deb package files
echo "cleaning up."
rm -f ${BUILDDEST}/../airtime_${DEBVERSION}*
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/airtime-${VERSION}${SFOCUSTOM}.tar.gz || exit
cp -a $DEBDIR debian || exit

mv -vi airtime-${VERSION}${SFOCUSTOM} airtime
pwd

# FIXES for 2.0.2 #############

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE
rm airtime/airtime_mvc/library/soundcloud-api/README.md

# Disable install script check for Debian package, we don't need it
sed -i '11s:DEB=$(dpkg:# DEB=$(dpkg:g' airtime/install_minimal/airtime-install
sed -i '13s\"$DEB" = "Status: install ok installed"\-f /var/lib/dpkg/info/airtime.config\g' airtime/install_minimal/airtime-install
sed -i '14s: Please use the debian package to upgrade.:..:g' airtime/install_minimal/airtime-install
sed -i '15s:exit 1:# We do not exit here:g' airtime/install_minimal/airtime-install

# Remove Liquidsoap binaries
rm -r airtime/python_apps/pypo/liquidsoap_bin/

# Disable installation of Liquidsoap binaries
sed -i '83s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '85s:binary_path:#binary_path:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '87s:try:#try:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '88s:shutil.copy:#shutil.copy:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '89s:except:#except:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '90s:    """:""":g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '98s:    """:""":g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '99s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '100s:sys.exit(1):#sys.exit(1):g' airtime/python_apps/pypo/install/pypo-initialize.py

# Modify the Liquidsoap path to distro installed Liquidsoap path
sed -i '9s:/usr/lib/airtime/pypo/bin/liquidsoap_bin/liquidsoap:/usr/bin/liquidsoap:g' airtime/python_apps/pypo/airtime-liquidsoap

#Remove phing library
rm -r airtime/airtime_mvc/library/phing/

#Remove ZFDebug
rm -r airtime/airtime_mvc/library/ZFDebug/

#Strip un-needed install scripts
rm -r airtime/install_full/

#############################

cd ../
tar czf airtime_${VERSION}.orig.tar.gz  airtime-${DEBVERSION}/airtime/
cd ${BUILDDEST} || exit

debuild -k174C1854 $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes

lintian -i --pedantic ${BUILDDEST}/../airtime_${DEBVERSION}*.changes | tee /tmp/airtime-${DEBVERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo /tmp/airtime_${DEBVERSION}*.changes
