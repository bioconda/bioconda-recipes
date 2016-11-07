#!/bin/bash

# works with xerces-c 3.1.2/xsd and boost 1.60, not with xerces-x 3.1.4
# export LD_LIBRARY_PATH=/opt/conda/lib # necessary to actually run!
cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DXML_SUPPORT=ON -DCMAKE_PREFIX_PATH="$PREFIX;$PREFIX/lib" .
make && make install

cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX -DBOOST_LIBRARYDIR=$PREFIX/lib -DSERIALIZE="TokyoCabinet" -DCMAKE_PREFIX_PATH=$PREFIX ./src/converters
make && make install
