#!/usr/bin/env python3
"""
Test that Snakemake workflow files are properly installed.
"""
import sys
from pathlib import Path


def test_snakemake_files():
    """Verify critical Snakemake workflow files exist."""
    try:
        # Import to get package location
        import alleleflux
        from alleleflux.workflow import get_snakefile, get_template_path

        # Test 1: Main Snakefile exists
        snakefile = get_snakefile()
        assert snakefile.exists(), f"Snakefile not found at {snakefile}"
        print(f"✓ Snakefile found: {snakefile}")

        # Test 2: Config template exists
        template = get_template_path()
        assert template.exists(), f"Config template not found at {template}"
        print(f"✓ Config template found: {template}")

        # Test 3: Workflow directory structure
        package_dir = Path(alleleflux.__file__).parent
        workflow_dir = package_dir / "smk_workflow"
        assert workflow_dir.exists(), f"Workflow directory not found at {workflow_dir}"
        print(f"✓ Workflow directory found: {workflow_dir}")

        # Test 4: Key workflow files
        required_files = [
            "smk_workflow/alleleflux_pipeline/Snakefile",
            "smk_workflow/config.template.yml",
            "smk_workflow/slurm_profile/config.yaml",
            # Shared modules
            "smk_workflow/alleleflux_pipeline/shared/common.smk",
            "smk_workflow/alleleflux_pipeline/shared/dynamic_targets.smk",
            # Core pipeline rules
            "smk_workflow/alleleflux_pipeline/rules/metadata.smk",
            "smk_workflow/alleleflux_pipeline/rules/profiling.smk",
            "smk_workflow/alleleflux_pipeline/rules/quality_control.smk",
            "smk_workflow/alleleflux_pipeline/rules/eligibility.smk",
            "smk_workflow/alleleflux_pipeline/rules/allele_analysis.smk",
            "smk_workflow/alleleflux_pipeline/rules/gene_analysis.smk",
            "smk_workflow/alleleflux_pipeline/rules/scoring.smk",
            "smk_workflow/alleleflux_pipeline/rules/p_value_summary.smk",
            "smk_workflow/alleleflux_pipeline/rules/dnds_analysis.smk",
            # Accessory workflow rules
            "smk_workflow/accessory/coverage_and_allele_stats.smk",
            # Visualization workflow rules
            "smk_workflow/visualization/visualization.smk",
            "smk_workflow/visualization/visualization_config.yaml",
            "smk_workflow/visualization/smks/metadata_prep.smk",
            "smk_workflow/visualization/smks/analysis.smk",
            "smk_workflow/visualization/smks/plotting.smk",
        ]

        for rel_path in required_files:
            file_path = package_dir / rel_path
            assert file_path.exists(), f"Required file not found: {file_path}"
            print(f"✓ Found: {rel_path}")

        print("\n✅ All Snakemake workflow files are properly installed!")
        return 0

    except Exception as e:
        print(f"\n❌ Test failed: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(test_snakemake_files())
