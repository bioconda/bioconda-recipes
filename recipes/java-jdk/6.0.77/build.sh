#/bin/bash -eu

# No Java 6 version for Mac

# clean up
rm -rf release README readme.txt Welcome.html *jli.* demo sample *.zip

    mv lib/amd64/jli/*.so lib
    rm -r lib/amd64

mv * $PREFIX

# more clean up
rm -rf $PREFIX/release $PREFIX/README $PREFIX/Welcome.html
rm -f $PREFIX/DISCLAIMER
rm -f $PREFIX/LICENSE
rm -f $PREFIX/THIRD_PARTY_README
rm -f $PREFIX/ASSEMBLY_EXCEPTION
