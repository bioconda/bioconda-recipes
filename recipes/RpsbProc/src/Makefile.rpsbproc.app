APP = rpsbproc
SRC = rpsbproc_main \
 common/offl_cd_align_proc \
 common/cdalignproc_biodata \
 common/cdalignproc_base \
 common/offl_sparcle_data \
 common/biodata_blast \
 common/biodata_core \
 common/basedata \
 common/objutils \
 common/argwrapper \
 common/basealgo \
 common/combistream \
 common/datanode \
 common/prosite \
 common/segset \
 common/lxml \
 common/ljson \
 common/ustring \
 common/normbase

CPPFLAGS = -D__DB_OFFLINE__ -I. \
	$(ORIG_CPPFLAGS)

LIB = $(BLAST_LIBS) $(BLAST_FORMATTER_MINIMAL_LIBS) $(SOBJMGR_LIBS)

LIBS = $(ORIG_LIBS) $(BZ2_LIBS) $(Z_LIBS) $(DL_LIBS)



