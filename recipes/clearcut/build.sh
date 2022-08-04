cd clearcut || true
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install clearcut "${PREFIX}/bin/"
