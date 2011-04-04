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

# FIXES fo 1.6 #############
#find airtime \( \
#	   -iname "*.php" -o -iname "*.js" -o -iname "*.mp3" \
#	-o -iname "*.xsd" -o -iname "*.xsl" -o -iname "*.xml" \
#	-o -iname "*.cfg.*" -o -iname "*.txt" \
#	\) -exec chmod -x "{}" \;
#
#find airtime/pypo -iname "*.py"  \
#	-exec chmod +x "{}" \;

echo "RewriteBase /" >> airtime/public/.htaccess

#############################

debuild $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes


lintian -i --pedantic ${BUILDDEST}/../airtime_${DEBVERSION}*.changes | tee /tmp/airtime-${DEBVERSION}.issues

exit
echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput rg42 /tmp/airtime_${DEBVERSION}*.changes      
