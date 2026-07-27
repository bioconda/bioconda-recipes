"""Smoke test run by the conda package test phase.

Exercises the compiled Rust extension end to end rather than only importing it,
so a package that imports but cannot execute a query fails the build.
"""

import polars as pl

import polars_bio as pb


def test_overlap_finds_expected_pairs():
    df1 = pl.DataFrame(
        {
            "chrom": ["chr1", "chr1", "chr2"],
            "start": [100, 500, 100],
            "end": [200, 600, 200],
        }
    )
    df2 = pl.DataFrame(
        {
            "chrom": ["chr1", "chr2"],
            "start": [150, 900],
            "end": [250, 1000],
        }
    )

    # Setting this explicitly keeps the test independent of the global
    # coordinate-system default, and confirms the polars-config-meta
    # dependency is wired up.
    df1.config_meta.set(coordinate_system_zero_based=False)
    df2.config_meta.set(coordinate_system_zero_based=False)

    result = pb.overlap(df1, df2, output_type="polars.DataFrame")

    # chr1:100-200 overlaps chr1:150-250. chr1:500-600 has no partner, and the
    # chr2 intervals are disjoint, so exactly one pair is expected.
    assert result.height == 1, result

    row = result.row(0, named=True)
    assert row["chrom_1"] == "chr1"
    assert row["start_1"] == 100
    assert row["chrom_2"] == "chr1"
    assert row["start_2"] == 150
