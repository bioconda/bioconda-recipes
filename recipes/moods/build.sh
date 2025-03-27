#!/bin/bash
cat > setup.py.patch << EOF
--- a/setup.py
+++ b/setup.py
@@ -4,7 +4,7 @@ from setuptools import setup, Extension
 from os import path

 common_includes = ["core/"]
-common_compile_args = ['-O3', '-fPIC', '--std=c++11']
+common_compile_args = ['-mtune=generic', '-O3', '-fPIC', '--std=c++14']

 tools_mod = Extension('MOODS._tools',
                            sources=['core/tools_wrap.cxx',
EOF
patch setup.py setup.py.patch
rm setup.py.patch
${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir
