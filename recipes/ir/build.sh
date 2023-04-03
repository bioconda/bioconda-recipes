make CC="${CC} -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
cp ir "${PREFIX}/bin/"
