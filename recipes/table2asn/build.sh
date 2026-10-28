#!/bin/bash -ex

gunzip *table2asn.gz
mkdir -p ${PREFIX}/bin

if [[ `uname` == Darwin ]]; then
	cp -f mac.table2asn ${PREFIX}/bin/table2asn
	else
	cp -f *.table2asn ${PREFIX}/bin/table2asn
fi

chmod 0755 "${PREFIX}/bin/table2asn"



# patchelf to point the RUNPATH of table2asn at the conda lib directory (libsqlite3)
if [[ `uname` == Darwin ]]; then
	install_name_tool -add_rpath "${PREFIX}/lib" "${PREFIX}/bin/table2asn"
	else
	patchelf --set-rpath "${PREFIX}/lib" "${PREFIX}/bin/table2asn"
fi

