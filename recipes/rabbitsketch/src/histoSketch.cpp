#include "histoSketch.h"
#include "robin_hood.h"
#include <math.h>
#include <random>
#include <float.h>
#include "fmath.hpp"
//#include <cmath>


const int DISTRIBUTION_SEED = 1;

void getCWS(double *r, double *c, double *b, int sketchSize, int dimension){
//	cerr << "successful malloc r, c, b in getCWS" << endl;
    default_random_engine generator(DISTRIBUTION_SEED);
    gamma_distribution<double> gamma(2.0,1.0);
    uniform_real_distribution<double> uniform(0.0,1.0);

    for (int i = 0; i < sketchSize * dimension; ++i){
        r[i] = gamma(generator);
        c[i] = log(gamma(generator));
        b[i] = uniform(generator) * r[i];
    }
}	


uint64_t hash64(uint64_t key, uint64_t mask){
	key = (~key + (key << 21)) & mask;//key = (key << 21) - key - 1;
	key = key ^ key>>24;
	key = ((key + (key << 3)) + (key << 8)) & mask;//key * 265
	key = key ^ key>>14;
	key = ((key + (key << 2)) + (key << 4)) & mask;//key * 21
	key = key ^ key>>28;
	key = (key + (key << 31)) & mask;
	return key;
}

bool findElement(vector <uint64_t> arr, uint64_t element){
	bool result =false;
	for(int i = 0; i < arr.size(); i++){
		if(arr[i] == element){
			result = true;
			break;
		}
	}
	return result;
}



//vector <uint64_t> findMinimizers(int k, int w, string s)
void findMinimizers(int k, int w, string s, vector <uint64_t> &minimizerSketch)
{

	uint8_t seq_nt4_table[256] = {
		0, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 0, 4, 1, 4, 4, 4, 2, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 0, 4, 1, 4, 4, 4, 2, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
		4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
	};

	if(w < 0 || w > 256){
		std::cerr << "w must be: 0 < w < 257" << std::endl;
		exit(1);
	}
	if(k < 0 || k > 31){
		std::cerr << " k size must be: 0 < k < 32" << std::endl;	
		exit(1);
	}

	int len = s.length();
	//cerr << "the length of the sequence is: " << len << endl;
	if(len < 1){
		std::cerr << "sequence length must be > 0 " << std::endl;
		//exit(1);
		return;
	}
	if(len < (w + k - 1)){
		std::cerr << "sequence length must be >= w + k -1" << std::endl;
		//exit(1);
		return;
	}
//	vector <uint64_t> minimizerSketch;

	uint64_t kmers[2] = {0, 0};
	int kmerSpan = 0;

	//cout << "the k is: " << k << endl;
	uint64_t bitmask = (uint64_t)(((uint64_t)1 << (2 * k)) - 1);
	uint64_t bitshift = (uint64_t)(2 * (k - 1));
//	printf("the bitmask is: %lx \n", bitmask);
//	printf("the bitshift is: %lx \n", bitshift);


	//q = queue.newQueue();
	vector <Pair> q;
	robin_hood::unordered_map<uint64_t, double> minimizerMap;

	for(int i = 0; i < len; i++){
		int windowIndex = i - w + 1;
		//cout << "the windowIndex is: " << windowIndex << endl; //done@xxm

		uint8_t c = seq_nt4_table[s[i]]; // c should be uint8_t
		//printf("%x\n",c);
		
		//printf("the c is: %d \n", c); //done@xxm
		if(c > 3){
			//TODO: handle these, by skiping the base and starting w again? @hulk

		}
		if(windowIndex + 1 < k){
			kmerSpan = windowIndex + 1;
		}
		else{
			kmerSpan = k;
		}

		//get the forward k-mer
		kmers[0] = (kmers[0] << 2 | (uint64_t)c) & bitmask;

		//get the reverse k-mer
		kmers[1] = (kmers[1] >> 2) | ((uint64_t)3 ^ (uint64_t)c) << bitshift;

		//don't try for minimizers until a full k-mer has been collected
		if(i < k - 1){
			//cout << "i < k - 1" << endl;
			continue;
		}

		//skip symmetric k-mers as we don't know the strand
		if(kmers[0] == kmers[1]){
			//cout << "kmers0 == kmers1" << endl;
			continue;
		}

		//set the canonical k-mer
		int strand = 0;
		
		if(kmers[0] > kmers[1]){
			strand = 1;
		}

		Pair currentKmer;

		uint64_t x = hash64(kmers[strand], bitmask) << 8 | (uint64_t)kmerSpan;
		//printf("%lx\n",kmers[strand]);
		
		//cout << "the i is: " << i << " and the hash64 x is: " << x << endl;
		//printf("%lx\n",x);
		currentKmer.X = x;
		currentKmer.Y = i;

		//if(q.size() != 0){
			//if minimizers are in the q from the previous window, remove them.
			while(q.size() != 0){
				if(q.front().Y > (i - w)){
					break;
				}
				q.erase(q.begin());
			}

			// hashed k-mers less than equal to the currentKmer are not required,so remove them from the back of the q.
			while(q.size() != 0){
				if(q.back().X < currentKmer.X){
					break;
				}
				q.pop_back();
			}
		//}

		q.push_back(currentKmer);
		//no problem before this.@xxm
	//	for(int i_ = 0; i_ < q.size(); i_++){
	//		printf("%lx\t",q[i_].X);
	//	}
	//	printf("\n");
		
		//printf("%lx\n",currentKmer.X);

		if(windowIndex >= 0){
		//	if(minimizerSketch.size() == 0){
		//		minimizerSketch.push_back(q.front().X);
		//		continue;
		//	}

		//	if(findElement(minimizerSketch, q.front().X)){
		//		continue;
		//	}

		//	minimizerSketch.push_back(q.front().X);
			minimizerMap.insert({q.front().X, 1.0});
		//	if(!findElement(minimizerSketch, q.front().X)){
		//		minimizerSketch.push_back(q.front().X);
		//		//printf("%lx\n",q.front().X);
		//	}

		}

	}//end of sequence.
	for(auto& x:minimizerMap){
		minimizerSketch.push_back(x.first);
	}

//	return minimizerSketch;
}


