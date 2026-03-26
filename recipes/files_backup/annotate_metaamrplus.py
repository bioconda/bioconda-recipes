#!/usr/bin/env python3
import sys

VERSION = "1.4"

if len(sys.argv) != 3:
    sys.stderr.write(
        "MetaAMRplus annotate script v%s\n"
        "Usage: annotate_metaamrplus.py blast.filtered.tsv idmap.tsv\n" % VERSION
    )
    sys.exit(1)

blast_file = sys.argv[1]
idmap_file = sys.argv[2]

# -----------------------------
# Metal keywords & gene systems
# -----------------------------
METAL_KEYWORDS = [
    "copper", "silver", "arsenic", "mercury", "cadmium",
    "zinc", "nickel", "cobalt", "chromium", "lead",
    "iron", "manganese", "multimetal", "biocide"
]

METAL_GENE_PREFIXES = (
    "pco", "sil", "cus", "ars", "mer", "cop",
    "czc", "znt", "nik", "rcn", "chr"
)

# -----------------------------
# Load ID map
# -----------------------------
idmap = {}
with open(idmap_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            acc, meta = line.split("\t", 1)
            idmap[acc.strip()] = meta.strip()
        except ValueError:
            continue

# -----------------------------
# Output header
# -----------------------------
print("\t".join([
    "query_protein",
    "metaamrplus_id",
    "gene",
    "type",
    "phenotype",
    "mechanism",
    "source",
    "pident",
    "coverage",
    "bitscore"
]))

# -----------------------------
# Process BLAST hits
# -----------------------------
with open(blast_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        cols = line.split("\t")
        if len(cols) < 7:
            continue

        qseqid, sseqid, pident, length, qlen, evalue, bitscore = cols

        try:
            coverage = round((float(length) / float(qlen)) * 100, 2)
            if coverage > 100:
                coverage = 100.0
        except Exception:
            coverage = "NA"

        meta = idmap.get(sseqid.strip(), "NA")

        meta_dict = {}
        if meta != "NA":
            for item in meta.split("|"):
                if "=" in item:
                    k, v = item.split("=", 1)
                    meta_dict[k.strip()] = v.strip()

        gene = meta_dict.get("gene", "NA")
        gene_type = meta_dict.get("type", "NA")
        phenotype = meta_dict.get("phenotype", "NA")
        mechanism = meta_dict.get("mechanism", "NA")
        source = meta_dict.get("source", "NA")

        # -----------------------------
        # CRITICAL FIX: metal override
        # -----------------------------
        is_metal = False

        if phenotype != "NA":
            for kw in METAL_KEYWORDS:
                if kw in phenotype.lower():
                    is_metal = True
                    break

        if gene != "NA":
            for prefix in METAL_GENE_PREFIXES:
                if gene.lower().startswith(prefix):
                    is_metal = True
                    break

        if is_metal:
            gene_type = "metal"

        print("\t".join([
            qseqid,
            sseqid,
            gene,
            gene_type,
            phenotype,
            mechanism,
            source,
            pident,
            str(coverage),
            bitscore
        ]))

