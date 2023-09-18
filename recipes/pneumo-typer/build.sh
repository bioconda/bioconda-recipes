#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/pneumo-typer

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}


# Set a executable file for Pneumo-Typer.pl
cat <<END >>${PREFIX}/bin/pneumo-typer
#!/bin/bash
perl ${RM_DIR}/pneumo-typer.pl \$@
END


chmod a+x ${PREFIX}/bin/pneumo-typer
