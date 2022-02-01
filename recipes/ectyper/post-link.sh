echo "Downloading and initializing species identification data (NCBI RefSeq MASH sketch and  assembly metadata) ..."
python3 -c "from ectyper.speciesIdentification import get_refseq_mash_and_assembly_summary; get_refseq_mash_and_assembly_summary()"
echo "Initialization completed"
