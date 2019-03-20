#!/bin/bash
mkdir -p $PREFIX/bin/irida_uploader
cp -a * ${PREFIX}/bin/irida_uploader
ln -s $PREFIX/bin/irida_uploader/upload_run.py $PREFIX/bin/irida-uploader
chmod +x $PREFIX/bin/irida-uploader
