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

python <- Sys.getenv("BASILISK_CUSTOM_PYTHON_3_11_9") 
modules <- c("pip", "venv")
print(stringr::str_c("Python version: ", reticulate:::python_version(python)))
print(stringr::str_c("Python has modules 'pip' and 'venv': ", reticulate:::python_has_modules(python, modules)))

# print warnings when they occur
options(warn=1)
pipeline <-run_FLAMES(pipeline)
pipeline
# Explicitly throw an error, if any errors were encountered during pipeline
# execution. During the pipeline, they are caught and turned into warnings,
# but turning all warnings into errors will also error genuine warnings that
# occur during the pipeline run. So this seems to be the sanest solution.
if (length(pipeline@last_error) > 0) {
    cli::cli_abort("Found errors during SingleCellPipeline in run_test.r, please debug before finalizing new bioconda package version.")
}

# Also test BLAZE as an alternative demultiplexer
pipeline2 <- example_pipeline("MultiSampleSCPipeline") # or SingleCellPipeline
pipeline2@config$pipeline_parameters$bambu_isoform_identification <- FALSE #
pipeline2@config$pipeline_parameters$oarfish_quantification <- FALSE       #  might as well test the built-in Python scripts
pipeline2@config$pipeline_parameters$demultiplexer <- "BLAZE"
pipeline2@expect_cell_number <- rep(100L, length(pipeline@fastq))
pipeline2@controllers <- list(default = crew::crew_controller_local()) # also test if the crew controller works

pipeline2 <- run_FLAMES(pipeline2)
pipeline2
if (length(pipeline2@last_error) > 0) {
    cli::cli_abort("Found errors during MultiSampleSCPipeline in run_test.r, please debug before finalizing new bioconda package version.")
}

