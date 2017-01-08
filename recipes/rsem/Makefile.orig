CC = g++
CFLAGS = -Wall -c -I.
COFLAGS = -Wall -O3 -ffast-math -c -I.
LFLAGS = -Wall -O3 -I.

SAMTOOLS = samtools-1.3
HTSLIB = htslib-1.3
SAMFLAGS = -I$(SAMTOOLS) -I$(SAMTOOLS)/$(HTSLIB)
SAMLIBS = $(SAMTOOLS)/libbam.a $(SAMTOOLS)/$(HTSLIB)/libhts.a
PROGRAMS = rsem-extract-reference-transcripts rsem-synthesis-reference-transcripts rsem-preref rsem-parse-alignments rsem-build-read-index rsem-run-em rsem-tbam2gbam rsem-run-gibbs rsem-calculate-credibility-intervals rsem-simulate-reads rsem-bam2wig rsem-get-unique rsem-bam2readdepth rsem-sam-validator rsem-scan-for-paired-end-reads


.PHONY : all ebseq clean

all : $(PROGRAMS)

$(SAMTOOLS)/libbam.a : $(SAMTOOLS)/$(HTSLIB)/libhts.a

$(SAMTOOLS)/$(HTSLIB)/libhts.a : 
	cd $(SAMTOOLS) ; ${MAKE} all

Transcript.h : utils.h

Transcripts.h : utils.h my_assert.h Transcript.h

rsem-extract-reference-transcripts : utils.h my_assert.h GTFItem.h Transcript.h Transcripts.h extractRef.cpp
	$(CC) $(LFLAGS) extractRef.cpp -o rsem-extract-reference-transcripts

rsem-synthesis-reference-transcripts : utils.h my_assert.h Transcript.h Transcripts.h synthesisRef.cpp
	$(CC) $(LFLAGS) synthesisRef.cpp -o rsem-synthesis-reference-transcripts

BowtieRefSeqPolicy.h : RefSeqPolicy.h

RefSeq.h : utils.h

Refs.h : utils.h RefSeq.h RefSeqPolicy.h PolyARules.h


rsem-preref : preRef.o
	$(CC) preRef.o -o rsem-preref

preRef.o : utils.h RefSeq.h Refs.h PolyARules.h RefSeqPolicy.h AlignerRefSeqPolicy.h preRef.cpp
	$(CC) $(COFLAGS) preRef.cpp


SingleRead.h : Read.h

SingleReadQ.h : Read.h

PairedEndRead.h : Read.h SingleRead.h

PairedEndReadQ.h : Read.h SingleReadQ.h


PairedEndHit.h : SingleHit.h

HitContainer.h : GroupInfo.h

sam_utils.h : $(SAMTOOLS)/bam.h Transcript.h Transcripts.h

SamParser.h : $(SAMTOOLS)/sam.h $(SAMTOOLS)/bam.h sam_utils.h utils.h my_assert.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleHit.h PairedEndHit.h Transcripts.h


rsem-parse-alignments : parseIt.o $(SAMLIBS)
	$(CC) -o rsem-parse-alignments parseIt.o $(SAMLIBS) -lz -lpthread 

parseIt.o : $(SAMTOOLS)/sam.h $(SAMTOOLS)/bam.h sam_utils.h utils.h my_assert.h GroupInfo.h Transcripts.h Read.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleHit.h PairedEndHit.h HitContainer.h SamParser.h parseIt.cpp
	$(CC) -Wall -O2 -c -I. $(SAMFLAGS) parseIt.cpp


rsem-build-read-index : utils.h buildReadIndex.cpp
	$(CC) $(LFLAGS) buildReadIndex.cpp -o rsem-build-read-index


simul.h : boost/random.hpp

ReadReader.h : SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h ReadIndex.h

SingleModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h Profile.h NoiseProfile.h ModelParams.h RefSeq.h Refs.h SingleRead.h SingleHit.h ReadReader.h simul.h

SingleQModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h ModelParams.h RefSeq.h Refs.h SingleReadQ.h SingleHit.h ReadReader.h simul.h

PairedEndModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h Profile.h NoiseProfile.h ModelParams.h RefSeq.h Refs.h SingleRead.h PairedEndRead.h PairedEndHit.h ReadReader.h simul.h 

PairedEndQModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h ModelParams.h RefSeq.h Refs.h SingleReadQ.h PairedEndReadQ.h PairedEndHit.h ReadReader.h simul.h

HitWrapper.h : HitContainer.h



BamWriter.h : $(SAMTOOLS)/sam.h $(SAMTOOLS)/bam.h sam_utils.h utils.h my_assert.h SingleHit.h PairedEndHit.h HitWrapper.h Transcript.h Transcripts.h

sampling.h : boost/random.hpp

WriteResults.h : utils.h my_assert.h GroupInfo.h Transcript.h Transcripts.h RefSeq.h Refs.h Model.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h

