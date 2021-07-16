#!/bin/bash
# TODO actually it would be better if we could adapt our MANIFEST.in
# to not package the openms libs and dependencies again. Same for share.
pushd build

# Split in more modules to reduce memory usage (default=8), stay on serial compilation (default PY_NUM_THREADS=1)
cmake -DPYOPENMS=ON -DPY_NUM_MODULES=8 .
# Unfortunately if we would call make, it thinks that OpenMS lib is not built since the build folder
# might have been copied, so it rebuilds. Skip this by using setup.py directly.
# TODO check that it actually uses the prebuilt libOpenMS from the prefix.
#make -j${CPU_COUNT} pyopenms
pushd pyOpenMS
ulimit -v 128000
$PYTHON create_cpp_extension.py
$PYTHON -m pip install . --ignore-installed --no-deps --global-option="--single-threaded"
ulimit -v unlimited
popd
popd
