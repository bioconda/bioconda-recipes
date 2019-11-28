#!/bin/bash

./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make install
