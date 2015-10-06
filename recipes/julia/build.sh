#!/bin/sh
make -j --
env PREFIX=$PREFIX prefix=$PREFIX make install
