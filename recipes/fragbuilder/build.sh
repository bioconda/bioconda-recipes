#!/bin/bash

#export PYTHONPATH=${PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}
#cp -r fragbuilder  ${PREFIX}/lib/python2.7/site-packages/

#wget https://codeload.github.com/jensengroup/fragbuilder/tar.gz/1.0.1
export PYTHONPATH=${PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}
#cp -r ${PREFIX}/fragbuilder  ${PREFIX}/lib/python2.7/site-packages/

#curl -OL https://github.com/jensengroup/fragbuilder/archive/1.0.1.tar.gz/fragbuilder-1.0.1.tar.gz

#tar -xvzf fragbuilder-1.0.1.tar.gz

#ls $SRC_DIR


cp -r $SRC_DIR/fragbuilder ${PREFIX}/lib/python2.7/site-packages/


#python -m site 

#ls ${PREFIX}/conda-meta/history
