#!/bin/bash

mkdir -p ${PREFIX}/bin

install -m775 MACARON ${PREFIX}/bin/

cp MACARON_validate.sh MACARON_validate

install -m775 MACARON_validate ${PREFIX}/bin/
