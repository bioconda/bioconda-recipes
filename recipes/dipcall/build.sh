#! /bin/sh

install -d "${PREFIX}/bin"
install \
  dipcall-aux.js \
  run-dipcall \
  "${PREFIX}/bin/"
