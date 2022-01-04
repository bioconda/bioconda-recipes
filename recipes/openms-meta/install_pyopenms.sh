#!/bin/bash
# TODO actually it would be better if we could adapt our MANIFEST.in
# to not package the openms libs and dependencies again. Same for share.

pushd build
cmake -DPYOPENMS=ON -DPY_NUM_THREADS=1 -DPY_NUM_MODULES=12 .
# Unfortunately if we would call make, it thinks that OpenMS lib is not built since the build folder
# might have been copied, so it rebuilds. Skip this by using setup.py directly.
# TODO check that it actually uses the prebuilt libOpenMS from the prefix.
#make -j${CPU_COUNT} pyopenms
pushd pyOpenMS
$PYTHON create_cpp_extension.py
# try to separate the extension building from the rest. Let's hope pip install is smart enough to not do it again.
$PYTHON setup.py build_ext -j 1 --single-threaded
$PYTHON -m pip install . --ignore-installed --no-deps
popd
popd
