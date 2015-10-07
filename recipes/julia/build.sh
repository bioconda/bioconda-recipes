#!/bin/sh
make
env PREFIX=$PREFIX prefix=$PREFIX make install
