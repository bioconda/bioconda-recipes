#!/bin/sh

./configure --prefix=$PREFIX && \
make ${CPUS_COUNT} && \
make install
