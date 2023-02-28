#!/bin/bash
set -x
set -euo pipefail

tar -xf input_files.tar.gz

cp $CONDA_PREFIX/.curvesplus/* .

# Curves+ executable
Cur+ <<!
&inp 
 file=mABCs1_stride.trj,
 ftop=abctop_nowat.prmtop,
 lis=curout_ions,
 lib=standard,
 line=.t.,
 fit=.t.,
 test=.t.,
 ions=.t.,
&end        
2 1 -1 0 0                                               
1:18 
36:19     
!

test -e curout_ions.cda
test -e curout_ions.cdi
test -e curout_ions.lis

# test Canal executable
Canal <<! 
&inp
  lis=canout,
  series=.t.,
&end
curout_ions.cda GCAACGTGCTATGGAAGC       
!

test -e canout.lis
ls -l
ls | grep canout
ls | grep -c canout
test $(ls | grep -c canout) = 45

# test Canion executable
Canion <<!
&inp
 lis=canionout,
 axfrm=curout_avg,
 dat=curout_ions.cdi,
 solute=mABCs1_avg,
 type=K,
&end
!

test -e canionout.lis
ls -l
ls -l | grep canionout
ls -l | grep -c canionout

test $(ls | grep -c canionout ) = 9
