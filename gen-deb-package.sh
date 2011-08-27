#/bin/sh

VERSION=1.9.3
SFOCUSTOM=""
DEBVERSION=1.9.3
DLURL=http://sourceforge.net/projects/airtime/files/${DEBVERSION}/airtime-${VERSION}${SFOCUSTOM}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${DEBVERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}.tar.gz \
		${DLURL}
fi

#we no longer have an airtime-audiosamples package for each release
#if [ ! -f ${MIRRORPATH}/airtime-audiosamples-${VERSION}.tar.gz ]; then
#	curl -L \
#		-o ${MIRRORPATH}/airtime-audiosamples-${VERSION}.tar.gz \
#		http://sourceforge.net/projects/airtime/files/${VERSION}${SFOCUSTOM}/airtime-audiosamples-${VERSION}${SFOCUSTOM}.tar.gz/download
#fi

#delete prev. deb package files
echo "cleaning up."
rm -f ${BUILDDEST}/../airtime_${DEBVERSION}*
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/airtime-${VERSION}.tar.gz || exit
#tar xzf ${MIRRORPATH}/airtime-audiosamples-${VERSION}.tar.gz || exit
cp -a $DEBDIR debian || exit

mv -vi airtime-${VERSION}${SFOCUSTOM} airtime
pwd

# FIXES for 1.9 #############
find airtime \( \
	   -iname "*.php" -o -iname "*.js" -o -iname "*.mp3" \
	-o -iname "*.xsd" -o -iname "*.xsl" -o -iname "*.xml" \
	-o -iname "*.cfg.*" -o -iname "*.txt" \
	\) -exec chmod -x "{}" \;

chmod +x airtime/airtime_mvc/application/models/cron/croncall.php
chmod +x airtime/airtime_mvc/library/php-amqplib/demo/amqp_airtime_consumer.php
chmod +x airtime/airtime_mvc/library/php-amqplib/demo/amqp_consumer.php
chmod +x airtime/airtime_mvc/library/php-amqplib/demo/amqp_publisher.php

chmod +x airtime/install_minimal/3rd_party/setuptools-0.6c11-py2.6.egg

chmod +x airtime/python_apps/api_clients/api_client.py
chmod +x airtime/python_apps/media-monitor/MediaMonitor.py
chmod +x airtime/python_apps/show-recorder/recorder.py

chmod +x airtime/utils/airtime-import/airtime-import.py
chmod +x airtime/utils/airtime-user.php
chmod +x airtime/utils/phone_home_stat.php
chmod +x airtime/utils/rivendell-converter.sh

# we don't use env in a Debian package
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/api_clients/api_client.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/media-monitor/install/media-monitor-install.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/media-monitor/install/media-monitor-uninstall.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/pypo/install/pypo-install.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/pypo/install/pypo-uninstall.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/pypo/pypo-cli.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/pypo/pypo-notify.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/pypo/util/status.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/show-recorder/install/recorder-install.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/python_apps/show-recorder/install/recorder-uninstall.py
#sed -i 's:#!/usr/bin/env python:#!/usr/bin/python2.6:g' airtime/utils/serbianLatinToCyrillicConverter.py

# invalid interpreter #!/usr/local/bin/python != /usr/bin/python
#sed -i 's:#!/usr/local/bin/python:#!/usr/bin/python2.6:g' airtime/python_apps/media-monitor/MediaMonitor.py
#sed -i 's:#!/usr/local/bin/python:#!/usr/bin/python2.6:g' airtime/python_apps/show-recorder/recorder.py
#sed -i 's:#!/usr/local/bin/python:#!/usr/bin/python2.6:g' airtime/utils/airtime-import/airtime-import.py

# force scripts to use the virtualenv in bundled install
sed -i 's:#!/usr/local/bin/python:#!/usr/bin/env python:g' airtime/python_apps/media-monitor/MediaMonitor.py
sed -i 's:#!/usr/local/bin/python:#!/usr/bin/env python:g' airtime/python_apps/show-recorder/recorder.py
sed -i 's:#!/usr/local/bin/python:#!/usr/bin/env python:g' airtime/utils/airtime-import/airtime-import.py

# no hash-bang
chmod -x airtime/python_apps/pypo/pypofetch.py
chmod -x airtime/python_apps/pypo/pypopush.py
chmod -x airtime/python_apps/pypo/liquidsoap_scripts/library/tests/LS354-1.liq
chmod -x airtime/python_apps/pypo/liquidsoap_scripts/library/tests/LS354-2.liq
chmod -x airtime/python_apps/pypo/test/pypo-api-validator.py
chmod -x airtime/python_apps/pypo/util/__init__.py

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE

# we no longer have an airtime-audiosamples package for each release
#find airtime/audio_samples -iname "LICENSE.txt" -exec rm "{}" \;

# we don't need a Gentoo init script in a Debian package
rm airtime/python_apps/pypo/liquidsoap_scripts/library/liquidsoap.gentoo.initd.in

# we don't need a Windows script in a Debian package
rm airtime/airtime_mvc/library/propel/generator/bin/propel-gen.bat

# changelog filename must be in lower case
mv airtime/Changelog airtime/changelog

#############################

debuild $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes


lintian -i --pedantic ${BUILDDEST}/../airtime_${DEBVERSION}*.changes | tee /tmp/airtime-${DEBVERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo /tmp/airtime_${DEBVERSION}*.changes
