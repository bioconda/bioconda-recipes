##07/29/2019
##@@author: Simon (Chong) Chu, DBMI, Harvard Medical School
##@@contact: chong_chu@hms.harvard.edu

#Build workflows for different types of sequencing data (or hybrid)
#####1. combine different modules for different types of data
#####2. Module the code in "gnrt_pipeline_xxx.py" (merge the four scripts to one)

#To-do-list: 1. Build workflows for different sequencing data (Illumina, 10X, long reads or hybrid data)
#            2. Build workflows for different type of reference genomes (human)
#            3. Build workflows for different type of repeats (or template insertions)
#            4. Build workflows for non-human species (in the future)

class xWorkFlow():#
    def __init__(self):
        return
    ####
    ####

    # s_cmd = ""
    # if iflag & 1 == 1:
    #     s_cmd += sclip_step
    # if iflag & 2 == 2:
    #     s_cmd += sdisc_step
    # if iflag & 4 == 4:
    #     s_cmd += sbarcode_step
    # if iflag & 8 == 8:
    #     s_cmd += sfilter_10x
    # if iflag & 16 == 16:
    #     s_cmd += s_filter
    # if iflag & 32 == 32:
    #     s_cmd += sf_collect
    # if iflag & 64 == 64:
    #     s_cmd += sf_asm
    # if iflag & 128 == 128:
    #     s_cmd += sf_alg_ctg
    # if iflag & 256 == 256:
    #     s_cmd += sf_trsdct
    # if iflag & 512 == 512:
    #     s_cmd += sf_post_filter
    #     s_cmd += sf_post_filter_hc
    # if iflag & 1024 == 1024:
    #     s_cmd += sf_gene
    #     s_cmd+=sf_gntp_classify
    #     s_cmd+=sf_cvt_gvcf



####