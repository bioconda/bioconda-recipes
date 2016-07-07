#ifndef Kmer64_h
#define Kmer64_h

#include <stdint.h>

#ifdef _largeint
#include "LargeInt.h"
typedef LargeInt<KMER_PRECISION> kmer_type;
#else
#ifdef _ttmath
#include "ttmath/ttmath.h"
typedef ttmath::UInt<KMER_PRECISION> kmer_type;
#else
#if (! defined kmer_type) || (! defined _LP64)
typedef uint64_t kmer_type;
#endif
#endif
#endif

extern int sizeKmer;
extern kmer_type kmerMask;
extern kmer_type kmerMaskm1;

extern uint64_t nsolids;

int NT2int(char nt);
int revcomp_int(int nt_int);
kmer_type  codeSeed(char *seq, int sizeKmer, kmer_type kmerMask);
kmer_type  codeSeed(char *seq);
kmer_type  codeSeedRight(char *seq, kmer_type  val_seed, bool new_read);
kmer_type  codeSeedRight(char *seq, kmer_type  val_seed, bool new_read, int sizeKmer, kmer_type kmerMask);
kmer_type  codeSeedRight_revcomp(char *seq, kmer_type  val_seed, bool new_read);
kmer_type  codeSeedRight_revcomp(char *seq, kmer_type  val_seed, bool new_read, int sizeKmer, kmer_type kmerMask);
unsigned char  code_n_NT(char *seq, int nb);
unsigned char  code4NT(char *seq);

uint64_t revcomp(uint64_t x);
uint64_t revcomp(uint64_t x, int size);

#ifdef _largeint
LargeInt<KMER_PRECISION> revcomp(LargeInt<KMER_PRECISION> x);
LargeInt<KMER_PRECISION> revcomp(LargeInt<KMER_PRECISION> x, int size);
#endif
#ifdef _ttmath
ttmath::UInt<KMER_PRECISION> revcomp(ttmath::UInt<KMER_PRECISION> x);
ttmath::UInt<KMER_PRECISION> revcomp(ttmath::UInt<KMER_PRECISION> x, int size);
#endif
#ifdef _LP64
__uint128_t revcomp(__uint128_t x);
__uint128_t revcomp(__uint128_t x, int size);
#endif

int code2seq ( kmer_type code,char *seq);
int code2seq ( kmer_type code,char *seq, int sizeKmer, kmer_type kmerMask);
int code2nucleotide( kmer_type code, int which_nucleotide);

kmer_type extractKmerFromRead(char *readSeq, int position, kmer_type *graine, kmer_type *graine_revcomp);
kmer_type extractKmerFromRead(char *readSeq, int position, kmer_type *graine, kmer_type *graine_revcomp, bool sequential);
kmer_type extractKmerFromRead(char *readSeq, int position, kmer_type *graine, kmer_type *graine_revcomp, bool sequential, int sizeKmer, kmer_type kmerMask);

// compute the next kmer w.r.t forward or reverse strand, e.g. for ACTG (revcomp = CAGT)
// it makes sure the result is the min(kmer,revcomp_kmer)
// indicates if the result is the revcomp_kmer by setting *strand 
// examples:
// next_kmer(ACTG,A,&0)=CTGA with strand = 0 (because revcomp=TCAG); 
// next_kmer(ACTG,A,&1)= (revcomp of ACTG + A = CAGT+A = ) AGTA with strand = 0 (because revcomp = TACT)
kmer_type next_kmer(kmer_type graine, int added_nt, int *strand);

void revcomp_sequence(char s[], int len);


kmer_type  codeSeed_bin(char *seq);

kmer_type  codeSeedRight_bin(char *seq, kmer_type  val_seed, bool new_read);

kmer_type  codeSeedRight_revcomp_bin(char *seq, kmer_type  val_seed, bool new_read);

kmer_type extractKmerFromRead_bin(char *readSeq, int position, kmer_type *graine, kmer_type *graine_revcomp, bool use_compressed);

char* print_kmer(kmer_type kmer); // debugging
char* print_kmer(kmer_type kmer, int sizeKmer, kmer_type kmerMask); // debugging


#endif
