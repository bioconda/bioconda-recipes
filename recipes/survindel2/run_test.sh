mkdir workdir
survindel2.py demo/reads.bam workdir/ demo/ref.fa
n=`bcftools view -H workdir/out.pass.vcf.gz | wc -l`
if [[ $n -ne 2 ]]; then
	exit 1
fi

survindel2.py -h

exit 0
