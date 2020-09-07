make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
cp ir "${PREFIX}/bin/"
