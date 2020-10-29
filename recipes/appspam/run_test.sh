# basic execution
appspam -h
t0=$(echo $?)

#verify that jplace can be computed 
appspam -s test/ref.fasta -t test/tree.nwk -q test/query.fasta -o test/out.jplace
test -f test/out.jplace
t1=$(echo $?)

#remove tests outputs
rm -f test/out.jplace

#both test successful ?
if [[ $t0 == 0 && $t1 == 0 ]]
  then
    echo "All tests successful !" ;
    exit 0
  else
    echo "Test failed"
    if [[ $t0 != 0 ]]; then echo "launch = failed"; fi
    if [[ $t1 != 0 ]]; then echo "placement = failed"; fi
    exit 1
fi
