#!/bin/env bash

./configure --prefix=$PREFIX
make libs 
make all install
