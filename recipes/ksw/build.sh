#!/bin/bash

set -euo pipefail

# These are used ksw's makefile
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

get_submodule () {
    read name git_hash owner repo tarball_hash <<< "$@"
    wget --no-check-certificate "https://github.com/$owner/$repo/archive/$git_hash.tar.gz"
    downloaded_hash=`sha256sum "$git_hash.tar.gz" | tr -s ' ' | cut -d ' ' -f 1`
    if ! [ "$tarball_hash" == "$downloaded_hash" ]; then
        echo "Error: Hash does not match for $owner/$repo: $downloaded_hash != $tarball_hash" >&2
        return 1
    fi
    tar -zxvpf "$git_hash.tar.gz"
    rm -rf "src/$name"
    mv "$repo-$git_hash" "src/$name";
    rm "$git_hash.tar.gz"
}

ksw2_git_hash=$(cat versions/version.ksw2.txt | awk '{print $3}')
echo ksw2_git_hash: $ksw2_git_hash
get_submodule ksw2 ${ksw2_git_hash} lh3 ksw2 ccd8d57cb98c44d79ccbb6b380b91d5ca1e600d44086b821796396354e0b4aad

mkdir -p $PREFIX/bin
make clean
make -j${CPU_COUNT} PKG_VERSION=${PKG_VERSION} 
make PREFIX=${PREFIX}/bin PKG_VERSION=${PKG_VERSION} install
