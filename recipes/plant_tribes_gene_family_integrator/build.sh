#!/bin/sh

mkdir -p $PREFIX/bin

cp ./pipelines/GeneFamilyIntegrator $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyIntegrator
