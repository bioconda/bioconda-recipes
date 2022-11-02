mkdir -p $PREFIX/bin

# Testing
# ls -l "${PREFIX}"/include
# ls -l "${PREFIX}"/lib/

make \
    FC="${FC}" \
    CC="${CC}" \
    INCLUDE="${PREFIX}"/include \
    LIB_DIR="${PREFIX}"/lib/

chmod u+x pcazip
cp pcazip $PREFIX/bin/
chmod u+x pcaunzip
cp pcaunzip $PREFIX/bin/
chmod u+x pczdump
cp pczdump $PREFIX/bin/
chmod u+x genpcz
cp genpcz $PREFIX/bin/

mkdir -p $PREFIX/etc/conda/activate.d                                                                         # [osx]
echo "export OLD_DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/activate.d/env_vars.sh            # [osx]
echo "export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$PREFIX/lib" >> $PREFIX/etc/conda/activate.d/env_vars.sh    # [osx]
mkdir -p $PREFIX/etc/conda/deactivate.d                                                                       # [osx]
echo "export DYLD_LIBRARY_PATH=$OLD_DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/deactivate.d/env_vars.sh          # [osx]

echo "setenv OLD_DYLD_LIBRARY_PATH $DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/activate.d/env_vars.csh           # [osx]
echo "setenv DYLD_LIBRARY_PATH $DYLD_LIBRARY_PATH:$PREFIX/lib" >> $PREFIX/etc/conda/activate.d/env_vars.csh   # [osx]
echo "setenv DYLD_LIBRARY_PATH $OLD_DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/deactivate.d/env_vars.csh         # [osx]
