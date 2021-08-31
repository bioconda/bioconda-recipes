#!/bin/bash

make

mkdir -p ${PREFIX}/bin
cp shark ${PREFIX}/bin
