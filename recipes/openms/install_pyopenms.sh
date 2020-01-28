#!/bin/bash
# TODO actually it would be better if we could adapt our MANIFEST.in
# to not package the openms libs and dependencies again. Same for share.
pushd build
cmake -DPYOPENMS=ON .
make -j${CPU_COUNT} pyopenms
pushd pyOpenMS
$PYTHON -m pip install . --ignore-installed --no-deps
popd
popd
