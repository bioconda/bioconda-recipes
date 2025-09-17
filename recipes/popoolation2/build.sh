#!/bin/bash

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${PREFIX}/bin ${outdir}

chmod +x *.pl export/*.pl indel_filtering/*.pl
cp -R *.pl export Modules indel_filtering ${PREFIX}/bin
cp mpileup2sync.jar ${outdir}
cp ${RECIPE_DIR}/mpileup2sync.py ${outdir}/mpileup2sync

ln -s ${outdir}/mpileup2sync ${PREFIX}/bin

for f in cmh2gwas.pl  pwc2igv.pl  subsample_sync2fasta.pl  subsample_sync2GenePop.pl
  do 
      ln -s ${PREFIX}/bin/export/${f} ${PREFIX}/bin
done

for f in filter-sync-by-gtf.pl  identify-indel-regions.pl
    do
      ln -s ${PREFIX}/bin/indel_filtering/${f} ${PREFIX}/bin
done
