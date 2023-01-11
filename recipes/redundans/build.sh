#!/bin/bash

#source <(curl -Ls http://bit.ly/redundans_installer)
#cd ..
if [ ! -d "$PREFIX/opt" ] ; then
	mkdir "$PREFIX/opt"
fi

export https_proxy="http://in:3128"
export http_proxy="http://in:3128"
export ftp_proxy="http://in:3128"

cd $PREFIX/opt/
source <(curl -Ls http://bit.ly/redundans_installer)
ln -s "$PREFIX/opt/redundans/redundans.py" "$PREFIX/bin/redundans.py"

NEW_SRC=`cat "$PREFIX/opt/redundans/redundans.py" | grep -e "^src" | sed -e "s%bin%$PREFIX/opt/redundans/bin%g" | sed -e "s/\"/\'/g"`
cp "$PREFIX/opt/redundans/redundans.py" "$PREFIX/opt/redundans/redundans.py-backup"
sed -i "s|^src.*|$NEW_SRC|" "$PREFIX/opt/redundans/redundans.py"
sed -i "s|sspacebin = os.path.join(root.*bin/SSPACE/SSPACE_Standard_v3.0.pl.*|sspacebin = os.path.join('$PREFIX/opt/redundans/bin/SSPACE/SSPACE_Standard_v3.0.pl')|" "$PREFIX/opt/redundans/redundans.py"

