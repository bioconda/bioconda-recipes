
/*

-multiampping: pour els contigs circular, les reads vont mapper au deux extremiter et etre mal corriger donc vu qu'on garde qu'un coté (faudrait juste ajouter une exception en focntion du hang)

- Polisher pas deterministe dans la selection des 20 copies
	- utiliser un meilleur critiere (qualité de l'alignement etc)

- memory usage: attention si on a trier les contigs par longueur, les premiere passes pourrait demander un max de mémoire
	- !! attention les contigs sont trier dans le sens inverse (les plus grand a la fin)
 	
-ToBasespace index reads:
	- pas besoin d'indexer les reads qui ne contiennent pas de minimizer dupliquer

- ToBasespaceNoCorrection a paralleliser (remove overlaps etc)

- Tester racon sur contigs 0.33 avec l'option -c (write cigar in ouput file), voir si ça ameliore les résulats de binning ou non

- read best hit: la maniere dont on le selection actuellement est pas forcement la meilleur car elle ne favorise pas les petit contigs (les grand contig vont attirer les reads meme si leur sililarité est plus faible que sur un petit contig)
- attention ne pas outupt empty contig
- ToBasespace: générer un assemblage grossier
- tester les scores de qualité ?
- quand un read a été process, on peut erase son entrée dans _alignments ?
- window sequence a selectionner en priorité: 
	- la distance est une mauvaise metrique car on ne sait pas si la sequence de reference est erroné ou non
	- un mapping tres long sur un contig a plus de valeur qu'un mapping court (on est plus sûr que ce read appartient au contig)+
	- NEW: on peut garder la window avec la quality la plus haute
- si "no sequencer fo window": utiliser la fenetre original du contig ?
- minimap2 output: écrire un petit programme pour compresser les résultats d'alignements on the fly
- version finale: remove le minimap2 align filename
- voir comment racon handle multimap
- minimap2 read name: lors d'une premiere passe sur les reads, ecrire tous les headers (minimap2 name) dans un fichier
- vu que le polisher est standalone, ne pas changer le nom des header des contigs (les load en memoire t restituer dans le fichier output)
- mettre minimap2 dans le process de contig subsampling (donc écrire un chunk de contig dans un fichier séparer, puis refaire le minimap2 a cahque pass etc)

"reprise: ajouter les dernieres filtres de qualité de racon (easy) et refaire des test, aussi potentiellement 20 copies est pas l'optimum, essayer entre 20 et 25, tester correction k=5, revoir comment calculer superbubble lineairement"
- Blocoo creat graph: load les edge apres que les nodes du graphe soit tous indexé, comme ça on peut delete mdbg_init (abundance calculation) avant d'indexé les edges
*/

#ifndef MDBG_METAG_CONTIGPOLISHER
#define MDBG_METAG_CONTIGPOLISHER

#include "../Commons.hpp"
#include "../utils/edlib.h"
#include "../utils/spoa/include/spoa/spoa.hpp"
#include "../utils/DnaBitset.hpp"
//#include "../utils/abPOA2/include/abpoa.h"
//#include "../utils/pafParser/paf_parser.hpp"

/*
extern unsigned char nt4_table;
unsigned char nt4_table2[256] = {
       0, 1, 2, 3,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 0, 4, 1,  4, 4, 4, 2,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  3, 3, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 0, 4, 1,  4, 4, 4, 2,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  3, 3, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4, 
       4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4
};

// 65,97=>A, 67,99=>C, 71,103=>G, 84,85,116,117=>T, else=>N
const char nt256_table2[256] = {
       'A', 'C', 'G', 'T',  'N', '-', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', '-',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'A', 'N', 'C',  'N', 'N', 'N', 'G',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'T', 'T', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'A', 'N', 'C',  'N', 'N', 'N', 'G',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'T', 'T', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',
       'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N',  'N', 'N', 'N', 'N'
};
*/

class ContigPolisher : public Tool{
    
public:


	struct Alignment{
		u_int32_t _contigIndex;
		//u_int64_t _readIndex;
		bool _strand;
		u_int32_t _readStart;
		u_int32_t _readEnd;
		u_int32_t _contigStart;
		u_int32_t _contigEnd;
		float _identity;
		//float _score;
		//u_int64_t _length;
		
		u_int64_t length() const{
			return std::max((u_int64_t)(_readEnd - _readStart), (u_int64_t)(_contigEnd - _contigStart));
		}

		float score() const{
			return (_contigEnd - _contigStart) * _identity;
		}

	};


	string _inputFilename_reads;
	string _inputFilename_contigs;
	int _nbCores;
	size_t _windowLength;
	size_t _windowLengthVariance;
	size_t _maxWindowCopies;
	//string _mapperOutputExeFilename;
	bool _useQual;
	string _outputDir;
	string _tmpDir;
	string _readPartitionDir;
	bool _circularize;
	u_int64_t _minContigLength;
	
	string _outputFilename_contigs;
	string _outputFilename_mapping;
	u_int64_t _maxMemory;
	double _qualityThreshold;
	bool _isMetaMDBG;

	//abpoa_para_t *abpt;
	

	//unordered_set<string> _isContigCircular;
	//unordered_set<u_int32_t> _isReadCircular;
	//unordered_map<u_int64_t, u_int64_t> _contigLength;
	//unordered_map<string, vector<string>> _contigMapLeft;
	//unordered_map<string, vector<string>> _contigMapRight;
	//unordered_map<u_int32_t, vector<u_int32_t>> _contigHitPos;
	unordered_map<u_int32_t, u_int32_t> _contigLength;
	unordered_map<u_int32_t, float> _contigCoverages;

	u_int64_t _checksumWrittenReads;

	struct ContigRead{
		u_int32_t _contigIndex;
		u_int64_t _readIndex;

		bool operator==(const ContigRead &other) const{
			return _contigIndex == other._contigIndex && _readIndex == other._readIndex;
		}

		size_t hash() const{
			std::size_t seed = 2;
			seed ^= _contigIndex + 0x9e3779b9 + (seed << 6) + (seed >> 2);
			seed ^= _readIndex + 0x9e3779b9 + (seed << 6) + (seed >> 2);
			return seed;
		}

	};

	struct ContigRead_hash {
		size_t operator()(const ContigRead& p) const
		{
			return p.hash();
		}
	};
	
	struct Window{
		DnaBitset2* _sequence;
		string _quality;
		u_int32_t _posStart;
		u_int32_t _posEnd;
		float _score;
	};

	ContigPolisher(): Tool (){

	}


	void parseArgs(int argc, char* argv[]){


		string ARG_NO_QUAL = "noqual";
		string ARG_IS_METAMDBG = "metaMDBG";
		string filenameExe = argv[0];
		//_logFile << filenameExe << endl;

		//fs::path pa(filenameExe);
		//_mapperOutputExeFilename = pa.parent_path().string() + "/mapper";
		//_logFile << _mapperOutputExeFilename << endl;
		//exit(1);

		/*
		cxxopts::Options options("ToBasespace", "");
		options.add_options()
		("contigs", "", cxxopts::value<string>())
		("reads", "", cxxopts::value<string>())
		("tmpDir", "", cxxopts::value<string>())
		(ARG_USE_QUAL, "", cxxopts::value<bool>()->default_value("false"))
		(ARG_CIRCULARIZE, "", cxxopts::value<bool>()->default_value("false"))
		(ARG_NB_CORES, "", cxxopts::value<int>()->default_value(NB_CORES_DEFAULT));


		options.parse_positional({"contigs", "reads", "tmpDir"});
		options.positional_help("contigs reads tmpDir");


		//("k,kminmerSize", "File name", cxxopts::value<std::string>())
		//("v,verbose", "Verbose output", cxxopts::value<bool>()->default_value("false"))
		//;

		if(argc <= 1){
			_logFile << options.help() << endl;
			exit(0);
		}

		cxxopts::ParseResult result;

		try{
			result = options.parse(argc, argv);

			_inputFilename_reads = result["reads"].as<string>();
			_inputFilename_contigs = result["contigs"].as<string>();
			_outputDir = result["tmpDir"].as<string>();;
			_nbCores = result[ARG_NB_CORES].as<int>();
			_useQual = result[ARG_USE_QUAL].as<bool>();
			_circularize = result[ARG_CIRCULARIZE].as<bool>();
			_windowLength = 500;
			_maxWindowCopies = 10000; //21;
			_qualityThreshold = 10.0;
			_minContigLength = 1000000;
			
		}
		catch (const std::exception& e){
			std::_logFile << options.help() << std::endl;
			std::cerr << e.what() << std::endl;
			std::exit(EXIT_FAILURE);
		}
		*/
	
		args::ArgumentParser parser("polish", ""); //"This is a test program.", "This goes after the options."
		
		//args::ValueFlag<std::string> arg_outputDir(parser, "", "Output dir for contigs and temporary files", {ARG_OUTPUT_DIR2});
		//args::NargsValueFlag<std::string> arg_readFilenames_hifi(parser, "", "PacBio HiFi read filename(s) (separated by space)", {ARG_INPUT_HIFI}, 2);
		//args::NargsValueFlag<std::string> arg_readFilenames_nanopore(parser, "", "nanopore R10.4+ read filename(s) (separated by space)", {ARG_INPUT_NANOPORE}, 2);
		//args::ValueFlag<int> arg_nbCores(groupInputOutput, "", "Number of cores", {ARG_NB_CORES2}, NB_CORES_DEFAULT_INT);

		args::Positional<std::string> arg_contigs(parser, "contigs", "Contig filename to be corrected", args::Options::Required);
		args::Positional<std::string> arg_outputDir(parser, "outputDir", "Output dir for contigs and temporary files", args::Options::Required);
		//args::PositionalList<std::string> arg_readFilenames(parser, "reads", "Read filename(s) used for correction (separated by space)", args::Options::Required);
		args::ValueFlag<int> arg_nbWindows(parser, "", "Maximum read coverage used for contig correction (increase for better correction)", {ARG_NB_WINDOWS}, 0);
		//args::ValueFlag<string> arg_minimap2params(parser, "", "Set any minimap2 options (e.g. \"-x map-ont\")", {"minimap2-options"}, "");
		args::Flag arg_noQual(parser, "", "Do not use qualities during correction", {ARG_NO_QUAL});
		args::Flag arg_isMetaMDBG(parser, "", "Do not use qualities during correction", {ARG_IS_METAMDBG}, args::Options::Hidden);
		args::ValueFlag<int> arg_nbCores(parser, "", "Number of cores", {ARG_NB_CORES2}, NB_CORES_DEFAULT_INT);
		//args::Flag arg_useCirculize(parser, "", "Check if contigs are circular and add a flag in contig header (l: linear, c: circular)", {ARG_CIRCULARIZE});
		args::Flag arg_help(parser, "", "", {'h', "help"}, args::Options::Hidden);
		//args::HelpFlag help(parser, "help", "Display this help menu", {'h'});
		//args::CompletionFlag completion(parser, {"complete"});

		//(ARG_INPUT_FILENAME_TRUTH, "", cxxopts::value<string>()->default_value(""))
		//(ARG_MINIMIZER_LENGTH, "", cxxopts::value<int>()->default_value("13"))
		//(ARG_MINIMIZER_DENSITY, "", cxxopts::value<float>()->default_value("0.005"))
		//(ARG_NB_CORES, "", cxxopts::value<int>()->default_value(NB_CORES_DEFAULT))
		//(ARG_BLOOM_FILTER, "", cxxopts::value<bool>()->default_value("false"));

		try
		{
			parser.ParseCLI(argc, argv);
		}
		catch (const args::Help&)
		{
			cerr << parser;
			exit(0);
		}
		catch (const std::exception& e)
		{
			cerr << parser;
			//_logFile << endl;
			cerr << e.what() << endl;
			exit(0);
		}

		if(arg_help){
			cerr << parser;
			exit(0);
		}
		/*
		if(!arg_readFilenames_hifi && !arg_readFilenames_nanopore){
			std::cerr << parser;
			cerr << " One of the arguments ";
			for(const string& arg : possibleInputArguments){
				cerr << arg + " ";
			}
			cerr << "is required" << endl;
			exit(1);
		}

		if(arg_readFilenames_hifi && arg_readFilenames_nanopore){
			std::cerr << parser;
			cerr << " Choose only one of the arguments ";
			for(const string& arg : possibleInputArguments){
				cerr << arg + " ";
			}
			cerr << endl;
			exit(1);
		}
		*/

		_inputFilename_contigs = args::get(arg_contigs);
		_outputDir = args::get(arg_outputDir);
		_nbCores = args::get(arg_nbCores);
		//_minimap2Params = args::get(arg_minimap2params);

		_useQual = true;
		if(arg_noQual){
			_useQual = false;
		}

		_isMetaMDBG = false;
		if(arg_isMetaMDBG){
			_isMetaMDBG = true;
		}

		_circularize = false;
		//if(arg_useCirculize){
		//	_circularize = true;
		//}



		_windowLength = 500;
		_windowLengthVariance = _windowLength*0.01;
		_maxWindowCopies = args::get(arg_nbWindows);
		_qualityThreshold = 10.0;
		_minContigLength = 0;

		_tmpDir = _outputDir;// + "/tmp/";
		//if(!fs::exists(_tmpDir)){
		//	fs::create_directories(_tmpDir);
		//}

			_readPartitionDir = _tmpDir + "/_polish_readPartitions/";
		_inputFilename_reads = _tmpDir + "/input.txt";
		/*
		if(arg_readFilenames_hifi){
			Commons::createInputFile(args::get(arg_readFilenames_hifi), _inputFilename_reads);
		}
		else if(arg_readFilenames_nanopore){
			Commons::createInputFile(args::get(arg_readFilenames_nanopore), _inputFilename_reads);
		}
		*/

		//Commons::createInputFile(args::get(arg_readFilenames), _inputFilename_reads);

		openLogFile(_tmpDir);


		Logger::get().debug() << "";
		Logger::get().debug() << "Contigs: " << _inputFilename_contigs;
		Logger::get().debug() << "Reads: " << _inputFilename_reads;
		Logger::get().debug() << "Use quality: " << _useQual ;
		Logger::get().debug() << "Max window variants: " << _maxWindowCopies ;
		Logger::get().debug() << "";

		//fs::path p(_inputFilename_contigs);
		//while(p.has_extension()){
		//	p.replace_extension("");
		//}



		//_outputFilename_contigs = p.string() + "_corrected.fasta.gz";
		//_outputFilename_mapping = p.string() + "_tmp_mapping__.paf";
		_outputFilename_contigs = _outputDir + "/contigs_polished.fasta.gz";
		_outputFilename_mapping = _readPartitionDir + "/polish_mapping.paf.gz";
		//_outputFilename_mapping = "/mnt/gpfs/gaetan/tmp/debug_polish/racon_align.paf";

		_maxMemory = 4000000000ull;
		//_maxMemory = 2000000ull;
		//_nbCores = 2;


		_fields = new vector<string>();
		_fields_optional = new vector<string>();


	}


