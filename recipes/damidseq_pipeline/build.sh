sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' damidseq_pipeline gatc.track.maker.pl gff2tdf.pl
chmod +x gatc.track.maker.pl gff2tdf.pl
cp gatc.track.maker.pl gff2tdf.pl damidseq_pipeline $PREFIX/bin
