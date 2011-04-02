#/bin/sh

VERSION=1.6.1-GA
DLURL=http://sourceforge.net/projects/airtime/files/airtime-${VERSION}.tar.gz/download
MIRRORPATH=/tmp
BUILDDEST=/tmp/airtime-pkg/
DEBDIR=`pwd`/debian

if [ ! -f ${MIRRORPATH}/airtime-${VERSION}.tar.gz ]; then
	curl -L \
		-o ${MIRRORPATH}/airtime-${VERSION}.tar.gz \
		${DLURL} 
fi

rm -rf ${BUILDDEST}
mkdir -p ${BUILDDEST}/airtime
#mkdir -p ${BUILDDEST}/debian

cd ${BUILDDEST}/airtime
tar xvzf ${MIRRORPATH}/airtime-${VERSION}.tar.gz || exit
cd ${BUILDDEST}

cp -a $DEBDIR debian || exit


debuild $@ || exit

ls -l /tmp/airtime*deb
ls -l /tmp/airtime*changes

exit 

lintian -i --pedantic /tmp/airtime_${DEBRELEASE}_*.changes | tee /tmp/airtime-${DEBRELEASE}.issues

echo -n "UPLOAD? [enter|CTRL-C]" ; read

dput rg42 /tmp/airtime_${DEBRELEASE}_*.changes      
