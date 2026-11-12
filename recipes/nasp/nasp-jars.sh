target_platform=${target_platform:-linux-64}

(
    for nasp_spec in gatk3:GenomeAnalysisTK.jar picard:picard.jar varscan:VarScan.jar trimmomatic:trimmomatic.jar; do
        nasp_name=${nasp_spec#*:}
        nasp_link="$CONDA_PREFIX/bin/$nasp_name"
        [ -L "$nasp_link" ] && [ -f "$nasp_link" ] && continue
        nasp_directory=$(dirname "$(readlink -f "$CONDA_PREFIX/bin/${nasp_spec%%:*}")")
        nasp_target="$nasp_directory/$nasp_name"
        ln -sfn "../${nasp_target#"$CONDA_PREFIX"/}" "$nasp_link"
    done
)
