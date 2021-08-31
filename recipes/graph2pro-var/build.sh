#!/bin/bash

mkdir -p $PREFIX/bin
for i in pyscript/*.py; do chmod 755 ${i}; cp -p ${i} $PREFIX/bin/; done
