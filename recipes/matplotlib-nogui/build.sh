#!/bin/bash

cat <<EOF > setup.cfg
[directories]
basedirlist = $PREFIX

[packages]
tests = False
sample_data = False
toolkits = False

[gui_support]
agg = True
cairo = False
gtk = False
gtk3agg = False
gtk3cairo = False
gtkagg = False
macosx = False
pyside = True
qt4agg = False
tkagg = False
windowing = False
wxagg = auto

[rc_options]
backend = Agg

EOF

export CPLUS_INCLUDE_PATH="$PREFIX/include"

$PYTHON setup.py install --single-version-externally-managed
