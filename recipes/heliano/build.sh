## check dependencies

dependency_stat=1

gt=`which gt`
if [[ ${gt} == '' ]];then echo "Dependency genometools was not installed!";dependency_stat=0;fi

hmmsearch=`which hmmsearch`
if [[ ${hmmsearch} == '' ]];then echo "Dependency hmmsearch was not installed!";dependency_stat=0;fi

cdhit=`which cd-hit-est`
if [[ ${cdhit} == '' ]];then echo "Dependency cd-hit-est was not installed!";dependency_stat=0;fi

mafft=`which mafft`
if [[ ${mafft} == '' ]];then echo "Dependency mafft was not installed!";dependency_stat=0;fi

blast=`which blastn`
if [[ ${blast} == '' ]];then echo "Dependency blastn was not installed!";dependency_stat=0;fi

bedtools=`which bedtools`
if [[ ${bedtools} == '' ]];then echo "Dependency bedtools was not installed!";dependency_stat=0;fi

dialign2=`which dialign2-2`
if [[ ${dialign2} == '' ]];then echo "Dependency dialign2 was not installed!";dependency_stat=0;fi

rnabob=`which rnabob`
if [[ ${rnabob} == '' ]];then echo "Dependency rnabob was not installed!";dependency_stat=0;fi

getorf=`which getorf`
if [[ ${getorf} == '' ]];then echo "Dependency getorf was not installed!";dependency_stat=0;fi

## check R packages
R_path=`which R`
if [[ ${R_path} == '' ]];
then    
	echo "R was not installed!"
	dependency_stat=0
else
	rpack_stat=`Rscript check_rpack.r|grep "installed"`
	echo -e ${rpack_stat}
	if [[ ${rpack_stat} != '' ]];then dependency_stat=0;fi
fi

## check python packages
myPYTHON_PATH=`which python3`
if [[ ${myPYTHON_PATH} == '' ]];
then
	echo "python3 was not installed!"
	dependency_stat=0
else
	pypack_stat=`python3 check_pypack.py|grep "installed"`
	echo -e ${pypack_stat}
	if [[ ${pypack_stat} != '' ]];then dependency_stat=0;fi
fi

## To summary dependecny status
if [[ ${dependency_stat} == 0 ]];
then
	echo "Please make sure that these dependencies installed!"
	exit 0
fi

## set pathes for heliano
SCRIT_DIR_PATH=`pwd`

BCHECK=${SCRIT_DIR_PATH}/heliano_bcheck.R
FISHER=${SCRIT_DIR_PATH}/heliano_fisher.R
HMMmodel=${SCRIT_DIR_PATH}/RepHel.hmm
Headermodel=${SCRIT_DIR_PATH}/tclcv.txt
SPLIT=${SCRIT_DIR_PATH}/SplitJoint.R
SORT=${SCRIT_DIR_PATH}/Sort.sh

cp heliano.py heliano

sed -i "s|_INTERPRETERPYTHON_PATH_|${myPYTHON_PATH}|" heliano

sed -i "s|_HMM_|${HMMmodel}|" heliano

sed -i "s|_HEADER_|${Headermodel}|" heliano

sed -i "s|_FISHER_|${FISHER}|" heliano

sed -i "s|_BOUNDARY_|${BCHECK}|" heliano

sed -i "s|_SPLIT_JOINT_|${SPLIT}|" heliano

sed -i "s|_SORTPRO_|${SORT}|" heliano

chmod 755 heliano

## set pathes for heliano_cons

cp heliano_cons.py heliano_cons
sed -i "s|_INTERPRETERPYTHON_PATH_|${myPYTHON_PATH}|" heliano_cons
chmod 755 heliano_cons

if [ ! -d "bin" ];then mkdir bin;fi
mv heliano heliano_cons bin/

echo "Succeed! Please find programs in bin/ directory."
