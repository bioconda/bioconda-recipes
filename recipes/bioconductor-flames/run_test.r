library(FLAMES)

outdir <- tempfile()
dir.create(outdir)
# some example data
# known cell barcodes, e.g. from coupled short-read sequencing
bc_allow <- file.path(outdir, "bc_allow.tsv")
R.utils::gunzip(
  filename = system.file("extdata", "bc_allow.tsv.gz", package = "FLAMES"),
  destname = bc_allow, remove = FALSE
)
# reference genome
genome_fa <- file.path(outdir, "rps24.fa")
R.utils::gunzip(
  filename = system.file("extdata", "rps24.fa.gz", package = "FLAMES"),
  destname = genome_fa, remove = FALSE
)

pipeline <- SingleCellPipeline(
  # use the default configs
  config_file = create_config(
    outdir,
    pipeline_parameters.demultiplexer = "flexiplex"
  ),
  outdir = outdir,
  # the input fastq file
  fastq = system.file("extdata", "fastq", "musc_rps24.fastq.gz", package = "FLAMES"),
  # reference annotation file
  annotation = system.file("extdata", "rps24.gtf.gz", package = "FLAMES"),
  genome_fa = genome_fa,
  barcodes_file = bc_allow
)

# try turning all warnings into errors, to get pipeline to properly fail when
# some steps fail --- otherwise the test will simply always pass
options(warn=2)
run_FLAMES(pipeline)