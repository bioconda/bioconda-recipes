#include "Sketch.h"
#include <random>
#include "histoSketch.h"

namespace Sketch{

//start the WMinHash@xxm
//WMinHash::WMinHash(Parameters parametersNew)//:parameters(parametersNew)

void WMinHash::update(char * seq)
{
	findMinimizers(kmerSize, minimizerWindowSize, seq, sketches);
	kmerSpectrumAddHash(sketches, binsArr, numBins);
//	for(int i = 0; i < numBins; i++){
//		if(binsArr[i] != 0){
//			printf("%d\t%lf\n", i, binsArr[i]);
//		}
//	}
	sketches.clear();
	sketches.shrink_to_fit();
//	needToCompute = true;

}

void WMinHash::computeHistoSketch()
{
	kmerSpectrumDump(binsArr, numBins, kmerSpectrums);
	free(binsArr);

	for(int i = 0; i < kmerSpectrums.size(); i++){
	//cerr << "finish the " << i << " iterator to addElement" << endl;
		histoSketchAddElement((uint64_t)kmerSpectrums[i].BinID, kmerSpectrums[i].Frequency, countMinSketch, applyConceptDrift, decayWeight, r, c, b, histoSketchSize, histoDimension, histoSketches, histoWeight);
	}
	free(countMinSketch);
	kmerSpectrums.clear();
	kmerSpectrums.shrink_to_fit();
	//cerr << "finish the histoSketchAddElement " << endl;

}

void WMinHash::getWMinHash(){
//	if(needToCompute){
//		computeHistoSketch();
//		needToCompute = false;
//	}
	cout << "the sketch is: " << endl;
	for(int i = 0; i < histoSketchSize; i++){
		printf("%d\n", histoSketches[i]);
	}

	cout << "the sketchweight is: " << endl;
	for(int j = 0; j < histoSketchSize; j++){
		printf("%lf\n", histoWeight[j]);
	}

}

double WMinHash::wJaccard(WMinHash * wmh)
{
	//cout << "the needToCompute is: " << needToCompute << endl;
//	if(needToCompute){
//		computeHistoSketch();
//		needToCompute = false;
//	}
//	if(wmh->needToCompute){
//		wmh->computeHistoSketch();
//		wmh->needToCompute = false;
//	}
	double intersectElement = 0.0;
	double unionElement = 0.0;
	double jaccard = 0.0;
	//cerr << "the parameters.get_histoSketch_sketchSize() is: " << histoSketchSize << endl;
	for(int i = 0 ; i < histoSketchSize; i++){

		double curWeightA = abs(histoWeight[i]);
		double curWeightB = abs(wmh->histoWeight[i]);

		//get the intersection and union values
		if(histoSketches[i] == wmh->histoSketches[i]){
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
	jaccard = intersectElement / unionElement;
//	printf("the intersect and union is: %lf and %lf \n", intersectElement, unionElement);

	return jaccard;

}

	
double WMinHash::distance(WMinHash * wmh){
	return 1 - wJaccard(wmh);
}

//void WMinHash::setHistoSketchSize(int histoSketchSizeNew){
//	histoSketchSize = histoSketchSizeNew;
//
//	r = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
//	c = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
//	b = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
//	getCWS(r, c, b, histoSketchSize, histoDimension);
//	
//
//	histoSketches = (uint32_t *) malloc (histoSketchSize * sizeof(uint32_t));
//	histoWeight = (double *) malloc (histoSketchSize * sizeof(double));
//}

//void WMinHash::setHistoDimension(int histoDimensionNew){
//	histoDimension = histoDimensionNew;
//	
//	r = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
//	c = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
//	b = (double *)malloc(histoSketchSize * histoDimension * sizeof(double));
//	getCWS(r, c, b, histoSketchSize, histoDimension);
//	
//
//	histoSketches = (uint32_t *) malloc (histoSketchSize * sizeof(uint32_t));
//	histoWeight = (double *) malloc (histoSketchSize * sizeof(double));
//}


WMinHash::~WMinHash()
{
	free(binsArr);
	free(countMinSketch);
	free(histoSketches);
	free(histoWeight);

}

}
