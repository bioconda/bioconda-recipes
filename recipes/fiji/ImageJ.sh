#!/bin/bash
dir=$(dirname $(which ImageJ_bin))
cfg=${dir}/../share/ImageJ.cfg
if [ ! -e ${cfg} ]; then
    echo ".                                                    
jre/bin/java
-Djava.util.prefs.userRoot=${dir}/../uprefs/ -cp ij.jar ij.ImageJ
" > ${cfg}
elif ! grep -q "Djava.util.prefs.userRoot" "${cfg}"; then
    mv ${cfg} ${cfg}.bk
    cat ${cfg}.bk | awk -v prefsuser="${dir}/../uprefs/" 'NR<3{print}NR==3{print "-Djava.util.prefs.userRoot="prefsuser" "$0}' > ${cfg}
fi

$(readlink -n -f ${dir}/ImageJ_bin) --jar-path ${dir}/../share/jars "$@"
