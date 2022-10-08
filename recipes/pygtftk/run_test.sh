# Stop on first error
set -e

gtftk -h

cd /tmp
mkdir -p gtftk_test
cd gtftk_test
a=`python -c "import os,pygtftk; print(os.path.dirname(pygtftk.__file__))"`
cd $a
for i in `find . -name "*.py" | perl -ne  'print unless(/(gtf_interface.py)|(fasta_interface.py)|(setup)|(plugin)|(bwig)|(libgtftk.py)|(__)/)'`
do 
	echo "================="
	echo $i
	nosetests --with-doctest $i
done

## bats tests skipped to save biconda CI resources.
#gtftk -p > gtftk_test.bats
#bats -t gtftk_test.bats
#rm -f gtftk_test.bats
