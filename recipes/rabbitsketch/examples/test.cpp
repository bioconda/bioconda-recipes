#include "Sketch.h"
#include <iostream>
#include <sys/time.h>
#include <zlib.h>
#include "kseq.h"

using namespace std;

KSEQ_INIT(gzFile, gzread)

double get_sec(){
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (double)tv.tv_sec + (double)tv.tv_usec / 1000000;
}

void getCWS(double *r, double *c, double *b, int sketchSize, int dimension){
//	cerr << "successful malloc r, c, b in getCWS" << endl;
	const int DISTRIBUTION_SEED = 1;
    default_random_engine generator(DISTRIBUTION_SEED);
    gamma_distribution<double> gamma(2.0,1.0);
    uniform_real_distribution<double> uniform(0.0,1.0);

    for (int i = 0; i < sketchSize * dimension; ++i){
        r[i] = gamma(generator);
        c[i] = log(gamma(generator));
        b[i] = uniform(generator) * r[i];
    }
}	

int main(int argc, char* argv[])
{

	gzFile fp1;
	gzFile fp2;
	kseq_t *ks1;
	kseq_t *ks2;
	
	fp1 = gzopen(argv[1],"r");
	fp2 = gzopen(argv[2],"r");
	if(NULL == fp1){
		fprintf(stderr,"Fail to open file: %s\n", argv[1]);
		return 0;
	}

	if(NULL == fp2){
		fprintf(stderr,"Fail to open file: %s\n", argv[2]);
		return 0;
	}

	ks1 = kseq_init(fp1);
	ks2 = kseq_init(fp2);

	int l1 = kseq_read(ks1);
	int l2 = kseq_read(ks2);
	char * seq1 = ks1->seq.s;
	char * seq2 = ks2->seq.s;

	double distance;
	double time1 = get_sec();	
	Sketch::WMHParameters parameter;
	parameter.kmerSize = 21;
	parameter.sketchSize = 50;
	parameter.windowSize = 20;
	parameter.r = (double *)malloc(parameter.sketchSize * pow(parameter.kmerSize, 4) * sizeof(double));
	parameter.c = (double *)malloc(parameter.sketchSize * pow(parameter.kmerSize, 4) * sizeof(double));
	parameter.b = (double *)malloc(parameter.sketchSize * pow(parameter.kmerSize, 4) * sizeof(double));
	getCWS(parameter.r, parameter.c, parameter.b, parameter.sketchSize, pow(parameter.kmerSize, 4));

	//Sketch::WMinHash * wmh1 = new Sketch::WMinHash(21, 50, 9, 0.0);
	//Sketch::WMinHash * wmh2 = new Sketch::WMinHash(21, 50, 9, 0.0);
	Sketch::WMinHash * wmh1 = new Sketch::WMinHash(parameter);
	Sketch::WMinHash * wmh2 = new Sketch::WMinHash(parameter);
	//wmh1->setHistoSketchSize(500);
	//wmh2->setHistoSketchSize(500);
	wmh1->update(seq1);
	wmh2->update(seq2);

	double time3 = get_sec();

	distance = wmh1->distance(wmh2);

	double time2 = get_sec();
	cout << "Algorithm\t" << "distance\t" << "totaltime\t" << "sketchtime\t" << endl;
	cout << "WMinHash\t"  << distance << "\t" << time2 - time1 << "\t" << time3 - time1 << endl;
	//cout << "WMinHash: the distance(1-WJ) is: " << distance << endl;
	//cout << "WMinHash time: " << time2 - time1  << endl;
	//cout << "WMinHash sketch time: " << time3 - time1 << endl;
	//cout << "=======================================================" << endl;
	
	time1 = get_sec();

	Sketch::MinHash * mh1 = new Sketch::MinHash();
	Sketch::MinHash * mh2 = new Sketch::MinHash();
	mh1->update(seq1);	
	//std::cout << "mh1 set size: " << mh1->count() << std::endl;
	mh2->update(seq2);	
	//std::cout << "mh2 set size: " << mh2->count() << std::endl;

	time3 = get_sec();

	double minhash_jac = mh1->jaccard(mh2);	
	//double minhash_jac = mh1->mdistance(mh2);	

	time2 = get_sec();

	cout << "MinHash\t"  << 1.0 - minhash_jac << "\t" << time2 - time1 << "\t" << time3 - time1 << endl;
	//cout << "MinHash: the distance(1-J) is: " << 1.0 - minhash_dist << endl;
	//cout << "MinHash time: " << time2 - time1  << endl;
	//cout << "MinHash sketch time: " << time3 - time1  << endl;
	//cout << "=======================================================" << endl;


	time1  = get_sec();

	Sketch::OrderMinHash omh1;
	Sketch::OrderMinHash omh2;
	omh1.buildSketch(seq1);
	omh2.buildSketch(seq2);

	time3 = get_sec();

	double odist = omh1.distance(omh2);

	time2 = get_sec();

	cout << "OMinHash\t"  << odist  << "\t" << time2 - time1 << "\t" << time3 - time1 << endl;
	//cout << "OMinHash: the distance(1-J) is: " << odist << endl;
	//cout << "OMinHash time: " << time2 -  time1 << endl;
	//cout << "OMinHash sketch: " << time3 -  time1 << endl;
	//cout << "=======================================================" << endl;


	time1  = get_sec();

    static const size_t BITS = 20; //24
	Sketch::HyperLogLog t(BITS);
	Sketch::HyperLogLog t1(BITS);

    t.update(seq1);
    t1.update(seq2);

	time3 = get_sec();

    double dist = t1.distance(t);

	time2  = get_sec();

	cout << "HLL\t"  << 1.0 - dist  << "\t" << time2 - time1 << "\t" << time3 - time1 << endl;
    //cout << "HLL distance(1-J) = " <<  1.0 - dist << endl;
	//cout << "HLL time: " << time2 -  time1 << endl;
	//cout << "HLL sketch time: " << time3 -  time1 << endl;

	kseq_destroy(ks1);
	kseq_destroy(ks2);
	gzclose(fp1);
	gzclose(fp2);

	return 0;
	
}