	u_int64_t _currentContigSize;
	//u_int64_t _windowByteSize;
	//unordered_set<u_int32_t> _validContigIndexes;
	gzFile _outputContigFile;

    void execute (){


		_outputContigFile = gzopen(_outputFilename_contigs.c_str(),"wb");

		/*
		abpt = abpoa_init_para();
		abpt->out_msa = 0; // generate Row-Column multiple sequence alignment(RC-MSA), set 0 to disable
		abpt->out_cons = 1; // generate consensus sequence, set 0 to disable
		abpt->w = 6, abpt->k = 9; abpt->min_w = 10; // minimizer-based seeding and partition
		abpt->progressive_poa = 1;
		abpt->max_n_cons = 1;

		abpoa_post_set_para(abpt);
		*/
		
		
		//mapReads();
		indexContigName();
		indexReadName();
		//if(_circularize) executeCircularize();
		
		parseAlignmentsGz(false);

		_contigName_to_contigIndex.clear();
		_readName_to_readIndex.clear();

		computeContigCoverages();
		//writeAlignmentBestHits();
		//parseAlignments(true, false);
		partitionReads();
		

		/*
		for(size_t i=0; i<10000000ull; i++){
			_contigToPartition[i] = 0;
		}

		_nbPartitions = 1;
		_partitionNbReads[0] = 10000;
		*/
		for(size_t i=0; i<_nbPartitions; i++){
			processPartition(i);
		}

		//exit(1);
		//indexContigName();
		//indexReadName();

		/*
		u_int64_t totalByteSize = 0;

		u_int64_t contigIndex = 0;
		gzFile fp;
		kseq_t *seq;
		int slen = 0, qlen = 0;
		fp = gzopen(_inputFilename_contigs.c_str(), "r");
		seq = kseq_init(fp);

		while (kseq_read(seq) >= 0){

			totalByteSize += loadContig(contigIndex, string(seq->seq.s));
			//_logFile << totalByteSize << " " << _windowByteSize << endl;
			if(totalByteSize >= _maxMemory){
				processPass();
				clearPass();
				totalByteSize = 0;
			}

			contigIndex += 1;
		}
		*/
			
		//processPass();

		/* !!!!!!!!!!!!
		kseq_destroy(seq);
		gzclose(fp);
		*/
		gzclose(_outputContigFile);
		fs::remove_all(_readPartitionDir);

		//closeLogFile();
	}

	/*
	void executeCircularize(){

		cerr << "Detecting circular contigs..." << endl;

		indexCircularContigs();
		indexMappingOnContigEnds();
		detectCircularContigs();

		_contigMapRight.clear();
		_contigMapLeft.clear();
		//_contigLength.clear();
		//_isContigCircular.clear();
	}

	void indexCircularContigs(){

		auto fp = std::bind(&ContigPolisher::indexCircularContigs_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false, _logFile);
		readParser.parse(fp);
    
	}

	void indexCircularContigs_read(const Read& read){

		//u_int64_t contigIndex = Utils::contigName_to_contigIndex(read._header);

		//_logFile << "Contig: " << read._index << " " << read._seq.size() << endl;

		if (read._seq.size() < _minContigLength) return;

		//u_int32_t contigIndex = Utils::contigName_to_contigIndex(read._header);
		//_contigLength[read._index] = read._seq.size();

		char lastChar = read._header[read._header.size()-1];
		if(lastChar == 'c'){
			_isContigCircular.insert(Utils::shortenHeader(read._header));
		}

	}

	void indexMappingOnContigEnds(){

		cerr << "\tParsing alignments" << endl;

		_alignments.clear();
		//_indexPartitionOnly = indexPartitionOnly;

		PafParser pafParser(_outputFilename_mapping);
		auto fp = std::bind(&ContigPolisher::indexMappingOnContigEnds_read, this, std::placeholders::_1);
		pafParser.parse(fp);

	}

	void indexMappingOnContigEnds_read(const string& line){

    	long maxHang = 100;

		double errorThreshold = 0.3;

		GfaParser::tokenize(line, _fields, '\t');

		//_logFile << line << endl;

		const string& readName = Utils::shortenHeader((*_fields)[0]);
		const string& contigName = Utils::shortenHeader((*_fields)[5]);
		

		u_int32_t readStart = stoull((*_fields)[2]);
		u_int32_t readEnd = stoull((*_fields)[3]);
		u_int32_t contigLength = stoull((*_fields)[6]);
		u_int32_t contigStart = stoull((*_fields)[7]);
		u_int32_t contigEnd = stoull((*_fields)[8]);

		u_int64_t nbMatches = stoull((*_fields)[9]);
		u_int64_t alignLength = stoull((*_fields)[10]);
		u_int64_t queryLength = stoull((*_fields)[1]);

		bool strand = (*_fields)[4] == "-";
		//float score = (double) nbMatches / (double) queryLength;
		//float score2 = (double) nbMatches / (double) alignLength;

		//u_int32_t contigIndex = mappingIndex._contigName_to_contigIndex[contigName];
		//u_int64_t readIndex = mappingIndex._readName_to_readIndex[readName];
		//u_int64_t length = std::max(readEnd - readStart, contigEnd - contigStart);

		if(alignLength < 3000) return;
		if (contigLength < _minContigLength) return;
		//_logFile << contigIndex << " " << readIndex << endl;

		double length = max((double)(contigEnd - contigStart), (double)(readEnd - readStart));
		double error = 1 - min((double)(contigEnd - contigStart), (double)(readEnd - readStart)) / length;
		//_logFile << error << " " << errorThreshold << endl;
		
		if(error > errorThreshold) return;




		long hangLeft = contigStart;
		long hangRight = contigLength - contigEnd;

		if (hangLeft < maxHang){
			_contigMapLeft[contigName].push_back(readName);
			//_logFile << lineInput << endl;
		}
		if (hangRight < maxHang){
			_contigMapRight[contigName].push_back(readName);
			//_logFile << lineInput << endl;
		}

	}

	
	void detectCircularContigs(){

		auto fp = std::bind(&ContigPolisher::detectCircularContigs_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false, _logFile);
		readParser.parse(fp);
    
	}

	void detectCircularContigs_read(const Read& read){

		const string& contigName = Utils::shortenHeader(read._header);

		//u_int64_t contigIndex = read._index; //Utils::contigName_to_contigIndex(read._header);

		u_int8_t isCircular = CONTIG_LINEAR
		u_int64_t nbSupportingReads = countCircularReads(contigName);

		//char lastChar = read._header[read._header.size()-1];




		//string header = read._header;
		//header.pop_back();
		
		//if(isCircular){
		//	header += "c";
			//_isContigCircular[read._index] = true;
		//}
		//else{
			//_isContigCircular[read._index] = false;
		//	header += "l";
		//}

		//header = ">" + header + '\n';
		//gzwrite(_outputContigFile, (const char*)&header[0], header.size());
		//string contigSequence = read._seq + '\n';
		//gzwrite(_outputContigFile, (const char*)&contigSequence[0], contigSequence.size());

		if(read._seq.size() >= _minContigLength){
			_logFile << read._header << " " << (_isContigCircular.find(contigName) != _isContigCircular.end()) << " " << nbSupportingReads << endl;
		}

		if(_isContigCircular.find(contigName) != _isContigCircular.end()){
			//isCircular = true;
		}
		else{
			if(nbSupportingReads >= 3){
				//isCircular = true;
				_isContigCircular.insert(contigName);
			}
		}

	}
	



	u_int64_t countCircularReads(const string& contigIndex){

		if((_contigMapLeft.find(contigIndex) == _contigMapLeft.end()) || (_contigMapRight.find(contigIndex) == _contigMapRight.end())) return 0;

		//_logFile << "---" << endl;
		u_int64_t nbSupportingReads = 0;


		const vector<string>& leftReads = _contigMapLeft[contigIndex];
		const vector<string>& rightReads = _contigMapRight[contigIndex];

		//_logFile << leftReads.size() << endl;
		//_logFile << rightReads.size() << endl;

		for(const string& readIndex : leftReads){
			//_logFile << readIndex << endl;
			if(std::find(rightReads.begin(), rightReads.end(), readIndex) != rightReads.end()){
				nbSupportingReads += 1;
				//_logFile << readIndex << endl;
				//_isReadCircular.insert(readIndex);
			}
		}

		return nbSupportingReads;


	}
	*/

