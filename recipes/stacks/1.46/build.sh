#!/bin/bash

if [[ "$(uname)" == Darwin ]]; then
    # Fix for install_name_tool error:
    #   error: install_name_tool: changing install names or rpaths can't be
    #   redone for: $PREFIX/bin/abyss-overlap (for architecture x86_64) because
    #   larger updated load commands do not fit (the program must be relinked,
    #   and you may need to use -headerpad or -headerpad_max_install_names)
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
fi

export CXXFLAGS="${CXXFLAGS} -std=c++11"

# htslib shipped with stacks-1.46:
# - fix hardcoded prefix
# - set gcc, ar, ranlib binaries
# - add include path (otherwise zlib is not found)
sed -i -e 's:^prefix *= /usr/local:prefix = '"$PREFIX"':; s:^CC *= gcc:CC = '"$CC"':; s:^AR *= ar:AR = '"$AR"':; s:^RANLIB = ranlib:RANLIB = '"$RANLIB"':; s:-I\. :-I\. -I'"$PREFIX"'/include/:' htslib/Makefile 

./configure --prefix="$PREFIX" --enable-bam
make
make install
# copy missing scripts
cp -p scripts/{convert_stacks.pl,extract_interpop_chars.pl} "$PREFIX/bin/"

