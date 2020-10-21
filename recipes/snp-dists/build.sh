#!/bin/bash

mkdir -p "${PREFIX}/bin"
LIBS="${LDFLAGS}" make CC="${CC}" PREFIX="${PREFIX}" install
