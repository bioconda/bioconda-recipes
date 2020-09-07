#!/bin/bash

make prefix="${PREFIX}" install

cp -r scripts "${PREFIX}/bin/"
