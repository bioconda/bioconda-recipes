#include "Sketch.h"
#include <iostream>
#include <sys/time.h>
#include <zlib.h>
#include "kseq.h"
#include <vector>
#include <math.h>
#include <random>
#include <sstream>
#include <fstream>


using namespace std;

KSEQ_INIT(gzFile, gzread)


int main(int argc, char* argv[])
{

	gzFile fp1;
	kseq_t *ks1;
	
	fp1 = gzopen(argv[1],"r");
	if(NULL == fp1){
		fprintf(stderr,"Fail to open file: %s\n", argv[1]);
		return 0;
	}


	vector<string> vseq;
	vector<int> vlength;
	int count = 0;

	Sketch::WMHParameters parameter;
	parameter.kmerSize = 21;
	parameter.sketchSize = 50;
	parameter.windowSize = 20;
	parameter.r = (double *)malloc(parameter.sketchSize * pow(parameter.kmerSize, 4) * sizeof(double));
	parameter.c = (double *)malloc(parameter.sketchSize * pow(parameter.kmerSize, 4) * sizeof(double));
	parameter.b = (double *)malloc(parameter.sketchSize * pow(parameter.kmerSize, 4) * sizeof(double));
	getCWS(parameter.r, parameter.c, parameter.b, parameter.sketchSize, pow(parameter.kmerSize, 4));

	int half_k = 10;
	int half_subk = 6;
	int drlevel = 3;

	Sketch::kssd_parameter_t kssdPara(half_k, half_subk, drlevel, "shuf_file/L3K10.shuf");
	vector<Sketch::Kssd *> vkssd;
	vector<Sketch::WMinHash *> vwmh; 
	vector<Sketch::MinHash *> vmh; 
	vector<Sketch::OrderMinHash > vomh; 
	vector<Sketch::HyperLogLog> vhlog;
	ks1 = kseq_init(fp1);
	while(1){
		int length = kseq_read(ks1);
		if(length < 0){
			break;
		}

		Sketch::WMinHash * wmh1 = new Sketch::WMinHash(parameter);
		Sketch::MinHash * mh1 = new Sketch::MinHash();
		Sketch::OrderMinHash omh1;
    static const size_t BITS = 10; //24
		Sketch::HyperLogLog t(BITS);
		Sketch::Kssd* kssd = new Sketch::Kssd(kssdPara);
		cerr << "end the wmh construction" << endl;
		wmh1->update(ks1->seq.s);
		mh1->update(ks1->seq.s);	
		omh1.buildSketch(ks1->seq.s);
		t.update(ks1->seq.s);
		kssd->update(ks1->seq.s);
		cerr << "end the wmh update" << endl;
		vwmh.push_back(wmh1);
		vmh.push_back(mh1);
		vomh.push_back(omh1);
		vhlog.push_back(t);
		vkssd.push_back(kssd);
		cerr << "the index of the wmh is: " << count << endl;
		count++;

	}

//	for(int i = 0; i < vkssd.size(); i++){
//		vector<uint64_t> hashArr = vkssd[i]->storeHashes();
//		cout << "seq " << i << " is: " << endl;
//		for(auto x : hashArr){
//			cout << x << endl;
//		}
//	}

	cout << "begin to compute the WMH distance: "  << endl;
	printf("=====================================\t WMinHash \t MinHash \t OMinHash \t HyperLog\t KSSD \n");
	for(int i = 0; i < count; i++){
		for(int j = i+1; j < count; j++){
			double distance0 = vwmh[i]->distance(vwmh[j]);
			//double distance1 = 1.0 - vmh[i]->jaccard(vmh[j]);
			double distance1 = vmh[i]->distance(vmh[j]);
			double distance2 = vomh[i].distance(vomh[j]);
			double distance3 = vhlog[i].distance(vhlog[j]);
			double distance4 = vkssd[i]->distance(vkssd[j]);
			printf("the distance of seq[%d] and seq[%d] is:\t %lf \t %lf \t %lf \t %lf \t %lf \n", i, j, distance0, distance1, distance2, distance3, distance4);
		}
	}
	cout << "end to compute the WMH distance;"  << endl;



	return 0;
	
}

