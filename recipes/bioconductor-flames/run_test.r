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
    print(pipeline@last_error)
    cli::cli_abort("Found errors during first SingleCellPipeline in run_test.r, please debug before finalizing new bioconda package version.")
}

# Also test BLAZE as an alternative demultiplexer
outdir2 <- tempfile()
pipeline2 <- SingleCellPipeline(
  # use the default configs
  config_file = create_config(
    outdir2,
    # turn to FALSE later, once the test case data is sufficient for the internal scripts: https://github.com/bioconda/bioconda-recipes/pull/68065#issuecomment-5340208383
    pipeline_parameters.bambu_isoform_identification = TRUE,
    pipeline_parameters.demultiplexer = "BLAZE",
    pipeline_parameters.oarfish_quantification = FALSE
  ),
  expect_cell_number = 100,
  outdir = outdir2,
  # the input fastq file
  fastq = system.file("extdata", "fastq", "musc_rps24.fastq.gz", package = "FLAMES"),
  # reference annotation file
  annotation = system.file("extdata", "rps24.gtf.gz", package = "FLAMES"),
  genome_fa = genome_fa
) 
pipeline2@controllers <- list(default = crew::crew_controller_local()) # also test if the crew controller works

pipeline2 <- run_FLAMES(pipeline2)
pipeline2
if (length(pipeline2@last_error) > 0) {
    print(pipeline2@last_error)
    print(pipeline2@controllers[["default"]]$error)
    cli::cli_abort("Found errors during second SingleCellPipeline (with BLAZE) in run_test.r, please debug before finalizing new bioconda package version.")
}

