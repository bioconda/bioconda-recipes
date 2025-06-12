mkdir -p $PREFIX/bin

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

if [ "$(uname)" = 'Darwin' ] ; then
  mkdir -p $PREFIX/etc/conda/activate.d
  echo "export OLD_DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/activate.d/env_vars.sh
  echo "export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$PREFIX/lib" >> $PREFIX/etc/conda/activate.d/env_vars.sh
  mkdir -p $PREFIX/etc/conda/deactivate.d
  echo "export DYLD_LIBRARY_PATH=$OLD_DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/deactivate.d/env_vars.sh

  echo "setenv OLD_DYLD_LIBRARY_PATH $DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/activate.d/env_vars.csh
  echo "setenv DYLD_LIBRARY_PATH $DYLD_LIBRARY_PATH:$PREFIX/lib" >> $PREFIX/etc/conda/activate.d/env_vars.csh
  echo "setenv DYLD_LIBRARY_PATH $OLD_DYLD_LIBRARY_PATH" >> $PREFIX/etc/conda/deactivate.d/env_vars.csh
fi

