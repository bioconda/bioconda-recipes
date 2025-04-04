#!/bin/bash

export MUGSY_INSTALL=${PREFIX}/bin
mugsy -h | grep mugsy > /dev/null
mugsyWGA  --version
synchain-mugsy 2>&1 | grep mugsy > /dev/null
