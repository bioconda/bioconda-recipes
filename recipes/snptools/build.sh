#!/usr/bin/env bash

make all CC=$CXX

install bamodel poprob probin impute hapfuse $PREFIX/bin

