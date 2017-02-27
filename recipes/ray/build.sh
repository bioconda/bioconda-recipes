#!/bin/bash

mkdir -p $PREFIX/bin
make PREFIX=$PREFIX/bin MPICXX=$PREFIX/bin
make install