#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

for CHANGE in "activate" "deactivate"
do
	mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
	cp -f "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done

case $(uname -s) in
    Darwin)
	export LDFLAGS="${LDFLAGS} -Wl,-headerpad_max_install_names" ;;
esac

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|g' makefile
	rm -f *.bak ;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|g' makefile
	rm -f *.bak ;;
esac

make -j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"
