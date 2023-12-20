CFLAGS="${CFLAGS} ${LDFLAGS}" \
    make \
    CXX="${CXX}" CC="${CC}"
install -d "${PREFIX}/bin"
install msisensor "${PREFIX}/bin/"