	int _contigCoverageWindow = 100;

	void computeContigCoverages(){
		
		Logger::get().debug() << "Computing contig coverages...";

		unordered_map<u_int32_t, vector<pair<u_int32_t, u_int32_t>>> contigHits;
		auto fp = std::bind(&ContigPolisher::computeContigCoverages_setup_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);


		for(const auto& it : _alignments){

			//const string& contigName = it.second._contigName;
			u_int32_t contigIndex = it.second._contigIndex;

			//if(contigHits.find(contigIndex) == contigHits.end()){
			//	contigHits[contigIndex] = {};
			//}

			contigHits[contigIndex].push_back({it.second._contigStart, it.second._contigEnd});

			//for(size_t i=it.second._contigStart; i<it.second._contigEnd; i++){
			//	if(i%_contigCoverageWindow != 0) continue;
				//cout << i/_contigCoverageWindow << " " << contigHitPos.size() << endl;
			//	if(i/_contigCoverageWindow >= contigHitPos.size()) continue;
			//	contigHitPos[i/_contigCoverageWindow] += 1;
				//cout << i/_contigCoverageWindow << " " << contigHitPos.size() << endl;
			//}

		}

		for(auto& it : contigHits){

			//cout << it.first << " " << _contigLength[it.first] << endl;
			vector<u_int32_t> coverages(_contigLength[it.first], 0);

			for(auto& interval : it.second){

				for(size_t i=interval.first; i<interval.second; i++){
					coverages[i] += 1;
				}
			}
			//cout << it.first << endl;
			//for(u_int32_t count : it.second){
			//	cout << count << " ";
			//}
			//cout << endl;

			if (coverages.size() < 80 *2){
				_contigCoverages[it.first] = 1;
			}
			else{
				u_int64_t sum = 0;
				for(long i=75; i<((long)coverages.size())-75; i++){
					sum += coverages[i];
				}

				float coverage = sum / ((double)coverages.size());  //Utils::compute_median(coverages);
				_contigCoverages[it.first] = coverage;
			}


			//Logger::get().debug() << "Coverage " << it.first << ": " << coverage << endl;
		}

		//_contigHitPos.clear();
		_contigLength.clear();
	}

	
	void computeContigCoverages_setup_read(const Read& read){

		_contigLength[read._index] = read._seq.size();
		//int nbCounts = read._seq.size() / _contigCoverageWindow;
		//cout << Utils::shortenHeader(read._header) << " " << nbCounts << endl;
		//_contigHitPos[read._index].resize(nbCounts, 0);
	}

	/*
	void computeContigCoverages(){
		
		Logger::get().debug() << "Computing contig coverages...";

		auto fp = std::bind(&ContigPolisher::computeContigCoverages_setup_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);


		for(const auto& it : _alignments){

			//const string& contigName = it.second._contigName;
			u_int32_t contigIndex = it.second._contigIndex;
			vector<u_int32_t>& contigHitPos = _contigHitPos[contigIndex];

			for(size_t i=it.second._contigStart; i<it.second._contigEnd; i++){
				if(i%_contigCoverageWindow != 0) continue;
				//cout << i/_contigCoverageWindow << " " << contigHitPos.size() << endl;
				if(i/_contigCoverageWindow >= contigHitPos.size()) continue;
				contigHitPos[i/_contigCoverageWindow] += 1;
				//cout << i/_contigCoverageWindow << " " << contigHitPos.size() << endl;
			}

		}

		for(auto& it : _contigHitPos){
			//cout << it.first << endl;
			//for(u_int32_t count : it.second){
			//	cout << count << " ";
			//}
			//cout << endl;

			
			float coverage = Utils::compute_median(it.second);
			_contigCoverages[it.first] = coverage;

			//Logger::get().debug() << "Coverage " << it.first << ": " << coverage << endl;
		}

		_contigHitPos.clear();
	}


	void computeContigCoverages_setup_read(const Read& read){

		int nbCounts = read._seq.size() / _contigCoverageWindow;
		//cout << Utils::shortenHeader(read._header) << " " << nbCounts << endl;
		_contigHitPos[read._index].resize(nbCounts, 0);
	}
	*/
	/*
	u_int64_t loadContig(u_int64_t contigIndex, const string& seq){

		//_validContigIndexes.insert(contigIndex);

		u_int64_t totalByteSize = 0;

		_contigSequences[contigIndex] = seq;

		//_logFile << "load contig: " << contigIndex << " " << seq.size() << endl;
		size_t nbWindows = ceil((double)seq.size() / (double)_windowLength);
		vector<vector<Window>> windows(nbWindows);
		//_logFile << "Nb windows: " << nbWindows << endl;

		_contigWindowSequences[contigIndex] = windows;

		//_logFile << nbWindows << " " << nbWindows * _windowByteSize << endl;
		return nbWindows * _windowByteSize;
	}
	*/
	
	class PartitionFile{

		public:

		gzFile _file;
		omp_lock_t _mutex;

		PartitionFile(u_int32_t partition, const string& tmpDir){
			const string& partitionFilename = tmpDir + "/part_" + to_string(partition) + ".gz";
			_file = gzopen(partitionFilename.c_str(), "wb");

			omp_init_lock(&_mutex);
		}

		~PartitionFile(){
			gzclose(_file);
			omp_destroy_lock(&_mutex);
		}
	};

	unordered_map<u_int32_t, u_int32_t> _contigToPartition;
	vector<PartitionFile*> _partitionFiles;
	unordered_map<u_int32_t, u_int64_t> _partitionNbReads;

	
	struct ContigStats{
		u_int32_t _contigIndex;
		u_int32_t _length;
	};

	vector<ContigStats> _contigStats;
	u_int32_t _nbPartitions;


	void partitionReads(){


		Logger::get().debug() << "Partitionning reads on the disk...";
		collectContigStats();

		int nbPartitionsInit = max((u_int32_t)1, (u_int32_t)_nbCores);
		u_int64_t totalByteSize = 0;

		vector<u_int64_t> memoryPerPartitions(nbPartitionsInit, 0);


		for(const ContigStats& contigStat : _contigStats){

			int partitionIndex = 0;
			u_int64_t minMemory = -1;

			for(size_t i=0; i<memoryPerPartitions.size(); i++){
				if(memoryPerPartitions[i] < minMemory){
					minMemory = memoryPerPartitions[i];
					partitionIndex = i;
				}
			}

			u_int64_t currentParitionMemory = memoryPerPartitions[partitionIndex];
			u_int64_t contigMemory = computeContigMemory(contigStat._contigIndex, contigStat._length);

			//cout << "lala " << contigMemory << endl;
			
			if(currentParitionMemory > 0 && currentParitionMemory+contigMemory > _maxMemory){
				memoryPerPartitions.push_back(0);
				partitionIndex = memoryPerPartitions.size()-1;
			}
			
			memoryPerPartitions[partitionIndex] += contigMemory;
			_contigToPartition[contigStat._contigIndex] = partitionIndex;
			
			//cout << "-----------" << endl;
			//for(size_t i=0; i<memoryPerPartitions.size(); i++){
			//	cout << i << ": " << memoryPerPartitions[i] << endl;
			//}

			//totalByteSize += 
			//if(totalByteSize >= _maxMemory){
			//	_nbPartitions += 1;
			//	totalByteSize = 0;
			//}
			//_contigToPartition[contigIndex] = partition;

		}
		//if(totalByteSize >= _maxMemory){
		//	_nbPartitions += 1;
		//}


        //srand(time(NULL));
        //std::random_shuffle(_contigStats.begin(), _contigStats.end());
		

		
		/*
		u_int64_t totalByteSize = 0;
		_nbPartitions = 0;

		for(const ContigStats& contigStat : _contigStats){

			totalByteSize += computeContigMemory(contigStat._contigName, contigStat._length);
			if(totalByteSize >= _maxMemory){
				_nbPartitions += 1;
				totalByteSize = 0;
			}
			//_contigToPartition[contigIndex] = partition;

		}
		if(totalByteSize >= _maxMemory){
			_nbPartitions += 1;
		}

		_nbPartitions = max(_nbPartitions, (u_int32_t)_nbCores);
		_nbPartitions = min(_nbPartitions, (u_int32_t)_contigStats.size());
		//u_int64_t nbContigsPerPartition = _contigStats.size() / _nbPartitions;
		_logFile << "Nb partitions: " << _nbPartitions << endl;
		//_logFile << "Contigs per partition: " << nbContigsPerPartition << endl;

		for(u_int32_t i=0; i<_nbPartitions; i++){
			_partitionNbReads[i] = 0;
			_partitionFiles.push_back(new PartitionFile(i, _readPartitionDir));
		}

		u_int32_t partition = 0;

		u_int64_t nbContigs = 0;
		//totalByteSize = 0;

		for(const ContigStats& contigStat : _contigStats){

			//totalByteSize += computeContigMemory(contigStat._length);
			_contigToPartition[contigStat._contigName] = partition;
			//_logFile << nbContigs << " " << partition << endl;
			nbContigs += 1;

			//if(partition == 0){
			//	_logFile << "Contig in partition 0: " << contigStat._contigIndex << endl;
			//}
			
			if(nbContigs >= nbContigsPerPartition){
				//totalByteSize = 0;
				partition += 1;
				partition = min(partition, _nbPartitions-1);
				nbContigs = 0;
			}

			//_contigToPartition[contigIndex] = partition;

		}
		//if(totalByteSize >= _maxMemory){
		//	_partitionFiles.push_back(new PartitionFile(partition, _tmpDir));
		//}
		*/


		_nbPartitions = 0;
		for(size_t i=0; i<memoryPerPartitions.size(); i++){
			if(memoryPerPartitions[i] > 0){
				_nbPartitions += 1;
			}
		}
		
		//memoryPerPartitions.size();

		for(u_int32_t i=0; i<_nbPartitions; i++){
			_partitionNbReads[i] = 0;
			_partitionFiles.push_back(new PartitionFile(i, _readPartitionDir));
		}


		_contigStats.clear();
		//_contigCoverages.clear();

		Logger::get().debug() << "Nb partitions: " << _nbPartitions;

		//vector<vector<u_int32_t>> contigPartitions;
		//vector<u_int32_t> contigPartition;

		/*
		u_int64_t totalByteSize = 0;
		u_int64_t contigIndex = 0;
		u_int32_t partition = 0;

		gzFile fp;
		kseq_t *seq;
		int slen = 0, qlen = 0;
		fp = gzopen(_inputFilename_contigs.c_str(), "r");
		seq = kseq_init(fp);

		//"todo: nbPartition en fonction du maxMemory mais aussi nb thread available + besoin de randomiser l'ordre des contigs (créer des partitions equilibré"
		while (kseq_read(seq) >= 0){

			totalByteSize += computeContigMemory(strlen(seq->seq.s));
			_contigToPartition[contigIndex] = partition;

			//_logFile << totalByteSize << " " << _windowByteSize << endl;
			if(totalByteSize >= _maxMemory){

				//omp_lock_t writelock;
				//omp_init_lock(&writelock);

				_partitionFiles.push_back(new PartitionFile(partition, _tmpDir));
				//contigPartitions.push_back(contigPartition);
				//contigPartition.clear();
				totalByteSize = 0;
				partition += 1;
			}

			contigIndex += 1;
		}

		if(totalByteSize > 0){
			_partitionFiles.push_back(new PartitionFile(partition, _tmpDir));
		}


		kseq_destroy(seq);
		gzclose(fp);
		*/



		writeReadPartitions();

		//readToContigIndex.clear();
		//_contigToPartition.clear();
		//_alignments.clear();

		for(PartitionFile* partitionFile : _partitionFiles){
			delete partitionFile;
		}
		_partitionFiles.clear();
	}


	void collectContigStats(){
		auto fp = std::bind(&ContigPolisher::collectContigStats_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);
	}
	
	void collectContigStats_read(const Read& read){
		_contigStats.push_back({(u_int32_t)read._index, (u_int32_t)read._seq.size()});
	}

	u_int64_t computeContigMemory(u_int32_t contigIndex, size_t contigLength){
		
		u_int64_t windowByteSize = 0;
		u_int32_t contigCoverage = _contigCoverages[contigIndex];
		contigCoverage = max((u_int32_t)1, contigCoverage);

		//cout << contigCoverage << endl;
		if(_useQual){
			windowByteSize = contigCoverage  * ((_windowLength/4) + _windowLength);
		}
		else{
			windowByteSize = contigCoverage  * (_windowLength/4);
		}

		size_t nbWindows = ceil((double)contigLength / (double)_windowLength);
		return nbWindows * windowByteSize;
	}


	void writeReadPartitions(){
		_checksumWrittenReads = 0;
		ReadParserParallel readParser(_inputFilename_reads, false, false, _nbCores);
		readParser.parse(ReadPartitionFunctor(*this));
	}

	class ReadPartitionFunctor {

		public:

		ContigPolisher& _contigPolisher;


		ReadPartitionFunctor(ContigPolisher& contigPolisher) : _contigPolisher(contigPolisher){
		}

		ReadPartitionFunctor(const ReadPartitionFunctor& copy) : _contigPolisher(copy._contigPolisher){
		}

		~ReadPartitionFunctor(){
		}

		void operator () (const Read& read) {

			u_int32_t readIndex = read._index;
			//const string& readName = Utils::shortenHeader(read._header);

			if(read._index % 10000 == 0) Logger::get().debug() << "\t" << read._index;
			
			if(_contigPolisher._alignments.find(readIndex) == _contigPolisher._alignments.end()) return;


			//unordered_set<u_int32_t> writtenPartitions;

			//for(const Alignment& al : _contigPolisher._alignments[readIndex]){
			const Alignment& al = _contigPolisher._alignments[readIndex];
			u_int32_t contigIndex = al._contigIndex;
			//if(contigName != "ctg90297c") return;
			//u_int32_t contigIndex = al._contigIndex; //_contigPolisher._alignments[readIndex]._contigIndex;
			//_logFile << contigIndex << " " << (_contigPolisher._contigToPartition.find(contigIndex) != _contigPolisher._contigToPartition.end()) << endl;
			u_int32_t partition = _contigPolisher._contigToPartition[contigIndex];

			//if(writtenPartitions.find(partition) != writtenPartitions.end()) return;
			//writtenPartitions.insert(partition);

			//_logFile << partition << endl;
			PartitionFile* partitionFile = _contigPolisher._partitionFiles[partition];

			omp_set_lock(&partitionFile->_mutex);
			
			//if(partition == 0){
				//_logFile << "Read: " << readIndex << endl;
			//}

			bool isFastq = read._qual.size() > 0 && _contigPolisher._useQual;

			_contigPolisher._partitionNbReads[partition] += 1;

			u_int32_t readSize = read._seq.size();

			if(isFastq){
				//string header = '@' + to_string(read._index) + '\n';
				string header = '@' + to_string(readIndex) + '\n';
				string seq = read._seq + '\n';
				gzwrite(partitionFile->_file, (const char*)&header[0], header.size());
				gzwrite(partitionFile->_file, (const char*)&seq[0], seq.size());
				static string strPlus = "+\n";
				gzwrite(partitionFile->_file, (const char*)&strPlus[0], strPlus.size());
				string qual = read._qual + '\n';
				gzwrite(partitionFile->_file, (const char*)&qual[0], qual.size());
			}
			else{
				//string header = '>' + to_string(read._index) + '\n';
				string header = '>' + to_string(readIndex) + '\n';
				string seq = read._seq + '\n';
				gzwrite(partitionFile->_file, (const char*)&header[0], header.size());
				gzwrite(partitionFile->_file, (const char*)&seq[0], seq.size());
			}

			//for(char letter : readName){
			//	_contigPolisher._checksumWrittenReads += letter;
			//}
			//_logFile << readName << " " << _contigPolisher._checksumWrittenReads << endl;

			//gzwrite(partitionFile->_file, (const char*)&readIndex, sizeof(readIndex));
			//gzwrite(partitionFile->_file, (const char*)&readSize, sizeof(readSize));
			//gzwrite(partitionFile->_file, read._seq.c_str(), read._seq.size());
			//gzwrite(partitionFile->_file, read._qual.c_str(), read._qual.size());
			omp_unset_lock(&partitionFile->_mutex);
			//}
		}
	};

	u_int32_t _currentPartition;

	void processPartition(u_int32_t partition){
		_currentPartition = partition;
		//if(_contigSequences.size() == 0) return;
		Logger::get().debug() << "Processing partition: " << _currentPartition << "/" << _nbPartitions;

		if(_partitionNbReads[partition] == 0) return;


		//indexContigs();
		clearPass();
		loadContigs();
		//parseAlignmentsGz(true);

		
		//_contigName_to_contigIndex.clear();
		//_readName_to_readIndex.clear();

		collectWindowSequences(_currentPartition);
		performCorrection();
		//if(fs::exists(_outputFilename_mapping)) fs::remove(_outputFilename_mapping);
	}

	void loadContigs(){
		auto fp = std::bind(&ContigPolisher::loadContigs_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);
	}
	
	void loadContigs_read(const Read& read){

		u_int32_t contigIndex = read._index;
		//const string& contigName = Utils::shortenHeader(read._header);
		u_int32_t contigPartition = _contigToPartition[contigIndex];

		if(contigPartition != _currentPartition) return;
		

		//if(_currentPartition == 0) _logFile << "Loading contig in partition 0: " << contigIndex << endl;
		_contigSequences[contigIndex] = read._seq;
		size_t nbWindows = ceil((double)read._seq.size() / (double)_windowLength);
		vector<vector<Window>> windows(nbWindows);

		_contigWindowSequences[contigIndex] = windows;
		_contigHeaders[contigIndex] = read._header;
	}

	//_validContigIndexes.insert(contigIndex);

	//u_int64_t totalByteSize = 0;


	//_logFile << "load contig: " << contigIndex << " " << seq.size() << endl;
	//_logFile << "Nb windows: " << nbWindows << endl;

	

	//_logFile << nbWindows << " " << nbWindows * _windowByteSize << endl;
	//return nbWindows * _windowByteSize;


	void clearPass(){
		_contigSequences.clear();
		//_validContigIndexes.clear();
		_contigWindowSequences.clear();
		_contigHeaders.clear();
		//_alignments.clear();
	}
	/*
	void loadContigs(){
		auto fp = std::bind(&ContigPolisher::loadContigs_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);
	}
	*/


	void indexContigName(){
		
		//cout << "Indexing contig names" << endl;

		auto fp = std::bind(&ContigPolisher::indexContigName_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);
	}

	void indexContigName_read(const Read& read){

		_contigName_to_contigIndex[Utils::shortenHeader(read._header)] = read._index;
	}

	void indexReadName(){

		//cout << "Indexing read names" << endl;
		//cout << _inputFilename_reads << endl;
		auto fp = std::bind(&ContigPolisher::indexReadName_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_reads, false, false);
		readParser.parse(fp);

	}

	void indexReadName_read(const Read& read){
		//if(read._index % 100000 == 0) cout << read._index << endl;
		_readName_to_readIndex[Utils::shortenHeader(read._header)] = read._index;
	}

	/*
	struct Alignment{
		string _contigName;
		//u_int64_t _readIndex;
		bool _strand;
		u_int32_t _readStart;
		u_int32_t _readEnd;
		u_int32_t _contigStart;
		u_int32_t _contigEnd;
		//float _score;
		//u_int64_t _length;
		
		u_int64_t length() const{
			return std::max((u_int64_t)(_readEnd - _readStart), (u_int64_t)(_contigEnd - _contigStart));
		}
		
	};
	*/

	struct AlignmentPartitionning{
		u_int32_t _contigIndex;
		u_int32_t _length;
	};

	//unordered_map<string, u_int32_t> _contigName_to_contigIndex;
	//unordered_map<string, u_int64_t> _readName_to_readIndex;
	//unordered_map<u_int64_t, AlignmentPartitionning> _readToContigIndex;
	//unordered_map<u_int64_t, vector<Alignment>> _alignments;
	phmap::parallel_flat_hash_map<u_int32_t, Alignment> _alignments;
	phmap::parallel_flat_hash_map<u_int32_t, string> _contigSequences;
	phmap::parallel_flat_hash_map<u_int32_t, vector<vector<Window>>> _contigWindowSequences;
	phmap::parallel_flat_hash_map<u_int32_t, string> _contigHeaders;
	//unordered_map<ContigRead, u_int32_t, ContigRead_hash> _alignmentCounts;
	//u_int64_t _correctedContigIndex;

	phmap::parallel_flat_hash_map<string, u_int32_t> _contigName_to_contigIndex;
	phmap::parallel_flat_hash_map<string, u_int32_t> _readName_to_readIndex;

	/*
	void indexContigName(){
		
		_logFile << "Indexing contig names" << endl;

		auto fp = std::bind(&ContigPolisher::indexContigName_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_contigs, true, false);
		readParser.parse(fp);
	}
	
	void indexContigName_read(const Read& read){

		string minimap_name;

		auto find = read._header.find(' ');
		if(find == std::string::npos){
			minimap_name = read._header;
		}
		else{
		 	minimap_name = read._header.substr(0, find);
		}

		//_logFile << minimap_name << endl;
		_contigName_to_contigIndex[minimap_name] = read._index;
	}

	void indexReadName(){

		_logFile << "Indexing read names" << endl;
		auto fp = std::bind(&ContigPolisher::indexReadName_read, this, std::placeholders::_1);
		ReadParser readParser(_inputFilename_reads, false, false);
		readParser.parse(fp);

	}
	
	void indexReadName_read(const Read& read){
		//_logFile << read._index << endl;

		string minimap_name;

		auto find = read._header.find(' ');
		if(find == std::string::npos){
			minimap_name = read._header;
		}
		else{
		 	minimap_name = read._header.substr(0, find);
		}

		//string minimap_name = read._header.substr(0, read._header.find(' '));
		//_logFile << minimap_name << endl;
		_readName_to_readIndex[minimap_name] = read._index;
	}
	*/


	vector<string>* _fields;
	vector<string>* _fields_optional;

	void parseAlignmentsGz(bool indexPartitionOnly){

		Logger::get().debug() << "\tParsing alignments...";

		_alignments.clear();
		//_indexPartitionOnly = indexPartitionOnly;

		PafParser pafParser(_outputFilename_mapping);
		auto fp = std::bind(&ContigPolisher::parseAlignmentsGz_read, this, std::placeholders::_1);
		pafParser.parse(fp);

		/*
		//infile.close();

		//delete fields;
		//delete fields_optional;

		if(indexPartitionOnly){
			auto it = _alignments.begin();
			while (it != _alignments.end()) {

				const string& contigName = it->second._contigName;

				if(_contigSequences.find(contigName) == _contigSequences.end()){
					it = _alignments.erase(it);
				}
				else{
					it++;
				}
			}
		}
		*/

	}

	//void parseAlignmentsGz_read(const string& line){
		
	//}

	void parseAlignmentsGz_read(const string& line){

		//cout << line << endl;
		double errorThreshold = 0.3;
		//_logFile << lineInput << endl;
		//getchar();


		GfaParser::tokenize(line, _fields, '\t');

		//_logFile << line << endl;

		const string& readName = Utils::shortenHeader((*_fields)[0]);
		const string& contigName = Utils::shortenHeader((*_fields)[5]);
		

		u_int32_t readStart = stoull((*_fields)[2]);
		u_int32_t readEnd = stoull((*_fields)[3]);
		u_int32_t contigLength = stoull((*_fields)[6]);
		u_int32_t contigStart = stoull((*_fields)[7]);
		u_int32_t contigEnd = stoull((*_fields)[8]);

		u_int64_t nbMatches = stoull((*_fields)[9]);
		u_int64_t alignLength = stoull((*_fields)[10]);
		u_int64_t queryLength = stoull((*_fields)[1]);

		bool strand = (*_fields)[4] == "-";
		//float score = (double) nbMatches / (double) queryLength;
		//float score2 = (double) nbMatches / (double) alignLength;

		//u_int32_t contigIndex = mappingIndex._contigName_to_contigIndex[contigName];
		//u_int64_t readIndex = mappingIndex._readName_to_readIndex[readName];
		//u_int64_t length = std::max(readEnd - readStart, contigEnd - contigStart);


		//_logFile << contigIndex << " " << readIndex << endl;

		double length = max((double)(contigEnd - contigStart), (double)(readEnd - readStart));
		double error = 1 - min((double)(contigEnd - contigStart), (double)(readEnd - readStart)) / length;
		//_logFile << error << " " << errorThreshold << endl;
		
		if(error > errorThreshold) return;

		float identity =  ((float)nbMatches) / alignLength;

		u_int32_t readIndex = _readName_to_readIndex[readName];
		u_int32_t contigIndex = _contigName_to_contigIndex[contigName];

		//if(indexPartitionOnly && _contigSequences.find(contigName) == _contigSequences.end()) continue;


		//u_int32_t length = std::max((u_int64_t)(readEnd - readStart), (u_int64_t)(contigEnd - contigStart));
		Alignment align = {contigIndex, strand, readStart, readEnd, contigStart, contigEnd, identity}; //, score

		if(_alignments.find(readIndex) == _alignments.end()){
			_alignments[readIndex] = align;
		}
		else{

			const Alignment& existingAlign = _alignments[readIndex];

			//if(length >= existingAlign.length()){
			if(align.score() >= existingAlign.score()){
				_alignments[readIndex] = align;
			}

			/*
			bool isUpdated = false;
			//bool isBetter = false;
			for(Alignment& al: _alignments[readIndex]){
				if(al._contigIndex != contigIndex) continue;
				
				if(length > al.length()){

					al._contigIndex = contigIndex;
					al._strand = strand;
					al._readStart = readStart;
					al._readEnd = readEnd;
					al._contigStart = contigStart;
					al._contigEnd = contigEnd;

					//isBetter = true;
					isUpdated = true;
					break;
					//_alignments[readIndex] = align;
				}
			}

			if(!isUpdated){
				_alignments[readIndex].push_back(align);
			}
			*/

			//if(length > _alignments[readIndex].length()){
			//	_alignments[readIndex] = align;
			//}
			
		}

		/*
		float divergence = 0;
		//_logFile << error << endl;
		//getchar();
		//_logFile << contigIndex << " " << readIndex << endl;

		for(size_t i=12; i<fields->size(); i++){

			//_logFile << (*fields)[i] << endl;

			GfaParser::tokenize((*fields)[i], fields_optional, ':');

			if((*fields_optional)[0] == "dv"){
				divergence = std::stof((*fields_optional)[2]);
			}

		}


		float score = divergence; //nbMatches /
		*/





		/*
        ifstream infile(_outputFilename_mapping);

        std::string line;
        //vector<string>* fields = new vector<string>();
        //vector<string>* fields_optional = new vector<string>();

		while(true){


			u_int32_t contigIndex;
			u_int32_t contigLength;
			u_int64_t readIndex;
			u_int32_t readStart;
			u_int32_t readEnd;
			u_int32_t contigStart;
			u_int32_t contigEnd;
			float score;
			bool strand;

			//u_int64_t nbMatches;
			//u_int64_t alignLength;
			//u_int64_t queryLength;


			infile.read((char*)&contigIndex, sizeof(contigIndex));
			if(infile.eof()) break;
			infile.read((char*)&contigLength, sizeof(contigLength));
			infile.read((char*)&contigStart, sizeof(contigStart));
			infile.read((char*)&contigEnd, sizeof(contigEnd));
			infile.read((char*)&readIndex, sizeof(readIndex));
			infile.read((char*)&readStart, sizeof(readStart));
			infile.read((char*)&readEnd, sizeof(readEnd));
			infile.read((char*)&strand, sizeof(strand));
			infile.read((char*)&score, sizeof(score));

			if(indexPartitionOnly && _contigSequences.find(contigIndex) == _contigSequences.end()) continue;


			u_int32_t length = std::max((u_int64_t)(readEnd - readStart), (u_int64_t)(contigEnd - contigStart));
			Alignment align = {contigIndex, strand, readStart, readEnd, contigStart, contigEnd}; //, score

			if(_alignments.find(readIndex) == _alignments.end()){
				_alignments[readIndex] = align;
			}
			else{

				if(length > align.length()){
					_alignments[readIndex] = align;
				}

			

				//if(length > _alignments[readIndex].length()){
				//	_alignments[readIndex] = align;
				//}
				
			}

			

        }
		*/

	}

	/*
	void writeAlignmentBestHits(){

        ofstream outputFile(_outputFilename_mapping);

		for(const auto& it : _alignments){

			u_int64_t readIndex = it.first;
			
			//for(const Alignment& al : it.second){
			const Alignment& al = it.second;
			float score = 0;

			u_int32_t contigLengthDummy = 0;

			outputFile.write((const char*)&al._contigIndex, sizeof(al._contigIndex));
			outputFile.write((const char*)&contigLengthDummy, sizeof(contigLengthDummy));
			outputFile.write((const char*)&al._contigStart, sizeof(al._contigStart));
			outputFile.write((const char*)&al._contigEnd, sizeof(al._contigEnd));
			outputFile.write((const char*)&readIndex, sizeof(readIndex));
			outputFile.write((const char*)&al._readStart, sizeof(al._readStart));
			outputFile.write((const char*)&al._readEnd, sizeof(al._readEnd));
			outputFile.write((const char*)&al._strand, sizeof(al._strand));
			outputFile.write((const char*)&score, sizeof(score));
			//}
		}

		outputFile.close();

		//_isReadCircular.clear();
	}
	*/


	void collectWindowSequences(u_int32_t partition){
		
		Logger::get().debug() << "\tAligning window sequences";

		//auto fp = std::bind(&ContigPolisher::collectWindowCopies_read, this, std::placeholders::_1);
		//ReadParser readParser(_inputFilename_reads, false, false);
		//readParser.parse(fp);


		const string& partitionFilename = _readPartitionDir + "/part_" + to_string(partition) + ".gz";
		ReadParserParallel readParser(partitionFilename, true, false, _nbCores);
		readParser.parse(CollectWindowSequencesFunctor(*this));
	}
	
	class CollectWindowSequencesFunctor {

		public:

		ContigPolisher& _contigPolisher;
		//unordered_map<string, u_int32_t>& _contigName_to_contigIndex;
		//unordered_map<string, u_int64_t>& _readName_to_readIndex;
		//unordered_map<u_int64_t, vector<Alignment>>& _alignments;
		phmap::parallel_flat_hash_map<u_int32_t, Alignment>& _alignments;
		phmap::parallel_flat_hash_map<u_int32_t, string>& _contigSequences;
		phmap::parallel_flat_hash_map<u_int32_t, vector<vector<Window>>>& _contigWindowSequences;
		size_t _windowLength;


		CollectWindowSequencesFunctor(ContigPolisher& contigPolisher) : _contigPolisher(contigPolisher), _alignments(contigPolisher._alignments), _contigSequences(contigPolisher._contigSequences), _contigWindowSequences(contigPolisher._contigWindowSequences), _windowLength(contigPolisher._windowLength){
		}

		CollectWindowSequencesFunctor(const CollectWindowSequencesFunctor& copy) : _contigPolisher(copy._contigPolisher), _alignments(copy._alignments), _contigSequences(copy._contigSequences), _contigWindowSequences(copy._contigWindowSequences), _windowLength(copy._windowLength){
			
		}

		~CollectWindowSequencesFunctor(){
		}

		void operator () (const Read& read) {

			//const string& readName = Utils::shortenHeader(read._header);
			u_int32_t readIndex = stoull(read._header);

			//if(_contigPolisher._currentPartition == 0) _logFile << readIndex << " " << (_alignments.find(readIndex) != _alignments.end()) << endl;
			
			//if(readIndex % 100000 == 0) _logFile << "\t" << readIndex << endl;

			if(_alignments.find(readIndex) == _alignments.end()) return;

			//const vector<Alignment>& als = _alignments[readIndex];
			const Alignment& al = _alignments[readIndex];
			//for(const Alignment& al : _alignments[readIndex]){
			u_int32_t contigIndex = al._contigIndex;

			if(_contigSequences.find(contigIndex) == _contigSequences.end()) return;

			//_logFile << read._seq.size() << " " << read._qual.size() << " " << _contigSequences[contigIndex].size() << " " << al._readStart << " " << al._readEnd << " " << al._contigStart << " " << al._contigEnd << endl;
			string readSeq = read._seq;
			string qualSeq = read._qual;
			string readSequence = readSeq.substr(al._readStart, al._readEnd-al._readStart);
			string contigSequence = _contigSequences[contigIndex].substr(al._contigStart, al._contigEnd-al._contigStart);



			if(al._strand){
				Utils::toReverseComplement(readSequence);
				Utils::toReverseComplement(readSeq);
				std::reverse(qualSeq.begin(), qualSeq.end());
			}
			

			//_logFile << readSequence << endl;
			//_logFile << contigSequence << endl;

			//_logFile << contigSequence.size() << " "<< readSequence.size() << endl;
			static EdlibAlignConfig config = edlibNewAlignConfig(-1, EDLIB_MODE_NW, EDLIB_TASK_PATH, NULL, 0);


			EdlibAlignResult result = edlibAlign(readSequence.c_str(), readSequence.size(), contigSequence.c_str(), contigSequence.size(), config);


			char* cigar;

			if (result.status == EDLIB_STATUS_OK) {
				cigar = edlibAlignmentToCigar(result.alignment, result.alignmentLength, EDLIB_CIGAR_STANDARD);
			} else {
				Logger::get().error() << "Invalid edlib results";
				exit(1);
			}

			//_logFile << cigar << endl;

			edlibFreeAlignResult(result);
			
			find_breaking_points_from_cigar(_windowLength, al, readSeq.size(), cigar, readSeq, qualSeq);
			free(cigar);

			//getchar();

			//}

		}

		void find_breaking_points_from_cigar(uint32_t window_length, const Alignment& al, u_int64_t readLength, char* cigar_, const string& readSequence, const string& qualSequence)
		{
			
			vector<std::pair<uint32_t, uint32_t>> breaking_points_;
			u_int64_t t_begin_ = al._contigStart;
			u_int64_t t_end_ = al._contigEnd;
			u_int64_t q_begin_ = al._readStart;
			u_int64_t q_end_ = al._readEnd;
			bool strand_ = al._strand;
			u_int64_t q_length_ = readLength;

			// find breaking points from cigar
			std::vector<int32_t> window_ends;
			for (uint32_t i = 0; i < t_end_; i += window_length) {
				if (i > t_begin_) {
					window_ends.emplace_back(i - 1);
				}
			}
			window_ends.emplace_back(t_end_ - 1);

			uint32_t w = 0;
			bool found_first_match = false;
			std::pair<uint32_t, uint32_t> first_match = {0, 0}, last_match = {0, 0};

			int32_t q_ptr = (strand_ ? (q_length_ - q_end_) : q_begin_) - 1;
			int32_t t_ptr = t_begin_ - 1;

			for (uint32_t i = 0, j = 0; i < strlen(cigar_); ++i) {
				if (cigar_[i] == 'M' || cigar_[i] == '=' || cigar_[i] == 'X') {
					uint32_t k = 0, num_bases = atoi(&cigar_[j]);
					j = i + 1;
					while (k < num_bases) {
						++q_ptr;
						++t_ptr;

						if (!found_first_match) {
							found_first_match = true;
							first_match.first = t_ptr;
							first_match.second = q_ptr;
						}
						last_match.first = t_ptr + 1;
						last_match.second = q_ptr + 1;
						if (t_ptr == window_ends[w]) {
							if (found_first_match) {
								breaking_points_.emplace_back(first_match);
								breaking_points_.emplace_back(last_match);
							}
							found_first_match = false;
							++w;
						}


						++k;
					}
				} else if (cigar_[i] == 'I') {
					q_ptr += atoi(&cigar_[j]);
					j = i + 1;
				} else if (cigar_[i] == 'D' || cigar_[i] == 'N') {
					uint32_t k = 0, num_bases = atoi(&cigar_[j]);
					j = i + 1;
					while (k < num_bases) {
						++t_ptr;
						if (t_ptr == window_ends[w]) {
							if (found_first_match) {
								breaking_points_.emplace_back(first_match);
								breaking_points_.emplace_back(last_match);
							}
							found_first_match = false;
							++w;
						}
						++k;
					}
				} else if (cigar_[i] == 'S' || cigar_[i] == 'H' || cigar_[i] == 'P') {
					j = i + 1;
				}
			}

			//if(breaking_points_.size() > 0) breaking_points_.emplace_back(last_match);
				
			for (uint32_t j = 0; j < breaking_points_.size(); j += 2) {

				if(breaking_points_[j].second >= readSequence.size()) return;
				if(breaking_points_[j + 1].second >= readSequence.size()) return;

				if (breaking_points_[j + 1].second - breaking_points_[j].second < 0.02 * _windowLength) {
					continue;
				}

				
				if (qualSequence.size() > 0) {

					//const auto& quality = overlaps[i]->strand() ? sequence->reverse_quality() : sequence->quality();
					double average_quality = 0;
					for (uint32_t k = breaking_points_[j].second; k < breaking_points_[j + 1].second; ++k) {
						average_quality += static_cast<uint32_t>(qualSequence[k]) - 33;
					}
					average_quality /= breaking_points_[j + 1].second - breaking_points_[j].second;

					if (average_quality < _contigPolisher._qualityThreshold) {
						continue;
					}
				}
				

				//uint64_t window_id = id_to_first_window_id[overlaps[i]->t_id()] +
				uint64_t window_id = breaking_points_[j].first / _windowLength;
				uint32_t window_start = (breaking_points_[j].first / _windowLength) * _windowLength;

				//const char* data = overlaps[i]->strand() ?
				//	&(sequence->reverse_complement()[breaking_points[j].second]) :
				//	&(sequence->data()[breaking_points[j].second]);
				const char* data = &readSequence[breaking_points_[j].second];
				uint32_t data_length = breaking_points_[j + 1].second - breaking_points_[j].second;

				string sequence = string(data, data_length);

				/*
				if(al._contigIndex == 1 && window_id > 1 && window_id < 1000){
					if(window_id == 192 || window_id == 193){
						_logFile << readSequence << endl;
						_logFile << sequence << endl;
						if(breaking_points_[j].second > 1) _logFile << readSequence[breaking_points_[j].second-1] << " " << readSequence[breaking_points_[j].second] << endl;
						if(readSequence.size() > readSequence[breaking_points_[j].second+data_length-1]) _logFile << readSequence[breaking_points_[j].second+data_length-1] << " " << readSequence[breaking_points_[j].second+data_length] << endl;
						_logFile << window_id << endl;
						//getchar();
					}
					

				}
				
				long pos = breaking_points_[j].second+data_length;
				while(true){
					if(pos >= readSequence.size()) break;
					char prevChar = readSequence[pos-1];
					char c = readSequence[pos];
					if(prevChar != c) break;

					//sequence += c;
					breaking_points_[j + 1].second += 1;
					//data_length += 1;

					pos += 1;
				}

				pos = ((long)breaking_points_[j].second)-1;
				while(true){
					if(pos < 0) break;
					char prevChar = readSequence[pos+1];
					char c = readSequence[pos];
					if(prevChar != c) break;

					//sequence += c;
					breaking_points_[j].second -= 1;
					//data_length += 1;

					pos -= 1;
				}
				*/

				data = &readSequence[breaking_points_[j].second];
				data_length = breaking_points_[j + 1].second - breaking_points_[j].second;
				sequence = string(data, data_length);

				/*
				if(al._contigIndex == 1 && window_id > 1 && window_id < 1000){
					if(window_id == 192 || window_id == 193){
						_logFile << readSequence << endl;
						_logFile << sequence << endl;
						if(breaking_points_[j].second > 1){
							_logFile << readSequence[breaking_points_[j].second-1] << " " << readSequence[breaking_points_[j].second] << endl;
							if(readSequence[breaking_points_[j].second-1] == readSequence[breaking_points_[j].second]) getchar();
						}
						if(readSequence.size() > readSequence[breaking_points_[j].second+data_length-1]) _logFile << readSequence[breaking_points_[j].second+data_length-1] << " " << readSequence[breaking_points_[j].second+data_length] << endl;
						_logFile << window_id << endl;
						//getchar();
					}
					

				}
				*/

                u_int32_t posStart = breaking_points_[j].first - window_start;
                u_int32_t posEnd =  breaking_points_[j + 1].first - window_start - 1;

				string quality = "";
				if(_contigPolisher._useQual && qualSequence.size() > 0){
					quality = string(&qualSequence[breaking_points_[j].second], data_length);
				}

				//if(al._contigIndex == 0 && window_id == 161){
					
					//_logFile << al._contigIndex << " " << al._readIndex << endl;
					//_logFile << (breaking_points_[j + 1].second - breaking_points_[j].second) << " " << (0.02 * _windowLength) << endl;
					//_logFile << sequence << endl;
					//_logFile << quality << endl;
					//getchar();
				//}

				//if(sequence.size() < 490) continue;
				indexWindow(al, window_id, posStart, posEnd, sequence, quality);

				//_logFile << window_id << " " << posStart << " " << posEnd << endl;
				//_logFile << sequence << endl;
				//getchar();
				/*
				const char* quality = overlaps[i]->strand() ?
					(sequence->reverse_quality().empty() ?
						nullptr : &(sequence->reverse_quality()[breaking_points[j].second]))
					:
					(sequence->quality().empty() ?
						nullptr : &(sequence->quality()[breaking_points[j].second]));
				uint32_t quality_length = quality == nullptr ? 0 : data_length;
				*/
			}

			/*
			for(size_t i=0; i<breaking_points_.size()-1; i++){
				u_int64_t contigWindowStart = breaking_points_[i].first;
				u_int64_t contigWindowEnd = breaking_points_[i+1].first;
				u_int64_t readWindowStart = breaking_points_[i].second;
				u_int64_t readWindowEnd = breaking_points_[i+1].second;

				//_logFile << contigWindowStart << " " << contigWindowEnd  << "      " << readWindowStart << " " << readWindowEnd << endl;

				//if(readWindowEnd-readWindowStart < _windowLength) continue; //window sides
				//string windowSequence = 

				string qualSeq = "";
				if(qualSequence.size() > 0){
					qualSeq = qualSequence.substr(readWindowStart, readWindowEnd-readWindowStart);
				}

				indexWindow(al, readWindowStart, readWindowEnd, contigWindowStart, contigWindowEnd, readSequence.substr(readWindowStart, readWindowEnd-readWindowStart), qualSeq);
			}
			*/
			

			//for(const auto& breakPoint : breaking_points_){
			//	_logFile << breakPoint.first << " " << breakPoint.second << endl;
			//}
		}

		//void indexWindow(const Alignment& al, size_t readWindowStart, size_t readWindowEnd, size_t contigWindowStart, size_t contigWindowEnd, const string& windowSequence, const string& windowQualities){
		void indexWindow(const Alignment& al, u_int64_t windowIndex, u_int32_t posStart, u_int32_t posEnd, const string& windowSequence, const string& windowQualities){

			#pragma omp critical(indexWindow)
			{
				
				//size_t contigWindowIndex = contigWindowStart / _windowLength;
				vector<Window>& windows = _contigWindowSequences[al._contigIndex][windowIndex];
				
				/*
				if(contigWindowIndex == 0){
					//_logFile << contigWindowStart << endl;
					_logFile << windowSequence << endl;
					//_logFile << windows.size() << endl;
					_logFile << readWindowStart << " " << readWindowEnd << endl;
					getchar();
					//_logFile << windowQualities << endl;
				}
				*/
				
				bool interrupt = false;
				if(_contigPolisher._maxWindowCopies == 0 || windows.size() < (_contigPolisher._maxWindowCopies-1)){


					windows.push_back({new DnaBitset2(windowSequence), windowQualities, posStart, posEnd, al.score()});

					/*
					if(al._contigIndex == 1 && windowIndex == 2){
						_logFile << "1111111111111111" << endl;
						_logFile  << windowSequence << endl;
					}
					if(al._contigIndex == 1 && windowIndex == 3){
						_logFile << "2222222222222222" << endl;
						_logFile  << windowSequence << endl;
					}
					*/

					/*
					if(windowSequences.size() > 1){
						static EdlibAlignConfig config = edlibNewAlignConfig(-1, EDLIB_MODE_NW, EDLIB_TASK_PATH, NULL, 0);

						char* dnaStrModel = windowSequences[0]->to_string();
						EdlibAlignResult result = edlibAlign(dnaStrModel, strlen(dnaStrModel), windowSequence.c_str(), windowSequence.size(), config);

						char* cigar;

						if (result.status == EDLIB_STATUS_OK) {
							cigar = edlibAlignmentToCigar(result.alignment, result.alignmentLength, EDLIB_CIGAR_STANDARD);
							_logFile << strlen(cigar) << endl;
							free(cigar);
						} else {
							_logFile << "Invalid edlib results" << endl;
							exit(1);
						}

						//_logFile << cigar << endl;

						edlibFreeAlignResult(result);
						free(dnaStrModel);

					}
					*/


					interrupt = true;
				}

				
				if(!interrupt){

					float score = al.score();

					u_int64_t incompleteWindowIndex = -1;
					//u_int64_t minWindowSize = -1;

					u_int64_t largerDistanceWindow = 0;

					for(size_t i=0; i<windows.size(); i++){

						const Window& window = windows[i];
						u_int64_t distance = abs(((long)window._sequence->m_len) - ((long)_windowLength));

						if(distance > _contigPolisher._windowLengthVariance){
							if(distance > largerDistanceWindow){
								largerDistanceWindow = distance;
								incompleteWindowIndex = i;
							}
						}
					}


					//u_int64_t distance = abs(((long)windowSequence.size()) - ((long)_windowLength));

					if(incompleteWindowIndex != -1){
						Window& window = windows[incompleteWindowIndex];
						delete window._sequence;
						windows[incompleteWindowIndex] = {new DnaBitset2(windowSequence), windowQualities, posStart, posEnd, score};
					}
					else{
						//u_int64_t largestAligmenet = 0;
						//u_int64_t largestAligmenetIndex = 0;

						/*
						size_t largerWindowIndex = 0;
						u_int64_t largerDistanceWindow = 0;

						for(size_t i=0; i<windows.size(); i++){

							const Window& window = windows[i];
							u_int64_t distance = abs(((long)window._sequence->m_len) - ((long)_windowLength));

							if(distance > largerDistanceWindow){
								largerDistanceWindow = distance;
								largerWindowIndex = i;
							}
						}


						u_int64_t distance = abs(((long)windowSequence.size()) - ((long)_windowLength));

						if(distance < largerDistanceWindow){
							Window& window = windows[largerWindowIndex];
							delete window._sequence;
							windows[largerWindowIndex] = {new DnaBitset2(windowSequence), windowQualities, posStart, posEnd};
						}
						*/

						

        				static float maxVal = std::numeric_limits<float>::max();
						size_t largerWindowIndex = 0;
						//u_int64_t largerDistanceWindow = 0;
						float lowestScore = maxVal;
						
						for(size_t i=0; i<windows.size(); i++){

							const Window& window = windows[i];
							//u_int64_t distance = abs(((long)window._sequence->m_len) - ((long)_windowLength));
							//float score =

							if(window._score < lowestScore){
								lowestScore = window._score;
								largerWindowIndex = i;
							}
						}

						//u_int64_t distance = abs(((long)windowSequence.size()) - ((long)_windowLength));

						if(score > lowestScore){
							Window& window = windows[largerWindowIndex];
							delete window._sequence;
							windows[largerWindowIndex] = {new DnaBitset2(windowSequence), windowQualities, posStart, posEnd, score};
						}

					}



				} 




			}
			//_logFile << contigWindowIndex << endl;


			

			/*
			if(contigWindowIndex == _contigWindowSequences[al._contigIndex].size()-1){

				for(size_t i=0; i<windowSequences.size(); i++){
					_logFile << windowSequences[i]->m_len << " ";
				}
				_logFile << endl;
				//_logFile << contigWindowEnd-contigWindowStart << endl;
				//_logFile << windowSequence << endl;
			}
			*/
		}


	};

	struct CorrectedWindow{
		size_t _windowIndex;
		DnaBitset2* _correctedSequence;
		bool _success;
	};

	static bool CorrectedWindowComparator (const CorrectedWindow& p1, const CorrectedWindow& p2){
		return p1._windowIndex < p2._windowIndex;
	}


	unordered_map<u_int32_t, vector<CorrectedWindow>> _currentContigs;


