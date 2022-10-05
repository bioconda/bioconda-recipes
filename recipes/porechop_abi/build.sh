#!/bin/bash
echo "[P_ABI build.sh]: Using c++17."
export CXXFLAGS="${CXXFLAGS} -std=c++17 -D_LIBCPP_DISABLE_AVAILABILITY "
echo ${CXX}
echo ${PREFIX}
echo ${CXXFLAGS}
# make release
echo "[P_ABI build.sh]: Using pip to build porechop_abi."
python3 -m pip install . --ignore-installed --no-deps -vv
