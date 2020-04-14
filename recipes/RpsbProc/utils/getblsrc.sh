#!/bin/bash
set -euo pipefail
script_name="${0##\/}"



BLAST_FTP="https://ftp.ncbi.nih.gov/blast/executables/LATEST"
SRCTARBALL='\-src\.tar\.gz$'


dst_dir=

usage ()
{
	local xcode=0
	while (( $# ))
	do
		echo "Error: $1" 1<&2
		xcode=255
		shift
	done
	cat <<EOF 1>&2
Obtain the lastest blast toolkit source code

Usage:
$script_name [-d <dst_dir>] [-h]
	-d <dst_dir>:
		If specified, untar the tarball to <dst_dir>. Default to current directory
		
	-h:
		Display this message and exit
EOF
exit $xcode
}

while (( $# ))
do
	cmd="$1"
	shift
	
	case $cmd in
	-d=*)
		dst_dir="${cmd#*=}"
		;;
	-d)
		dst_dir="$1"
		shift
		;;
	-h)
		usage
		;;
	*)
		;;
	esac
		
done

excode=0


if [[ ! -z $dst_dir ]]
then
	mkdir -p -- "${dst_dir}" || excode=$?
	if [[ excode -ne 0 ]]
	then
		echo "Cannot create directory ${dst_dir}" 1>&2
		exit $excode
	fi
	dst_dir="-C ${dst_dir}"
fi

blsrc_flist=( $(curl ${BLAST_FTP}/ 2> /dev/null | sed -E -e 's/^<.*">//' -e 's/<\/a>.*$//' | egrep $SRCTARBALL ) )

ttl_files=${#blsrc_flist[@]}

if [[ ttl_files -eq 0 ]]
then
	echo "Cannot find latest blast source toolkit." 1>&2
	exit 254
fi

##echo "blsrc_flist = ${blsrc_flist[@]}"
srcfn=${blsrc_flist[ttl_files-1]}
wget ${BLAST_FTP}/$srcfn 2> /dev/null || excode=$?

if [[ excode -ne 0 ]]
then
	echo "Unable to get source file ${BLAST_FTP}/$srcfn" 1>&2
	exit $excode
fi

tar -xzf $srcfn ${dst_dir} && rm -rf $srcfn




