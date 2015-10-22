#!/bin/bash

cp -r bin include jre lib $PREFIX

# TODO the following, more self-contained approach does currently
# not work because the .so files are not found
#dir=$PREFIX/lib/java-jdk
#mkdir -p $dir
#cp -r * $dir
#ln -s $dir/jre/lib/amd64 $PREFIX/lib/java
#
#cd bin
#for cmd in *
#do
#    s="$PREFIX/bin/$cmd"
#	cmd="$PREFIX/lib/java-jdk/bin/$cmd"
#    echo "#!/bin/bash" > $s
#    echo "$cmd $@" >> $s
#    chmod +x $s
#	chmod +x $cmd
#done
