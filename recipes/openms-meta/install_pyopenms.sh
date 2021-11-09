#!/bin/bash
# TODO actually it would be better if we could adapt our MANIFEST.in
# to not package the openms libs and dependencies again. Same for share.

SWAP_SIZE=6G

# Default swap file

SWAP_FILE=/var/lib/swap
# Checking if swap already exists in ./etc/fstab

fallocate -l "$SWAP_SIZE" "$SWAP_FILE"
chmod 600 "$SWAP_FILE"
mkswap "$SWAP_FILE"
swapon "$SWAP_FILE"


echo '----------------------'
echo 'Checking list of swap'
echo '----------------------'
swapon -s


pushd build
cmake -DPYOPENMS=ON -DPY_NUM_THREADS=1 .
# Unfortunately if we would call make, it thinks that OpenMS lib is not built since the build folder
# might have been copied, so it rebuilds. Skip this by using setup.py directly.
# TODO check that it actually uses the prebuilt libOpenMS from the prefix.
#make -j${CPU_COUNT} pyopenms
pushd pyOpenMS
$PYTHON create_cpp_extension.py
$PYTHON -m pip install . --ignore-installed --no-deps --global-option="--single-threaded"
popd
popd
