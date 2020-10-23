#!/bin/bash

make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install fastq-join "${PREFIX}/bin/"
