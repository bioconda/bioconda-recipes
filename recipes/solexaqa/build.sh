#!/bin/sh

cd source

make \
    BOOST_PATH="${PREFIX}" \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install SolexaQA++ "${PREFIX}/bin/"
