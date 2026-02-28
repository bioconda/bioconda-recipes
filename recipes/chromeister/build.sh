#!/bin/bash

make -C src/ all

cp -r bin/ "$PREFIX"
