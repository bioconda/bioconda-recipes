#!/bin/bash -x
TOOL=wgscoverageplotter
./gradlew $TOOL

OUT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $OUT
mkdir -p $PREFIX/bin
cp dist/$TOOL.jar $OUT/

cat <<END >$PREFIX/bin/${TOOL}.sh
#!/bin/bash
# Wraps wgscoverageplotter.jar
set -o pipefail

# extract memory and system property Java arguments from the list of provided arguments
# http://java.dzone.com/articles/better-java-shell-script
default_jvm_mem_opts="-Xms512m -Xmx1g"
jvm_mem_opts=""
jvm_prop_opts=""
pass_args=""
for arg in "\$@"; do
    case \$arg in
        '-D'*)
            jvm_prop_opts="\$jvm_prop_opts $arg"
            ;;
        '-XX'*)
            jvm_prop_opts="\$jvm_prop_opts $arg"
            ;;
         '-Xm'*)
            jvm_mem_opts="\$jvm_mem_opts $arg"
            ;;
         *)
            pass_args="\$pass_args \$arg"
            ;;
    esac
done

if [ "\$jvm_mem_opts" == "" ] && [ -z \${_JAVA_OPTIONS+x} ]; then
    jvm_mem_opts="\$default_jvm_mem_opts"
fi

java=\$(which java)
pass_arr=(\$pass_args)
if [[ \${pass_arr[0]} == org* ]]
then
    eval "\$java" $\jvm_mem_opts $\jvm_prop_opts -cp "$OUT/${TOOL}.jar" \$pass_args
else
    eval "\$java" $\jvm_mem_opts $\jvm_prop_opts -jar "$OUT/${TOOL}.jar" \$pass_args
fi
exit
END
chmod a+x $PREFIX/bin/${TOOL}.sh
