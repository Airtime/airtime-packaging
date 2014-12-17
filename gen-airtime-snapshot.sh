#/bin/sh
# Script for generating nightly Airtime snapshot packages

VERSION=2.5.2~$(date "+%Y%m%d")-1
BUILDDEST=/tmp/airtime-${VERSION}/
AIRTIMEDIR=/opt/airtime/
DEBDIR=/opt/airtime-packaging/debian/

git checkout $(git branch | grep "^*" | cut -d' ' -f 2)
git pull

echo "cleaning up previous build..."

rm -rf /tmp/airtime*
mkdir -p ${BUILDDEST}airtime

echo "copying files to temporary directory..."

cp -a $AIRTIMEDIR ${BUILDDEST} || exit
cp -a $DEBDIR ${BUILDDEST} || exit

cd ${BUILDDEST} || exit

# Set the version of the snapshot package

sed -i "1s:(2.5.2-1):(${VERSION}):g" debian/changelog

# FIXES for 2.5.2 #############

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE
rm airtime/airtime_mvc/library/soundcloud-api/README.md

# Remove Liquidsoap binary
rm -r airtime/python_apps/pypo/liquidsoap_bin/

# Remove phing library
rm -r airtime/airtime_mvc/library/phing/

# Remove ZFDebug
rm -r airtime/airtime_mvc/library/ZFDebug/

# Strip un-needed install scripts
rm -r airtime/install_full/

# Remove dev tools and files
rm -r airtime/dev_tools/
rm -r airtime/docs/
rm airtime/.gitignore
rm airtime/.zfproject.xml

# Remove Google tracking code
rm airtime/airtime_mvc/public/js/libs/google-analytics.js

#############################

echo "running the build..."

debuild -b -uc -us $@ || exit

cp /tmp/airtime_${VERSION}* /var/www/apt/snapshots/
