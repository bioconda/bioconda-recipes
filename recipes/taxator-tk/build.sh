tar -xvf download*

# copying over all necessary files
mkdir -p $PREFIX/bin/
mkdir -p $PREFIX/lib/
mkdir -p $PREFIX/doc/

cp taxator-tk_1.3.3e-64bit/bin/alignments-filter $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/binner $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/fasta-strip-identifier $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/last-merge-batches $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/last_maf_convert.py $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/lz4 $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/taxator $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/taxatortk.py $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/taxknife $PREFIX/bin/
cp taxator-tk_1.3.3e-64bit/bin/taxsummary2krona $PREFIX/bin/

cp taxator-tk_1.3.3e-64bit/lib/* $PREFIX/lib/


