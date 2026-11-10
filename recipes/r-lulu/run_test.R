library(lulu)

# Minimal deterministic functional test for LULU.
#
# OTU1 is the abundant parent.
# OTU2 and OTU3 are less abundant potential daughter OTUs.
# All three occur in both samples, and the two daughter-parent matches
# are comfortably above LULU's default minimum sequence-match threshold.

otutable <- data.frame(
    Sample1 = c(100, 10, 5),
    Sample2 = c(100, 10, 5),
    row.names = c("OTU1", "OTU2", "OTU3"),
    check.names = FALSE
)

# LULU match-list columns:
#   1. potential child OTU ID
#   2. potential parent OTU ID
#   3. sequence identity percentage
matchlist <- data.frame(
    child = c("OTU2", "OTU3"),
    parent = c("OTU1", "OTU1"),
    match = c(99, 98),
    stringsAsFactors = FALSE
)

result <- lulu(
    otutable,
    matchlist,
    minimum_match = 84
)

# The functional call must return the standard LULU result components.
stopifnot(is.list(result))
stopifnot("curated_table" %in% names(result))
stopifnot("curated_count" %in% names(result))
stopifnot("curated_otus" %in% names(result))
stopifnot("discarded_count" %in% names(result))
stopifnot("otu_map" %in% names(result))
stopifnot("original_table" %in% names(result))

# In this deliberately simple example, OTU2 and OTU3 should be merged
# into the consistently more abundant OTU1.
stopifnot(result$curated_count == 1)
stopifnot(result$discarded_count == 2)
stopifnot(identical(as.character(result$curated_otus), "OTU1"))

# Counts from the merged daughters must be retained in the parent:
# Sample1: 100 + 10 + 5 = 115
# Sample2: 100 + 10 + 5 = 115
stopifnot(nrow(result$curated_table) == 1)
stopifnot(as.numeric(result$curated_table["OTU1", "Sample1"]) == 115)
stopifnot(as.numeric(result$curated_table["OTU1", "Sample2"]) == 115)

cat("LULU functional test passed\n")