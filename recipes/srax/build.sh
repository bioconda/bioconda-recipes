#!/bin/bash

set -e

cp -r * ${PREFIX}/bin/
chmod u+rwx $PREFIX/bin/sraXlib/*
chmod u+rwx $PREFIX/bin/*