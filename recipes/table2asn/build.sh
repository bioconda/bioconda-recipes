#!/bin/bash -ex

gunzip *table2asn.gz
mkdir -p ${PREFIX}/bin

if [[ `uname` == Darwin ]]; then
	cp -f mac.table2asn ${PREFIX}/bin/table2asn
	else
	cp -f *.table2asn ${PREFIX}/bin/table2asn
fi

chmod 0755 "${PREFIX}/bin/table2asn"



# patchelf to modify the RPATH of table2asn's libbz libraries; refer to:
# https://github.com/bioconda/bioconda-recipes/pull/38770#issuecomment-1473627378
if [[ `uname` == Darwin ]]; then
	install_name_tool -change libbz2.1.dylib libbz2.1.0.dylib "${PREFIX}/bin/table2asn"
	install_name_tool -add_rpath "${PREFIX}/lib" "${PREFIX}/bin/table2asn"
	else
	patchelf --replace-needed libbz2.so.1 libbz2.so.1.0 "${PREFIX}/bin/table2asn"
	patchelf --set-rpath "${PREFIX}/lib" "${PREFIX}/bin/table2asn"
fi