int32_t JumpConsistentHash(uint64_t key, int32_t num_buckets){
	int64_t b = -1, j = 0;
	while (j < num_buckets) {
		b = j;
		key = key * 2862933555777941757ULL + 1;
		j = (b + 1) * (double(1LL << 31) / double((key >> 33) + 1));
	}
	return b;
}

void kmerSpectrumAddHash(vector <uint64_t> minimizerSketch, double * binsArr, int numBins){
	for(int i = 0; i < minimizerSketch.size(); i++){
		
		uint32_t bin = JumpConsistentHash(minimizerSketch[i], numBins);
//		cout << "the bin is: " << bin << endl;

		//record the bin id; check the kmerSpectrum.bv.add ? 
		{

		}

		binsArr[bin] += 1.0;

	}
}

void kmerSpectrumDump(double *binsArr, int numBins, vector <Bin> &kmerSpectrum){
	//implement the KmerSpectrum.Dump in go.
	for(int i = 0; i < numBins; i++){
		if(binsArr[i] != 0.0){
			Bin binDemo;
			binDemo.BinID = i;
			binDemo.Frequency = binsArr[i];
			kmerSpectrum.push_back(binDemo);
		}
	}

}

void countMinScale(double * countMinSketch, double decayWeight){

	int g = ceil(2 / EPSILON);
	int d = ceil(log(1 - DELTA) / log(0.5));

	for(int i = 0; i < d; i++){
		for(int j = 0; j < g; j ++){
			countMinSketch[i * g + j] = countMinSketch[i * g + j] * decayWeight;
		}
	}

}

