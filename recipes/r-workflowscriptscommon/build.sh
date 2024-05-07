#!/bin/bash

export LC_ALL=en_US.UTF-8

${R} CMD INSTALL --build . ${R_ARGS}
