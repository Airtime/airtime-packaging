#/bin/sh

VERSION=2.0.0
SFOCUSTOM="-1"
DEBVERSION=2.0.0
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

mv -vi airtime-${VERSION} airtime
pwd

# FIXES for 2.0.0 #############

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE

# Disable install script check for Debian package, we don't need it
sed -i '11s:DEB=$(dpkg:# DEB=$(dpkg:g' airtime/install_minimal/airtime-install
sed -i '13s\"$DEB" = "Status: install ok installed"\-f /var/lib/dpkg/info/airtime.config\g' airtime/install_minimal/airtime-install
sed -i '14s: Please use the debian package to upgrade.:..:g' airtime/install_minimal/airtime-install
sed -i '15s:exit 1:# We do not exit here:g' airtime/install_minimal/airtime-install

# Remove Liquidsoap binaries
rm -r airtime/python_apps/pypo/liquidsoap_bin/

# Disable installation of Liquidsoap binaries
sed -i '83s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '84s:if:#if:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '85s:shutil.copy:#shutil.copy:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '86s:else:#else:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '87s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '88s:sys.exit(1):#sys.exit(1):g' airtime/python_apps/pypo/install/pypo-initialize.py

# Modify the Liquidsoap path to distro installed Liquidsoap path
sed -i '9s:/usr/lib/airtime/pypo/bin/liquidsoap_bin/liquidsoap:/usr/bin/liquidsoap:g' airtime/python_apps/pypo/airtime-liquidsoap

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