rsem-run-em : EM.o $(SAMLIBS)
	$(CC) -o rsem-run-em EM.o $(SAMLIBS) -lz -lpthread

EM.o : utils.h my_assert.h Read.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleHit.h PairedEndHit.h Model.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h Refs.h GroupInfo.h HitContainer.h ReadIndex.h ReadReader.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h ModelParams.h RefSeq.h RefSeqPolicy.h PolyARules.h Profile.h NoiseProfile.h Transcript.h Transcripts.h HitWrapper.h BamWriter.h $(SAMTOOLS)/bam.h $(SAMTOOLS)/sam.h simul.h sam_utils.h sampling.h boost/random.hpp WriteResults.h EM.cpp
	$(CC) $(COFLAGS) $(SAMFLAGS) EM.cpp

bc_aux.h : $(SAMTOOLS)/bam.h

BamConverter.h : $(SAMTOOLS)/bam.h $(SAMTOOLS)/sam.h sam_utils.h utils.h my_assert.h bc_aux.h Transcript.h Transcripts.h

rsem-tbam2gbam : utils.h Transcripts.h Transcript.h BamConverter.h $(SAMTOOLS)/sam.h $(SAMTOOLS)/bam.h sam_utils.h my_assert.h bc_aux.h tbam2gbam.cpp $(SAMLIBS)
	$(CC) $(LFLAGS) $(SAMFLAGS) tbam2gbam.cpp $(SAMLIBS) -lz -lpthread -o $@

wiggle.o: $(SAMTOOLS)/bam.h $(SAMTOOLS)/sam.h sam_utils.h utils.h my_assert.h wiggle.h wiggle.cpp
	$(CC) $(COFLAGS) $(SAMFLAGS) wiggle.cpp

rsem-bam2wig : utils.h my_assert.h wiggle.h wiggle.o $(SAMLIBS) bam2wig.cpp
	$(CC) $(LFLAGS) bam2wig.cpp wiggle.o $(SAMLIBS) -lz -lpthread -o $@

rsem-bam2readdepth : utils.h my_assert.h wiggle.h wiggle.o $(SAMLIBS) bam2readdepth.cpp
	$(CC) $(LFLAGS) bam2readdepth.cpp wiggle.o $(SAMLIBS) -lz -lpthread -o $@


rsem-simulate-reads : simulation.o
	$(CC) -o rsem-simulate-reads simulation.o

simulation.o : utils.h Read.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h Model.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h Refs.h RefSeq.h GroupInfo.h Transcript.h Transcripts.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h Profile.h NoiseProfile.h simul.h boost/random.hpp WriteResults.h simulation.cpp
	$(CC) $(COFLAGS) simulation.cpp

rsem-run-gibbs : Gibbs.o
	$(CC) -o rsem-run-gibbs Gibbs.o -lpthread

#some header files are omitted
Gibbs.o : utils.h my_assert.h boost/random.hpp sampling.h Model.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h RefSeq.h RefSeqPolicy.h PolyARules.h Refs.h GroupInfo.h WriteResults.h Gibbs.cpp 
	$(CC) $(COFLAGS) Gibbs.cpp

Buffer.h : my_assert.h

rsem-calculate-credibility-intervals : calcCI.o
	$(CC) -o rsem-calculate-credibility-intervals calcCI.o -lpthread

#some header files are omitted
calcCI.o : utils.h my_assert.h boost/random.hpp sampling.h Model.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h RefSeq.h RefSeqPolicy.h PolyARules.h Refs.h GroupInfo.h WriteResults.h Buffer.h calcCI.cpp
	$(CC) $(COFLAGS) calcCI.cpp

rsem-get-unique : $(SAMTOOLS)/bam.h $(SAMTOOLS)/sam.h sam_utils.h utils.h getUnique.cpp $(SAMLIBS)
	$(CC) $(LFLAGS) $(SAMFLAGS) getUnique.cpp $(SAMLIBS) -lz -lpthread -o $@

rsem-sam-validator : $(SAMTOOLS)/bam.h $(SAMTOOLS)/sam.h sam_utils.h utils.h my_assert.h samValidator.cpp $(SAMLIBS)
	$(CC) $(LFLAGS) $(SAMFLAGS) samValidator.cpp $(SAMLIBS) -lz -lpthread -o $@

rsem-scan-for-paired-end-reads : $(SAMTOOLS)/bam.h $(SAMTOOLS)/sam.h sam_utils.h utils.h my_assert.h scanForPairedEndReads.cpp $(SAMLIBS)
	$(CC) $(LFLAGS) $(SAMFLAGS) scanForPairedEndReads.cpp $(SAMLIBS) -lz -lpthread -o $@

ebseq :
	cd EBSeq ; ${MAKE} all

clean :
	rm -f *.o *~ $(PROGRAMS)
	cd $(SAMTOOLS) ; ${MAKE} clean 
	rm -f $(SAMLIBS)
	cd EBSeq ; ${MAKE} clean