double countMinAdd(uint64_t element, double increment, bool applyScaling, double decayWeight, double * countMinSketch){
	
	int g = ceil(2 / EPSILON);//math.h
	int d = ceil(log(1 - DELTA) / log(0.5));//math.h

//	if(applyScaling){
//		//TODO
//		//cout << "do the countMinScale" << endl;
//		countMinScale(countMinSketch, decayWeight);
//		//countMinSketch.scale();
//	}

	//double currentMinimum = HUGE_VALL;//use c++11: huge long double value
	double currentMinimum = DBL_MAX;//float.h
	//cout << currentMinimum << endl;
	
	for(int i = 0; i < d; i++){
		uint64_t hash = element + (uint64_t)i * element;

		int j = JumpConsistentHash(hash, g);
	//	cout << j << endl;

		if(increment != 0.0){//actrually don't need the if
			countMinSketch[i * g + j] += increment;
		}

		if(countMinSketch[i * g + j] < currentMinimum){
			currentMinimum = countMinSketch[i * g + j];
		}
	
	}

	return currentMinimum;
}
	

//need to be implement.//TODO the dimention of r, c, b.
double histoSketch_getSample(int i, int j, double freq, double * r, double * c, double * b, int sketchSize, int dimension){
	//the b[j][i] need to be relocated the index.
	if(j >= sketchSize){
		cerr <<"out of bound sketchSize!" << endl;
		exit(1);
	}
	if(i >= dimension){
		cerr << "out of bound dimension!" << endl;
		exit(1);
	}

	//double yka = exp(log(freq) - c[j * dimension +i]*b[j * dimension + i]);
	double yka = fmath::expd(fmath::log(freq) - c[j * dimension +i]*b[j * dimension + i]);
//	cerr << "after exp for yak is: " << yka <<  endl;
	//double result = c[j][i] / (yka * exp(r[j][i]));
	double result = c[j * dimension + i] / (yka * fmath::expd(r[j * dimension + i]));
//	cerr << "after exp for result is: " << result << endl;
	return result;
}



void histoSketchAddElement(uint64_t bin, double value, double * countMinSketch, bool applyConceptDrift, double decayWeight, double * r, double * c, double * b, int sketchSize, int dimension, uint32_t * histoSketch_sketch, double * histoSketch_sketchWeight){
	
	double estiFreq = countMinAdd(bin, value, applyConceptDrift, decayWeight, countMinSketch);
	//cout << "the frequency(value) and estiFreq is: " << value << '\t' << estiFreq << endl;

	for(int i = 0; i < sketchSize; i++){
		//get the CWS value(A_Ka) for the incoming element
		double aka = histoSketch_getSample((int)bin, i, estiFreq, r, c, b, sketchSize, dimension);	
//		printf("the aka is: %lf\n", aka);
//		exit(1);

		//get the current minimum in the histosketchSlot, accounting for concept drift if requrested
		double curMin;
	//	if(applyConceptDrift){
	//		//TODO
	//		curMin = histoSketch_sketchWeight[i] /decayWeight;
	//	}
	//	else{
			curMin = histoSketch_sketchWeight[i];
	//	}

		if(aka < curMin){
			histoSketch_sketch[i] = (uint32_t)bin;
			histoSketch_sketchWeight[i] = aka;
		}
	}

}
		

double getWJD(uint32_t *setA, uint32_t *setB, double *weightA, double *weightB, int sketchSize){
	double intersectElement = 0.0;
	double unionElement = 0.0;
	double distance = 1.0;

	for(int i = 0; i < sketchSize; i++){
		double curWeightA = abs(weightA[i]);
		double curWeightB = abs(weightB[i]);

		//get the intersection and union values
		if(setA[i] == setB[i]){
			if(curWeightA < curWeightB){
				intersectElement += curWeightA;
				unionElement += curWeightB;
			}
			else{
				intersectElement += curWeightB;
				unionElement += curWeightA;
			}
		}
		else{
			if(curWeightA > curWeightB){
				unionElement += curWeightA;
			}
			else{
				unionElement += curWeightB;
			}
		}

	}

	distance = 1 - intersectElement / unionElement;

	return distance;

}





