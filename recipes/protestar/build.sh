#!/bin/bash
git submodule init
git submodule update
make protestar -j${CPU_COUNT}

