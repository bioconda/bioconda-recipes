#!/usr/bin/env bash

make \
    F77="${FC}"

chmod u+x Cur+
chmod u+x Canal
chmod u+x Canion
cp Cur+ Canal Canion $PREFIX/bin/

mkdir -p $PREFIX/.curvesplus
cp standard_b.lib $PREFIX/.curvesplus
cp standard_i.lib $PREFIX/.curvesplus
cp standard_s.lib $PREFIX/.curvesplus
