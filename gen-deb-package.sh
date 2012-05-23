#/bin/sh

VERSION=2.1.0
SFOCUSTOM="-rc1b"
DEBVERSION=2.1.0
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

# FIXES for 2.1.0 #############

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
sed -i '86s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '88s:binary_path:#binary_path:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '90s:try:#try:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '91s:open:#open:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '93s:try:#try:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '94s:os.remove:#os.remove:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '95s:except:#except:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '97s:pass:#pass:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '99s:os.symlink:#os.symlink:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '100s:except:#except:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '101s:    """:""":g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '102s:    """:""":g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '110s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '111s:print:#print:g' airtime/python_apps/pypo/install/pypo-initialize.py
sed -i '112s:sys.exit(1):#sys.exit(1):g' airtime/python_apps/pypo/install/pypo-initialize.py

# Modify the Liquidsoap path to distro installed Liquidsoap path
#sed -i '9s:/usr/bin/airtime-liquidsoap:/usr/bin/liquidsoap:g' airtime/python_apps/pypo/airtime-liquidsoap

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
