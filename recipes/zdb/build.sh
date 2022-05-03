#!/bin/bash

ZDB="${PKG_NAME}-${PKG_VERSION}"
ZDB_DIR="${PREFIX}/share/${ZDB}"

mkdir -p ${PREFIX}/bin ${ZDB_DIR}

cp bin/zdb ${PREFIX}/bin
chmod u+x ${PREFIX}/bin/zdb

mv bin/ nextflow.nf nextflow.config db_setup.nf zdb/ conda/ docs/ FAQ.txt README.md ${ZDB_DIR}
