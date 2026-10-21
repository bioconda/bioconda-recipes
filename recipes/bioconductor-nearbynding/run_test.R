library(nearBynding)

# Exercise both filtering steps in the genome-to-transcript mapping workflow.
gtf <- tempfile(fileext = ".gtf")
chain <- tempfile(fileext = ".chain")
writeLines(c(
    'chr1\ttest\texon\t101\t110\t.\t+\t.\tgene_id "gene1"; transcript_id "tx1";',
    'chr1\ttest\texon\t201\t210\t.\t+\t.\tgene_id "gene1"; transcript_id "tx1";'
), gtf)
GenomeMappingToChainFile(gtf, chain, transcript_list = "tx1", alignment = "hg19")
stopifnot(file.exists(chain), any(grepl("chr1_plus_exome", readLines(chain))))
unlink(c(gtf, chain))
