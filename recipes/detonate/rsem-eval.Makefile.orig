CC = g++
CFLAGS = -Wall -c -I.
COFLAGS = -Wall -O3 -ffast-math -c -I.
PROGRAMS = rsem-extract-reference-transcripts rsem-synthesis-reference-transcripts rsem-preref rsem-parse-alignments rsem-build-read-index rsem-eval-run-em rsem-simulate-reads rsem-sam-validator rsem-scan-for-paired-end-reads

.PHONY : all clean

all : $(PROGRAMS)

sam/libbam.a :
	cd sam ; ${MAKE} all

Transcript.h : utils.h

Transcripts.h : utils.h my_assert.h Transcript.h

rsem-extract-reference-transcripts : utils.h my_assert.h GTFItem.h Transcript.h Transcripts.h extractRef.cpp
	$(CC) -Wall -O3 extractRef.cpp -o rsem-extract-reference-transcripts

rsem-synthesis-reference-transcripts : utils.h my_assert.h Transcript.h Transcripts.h synthesisRef.cpp
	$(CC) -Wall -O3 synthesisRef.cpp -o rsem-synthesis-reference-transcripts

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

SamParser.h : sam/sam.h sam/bam.h utils.h my_assert.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleHit.h PairedEndHit.h Transcripts.h

rsem-parse-alignments : parseIt.o sam/libbam.a
	$(CC) -o rsem-parse-alignments parseIt.o sam/libbam.a -lz -lpthread 

parseIt.o : utils.h RefSeq.h Refs.h GroupInfo.h Read.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleHit.h PairedEndHit.h HitContainer.h SamParser.h Transcripts.h sam/sam.h sam/bam.h parseIt.cpp
	$(CC) -Wall -O2 -c -I. parseIt.cpp

rsem-build-read-index : utils.h buildReadIndex.cpp
	$(CC) -O3 buildReadIndex.cpp -o rsem-build-read-index


simul.h : boost/random.hpp

ReadReader.h : SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h ReadIndex.h

SingleModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h Profile.h NoiseProfile.h ModelParams.h RefSeq.h Refs.h SingleRead.h SingleHit.h ReadReader.h simul.h

SingleQModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h ModelParams.h RefSeq.h Refs.h SingleReadQ.h SingleHit.h ReadReader.h simul.h

PairedEndModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h Profile.h NoiseProfile.h ModelParams.h RefSeq.h Refs.h SingleRead.h PairedEndRead.h PairedEndHit.h ReadReader.h simul.h 

PairedEndQModel.h : utils.h my_assert.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h ModelParams.h RefSeq.h Refs.h SingleReadQ.h PairedEndReadQ.h PairedEndHit.h ReadReader.h simul.h

HitWrapper.h : HitContainer.h

sam_rsem_aux.h : sam/bam.h

BamWriter.h : sam/sam.h sam/bam.h sam_rsem_aux.h SingleHit.h PairedEndHit.h HitWrapper.h Transcript.h Transcripts.h

sampling.h : boost/random.hpp

WriteResults.h : utils.h my_assert.h GroupInfo.h Transcript.h Transcripts.h RefSeq.h Refs.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h

ContigLengthDist.h : boost/math/special_functions/log1p.hpp boost/math/special_functions/expm1.hpp boost/math/distributions/negative_binomial.hpp

CalcEvalScore.h : utils.h my_assert.h Refs.h GroupInfo.h Transcript.h Transcripts.h ContigLengthDist.h

rsem-eval-run-em : EM.o sam/libbam.a
	$(CC) -o rsem-eval-run-em EM.o sam/libbam.a -lz -lpthread

EM.o : utils.h my_assert.h Read.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleHit.h PairedEndHit.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h Refs.h GroupInfo.h HitContainer.h ReadIndex.h ReadReader.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h ModelParams.h RefSeq.h RefSeqPolicy.h PolyARules.h Profile.h NoiseProfile.h Transcript.h Transcripts.h HitWrapper.h BamWriter.h sam/bam.h sam/sam.h simul.h sam_rsem_aux.h sampling.h boost/random.hpp WriteResults.h boost/math/distributions/negative_binomial.hpp ContigLengthDist.h CalcEvalScore.h EM.cpp 
	$(CC) $(COFLAGS) EM.cpp

rsem-simulate-reads : simulation.o
	$(CC) -o rsem-simulate-reads simulation.o

simulation.o : utils.h Read.h SingleRead.h SingleReadQ.h PairedEndRead.h PairedEndReadQ.h SingleModel.h SingleQModel.h PairedEndModel.h PairedEndQModel.h Refs.h RefSeq.h GroupInfo.h Transcript.h Transcripts.h Orientation.h LenDist.h RSPD.h QualDist.h QProfile.h NoiseQProfile.h Profile.h NoiseProfile.h simul.h boost/random.hpp WriteResults.h simulation.cpp
	$(CC) $(COFLAGS) simulation.cpp

rsem-sam-validator : sam/bam.h sam/sam.h my_assert.h samValidator.cpp sam/libbam.a
	$(CC) -O3 -Wall samValidator.cpp sam/libbam.a -lz -lpthread -o $@

rsem-scan-for-paired-end-reads : sam/bam.h sam/sam.h my_assert.h scanForPairedEndReads.cpp sam/libbam.a
	$(CC) -O3 -Wall scanForPairedEndReads.cpp sam/libbam.a -lz -lpthread -o $@

clean :
	rm -f *.o *~ $(PROGRAMS)
	cd sam ; ${MAKE} clean
