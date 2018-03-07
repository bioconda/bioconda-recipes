#!/bin/sh

mkdir -p $PREFIX/bin

cp ./pipelines/KaKsAnalysis $PREFIX/bin
chmod +x $PREFIX/bin/KaKsAnalysis
