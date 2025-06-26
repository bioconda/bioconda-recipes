#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"
mkdir -p "$SP_DIR/mumemto"
mkdir -p "$PREFIX/share/licenses/$PKG_NAME"

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  "${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"

install -v -m 0755 build/mumemto_exec build/compute_lengths build/newscanNT.x build/extract_mums build/anchor_merge "$PREFIX/bin"
install -v -m 0755 mumemto/mumemto "$PREFIX/bin"
install -v -m 0755 mumemto/*.py "$SP_DIR/mumemto"

cp -f LICENSE $PREFIX/share/licenses/$PKG_NAME/
touch $SP_DIR/mumemto/__init__.py
