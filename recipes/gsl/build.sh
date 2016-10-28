if [[ "$(uname)" == "Darwin" ]]; then
  # CC=clang otherwise:
  # error: ambiguous instructions require an explicit suffix
  # (could be 'filds', or 'fildl')
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66509
  export CC=clang
fi

./configure --prefix=$PREFIX --with-pic

make -j ${CPU_COUNT}
make check || true
make install
