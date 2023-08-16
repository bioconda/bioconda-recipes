#!/bin/bash

./install.sh

install -d ${PREFIX}/tmp
install -t ${PREFIX} *.py ./raxml/ ./epac/ ./examples/ ./tests/

