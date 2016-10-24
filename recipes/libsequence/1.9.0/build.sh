#!/bin/bash

ls
./configure --prefix=$PREFIX
make
make install

