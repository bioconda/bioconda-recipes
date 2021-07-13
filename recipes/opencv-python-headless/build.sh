#!/bin/bash
if [ `uname` == Darwin ]; then
    pip install https://files.pythonhosted.org/packages/4a/c3/6a2cf67067e6d8c5aadb7cbae891a774cfc9e63ef35f7e8e74fa6636a9ef/opencv_python_headless-4.5.1.48-cp37-cp37m-macosx_10_13_x86_64.whl
fi

if [ `uname` == Linux ]; then
    pip install https://files.pythonhosted.org/packages/6d/6d/92f377bece9b0ec9c893081dbe073a65b38d7ac12ef572b8f70554d08760/opencv_python_headless-4.5.1.48-cp37-cp37m-manylinux2014_x86_64.whl
fi