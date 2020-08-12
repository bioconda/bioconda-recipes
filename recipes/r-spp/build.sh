export BOOST_ROOT=${PREFIX}
if [[ $(uname) == "Darwin" ]]; then
    export LDFLAGS=-L${PREFIX}/lib
    autoreconf -i
    $R CMD INSTALL --build . --configure-args="CFLAGS=-ferror-limit=0 CXXFLAGS=-ferror-limit=0"
else
    $R CMD INSTALL --build .
fi
