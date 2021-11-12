#!/bin/bash

make CXX="${CXX}" all
PREFIX=$PREFIX/bin make install
