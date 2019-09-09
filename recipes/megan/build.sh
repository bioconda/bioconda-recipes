#!/bin/bash

>&2 which java

# call installer
chmod u+x MEGAN_Community_unix_6_12_3.sh
sed -i "s%# INSTALL4J_JAVA_HOME_OVERRIDE=%INSTALL4J_JAVA_HOME_OVERRIDE=$PREFIX/bin%" MEGAN_Community_unix_6_12_3.sh
MEGAN="$PREFIX/opt/$PKG_NAME-$PKG_VERSION"
./MEGAN_Community_unix_6_12_3.sh -q -dir "$MEGAN"
# link to bin/ and fix paths
# in all scripts bin_dir is defined as: 
# ```
# bin_dir=`dirname "$0"`       # may be relative path
# bin_dir=`cd "$bin_dir" && pwd`    # ensure absolute path
# ```
# all other paths (eg to jars) are defined relative to bin_dir
# of course this does not work when linking/copying
# 
# so we just fix this to the actual file, ie MEGAN/tools/TOOL
find "$MEGAN"/tools -type f | while read -r file
do
	b=$(basename "$file")
	ln -s "$file" "$PREFIX"/bin/"$b"
        sed -i -e "s@\"\$0\"@\"$file\"@" "$file"
#	sed -i -e "s@^bin_dir=.*@bin_dir=\"$MEGAN\/tools\"@" "$file"
done
ln -s "$MEGAN"/MEGAN "$PREFIX"/bin/MEGAN
sed -i -e "s@\"\$0\"@\"$MEGAN/MEGAN\"@" "$MEGAN"/MEGAN
