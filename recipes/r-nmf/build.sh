#!/bin/bash
set -e
export DISABLE_AUTOBREW=1
${R} CMD INSTALL --build .
