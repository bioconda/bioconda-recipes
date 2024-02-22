#!/bin/bash
export LDFLAGS="${LDFLAGS} -lstdc++"

$R CMD INSTALL --build .
