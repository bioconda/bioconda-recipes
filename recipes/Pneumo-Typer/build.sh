#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/Pneumo-Typer

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}


# Set a executable file for Pneumo-Typer.pl
cat <<END >>${PREFIX}/bin/Pneumo-Typer
#!/bin/bash
perl ${RM_DIR}/Pneumo-Typer.pl \$@
END


chmod a+x ${PREFIX}/bin/Pneumo-Typer
