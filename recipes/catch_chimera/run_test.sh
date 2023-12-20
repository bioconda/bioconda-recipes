# basic execution test, showing help
CATCh_v1.run
t0=$(echo $?)

# do test on small sample
# option _h requires an absolute path
path=`pwd`
CATCh_v1.run _m d _n Sample.names _f Sample.fasta _h $path
t1=$(echo $?)

#both test successful ?
if [[ $t0 == 0 && $t1 == 0 ]]
  then
    echo "All tests successful !" ;
    exit 0
  else
    echo "Test failed"
    if [[ $t0 != 0 ]]; then echo "help = failed"; fi
    if [[ $t1 != 0 ]]; then echo "sample_run = failed"; fi
    exit 1
fi
