#!/bin/sh

## Moving SYNY to bin subdir
mkdir -p ${PREFIX}/bin
cp -R * ${PREFIX}/bin/

##### Circos
# DOWN_DIR=${SRC_DIR}/circos
# mkdir -p ${DOWN_DIR}

# wget \
#   --no-check-certificate \
#   https://circos.ca/distribution/circos-0.69-9.tgz \
#   -P $DOWN_DIR \

# TMP_DIR=${SRC_DIR}/tmp
# mkdir -p ${TMP_DIR}
# tar -zxvf $DOWN_DIR/circos-0.69-9.tgz -C ${TMP_DIR}
# cp -r $TMP_DIR/circos-0.69-9/* ${PREFIX}/

##### Text::Roman Perl module
# PERL_LIB=${PREFIX}/perl5
# mkdir -p ${PERL_LIB}
# wget https://cpan.metacpan.org/authors/id/S/SY/SYP/Text-Roman-3.5.tar.gz -P ${SRC_DIR}
# tar -zxvf ${SRC_DIR}/Text-Roman-3.5.tar.gz -C ${PERL_LIB}
# mv ${PERL_LIB}/Text-Roman-3.5/lib/* ${PERL_LIB}
# rm -R ${PERL_LIB}/Text-Roman-3.5*

# mkdir -p ${PREFIX}/etc/conda/activate.d
# cat <<EOF >> ${PREFIX}/etc/conda/activate.d/syny.sh
# export PERL5LIB=$PERL5LIB:$PERL_LIB
# EOF