	void performCorrection(){
		
		u_int64_t checksum = 0;

		Logger::get().debug() << "\tPerform correction";

		vector<u_int32_t> contigIndexes;
		for(auto& it : _contigWindowSequences){
			contigIndexes.push_back(it.first);
		}
		//vector<u_int32_t> contigIndexes;
		//for(auto& it : _contigWindowSequences){
		//	contigIndexes.push_back(it.first);
		//}


		size_t i = 0;
		size_t windowIndex = 0;
		//unordered_map<string, vector<vector<Window>>> _contigWindowSequences;

		#pragma omp parallel num_threads(_nbCores)
		{

			bool isEOF = false;
			size_t contigIndexLocal;
			size_t windowIndexLocal;
			

			while(true){


				#pragma omp critical(lala)
				{

					if(i >= _contigWindowSequences.size()){
						isEOF = true;
					}

					if(!isEOF){

						u_int32_t contigIndex = contigIndexes[i];
						//cout << "Contig: " << contigIndex << endl;
						//cout << windowIndex << " " << _contigWindowSequences[contigIndex].size() << endl;
						if(windowIndex >= _contigWindowSequences[contigIndex].size()){
							i += 1;
							windowIndex = 0;
							//cout << "inc contig index" << endl;
						}

						if(i >= _contigWindowSequences.size()){
							isEOF = true;
						}


						if(!isEOF){
							contigIndex = contigIndexes[i];
							contigIndexLocal = contigIndex;
							windowIndexLocal = windowIndex;
							windowIndex += 1;
						}
					}
					
				}

				if(isEOF) break;
				//functorSub(read);

				//#pragma omp critical(lala)
				//{
				//	cout << contigIndexLocal << ": " << windowIndexLocal << "/" << _contigWindowSequences[contigIndexLocal].size() << endl;
				//	getchar();
				//}

				//const string& contigName = contigIndexes[contigIndexLocal];

				//cout << _contigWindowSequences.size() << " " << contigIndexLocal << endl;
				//cout << "lala: " << contigIndexLocal << " " << endl;
				

				vector<Window>& sequences = _contigWindowSequences[contigIndexLocal][windowIndexLocal];

				//u_int64_t nbCorrectedWindows = 0;
				//vector<DnaBitset2*> correctedWindows(windows.size());
			
				std::unique_ptr<spoa::AlignmentEngine> alignmentEngine = spoa::AlignmentEngine::Create(spoa::AlignmentType::kNW, 3, -5, -4);
					
				
				u_int64_t wStart = windowIndexLocal*_windowLength;
				u_int64_t wEnd = min(_contigSequences[contigIndexLocal].size(), (size_t)(wStart+_windowLength));
				string contigOriginalSequence = _contigSequences[contigIndexLocal].substr(wStart, wEnd-wStart);

				if(sequences.size() < 2){

					for(size_t i=0; i<sequences.size(); i++){ 
						delete sequences[i]._sequence;
					}

					addCorrectedWindow(false, new DnaBitset2(contigOriginalSequence), contigIndexLocal, windowIndexLocal);	
					//correctedWindows[w] = new DnaBitset2(contigOriginalSequence);
					//_logFile << "No sequences for window" << endl;
					continue;
				}
				


				std::sort(sequences.begin(), sequences.end(), [&](const Window& lhs, const Window& rhs) {
					return lhs._posStart < rhs._posStart; });

				//_logFile << sequences.size() << endl;
				//_logFile << "1" << endl;
				spoa::Graph graph{};

				string backboneQuality = "";
				for(size_t i=0; i<contigOriginalSequence.size(); i++){
					backboneQuality += '!';
				}

				graph.AddAlignment(
					spoa::Alignment(),
					contigOriginalSequence.c_str(), contigOriginalSequence.size(),
					backboneQuality.c_str(), backboneQuality.size()
				);

				u_int32_t offset = 0.01 * contigOriginalSequence.size();


				for(size_t i=0; i<sequences.size(); i++){ 

					//size_t i = order[ii];
					const Window& window = sequences[i];
					//const DnaBitset2* dna = variant._sequence; //sequenceCopies[s._sequenceIndex];
					char* dnaStr = window._sequence->to_string();

						
					spoa::Alignment alignment;
					if (window._posStart < offset && window._posEnd > contigOriginalSequence.size() - offset) {
						alignment = alignmentEngine->Align(
							dnaStr, strlen(dnaStr),
							graph);
					} else {
						std::vector<const spoa::Graph::Node*> mapping;
						auto subgraph = graph.Subgraph(
							window._posStart,
							window._posEnd,
							&mapping);
						alignment = alignmentEngine->Align(
							dnaStr, strlen(dnaStr),
							subgraph);
						subgraph.UpdateAlignment(mapping, &alignment);
					}
					
					if (window._quality.size() == 0) {
						graph.AddAlignment(
							alignment,
							dnaStr, strlen(dnaStr));
					} else {
						graph.AddAlignment(
							alignment,
							dnaStr, strlen(dnaStr),
							window._quality.c_str(), window._quality.size());
					}
					
					free(dnaStr);
					delete window._sequence;
				}


				std::vector<uint32_t> coverages;
				string correctedSequence = graph.GenerateConsensus(&coverages);

				uint32_t average_coverage = (sequences.size()) / 2;

				int32_t begin = 0, end = correctedSequence.size() - 1;
				for (; begin < static_cast<int32_t>(correctedSequence.size()); ++begin) {
					if (coverages[begin] >= average_coverage) {
						break;
					}
				}
				for (; end >= 0; --end) {
					if (coverages[end] >= average_coverage) {
						break;
					}
				}

				if (begin >= end) {
					//fprintf(stderr, "[racon::Window::generate_consensus] warning: "
					//	"contig %lu might be chimeric in window %u!\n", id_, rank_);
				} else {
					correctedSequence = correctedSequence.substr(begin, end - begin + 1);
				}

				//for(char letter : correctedSequence){
				//	checksum += letter;
				//}

				addCorrectedWindow(true, new DnaBitset2(correctedSequence), contigIndexLocal, windowIndexLocal);

				//correctedWindows[w] = new DnaBitset2(correctedSequence);

			}
		}
		
		/*
		for(auto& it : _contigWindowSequences){

			const string& contigName = it.first;

			vector<vector<Window>>& windows = it.second;
			u_int64_t nbCorrectedWindows = 0;
			vector<DnaBitset2*> correctedWindows(windows.size());
		

			#pragma omp parallel num_threads(_nbCores)
			{

				std::unique_ptr<spoa::AlignmentEngine> alignmentEngine = spoa::AlignmentEngine::Create(spoa::AlignmentType::kNW, 3, -5, -4);
				
				#pragma omp for
				for(size_t w=0; w<windows.size(); w++){

					vector<Window>& sequences = windows[w];
					
					u_int64_t wStart = w*_windowLength;
					u_int64_t wEnd = min(_contigSequences[contigName].size(), wStart+_windowLength);
					string contigOriginalSequence = _contigSequences[contigName].substr(wStart, wEnd-wStart);

					if(sequences.size() < 2){
							
						
						correctedWindows[w] = new DnaBitset2(contigOriginalSequence);
						//_logFile << "No sequences for window" << endl;
						continue;
					}
					
					#pragma omp atomic
					nbCorrectedWindows += 1;


					std::sort(sequences.begin(), sequences.end(), [&](const Window& lhs, const Window& rhs) {
						return lhs._posStart < rhs._posStart; });

					//_logFile << sequences.size() << endl;
					//_logFile << "1" << endl;
					spoa::Graph graph{};

					string backboneQuality = "";
					for(size_t i=0; i<contigOriginalSequence.size(); i++){
						backboneQuality += '!';
					}

					graph.AddAlignment(
						spoa::Alignment(),
						contigOriginalSequence.c_str(), contigOriginalSequence.size(),
						backboneQuality.c_str(), backboneQuality.size()
					);

    				u_int32_t offset = 0.01 * contigOriginalSequence.size();


					for(size_t i=0; i<sequences.size(); i++){ 

						//size_t i = order[ii];
						const Window& window = sequences[i];
						//const DnaBitset2* dna = variant._sequence; //sequenceCopies[s._sequenceIndex];
						char* dnaStr = window._sequence->to_string();

							
						spoa::Alignment alignment;
						if (window._posStart < offset && window._posEnd > contigOriginalSequence.size() - offset) {
							alignment = alignmentEngine->Align(
								dnaStr, strlen(dnaStr),
								graph);
						} else {
							std::vector<const spoa::Graph::Node*> mapping;
							auto subgraph = graph.Subgraph(
								window._posStart,
								window._posEnd,
								&mapping);
							alignment = alignmentEngine->Align(
								dnaStr, strlen(dnaStr),
								subgraph);
							subgraph.UpdateAlignment(mapping, &alignment);
						}
						
						if (window._quality.size() == 0) {
							graph.AddAlignment(
								alignment,
								dnaStr, strlen(dnaStr));
						} else {
							graph.AddAlignment(
								alignment,
								dnaStr, strlen(dnaStr),
								window._quality.c_str(), window._quality.size());
						}
						
						free(dnaStr);
						delete window._sequence;
					}


    				std::vector<uint32_t> coverages;
    				string correctedSequence = graph.GenerateConsensus(&coverages);

					uint32_t average_coverage = (sequences.size()) / 2;

					int32_t begin = 0, end = correctedSequence.size() - 1;
					for (; begin < static_cast<int32_t>(correctedSequence.size()); ++begin) {
						if (coverages[begin] >= average_coverage) {
							break;
						}
					}
					for (; end >= 0; --end) {
						if (coverages[end] >= average_coverage) {
							break;
						}
					}

					if (begin >= end) {
						//fprintf(stderr, "[racon::Window::generate_consensus] warning: "
						//	"contig %lu might be chimeric in window %u!\n", id_, rank_);
					} else {
						correctedSequence = correctedSequence.substr(begin, end - begin + 1);
					}

					for(char letter : correctedSequence){
						checksum += letter;
					}

					correctedWindows[w] = new DnaBitset2(correctedSequence);
				}
			}

			if(nbCorrectedWindows == 0) continue;


			string contigSequence = "";
			for(size_t w=0; w<correctedWindows.size(); w++){
				if(correctedWindows[w] == nullptr) continue;
				char* seq = correctedWindows[w]->to_string();
				contigSequence += string(seq);
				free(seq);
				delete correctedWindows[w];
			}


			string header = _contigHeaders[contigName];
			if(_circularize){
				
				char lastChar = header[header.size()-1];
				if(lastChar == 'c' || lastChar == 'l'){
					header.pop_back();
				}

				if(_isContigCircular.find(contigName) == _isContigCircular.end()){
					header += 'l';
				}
				else{
					header += 'c';
				}
			}


			header = ">" + header + '\n';// ">ctg" + to_string(contigIndex) + '\n';
			//header += '\n';
			gzwrite(_outputContigFile, (const char*)&header[0], header.size());
			contigSequence +=  '\n';
			gzwrite(_outputContigFile, (const char*)&contigSequence[0], contigSequence.size());
			//_logFile << _contigHeaders[contigIndex] << " " << contigSequence.size() << endl;
		}

		_logFile << "Checksum: " << checksum << endl;
		*/
	}


	void addCorrectedWindow(bool success, DnaBitset2* seq, size_t contigIndexLocal, size_t windowIndexLocal){

		
		#pragma omp critical(addCorrectedWindow)
		{
			_currentContigs[contigIndexLocal].push_back({windowIndexLocal, seq, success});

			if(_currentContigs[contigIndexLocal].size() == _contigWindowSequences[contigIndexLocal].size()){
				dumpCorrectedContig(contigIndexLocal);
			}
		}
		
	}

	void dumpCorrectedContig(u_int32_t contigIndex){


		u_int64_t nbCorrectedWindows = 0;
		vector<CorrectedWindow>& correctedWindows = _currentContigs[contigIndex];

		for(const CorrectedWindow& correctedWindow : correctedWindows){
			if(correctedWindow._success){
				nbCorrectedWindows += 1;
			}
		}
		
		if(nbCorrectedWindows > 0){

			std::sort(correctedWindows.begin(), correctedWindows.end(), CorrectedWindowComparator);

			string contigSequence = "";
			//for(size_t w=0; w<correctedWindows.size(); w++){
			for(const CorrectedWindow& correctedWindow : correctedWindows){
				if(correctedWindow._correctedSequence == nullptr) continue;
				//if(correctedWindows[w] == nullptr) continue;
				char* seq = correctedWindow._correctedSequence->to_string();
				contigSequence += string(seq);
				free(seq);
				//delete correctedWindows[w];
			}

			u_int64_t length = contigSequence.size();
			bool isValid = true;

			if(_contigCoverages[contigIndex] <= 1){
				isValid = false;
			}
			else if(length < 3000){
				isValid = false;
			}
			else if(length < 7500 && _contigCoverages[contigIndex] < 4){
				isValid = false;
			}

			if(isValid){

				string header = _contigHeaders[contigIndex];

				if(_isMetaMDBG){

					bool isCircular = false;
					//if(header.find("rc") != string::npos){
					//	string h = header.substr(0, header.size()-2);
					//	header = h + "_" + to_string(_contigCoverages[contigIndex]) + "x_rc";
					//}
					//else 
					if(header[header.size()-1] == 'c'){
						isCircular = true;
						//string h = header.substr(0, header.size()-1);
						//header = h + " length=" + to_string(contigSequence.size()) + " coverage=" + to_string(_contigCoverages[contigIndex]) + " circular=yes";
					}

					header.pop_back(); //remove circular indicator
					header.erase(0, 3); //remove "ctg"
					u_int32_t contigIndex = stoull(header);

					//else{
					//	string h = header.substr(0, header.size()-1);
					//	header = h + " length=" + to_string(contigSequence.size()) + " coverage=" + to_string(_contigCoverages[contigIndex]) + " circular=no";
					//}
					header = Utils::createContigHeader(contigIndex, contigSequence.size(), _contigCoverages[contigIndex], isCircular);
				}


				header = ">" + header + '\n';// ">ctg" + to_string(contigIndex) + '\n';
				//header += '\n';
				gzwrite(_outputContigFile, (const char*)&header[0], header.size());
				contigSequence +=  '\n';
				gzwrite(_outputContigFile, (const char*)&contigSequence[0], contigSequence.size());
				//_logFile << _contigHeaders[contigIndex] << " " << contigSequence.size() << endl;

			}



		}

		for(CorrectedWindow& correctedWindow : correctedWindows){
			if(correctedWindow._correctedSequence == nullptr) continue;
			delete correctedWindow._correctedSequence;
		}
		_currentContigs.erase(contigIndex);
	}

};	

#endif 


