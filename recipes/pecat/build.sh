#!/bin/bash
set -x
set -e

export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export PATH="${PATH}:${PREFIX}/bin"

case $(uname -m) in
    aarch64|arm*)
        CFLAGS="${CFLAGS} -march=armv8-a+simd -DKSW_CPU_DISPATCH=0"
        CFLAGS="${CFLAGS} -mtune=cortex-a72"
        ;;
    *)
        CFLAGS="${CFLAGS} -march=native"
        ;;
esac


KSW2_DIR="${SRC_DIR}/thirdparty/ksw2"
[ -d "${KSW2_DIR}" ] || { echo "err：ksw2"; exit 1; }


cat > "${KSW2_DIR}/Makefile" <<'EOF'
CC ?= gcc
AR ?= ar
CFLAGS += -Wall -O2

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
