#!/bin/bash

git clone --recursive https://github.com/heathsc/gemBS-rs.git
cd gemBS-rs
make gemBS_config.mk
make install
cp gemBS $PREFIX/bin/
