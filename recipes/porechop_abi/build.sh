#!/bin/bash
echo "[P_ABI build.sh]: Using c++14."
export CXXFLAGS="${CXXFLAGS} -std=c++14"
# make release
echo "[P_ABI build.sh]: Using pip to build porechop_abi."
python3 -m pip install . --ignore-installed --no-deps -vv
