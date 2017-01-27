# Makefile, tebsts directory and samples by Catherine Letondal <letondal@pasteur.fr>

test:   testdna testprot testdist testtree

testdna:
	rm -f infile
	ln -s dna.data infile
	make testprog PROGRAM=dnapars
	make testprog PROGRAM=dnaml
	make testprog PROGRAM=dnadist

testprot:
	rm -f infile
	ln -s prot.data infile
	make testprog PROGRAM=protpars
	make testprog PROGRAM=protdist

testdist:
	rm -f infile
	ln -s distance.data infile
	make testprog PROGRAM=neighbor

testtree:
	rm -f intree
	ln -s tree.data intree
	echo 0 > params
	echo l >> params
	echo m >> params
	echo y >> params
	rm -f plotfile
	phylip drawtree < params > drawtree.out
	rm -f plotfile
	phylip drawgram < params > drawgram.out
	rm -f infile plotfile


testprog:
	echo 0 > params
	echo y >> params
	phylip ${PROGRAM} < params > ${PROGRAM}.out
	rm -f outtree outfile

clean:
	rm -f params infile *.out intree outfile outtree *~

