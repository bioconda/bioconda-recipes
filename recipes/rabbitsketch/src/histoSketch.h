#ifndef _HISTOSKETCH_
#define _HISTOSKETCH_

#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <stdint.h>
#include <vector>

using namespace std;

const double EPSILON = 0.001;
const double DELTA = 0.99;

struct Pair{
	uint64_t X;//the hash value.
	int Y;//the location of the minimizer in the sequence.
};

struct Bin{
	uint32_t BinID;
	double Frequency;
};

void findMinimizers(int k, int w, string s, vector <uint64_t> &minimizerSketch);

uint64_t hash64(uint64_t key, uint64_t mask);

bool findElement(vector <uint64_t> arr, uint64_t element);

void getCWS(double *r, double *c, double *b, int sketchSize, int dimension);

void kmerSpectrumAddHash(vector <uint64_t> minimizerSketch, double * binsArr, int numBins);
void kmerSpectrumDump(double *binsArr, int numBins, vector <Bin> &kmerSpectrum);

int32_t JumpConsistentHash(uint64_t key, int32_t num_buckets);

void countMinScale(double * countMinSketch, double decayWeight);
double countMinAdd(uint64_t element, double increment, bool applyScaling, double decayWeight, double * countMinSketch);


double histoSketch_getSample(int i, int j, double freq, double * r, double * c, double * b, int sketchSize, int dimension);

//void histoSketchAddElement(uint64_t bin, double value, double * countMinSketch, int histoSketchLength, bool applyConceptDrift, double * r, double * c, double * b, int sketchSize, int dimension, uint32_t * histoSketch_sketch, double * histoSketch_sketchWeight);


void histoSketchAddElement(uint64_t bin, double value, double * countMinSketch, bool applyConceptDrift, double decayWeight, double * r, double * c, double * b, int sketchSize, int dimension, uint32_t * histoSketch_sketch, double * histoSketch_sketchWeight);


double getWJD(uint32_t *setA, uint32_t *setB, double *weightA, double *weightB, int sketchSize);


#endif
