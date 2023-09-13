#!/bin/bash

unset CPPFLAGS
make -e
install -d "${PREFIX}/bin"
install vdjer "${PREFIX}/bin/"
