#!/bin/sh
set -e

# install PLATON via pip
python3 -m pip install . --no-deps --ignore-installed --no-cache-dir

# downloadn, extract and install custom database
wget https://s3.computational.bio.uni-giessen.de/swift/v1/platon/db.tar.gz
tar -xzf db.tar.gz

mkdir -p $PREFIX/db
mv db/* $PREFIX/db/