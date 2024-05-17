#! /bin/bash

APPROOT=$PREFIX/opt/$PKG_NAME

mkdir -p $APPROOT

bundle install && \
    bundle exec rake install && \
    bundle exec rake clobber


sed -i '1s|^.*$|#! /usr/bin/env ruby|' $PREFIX/share/rubygems/bin/excel2xml_dra
sed -i '1s|^.*$|#! /usr/bin/env ruby|' $PREFIX/share/rubygems/bin/excel2xml_jga
sed -i '1s|^.*$|#! /usr/bin/env ruby|' $PREFIX/share/rubygems/bin/submission-excel2xml
sed -i '1s|^.*$|#! /usr/bin/env ruby|' $PREFIX/share/rubygems/bin/validate_meta_dra
sed -i '1s|^.*$|#! /usr/bin/env ruby|' $PREFIX/share/rubygems/bin/validate_meta_jga



# Downloading xsd files
# Files will be downloaded to $PREFIX/opt/submission-excel2xml/data
# "submission-excel2xml/data" is hard-coded in the source code.
export XDG_DATA_HOME=$PREFIX/opt
submission-excel2xml download_xsd

# copy sample files
cp -r example/ $APPROOT/


## Set variables on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/${PKG_NAME}.sh
export XDG_DATA_HOME=$PREFIX/opt
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}.sh
unset XDG_DATA_HOME
EOF


