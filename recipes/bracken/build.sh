#!/bin/bash

mkdir -p "${PREFIX}/bin/src"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' src/Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' src/Makefile
	;;
esac

# inject compilers
sed -i.bak "s|g++|${CXX} -I${PREFIX}/include|" src/Makefile
rm -f src/*.bak

chmod +rx ./install_bracken.sh
bash ./install_bracken.sh

install -v -m 0755 bracken bracken-build src/kmer2read_distr analysis_scripts/combine_bracken_outputs.py "${PREFIX}/bin"
install -v -m 0755 src/est_abundance.py src/generate_kmer_distribution.py "${PREFIX}/bin/src"

ln -sf "${PREFIX}"/bin/src/est_abundance.py "${PREFIX}"/bin/est_abundance.py
ln -sf "${PREFIX}"/bin/src/generate_kmer_distribution.py "${PREFIX}"/bin/generate_kmer_distribution.py
