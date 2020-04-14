#!/bin/bash
#!/bin/bash
set -euo pipefail
script_name="${0##\/}"
LINE_LEN=120
cwd=$(pwd)
extra_prjs=()
blsrc_tree=

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
Embed offline project source into blast toolkit source tree

Usage:
$script_name -h
$script_name -b <blsrc_tree> [extra_proj1 [extra_proj2 [...]]]
	-h:
		Display this message and exit
		
	-b <blsrc_tree>:
		Untarred blast toolkit source tree where the project source(s)
		will be inserted
		
	extra_projn:
		Other untarred CDD projects. Each must contain a 'src' subdirectory
		where the C++ source files are located. $script_name always looks for
		'src' directory in current directory first.
EOF
exit $xcode
}

while (( $# ))
do
	cmd="$1"
	shift
	
	case "$cmd" in
	-h)
		usage
		;;
	-b=*)
		blsrc_tree="${cmd#*-}"
		;;
	-b)
		blsrc_tree="$1"
		shift
		;;
	*)
		if [[ -d "$cmd" && -d "$cmd/src" ]]
		then
			extra_prjs+=("$cmd")
		else
			echo "Warning: Project \"$cmd\" does not exist or is not a valid project source directory"
		fi
		
	esac

done

[[ -z "$blsrc_tree" ]] && usage "Blast toolkit source tree is mandatory"
[[ ! -d "$blsrc_tree" ]] && usage "Blast toolkit source tree \"$blsrc_tree\" does not exist"

appdir=

while read appdir
do
	if [[ -f "$appdir/Makefile.in" ]]
	then
		break
	else
		appdir=
	fi
done < <(find "$blsrc_tree" -type d -name "app")

[[ -z "$appdir" ]] && usage "Cannot locate app directory under \"$blsrc_tree\". Make sure it is a valid blast toolkit source tree"

append_prjs=()
excode=0
if [[ -d "./src" ]]
then
	aprj="${cwd##*\/}"
	append_prjs+=("$aprj")
	mkdir "$appdir/$aprj" || excode=$? 
	if [[ excode -ne 0 ]]
	then
		echo "Unable to create project directory. Make sure the blast toolkit source tree is writable" 1>&2
		exit $excode
	fi
	
	cp -r "./src/"* "$appdir/$aprj/"
	
fi

if [[ ${#extra_prjs[@]} -gt 0 ]]
then
	for exprj in "${extra_prjs[@]}"
	do
		aprj="${exprj##*\/}"
		append_prjs+=("$aprj")
		mkdir "$appdir/$aprj"
		cp -r "$exprj/src/"* "$appdir/$aprj/"
	done
fi

##Addpend projects
mv "$appdir/Makefile.in" "$appdir/Makefile.in.ori"

##break up long line into multiple lines with escaped newline
## $1=width in characters. Lines will not exceed this
##clout=continuous line output
clout()
{
	local w=$1
	local l=0
	local c=0
	shift
	
	while (( $# ))
	do
		ll=${#1}
		if [[ ll+l -gt w ]]
		then
			echo "\\"
			echo -n '    '
			l=4
		fi
		echo -n "$1 "
		(( l += ll+1 )) || :
		shift
	done
	echo
}


while read aline || [[ ! -z $aline ]]
do
	if [[ ! -z "$aline" ]]
	then
		
		lntag=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' <<<"${aline%%=*}")
		lnval=$(sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' -e 's/[ \t]+/ /' <<<"${aline#*=}")
		
		if [[ "$lntag" == "$lnval" ]]	##means no equal sign
		then
			echo "$lntag" >> "$appdir/Makefile.in"
		else
		
			[[ "$lntag" == "SUB_PROJ" ]] && lnval="$lnval ${append_prjs[@]}"
			clout $LINE_LEN ${lntag} '=' $lnval >> "$appdir/Makefile.in"
		fi
		##empty line
		echo>>"$appdir/Makefile.in"
	fi
done < "$appdir/Makefile.in.ori"


