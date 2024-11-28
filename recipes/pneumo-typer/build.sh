#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/pneumo-typer
mkdir -p ${RM_DIR}
mkdir -p ${PREFIX}/bin
ls -a
cp -r $SRC_DIR/* ${RM_DIR}
cp build_env_setup.sh ${RM_DIR}
cp conda_build.sh ${RM_DIR}
cp metadata_conda_debug.yaml ${RM_DIR}
# Set a executable file for Pneumo-Typer.pl
cat <<END >>${PREFIX}/bin/pneumo-typer
#!/bin/bash
perl ${RM_DIR}/pneumo-typer.pl \$@
END
# Set a executable file for update_mlstdb_cgmlstdb.pl
cat <<END >>${PREFIX}/bin/update_mlstdb_cgmlstdb
#!/bin/bash
perl ${RM_DIR}/update_mlstdb_cgmlstdb.pl \$@
END

chmod a+x ${PREFIX}/bin/pneumo-typer
chmod a+x ${PREFIX}/bin/update_mlstdb_cgmlstdb
