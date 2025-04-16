#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

for CHANGE in "activate" "deactivate"
do
	mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
	cp -rf "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

sed -i.bak 's|-O2|-O3|' makefile
rm -rf *.bak

if [[ `uname -m` != "aarch64" ]]; then
	sed -i.bak 's/-march=native/-march=x86-64 -mtune=generic/g' makefile
	rm -rf *.bak
fi

if [[ "$(uname)" == "Darwin" ]]; then
	sed -i.bak2 's/g++/${CXX}/g' makefile
	rm -rf *.bak
	make -j"${CPU_COUNT}" mac
else
	sed -i.bak2 's/g++/${CXX}/g' makefile
	rm -rf *.bak
	make -j"${CPU_COUNT}"
fi

[[ ! -d ${PREFIX}/bin ]] && mkdir -p "${PREFIX}/bin"

install -v -m 0755 bin/* "${PREFIX}/bin"
