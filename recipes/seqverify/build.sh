#!bin/bash
mkdir -p $PREFIX/bin

chmod +x SeqVerify-prerelease/seqverify
cp SeqVerify-prerelease/seqverify $PREFIX/bin
cp SeqVerify-prerelease/seqver_functions.py $PREFIX/bin
cp SeqVerify-prerelease/seqver_transgenes.py $PREFIX/bin
