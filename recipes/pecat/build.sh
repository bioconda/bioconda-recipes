#!/bin/bash
set -x
set -e

export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i.bak 's|-lrt||' src/makefile
fi
sed -i.bak 's|ar -r|$(AR) -rcs|' src/makefile
sed -i.bak 's|g++|$(CXX)|' src/makefile
sed -i.bak 's|gcc|$(CC)|' src/makefile

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
    sed -i.bak 's|-Wall -O3  -D_FILE_OFFSET_BITS=64|-Wall -O3 -D_FILE_OFFSET_BITS=64 -DKSW_CPU_DISPATCH=0|' src/makefile
    sed -i.bak 's|-std=c++11 -Wall -O3|-std=c++14 -Wall -O3 -march=armv8-a|' src/makefile
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
    sed -i.bak 's|-Wall -O3  -D_FILE_OFFSET_BITS=64|-Wall -O3 -D_FILE_OFFSET_BITS=64 -DKSW_CPU_DISPATCH=0|' src/makefile
    sed -i.bak 's|-std=c++11 -Wall -O3|-std=c++14 -Wall -O3 -march=armv8.4-a|' src/makefile
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
    sed -i.bak 's|-std=c++11 -Wall -O3|-std=c++14 -Wall -O3 -march=x86-64|' src/makefile
	;;
esac
rm -f src/*.bak

KSW2_DIR="${SRC_DIR}/thirdparty/ksw2"
[ -d "${KSW2_DIR}" ] || { echo "err：ksw2"; exit 1; }


cat > "${KSW2_DIR}/Makefile" <<'EOF'
CC ?= gcc
AR ?= ar
CFLAGS += -Wall -O3

OBJS = ksw2_gg.o ksw2_extz.o ksw2_extd.o

libksw2.a: $(OBJS)
<TAB>$(AR) -rc $@ $^

%.o: %.c
<TAB>@mkdir -p $(@D)
<TAB>$(CC) $(CFLAGS) -c $< -o $@

clean:
<TAB>rm -f *.o *.a
EOF

sed -i 's/<TAB>/\t/g' ${KSW2_DIR}/Makefile


cd "${KSW2_DIR}" || exit 1
make clean || true
make CC="${CC}" AR="${AR}" CFLAGS="${CFLAGS}" libksw2.a || exit 1

cd "${SRC_DIR}" || exit 1
make -j$(nproc) CFLAGS="${CFLAGS}" || \
make CFLAGS="${CFLAGS}" || exit 1

install -d "${PREFIX}/bin" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"
cp -r build/bin/* "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"

cat > "${PREFIX}/bin/pecat.pl" <<EOF
#!/bin/bash
${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/pecat.pl "\$@"
EOF
chmod +x "${PREFIX}/bin/pecat.pl"
