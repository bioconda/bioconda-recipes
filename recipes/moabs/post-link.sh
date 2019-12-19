#!/bin/bash

function cmd {
local f=$PREFIX/bin/$1
local url=$2
local sha256=$3
wget -q -O "$f" "$url"

SUCCESS=0
os=$(uname -s)
if [ "$os" == "Linux" ]
then
	shash=$(sha256sum "$f" | cut -f 1 -d ' ')
	if [ "$shash" == "$sha256" ]
	then
		SUCCESS=1
	fi
elif [ "$os" == "Darwin" ]
then
	shash=$(shasum -a 256 "$f" | cut -f 1 -d ' ')
	if [ "$shash" == "$sha256" ]
	then
		SUCCESS=1
	fi
fi

if [ $SUCCESS != 1 ]
then
	echo "ERROR: post-link.sh was unable to download $f with the sha256 $sha256 from $url at $os." >> "$PREFIX/.messages.txt"
	exit -1
fi
}

cmd lut_fet.dat 'https://ndownloader.figshare.com/files/16527371?private_link=44c546b05dd9fa0aee3d' 2f9099e79d6a23764b51220362634acd7412a025464001717ae58acca24a8eb3
cmd lut_pdiffCI.dat 'https://ndownloader.figshare.com/files/16527389?private_link=44c546b05dd9fa0aee3d' 98cd92911c9a73267129cb010b1186db7cd248267b58614cc836f78db331902f
cmd lut_pdiffInRegion.dat 'https://ndownloader.figshare.com/files/16527443?private_link=44c546b05dd9fa0aee3d' 6410f059842c11dc62e9452f36f6869edda25d44afc2bd51f9b495c4c3c128e4

