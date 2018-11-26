(cd src && \
bash configure --exec_prefix=$PREFIX/bin --table_dir=$PREFIX/share/spaln/table --alndbs_dir=$PREFIX/share/spaln/alndbs --use_zlib=0 && \
make AR="${AR:-ar} rc" && make install)

(cd perl && perl Makefile.PL && \
sed -i -s '1s^#!/usr/bin/perl^#!/usr/bin/env perl^' *.pl && make && make install && chmod u+w $PREFIX/bin/*.pl
)
