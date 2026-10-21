library(CHORD)
features <- read.delim("example/output/merged_contexts.txt", check.names = FALSE)
expected <- read.delim("example/output/chord_pred.txt", check.names = FALSE)
actual <- chordPredict(features, verbose = FALSE)
for (column in c("sample", "p_BRCA1", "p_BRCA2", "p_hrd", "hr_status", "hrd_type")) {
    stopifnot(isTRUE(all.equal(actual[[column]], expected[[column]], check.attributes = FALSE)))
}
