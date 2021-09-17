make \
    SRA_PATH=${PREFIX} \
    CC="${CC} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    cc="${cc} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    VERBOSE=1
install -d $PREFIX/bin
install sracat $PREFIX/bin/
