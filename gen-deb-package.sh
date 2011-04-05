#/bin/sh

VERSION=1.7.0-GA
DEBVERSION=1.7.0
DLURL=http://sourceforge.net/projects/airtime/files/airtime-${VERSION}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${DEBVERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}.tar.gz \
		${DLURL} 
fi

#delete prev. deb package files
rm -f ${BUILDDEST}/../airtime_${DEBVERSION}*
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
tar xzf ${MIRRORPATH}/airtime-${VERSION}.tar.gz || exit
cp -a $DEBDIR debian || exit

# FIXES fo 1.7 #############
find airtime \( \
	   -iname "*.php" -o -iname "*.js" -o -iname "*.mp3" \
	-o -iname "*.xsd" -o -iname "*.xsl" -o -iname "*.xml" \
	-o -iname "*.cfg.*" -o -iname "*.txt" \
	\) -exec chmod -x "{}" \;

chmod +x airtime/install/airtime-user.php
chmod +x airtime/library/php-amqplib/demo/amqp_airtime_consumer.php
chmod +x airtime/library/php-amqplib/demo/amqp_consumer.php
chmod +x airtime/library/php-amqplib/demo/amqp_publisher.php
chmod +x airtime/library/propel/generator/pear/pear-propel-gen
chmod +x airtime/python_apps/api_clients/api_client.py
chmod +x airtime/python_apps/pypo/install/pypo-daemontools-liquidsoap.sh
chmod +x airtime/python_apps/pypo/install/pypo-daemontools-logger.sh
chmod +x airtime/python_apps/pypo/install/pypo-daemontools.sh
chmod +x airtime/python_apps/pypo/install/pypo-install.py
chmod +x airtime/python_apps/pypo/install/pypo-start.py
chmod +x airtime/python_apps/pypo/install/pypo-stop.py
chmod +x airtime/python_apps/pypo/install/pypo-uninstall.py
chmod +x airtime/python_apps/pypo/scripts/library/liquidsoap.gentoo.initd

chmod +x airtime/python_apps/pypo/scripts/library/liquidsoap.initd
chmod +x airtime/python_apps/pypo/util/status.py
chmod +x airtime/python_apps/show-recorder/install/recorder-daemontools-logger.sh
chmod +x airtime/python_apps/show-recorder/install/recorder-daemontools.sh
chmod +x airtime/python_apps/show-recorder/install/recorder-install.py
chmod +x airtime/python_apps/show-recorder/install/recorder-start.py
chmod +x airtime/python_apps/show-recorder/install/recorder-stop.py
chmod +x airtime/python_apps/show-recorder/install/recorder-uninstall.py
chmod +x airtime/python_apps/show-recorder/testrecordscript.py
chmod +x airtime/application/models/cron/croncall.php

rm airtime/public/css/colorpicker/images/Thumbs.db

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/library/php-amqplib/LICENSE
rm airtime/library/phing/LICENSE
rm airtime/library/propel/LICENSE
find airtime/audio_samples -iname "LICENSE.txt" -exec rm "{}" \;

# unusual interpreter: #!/sbin/runscript, /usr/local/bin/python
rm airtime/python_apps/pypo/scripts/library/liquidsoap.gentoo.initd
rm airtime/python_apps/show-recorder/testrecordscript.py 
rm airtime/library/propel/generator/bin/propel-gen.bat

# missing hash-bang
chmod -x airtime/python_apps/pypo/pypo-api-validator.py

echo "RewriteBase /" >> airtime/public/.htaccess

#############################

debuild $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes


lintian -i --pedantic ${BUILDDEST}/../airtime_${DEBVERSION}*.changes | tee /tmp/airtime-${DEBVERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput rg42 /tmp/airtime_${DEBVERSION}*.changes      
