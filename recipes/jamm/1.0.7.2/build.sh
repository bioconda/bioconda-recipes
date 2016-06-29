#!/bin/bash

mkdir -p ${PREFIX}/bin
chmod +x *.sh
cp {*.sh,*.pl,*.r} ${PREFIX}/bin
