suppressPackageStartupMessages(library(Teddy))

stopifnot(is.function(Teddy::annotateTEPosition))

gtf <- GenomicRanges::GRanges(
  "chr1",
  IRanges::IRanges(c(100, 300, 500, 1000, 1200, 1400), width = 100),
  strand = rep(c("+", "-"), each = 3),
  type = "exon",
  transcript_id = rep(c("plus", "minus"), each = 3),
  tx_exon_rank = c(1L, 2L, 3L, 3L, 2L, 1L),
  TE_name = c("p5,antisense", "pi", "p3", "m3", "mi", "m5")
)
te <- GenomicRanges::GRanges(
  "chr1",
  IRanges::IRanges(c(100, 330, 580, 1000, 1230, 1480, 100), width = 20),
  strand = c(rep("+", 3), rep("-", 4)),
  names = c("p5", "pi", "p3", "m3", "mi", "m5", "antisense"),
  class = "LTR",
  family = "ERVL"
)

out <- Teddy::annotateTEPosition(gtf, te, gtf = gtf)
stopifnot(
  length(out) == 6L,
  !"antisense" %in% out$TE_name,
  all(is.na(out$TE_position)),
  all(is.na(out$TE_boundary)),
  all(out$overlap_bp == 20L),
  all(out$overlap_fraction_exon == 0.2),
  all(out$overlap_fraction_TE == 1),
  all(out$TE_family == "ERVL"),
  length(Teddy::annotateTEPosition(gtf, te, gtf = gtf, minoverlap = 21L)) == 0L
)

out <- Teddy::annotateTEPosition(gtf, te, gtf = gtf, boundary_tolerance = 0L)
out <- out[match(c("p5", "pi", "p3", "m5", "mi", "m3"), out$TE_name)]
stopifnot(
  identical(out$TE_category, rep(c("TE-initiated", "TE-exonized", "TE-terminated"), 2)),
  identical(out$TE_position, rep(c("5prime", "internal", "3prime"), 2)),
  identical(out$TE_boundary, rep(c("TE-associated-initiation", "TE-internal", "TE-associated-termination"), 2))
)
