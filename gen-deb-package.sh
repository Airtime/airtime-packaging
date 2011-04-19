#/bin/sh

VERSION=1.8.0
DEBVERSION=1.8.0
DLURL=http://sourceforge.net/projects/airtime/files/${VERSION}/airtime-${VERSION}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${DEBVERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}.tar.gz \
		${DLURL} 
fi

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}-audiosamples.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}-audiosamples.tar.gz \
		http://sourceforge.net/projects/airtime/files/${VERSION}/airtime-${VERSION}-audiosamples.tar.gz/download
fi


#delete prev. deb package files
echo "cleaning up."
rm -f ${BUILDDEST}/../airtime_${DEBVERSION}*
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/airtime-${VERSION}.tar.gz || exit
tar xzf ${MIRRORPATH}/airtime-${VERSION}-audiosamples.tar.gz || exit
cp -a $DEBDIR debian || exit

pwd

# FIXES fo 1.8 #############
find airtime \( \
	   -iname "*.php" -o -iname "*.js" -o -iname "*.mp3" \
	-o -iname "*.xsd" -o -iname "*.xsl" -o -iname "*.xml" \
	-o -iname "*.cfg.*" -o -iname "*.txt" \
	\) -exec chmod -x "{}" \;

chmod +x airtime/python_apps/api_clients/api_client.py
chmod +x airtime/python_apps/pypo/install/pypo-liquidsoap-daemontools-logger.sh
chmod +x airtime/python_apps/pypo/scripts/library/liquidsoap.gentoo.initd

chmod +x airtime/airtime_mvc/application/models/cron/croncall.php
chmod +x airtime/airtime_mvc/library/php-amqplib/demo/amqp_airtime_consumer.php
chmod +x airtime/airtime_mvc/library/php-amqplib/demo/amqp_consumer.php
chmod +x airtime/airtime_mvc/library/php-amqplib/demo/amqp_publisher.php
chmod +x airtime/airtime/install/airtime-user.php

# invalid interpreter #!/usr/local/bin/python != /usr/bin/python
echo "#!/usr/bin/python" > airtime/python_apps/show-recorder/recorder.py2
cat airtime/python_apps/show-recorder/recorder.py >> airtime/python_apps/show-recorder/recorder.py2
mv airtime/python_apps/show-recorder/recorder.py2 airtime/python_apps/show-recorder/recorder.py
chmod +x airtime/python_apps/show-recorder/recorder.py


# no hash-bang
chmod -x airtime/python_apps/pypo/pypo-api-validator.py
chmod -x airtime/python_apps/pypo/pypopush.py
chmod -x airtime/python_apps/pypo/dls/__init__.py
chmod -x airtime/python_apps/pypo/dls/__init__.py
chmod -x airtime/python_apps/pypo/pypofetch.py
chmod -x airtime/python_apps/pypo/pypo-cue-in-validator.py
chmod -x airtime/python_apps/pypo/util/__init__.py
chmod -x airtime/airtime_mvc/library/propel/generator/bin/propel-gen.bat

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE

find airtime/audio_samples -iname "LICENSE.txt" -exec rm "{}" \;

rm airtime/python_apps/pypo/scripts/library/liquidsoap.gentoo.initd
rm airtime/python_apps/pypo/scripts/library/liquidsoap.gentoo.initd.in
rm airtime/python_apps/show-recorder/testrecordscript.py 
rm airtime/airtime_mvc/library/propel/generator/bin/propel-gen.bat



#############################

debuild $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes


lintian -i --pedantic ${BUILDDEST}/../airtime_${DEBVERSION}*.changes | tee /tmp/airtime-${DEBVERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput rg42 /tmp/airtime_${DEBVERSION}*.changes      
