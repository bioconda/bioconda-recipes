#!/bin/bash

make CC="${CXX_FOR_BUILD}" all
cp tntblast $PREFIX/bin
