if [[ $target_platform =~ linux.* ]] || [[ $target_platform == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/PopGenome
  mv * $PREFIX/lib/R/library/PopGenome
fi
