#!/bin/bash
cmake -DCOMPONENT="Applications" -P build/cmake_install.cmake
command -v readelf >/dev/null 2>&1 && readelf -d ${PREFIX}/bin/OpenMSInfo | grep 'R.*PATH' || echo "Readelf.. skip rpath check"
