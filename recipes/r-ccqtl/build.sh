export DISABLE_AUTOBREW=1

${R} CMD INSTALL --build . ${R_ARGS}


cp ${SRC_DIR}/inst/scripts/ccqtl $PREFIX/bin
chmod +x $PREFIX/bin/ccqtl