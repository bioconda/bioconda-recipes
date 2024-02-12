#!/bin/bash

ZDB="${PKG_NAME}-${PKG_VERSION}"
ZDB_DIR="${PREFIX}/share/${ZDB}"

mkdir -p ${PREFIX}/bin ${ZDB_DIR}

sed "s=version=$PKG_VERSION=" bin/zdb > ${PREFIX}/bin/zdb

chmod u+x ${PREFIX}/bin/zdb

mv bin/ annotation_pipeline.nf zdb_base nextflow.config db_setup.nf zdb/ conda/ webapp FAQ.txt README.md ${ZDB_DIR}
