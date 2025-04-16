#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

for CHANGE in "activate" "deactivate"
do
	mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
	cp -rf "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

if [[ `uname -m` == "x86_64" ]]; then
	sed -i.bak 's/-march=native/-march=x86-64 -mtune=generic/g' makefile
elif [[ `uname -m` == "arm64" ]]; then
	sed -i.bak 's/-march=native/-mtune=generic/g' makefile
fi

if [[ "$(uname)" == "Darwin" ]]; then
	sed -i.bak 's/g++/${CXX}/g' makefile
	sed -i.bak 's/g++/${CXX}/g' makefile
	make -j"${CPU_COUNT}" mac
else
	sed -i.bak 's/g++/${CXX}/g' makefile
	sed -i.bak 's/g++/${CXX}/g' makefile
	make -j"${CPU_COUNT}"
fi

sed -i.bak 's|-O2|-O3|' makefile
rm -rf *.bak

[[ ! -d ${PREFIX}/bin ]] && mkdir -p "${PREFIX}/bin"

install -v -m 0755 bin/* "${PREFIX}/bin"
