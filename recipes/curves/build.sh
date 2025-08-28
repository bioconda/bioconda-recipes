#!/usr/bin/env bash

if [[ ${target_platform} =~ osx.* ]]; then
	make FC="${FC}" CC="${FC}" CXX="${CXX}"
else
	make FC="${FC}" CC="${FC}"
fi

chmod u+x Cur+
chmod u+x Canal
chmod u+x Canion
cp Cur+ Canal Canion $PREFIX/bin/

mkdir -p $PREFIX/.curvesplus
cp standard_b.lib $PREFIX/.curvesplus
cp standard_i.lib $PREFIX/.curvesplus
cp standard_s.lib $PREFIX/.curvesplus
