#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
outdir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${outdir}/libexec" "${PREFIX}/bin"

chmod u+x install_kraken2.sh

#install_name_tool error fix
if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

CXX="${CXX}" ./install_kraken2.sh "${outdir}/libexec"
for bin in kraken2 kraken2-build kraken2-inspect k2; do
	chmod 0755 "${outdir}/libexec/$bin"
	ln -sf "${outdir}/libexec/$bin" "${PREFIX}/bin/$bin"
	# Change from double quotes to single in case of special chars
	# we don't do the following for the k2 binariy
	if [[ $bin != "k2" ]]; then
		sed -i.bak "s#my \$KRAKEN_DIR = \"${outdir}/libexec\";#my \$KRAKEN_DIR = '${outdir}/libexec';#g" "${outdir}/libexec/${bin}"
		rm -rf "${outdir}/libexec/${bin}.bak"
	fi
done
