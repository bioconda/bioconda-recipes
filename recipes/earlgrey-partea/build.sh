#!/bin/bash

# Install wrapper scripts to bin/
mkdir -p $PREFIX/bin
install -m 755 earlGreyParTEA $PREFIX/bin/
install -m 755 earlGreyParTEA_LibConstruct $PREFIX/bin/
install -m 755 earlGreyParTEA_AnnotationOnly $PREFIX/bin/

# Install Snakemake workflow to share directory
mkdir -p $PREFIX/share/${PKG_NAME}-${PKG_VERSION}
cp Snakefile $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/
cp -r rules $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/
cp -r scripts $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/
cp -r config $PREFIX/share/${PKG_NAME}-${PKG_VERSION}/
