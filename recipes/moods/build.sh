#!/bin/bash
cat >setup_compile.patch << EOF
--- setup.py    2018-07-18 09:44:45.000000000 -0700
+++ new_setup.py    2018-07-18 09:46:32.000000000 -0700
@@ -7,7 +7,7 @@
 from distutils.core import setup, Extension
 
 common_includes = ["core/"]
-common_compile_args = ['-march=native', '-O3', '-fPIC', '--std=c++11']
+common_compile_args = ['-mtune=generic', '-O3', '-fPIC', '--std=c++11']
 
 
 tools_mod = Extension('MOODS._tools',
EOF
patch setup.py setup_compile.patch
rm setup_compile.patch
$PYTHON setup.py install --record=record.txt
