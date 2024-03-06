#!/bin/bash

# When your run the test, this command is launched
# If dependencies are not correct html is not built
R -e "rmarkdown::render('hicup_reporter.rmd', params=list(summary_file='test_dataset1_2.hicup.bam.HiCUP_summary_report_xRCWhUMSZD_16-13-38_08-09-2022.txt', ditag_lengths_file='test_dataset1_2.ditag_size_distribution_report.txt'), intermediates_dir='./', output_file='test_dataset1_2.hicup.bam.HiCUP_summary_report_xRCWhUMSZD_16-13-38_08-09-2022.html')"

if [ ! -e test_dataset1_2.hicup.bam.HiCUP_summary_report_xRCWhUMSZD_16-13-38_08-09-2022.html ]; then
    echo "FAIL"
    exit 1
else
    echo "PASS"
fi
