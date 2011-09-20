#/bin/sh

VERSION=1.9.4
SFOCUSTOM="-RC7"
DEBVERSION=1.9.4
DLURL=http://sourceforge.net/projects/airtime/files/${DEBVERSION}/airtime-${VERSION}${SFOCUSTOM}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${DEBVERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}${SFOCUSTOM}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}.tar.gz \
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

# FIXES for 1.9.4 #############
find airtime/airtime_mvc/public/js/datatables/unit_testing/tests_onhold \( \
	   -iname "*.js" \
	\) -exec chmod -x "{}" \;

# script-not-executable
chmod +x airtime/python_apps/media-monitor/install/media-monitor-install.py
chmod +x airtime/python_apps/media-monitor/install/media-monitor-uninstall.py
chmod +x airtime/python_apps/pypo/install/pypo-install.py
chmod +x airtime/python_apps/pypo/install/pypo-uninstall.py
chmod +x airtime/python_apps/pypo/pypo-cli.py
chmod +x airtime/python_apps/pypo/pypo-notify.py
chmod +x airtime/python_apps/pypo/util/status.py
chmod +x airtime/python_apps/show-recorder/install/recorder-install.py
chmod +x airtime/python_apps/show-recorder/install/recorder-uninstall.py
chmod +x airtime/utils/serbianLatinToCyrillicConverter.py

# executable-not-elf-or-script
chmod -x airtime/airtime_mvc/application/models/cron/CronJob.php
chmod -x airtime/airtime_mvc/application/models/cron/Crontab.php
chmod -x airtime/airtime_mvc/application/models/cron/Cron.php

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE

# we don't need a Gentoo init script in a Debian package
rm airtime/python_apps/pypo/liquidsoap_scripts/library/liquidsoap.gentoo.initd.in

# we don't need a Windows script in a Debian package
rm airtime/airtime_mvc/library/propel/generator/bin/propel-gen.bat

# changelog filename must be in lower case
mv airtime/Changelog airtime/changelog

# Disable install script check for Debian package, we don't need it
sed -i '6s:DEB=$(dpkg:# DEB=$(dpkg:g' airtime/install_minimal/airtime-install
sed -i '8s\"$DEB" = "Status: install ok installed"\-f /var/lib/dpkg/info/airtime.config\g' airtime/install_minimal/airtime-install
sed -i '9s: Please use the debian package to upgrade.:..:g' airtime/install_minimal/airtime-install
sed -i '10s:exit 1:# We do not exit here:g' airtime/install_minimal/airtime-install

#############################

debuild $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes


lintian -i --pedantic ${BUILDDEST}/../airtime_${DEBVERSION}*.changes | tee /tmp/airtime-${DEBVERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo /tmp/airtime_${DEBVERSION}*.changes
