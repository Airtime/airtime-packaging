#/bin/sh
# Script for generating official Airtime packages

GITTAG=2.5.x
VERSION=2.5.0
SFOCUSTOM="beta1"
DLURL=https://github.com/sourcefabric/Airtime/archive/airtime-${GITTAG}-${SFOCUSTOM}.tar.gz
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-${VERSION}/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${GITTAG}-${SFOCUSTOM}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${GITTAG}-${SFOCUSTOM}.tar.gz \
		${DLURL}
fi

#delete prev. deb package files
echo "cleaning up."
rm -rf ${BUILDDEST}

mkdir -p ${BUILDDEST}

cd ${BUILDDEST} || exit
echo "unzipping.."

tar xzf ${MIRRORPATH}/airtime-${GITTAG}-${SFOCUSTOM}.tar.gz || exit
cp -a $DEBDIR debian || exit

mv -vi airtime-${GITTAG}* airtime
pwd

# FIXES for 2.5.0-beta1 #############

# these are all moved to debian/copyright
rm airtime/python_apps/pypo/LICENSE
rm airtime/airtime_mvc/library/php-amqplib/LICENSE
rm airtime/airtime_mvc/library/phing/LICENSE
rm airtime/airtime_mvc/library/propel/LICENSE
rm airtime/airtime_mvc/library/soundcloud-api/README.md

#Remove phing library
rm -r airtime/airtime_mvc/library/phing/

#Remove ZFDebug
rm -r airtime/airtime_mvc/library/ZFDebug/

#Strip un-needed install scripts
rm -r airtime/install_full/

#Strip snapshot generation files
rm airtime/gen-snapshot.sh
rm -r airtime/debian/

#Fix executable bit
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/dataTables.ColReorder.js
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/dataTables.ColVis.js
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/psd/file_types.psd
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/js/ZeroClipboard.js
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/psd/copy\ document.psd
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/csv_hover.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/copy.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/as3/ZeroClipboard.as
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/js/TableTools.js
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/copy_hover.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/xls.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/print_hover.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/csv.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/print.png
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/as3/ZeroClipboardPdf.as
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/css/TableTools.css
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/css/TableTools_JUI.css
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/psd/printer.psd
chmod -x airtime/airtime_mvc/public/js/datatables/plugin/TableTools-2.1.5/images/xls_hover.png

#############################

cd ../
tar czf airtime_${VERSION}.orig.tar.gz  airtime-${VERSION}/airtime/
cd ${BUILDDEST} || exit

debuild -k174C1854 $@ || exit

ls -l ${MIRRORPATH}/airtime*deb
ls -l ${MIRRORPATH}/airtime*changes

lintian -i --pedantic ../airtime_${VERSION}*.changes | tee ../airtime-${VERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput sfo ../airtime_${VERSION}*.changes
