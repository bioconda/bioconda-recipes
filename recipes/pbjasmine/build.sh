#!/usr/bin/env bash

mkdir -p "${PREFIX}/"{bin,lib}
cp bin/* "${PREFIX}/bin"
cp lib/* "${PREFIX}/lib"
chmod +x "${PREFIX}"/bin/*
