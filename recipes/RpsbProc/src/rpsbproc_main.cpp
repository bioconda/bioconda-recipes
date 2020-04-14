/*$Id$
*  =========================================================================
*
*                            PUBLIC DOMAIN NOTICE
*               National Center for Biotechnology Information
*
*  This software/database is a "United States Government Work" under the
*  terms of the United States Copyright Act.  It was written as part of
*  the author's official duties as a United States Government employee and
*  thus cannot be copyrighted.  This software/database is freely available
*  to the public for use. The National Library of Medicine and the U.S.
*  Government have not placed any restriction on its use or reproduction.
*
*  Although all reasonable efforts have been taken to ensure the accuracy
*  and reliability of the software and data, the NLM and the U.S.
*  Government do not and cannot warrant the performance or results that
*  may be obtained by using this software or data. The NLM and the U.S.
*  Government disclaim all warranties, express or implied, including
*  warranties of performance, merchantability or fitness for any particular
*  purpose.
*
*  Please cite the author in any work or product based on this material.
*  ===========================================================================
* 
*  Authors:  Shennan Lu
*
*  =======================================================================*/
#include <ncbi_pch.hpp>
#include "common/envdef.hpp"
//#include "common/cdalignproc_biodata.hpp"
#include "common/offl_sparcle_data.hpp"
#include "common/offl_cd_align_proc.hpp"
#include "common/objutils.hpp"
#include "common/ptrmap.hpp"
#include "common/compactstore.hpp"
#include "common/basealgo.hpp"
#include "common/enumlit.hpp"
#include "common/argwrapper.hpp"
#include "common/datanode.hpp"
#include "common/lxml.hpp"
#include "common/ljson.hpp"
#include "common/ustring.hpp"
#include "common/combistream.hpp"
#include "common/segset.hpp"
#include "common/biodata_blast.hpp"

#include <objects/blast/Blast4_archive.hpp>
#include <objects/blast/Blast4_request.hpp>
#include <objects/blast/Blast4_request_body.hpp>
#include <objects/blast/Blast4_queue_search_reques.hpp>
#include <objects/blast/Blast4_queries.hpp>
#include <objects/blast/Blas_get_searc_resul_reply.hpp>
#include <objects/blast/Blast4_parameters.hpp>
#include <objects/blast/Blast4_parameter.hpp>
#include <objects/blast/Blast4_cutoff.hpp>
#include <objects/blast/Blast4_subject.hpp>
#include <objects/seqset/seqset__.hpp>

#include <corelib/ncbiapp.hpp>
#include <corelib/ncbifile.hpp>
#include <corelib/ncbireg.hpp>

//customize Argument definition
static const char *PROGRAM_USAGE =	//multiline
"Process output from offline rpsblast to annotate sequence with conserved domain information";

static const char *PROGRAM_DESCRIPTION =	//multiline
"This utility processes domain hit data produced by local RPS-BLAST and "
"generates domain family and/or superfamily annotations on the query sequences. "
"Instead of retrieving domain data from database, this program processes dumped datafiles "
"to obtain required information. All data files are downloadable from NCBI ftp site. Read "
"README file for details";

#define VERDEF 0, 5, 0

static constexpr const struct TVER
{
	int major;
	int minor;
	int patch_level;
} VER = {VERDEF};

std::ostream & operator << (std::ostream &os, const struct TVER &v)
{
	os << 'v' << v.major << '.' << v.minor << '.' << v.patch_level;
	return os;
}

// -- define error subcodes
// -- Define error codes
enum EErrorSubCode
{
	e_OK = 0,
	e_Info,
	e_DataLoadError,
	e_InputFileOpenError,
	e_OutputFileOpenError,
	e_InputDataError,
	//-----------------------
	eErr_TotalErrorCodes
};

//This macro must be used inside ncbi namespace
BEGIN_NCBI_SCOPE
NCBI_DEFINE_ERRCODE_X(RpsbProc_job, 135, eErr_TotalErrorCodes - 1);
END_NCBI_SCOPE

//customize Argument definition
USING_NCBI_SCOPE;
using namespace objects;
using namespace LXML;
// -- must be defined for ERR_POST_X
#define NCBI_USE_ERRCODE_X RpsbProc_job


// -- define constants that may be used in argument definitions
// -- give argument index names
enum EArgIndice: unsigned int
{
	// -- name-indice here. C++ standard, if no value explicitly assigned, enumerators start from 0 and increase by 1
	//argCfgFile,	//path/name of a file contains a list of input data files (ie, blast xml files)
	argInFile,
	argOutFile,
	argEVCutoff,
	argMode,
	argTData,
	argData,
	argFams,
	argQuiet,
	// ------------------------
	TOTALARGS	//This natually as arg count.
};

static TArgDefinition dimValidArgs[] = 
{
	// -- define your valid arguments
	// -- do not use nullptr. use EMPTYSTR as empty string
	//{
	//	"c",	//argCfgFile
	//	TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
	//	ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
	//	"Specify optional config file that contains custom path/names of input data files, which are used only when -d is not specified",	//string (description)
	//	true,	//if optional
	//	TArgDefinition::EMPTYSTR,	//Synopsis (short description)
	//	"-config",	//alias (can be used to specify at command line but not indexed in program
	//	0,	//ncbi::CArgDescriptions::EFlags
	//	TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
	//	TArgDefinition::EMPTYSTR,	//Default Value
	//	nullptr,	//ncbi::CArgAllow * , constraint
	//	ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	//},
	{
		"i",	//argInFile
		TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"Input file(s) that holds asn data produced by rpsblast with \"-outfmt 11\" switch. If omitted, default to stdin.",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-infile",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		TArgDefinition::EMPTYSTR,	//Default Value
		nullptr,	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"o",	//argOutFile
		TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"Output file to write the processed result. If omitted, default to stdout.",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-outfile",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		TArgDefinition::EMPTYSTR,	//Default Value
		nullptr,	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"e",	//argEVCutoff
		TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eDouble,	//ncbi::CArgDescriptions::EType(process type)
		"EValue cut-off. Program will only process hits with evalues better than this value.",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-evalue",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		NumericDefVal(DEF_EVALCUTOFF),	//Default Value
		nullptr,	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"m",	//argMode
		TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"Select redundancy level of domain hit data. Valid options are \"rep\" (concise), \"std\"(standard) and \"full\" (all hits). Default to \"rep\"",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-data-mode",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		GetDefaultLit<TDataModes> (),	//Default Value
		AllowEnumLits<TDataModes> (),	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"t",	//	argTData,
		TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"Target data: Select desired (target) data. Valid options are \"doms\", \"feats\" or \"both\". . If omitted, default to \"both\"",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-target-data",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		GetDefaultLit<TTargetData> (),	//Default Value
		AllowEnumLits<TTargetData> (),	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"d",	//argData
		TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"Specify directory that contains data files. By default, the program will look in 'data' directory in current directory and the directory where the program is located",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-data-path",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		TArgDefinition::EMPTYSTR,	//Default Value
		nullptr,	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"f",	//argFams
		TArgDefinition::eFlag,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"When specified, show corresponding superfamily information for domain hits.",	//string (description)
		true,	//if optional, has value if set
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-show-families",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		TArgDefinition::EMPTYSTR,	//Default Value
		nullptr,	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	},
	{
		"q",	//argQuiet
		TArgDefinition::eFlag,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
		ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
		"Quiet mode -- do not display program information and progress on stderr",	//string (description)
		true,	//if optional
		TArgDefinition::EMPTYSTR,	//Synopsis (short description)
		"-quiet",	//alias (can be used to specify at command line but not indexed in program
		0,	//ncbi::CArgDescriptions::EFlags
		TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
		TArgDefinition::EMPTYSTR,	//Default Value
		nullptr,	//ncbi::CArgAllow * , constraint
		ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	}
	
};

// -- positional arguments
static const size_t TOTALEXTRAARGS = 0;
static TExtraArg *dimValidExtraArgs = nullptr;
//static TExtraArg dimValidExtraArgs[] = 
//{};

class CRpsbProcApp: public CNcbiApplication
{
public:
	
	// -- just a sample of syntax to define pointers to member function
	//typedef void (CRpsbProcApp :: * TLPFNFunc) (...);
	// -- to declare: TLPFNFunc lpfnFunc = &CRpsbProcApp::MyFunc;
	// -- to call: (this->*lpfnFunc)(...);
	
	/**********************************************************************
	*	Constants defined here
	***********************************************************************/
	constexpr static const char *  DEFAULT_DDIR = "data";
	constexpr static const char *  __reg_section_datafiles = "datafiles";
	constexpr static const char *  __reg_tag_datadir = "data";
	constexpr static const char *  __reg_tag_cddids = "cdd";
	constexpr static const char *  __reg_tag_cdtrack = "cdt";
	constexpr static const char *  __reg_tag_famlinks = "clst";
	constexpr static const char *  __reg_tag_sparchs = "feats";
	constexpr static const char *  __reg_tag_genarchs = "genfeats";
	constexpr static const char *  __reg_tag_bscores = "spthr";
	constexpr static const char *  HITTYPE_SPECIFIC = "Specific";
	constexpr static const char *  HITTYPE_NONSPECIFIC = "Non-specific";
	constexpr static const char *  HITTYPE_CLUSTER = "Superfamily";
	constexpr static const char *  HITTYPE_MULTIDOM = "Multidom";
	constexpr static const char *  ANNOTTYPE_SPECIFIC = "Specific";
	constexpr static const char *  ANNOTTYPE_GENERIC = "Generic";
	constexpr static const char *  QUERY_TYPE_PEPTIDE = "Peptide";
	constexpr static const char *  QUERY_TYPE_NUCLEOTIDE = "Nucleotide";
	constexpr static const char *  PROGRAM_TITLE = "Post-RPSBLAST Processing Utility";
	constexpr static const char *  DATASTART = "DATA";
	constexpr static const char *  DATAEND = "ENDDATA";
	constexpr static const char *  SESSIONSTART = "SESSION";
	constexpr static const char *  SESSIONEND = "ENDSESSION";
	constexpr static const char *  QUERYSTART = "QUERY";
	constexpr static const char *  QUERYEND = "ENDQUERY";
	constexpr static const char *  DOMSTART = "DOMAINS";
	constexpr static const char *  DOMEND = "ENDDOMAINS";
	constexpr static const char *  FAMSTART = "SUPERFAMILIES";
	constexpr static const char *  FAMEND = "ENDSUPERFAMILIES";
	constexpr static const char *  FEATSTART = "SITES";
	constexpr static const char *  FEATEND = "ENDSITES";
	constexpr static const char *  MOTIFSTART = "MOTIFS";
	constexpr static const char *  MOTIFEND = "ENDMOTIFS";
	constexpr static const char *  CONFIGFILE = "rpsbproc.ini";
	
	constexpr static const int COORDSBASE = 1;
	constexpr static const char DELIMIT = '\t';
	constexpr static const char COORDELIMIT = ',';
	constexpr static const int OVERLAPLEADING = 500000;
	
	
	static string m_st_exec_name;	//binary full path
	static string m_st_launch_path;	//binary launch path
	static string m_st_real_path;	//binary true path
	
	CRpsbProcApp(void);
	virtual void Init(void);
	virtual int Run(void);
	virtual int DryRun(void);
	virtual void Exit(void);
	~CRpsbProcApp(void);

private:
	// -- common data members
	CNcbiRegistry &m_reg;
	int m_app_status;	//application status, hold value from defined EErrorSubCode
	stringstream m_init_msg;
	
	// -- arguments generated data
	double m_evalue = 0.01;
	TENUMIDX m_dmode;
	TENUMIDX m_tdata;
	bool m_show_clusters;
	bool m_silent;	//display program info
	
	istream *m_istream;
	CCombFileBuf m_infiles;	//combination of input files
	
	ostream *m_ostream;
	ofstream m_outfile;
	
	ESerialDataFormat m_sfmt;
	COfflDomClusterData m_dom_cluster_src;
	
	// -- functions that does real jobs
	void PrintDomQuery(const TDomQuery &q, size_t idxBlObj) const;
	void PrintDomLine(const char *pType, const TDomSeqAlignIndex::__TCdAlignRecord &rec) const;
	void PrintClstLine(const TDomSeqAlignIndex::__TCdAlignRecord &rec) const;
};

string CRpsbProcApp::m_st_exec_name;
string CRpsbProcApp::m_st_launch_path;
string CRpsbProcApp::m_st_real_path;

CRpsbProcApp::CRpsbProcApp(void): CNcbiApplication(), m_reg(GetConfig()), m_app_status(e_OK), 
	m_evalue(DEF_EVALCUTOFF), m_dmode(TDataModes::eDefault), m_tdata(TTargetData::eDefault), m_show_clusters(false), m_silent(false),
	m_istream(&cin), m_infiles(), m_ostream(&cout), m_outfile(), m_sfmt(eSerial_AsnText), m_dom_cluster_src()
{
	SetVersion(CVersionInfo(VER.major, VER.minor, VER.patch_level));
}

void CRpsbProcApp::Init(void)
{
	// -- first
	CNcbiApplication::Init();
	SetupArgDescriptions(ProcessArgDefinitions(CRpsbProcApp::m_st_exec_name, PROGRAM_USAGE, PROGRAM_DESCRIPTION, dimValidArgs, TOTALARGS, dimValidExtraArgs, TOTALEXTRAARGS));
	
	if (!m_silent)
	{
		cerr << PROGRAM_TITLE << ' ' << VER << endl;
		cerr << "-------------------------------------------------------" << endl;
		cerr << "Download:" << endl;
		cerr << "\tftp://ftp.ncbi.nlm.nih.gov/pub/mmdb/cdd/" << endl << endl;
		cerr << "Blast applications download:" << endl;
		cerr << "\tftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/" << endl << endl;
		cerr << "For more information please refer to the README file" << endl;
	}
	
	// -- start to process parameters
	const CArgs & args = GetArgs();
	
	const CArgValue
	
		//&AV_CfgFile = args[dimValidArgs[argCfgFile].name],	//path/name of a file contains a list of input data files (ie, blast xml files)
		&AV_InFile = args[dimValidArgs[argInFile].name],
		&AV_OutFile = args[dimValidArgs[argOutFile].name],
		&AV_Data = args[dimValidArgs[argData].name];
		
	
	m_init_msg << '#' << PROGRAM_TITLE << endl;
	//m_init_msg << "#Config file:";
	//if (AV_CfgFile.HasValue())
	//{
	//	const string & cfgname = AV_CfgFile.AsString();
	//	m_init_msg << '\t' << cfgname;
	//	if (CFile(cfgname).Exists())
	//	{
	//		ifstream cfgf(cfgname.c_str(), ios::binary | ios::in);
	//		if (cfgf.good())
	//			m_reg.Read(cfgf, IRegistry::fTransient | IRegistry::fOverride);
	//		else
	//		{
	//			LOG_POST_X(e_Info, "Unable to open config file: " << cfgname << ", ignored");
	//			m_init_msg << "\t(Unable to open)";
	//		}
	//		
	//		cfgf.close();
	//	}
	//	else
	//	{
	//		LOG_POST_X(e_Info, "Configure file does not exist: " << cfgname << ", ignored");
	//		m_init_msg << "\t(Does not exist)";
	//	}
	//}
	//else
	//	m_init_msg << "\t(Default)";
	m_init_msg << endl;
	m_init_msg << "#Input data file:";
	if (AV_InFile.HasValue())
	{
		const string &infname = AV_InFile.AsString();
		if (CFile(infname).Exists())
		{
			ifstream ifs(infname.c_str(), ios::binary | ios::in);
			if (ifs.good())
			{
				m_infiles.AppendFile(infname);
				m_init_msg << '\t' << infname;
			}
			else
			{
				LOG_POST_X(e_InputFileOpenError, "Unable to open input file: " << infname);
				m_app_status = e_InputFileOpenError;
			}
			ifs.close();
		}
		else
		{
			LOG_POST_X(e_InputFileOpenError, "Input file does not exist: " << infname);
			m_app_status = e_InputFileOpenError;
		}
	}
	
	if (m_infiles.NLeft() > 0)
		m_istream = m_infiles.OpenStream();
	else
		m_init_msg << "\tstdin";
	
	m_init_msg << endl;	
	
	m_init_msg << "#Output data file:";
	
	if (AV_OutFile.HasValue())
	{
		const string & ofilename = AV_OutFile.AsString();
		m_outfile.open(ofilename.c_str(), ios::binary | ios::out);	//append! not write. 
		if (m_outfile.good())
		{
			m_ostream = &m_outfile;
			m_init_msg << '\t' << ofilename;
		}
		else
		{
			LOG_POST_X(e_OutputFileOpenError, "Unable to open output file: " << ofilename);
			m_app_status = e_OutputFileOpenError;
		}
	}
	else
		m_init_msg << "\t(stdout)";
	
	
	// -- check stream type
	// -- test if the stream contains xml or asn
	char c = 0;
	while (m_istream->good() && c <= ' ')
		m_istream->get(c);
		
	if (!m_istream->good())
	{
		m_app_status = e_InputDataError;
		return;
	}
	
	if ('<' == c)	//xml
	{
		LOG_POST_X(e_Info, "Warning: XML format support is deprecated!");
		m_sfmt = eSerial_Xml;
	}
	
	m_istream->putback(c);
	
	
	m_init_msg << endl;
	
	// -- looking for data files
	string
		_datadir(DEFAULT_DDIR),
		_cdd(COfflDomClusterData::__cdd_ids_file),
		_cdt(COfflDomClusterData::__cdtrack_file),
		_clst(COfflDomClusterData::__domfam_link_file),
		_feats(COfflDomClusterData::__spec_feats_file),
		_genfeats(COfflDomClusterData::__gen_feats_file),
		_spthr(COfflDomClusterData::__bs_thrlds_file);


	const string &ddir = m_reg.Get(__reg_section_datafiles, __reg_tag_datadir);
	if (!ddir.empty())
		_datadir = ddir;
	
	const string &cddids = m_reg.Get(__reg_section_datafiles, __reg_tag_cddids);
	if (!cddids.empty())
		_cdd = cddids;
		
	 
	const string &cdtrack = m_reg.Get(__reg_section_datafiles, __reg_tag_cdtrack);
	if (!cdtrack.empty())
		_cdt = cdtrack;
	
	
	const string &clusters = m_reg.Get(__reg_section_datafiles, __reg_tag_famlinks);
	if (!clusters.empty())
		_clst = cddids;
	
	
	const string &spfeats = m_reg.Get(__reg_section_datafiles, __reg_tag_sparchs);
	if (!spfeats.empty())
		_feats = spfeats;
	
	
	const string &genfeats = m_reg.Get(__reg_section_datafiles, __reg_tag_genarchs);
	if (!genfeats.empty())
		_genfeats = cddids;
	

	const string &bscores = m_reg.Get(__reg_section_datafiles, __reg_tag_bscores);
	if (!bscores.empty())
		_spthr = bscores;
	

	string actual_path;
	
	
	m_init_msg << "#Annotation data at:";
	
	if (AV_Data.HasValue())	//take command line designated data path as first priority
	{
		const string &datapath = AV_Data.AsString();
		if (!datapath.empty())
		{
			actual_path = datapath + "/" + _datadir;
			if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())
				goto labelDataPathFound;
			
			actual_path = datapath;
			if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())
				goto labelDataPathFound;
				
			LOG_POST_X(e_DataLoadError, "Specified data location (" << datapath << ") does not exist or does not contain data files");
			m_app_status = e_DataLoadError;
			m_init_msg << "(error)";
			actual_path.clear();
		}
			
			
				
			//if (CDir(absddir).Exists())
			//{
			//	m_init_msg << '\t' << absddir;
			//	try
			//	{
			//		m_dom_cluster_src.LoadData_real(absddir + "/" + _cdd, absddir + "/" + _feats, absddir + "/" + _genfeats, absddir + "/" + _spthr, absddir + "/" + _cdt, absddir + "/" + _clst);
			//	}
			//	catch (CSimpleException e)
			//	{
			//		LOG_POST_X(e_DataLoadError, "Annotation data loading unsuccessful: " << e.what());
			//		m_app_status = e_DataLoadError;
			//		m_init_msg << "(error)";
			//	}
			//}
	}
	else	//not specified in command line, so try home directory (where the binary located) first
	{
		// -- first look for current directory for a "data" subdirectory
		actual_path = "./" + _datadir;

		if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())	//found
			goto labelDataPathFound;
			
		actual_path = "./";
		if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())	//found
			goto labelDataPathFound;
			
		actual_path = CRpsbProcApp::m_st_launch_path + "/" + _datadir;
		if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())	//found
			goto labelDataPathFound;
			
		actual_path = CRpsbProcApp::m_st_launch_path;
		
		actual_path = CRpsbProcApp::m_st_launch_path + "/" + _datadir;
		if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())	//found
			goto labelDataPathFound;
		
		if (CRpsbProcApp::m_st_real_path != CRpsbProcApp::m_st_launch_path)
		{
			actual_path = CRpsbProcApp::m_st_real_path + "/" + _datadir;
			if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())	//not there
				goto labelDataPathFound;
			
			actual_path = CRpsbProcApp::m_st_real_path;
			if (CDir(actual_path).Exists() && CFile(actual_path + "/" + _cdd).Exists())	//not there
				goto labelDataPathFound;
		}
		actual_path.clear();
	}
		
labelDataPathFound:
	
	if (!actual_path.empty())
	{
		m_init_msg << '\t' << actual_path;
		try
		{
			m_dom_cluster_src.LoadData_real(actual_path + "/" + _cdd, actual_path + "/" + _feats, actual_path + "/" + _genfeats, actual_path + "/" + _spthr, actual_path + "/" + _cdt, actual_path + "/" + _clst);
		}
		catch (CSimpleException e)
		{
			LOG_POST_X(e_DataLoadError, "Annotation data loading unsuccessful: " << e.what());
			m_app_status = e_DataLoadError;
			m_init_msg << "(error)";
		}
	}
	else
	{
		m_init_msg << "\tNot found!";
		LOG_POST_X(e_DataLoadError, "Cannot find data files");
		m_app_status = e_DataLoadError;
		m_init_msg << "(error)";
	}
	
	m_init_msg << endl;
	
	m_show_clusters = args[dimValidArgs[argFams].name].HasValue();
	m_evalue = args[dimValidArgs[argEVCutoff].name].AsDouble();
	const string &mode = args[dimValidArgs[argMode].name].AsString(),
		&tdata = args[dimValidArgs[argTData].name].AsString();
	m_dmode = GetIdx<TDataModes> (mode);
	m_tdata = GetIdx<TTargetData> (tdata);
	m_silent = args[dimValidArgs[argQuiet].name].HasValue();
	
	if (e_OK == m_app_status)
	{
	
		m_init_msg << "#E-Value cutoff:\t" << m_evalue << endl;
		m_init_msg << "#Redundancy:\t" << GetDisplay<TDataModes> (m_dmode) << endl;
		m_init_msg << "#Data requested:\t" << GetDisplay<TTargetData>(m_tdata) << endl;
		m_init_msg << "#Output format -- tab-delimited table" << endl;
		m_init_msg << "#Show superfamilies: " << (m_show_clusters ? "YES" : "NO") << endl;
		m_init_msg << '#' << DATASTART << endl;
		m_init_msg << '#' << SESSIONSTART << DELIMIT << "<session-ordinal>" << DELIMIT << "<program>" << DELIMIT << "<database>" << DELIMIT << "<score-matrix>" << DELIMIT << "<evalue-threshold>" << endl;
		m_init_msg << '#' << QUERYSTART << DELIMIT << "<query-id>" << DELIMIT << "<seq-type>" << DELIMIT << "<seq-length>" << DELIMIT << "<definition-line>" << endl;
  	
  	
		if (TTargetData::e_feats != m_tdata)
		{
			m_init_msg << '#' << DOMSTART << endl;
			m_init_msg << '#' << "<session-ordinal>" << DELIMIT << "<query-id[readingframe]>" << DELIMIT << "<hit-type>" << DELIMIT << "<PSSM-ID>" << DELIMIT << "<from>" << DELIMIT << "<to>" << DELIMIT << "<E-Value>" << DELIMIT << "<bitscore>" << DELIMIT << "<accession>" << DELIMIT << "<short-name>" << DELIMIT << "<incomplete>" << DELIMIT << "<superfamily PSSM-ID>" << endl;
			m_init_msg << "#more such lines......" << endl;
			m_init_msg << '#' << DOMEND << endl;
		}
		if (TTargetData::e_doms != m_tdata)
		{
			m_init_msg << '#' << FEATSTART << endl;
			m_init_msg << '#' << "<session-ordinal>" << DELIMIT << "<query-id[readingframe]>" << DELIMIT << "<annot-type>" << DELIMIT << "<title>" << DELIMIT << "<residue(coordinates)>" << DELIMIT << "<complete-size>" << DELIMIT << "<mapped-size>" << DELIMIT << "<source-domain>" << endl;
			m_init_msg << "#more such lines......" << endl;
			m_init_msg << '#' << FEATEND << endl;
			m_init_msg << '#' << MOTIFSTART << endl;
			m_init_msg << '#' << "<session-ordinal>" << DELIMIT << "<query-id[readingframe]>" << DELIMIT << "<title>" << DELIMIT << "<from>" << DELIMIT << "<to>" << DELIMIT << "<source-domain>" << endl;
			m_init_msg << "#more such lines......" << endl;
			m_init_msg << '#' << MOTIFEND << endl;
		}
		m_init_msg << '#' << QUERYEND << DELIMIT << "<query-id>" << endl;
		m_init_msg << "#more query sections.." << endl;
		m_init_msg << '#' << SESSIONEND << DELIMIT << "<session-ordinal>" << endl;
		m_init_msg << "#more session sections.." << endl;
		m_init_msg << '#' << DATAEND << endl;
		m_init_msg << "#=====================================================================" << endl;
	}
	
}

int CRpsbProcApp::Run(void)
{
	if (e_OK == m_app_status)
	{
		// -- output initial message
		(*m_ostream) << m_init_msg.str();
		(*m_ostream) << DATASTART << endl;
		m_init_msg.clear();
		
		//CNcbiCdAlignProcessor proc(&m_dom_cluster_src);
		COfflCdAlignProcessor proc(&m_dom_cluster_src);
		//list<_TOfflDomQuery> qobjs;
		size_t objCounter = 0, qCounter = 0;
		
		if (eSerial_Xml == m_sfmt)
		{
			//list<_TOfflDomQuery> qobjs;
			while (m_istream->good())
			{
				CBlastOutput objBlastOutput;
				try
				{
					ObjStreamIn<CBlastOutput> ((*m_istream), objBlastOutput, eSerial_Xml);
				}
				catch (...)
				{
					break;
				}
				
				if (!m_silent) cerr << "RPSBlast session " << objCounter << " start..." << endl;
				const CBlastOutput::TParam &params = objBlastOutput.GetParam();
				(*m_ostream) << SESSIONSTART << DELIMIT << ++objCounter << DELIMIT << objBlastOutput.GetVersion() << DELIMIT << objBlastOutput.GetDb() << DELIMIT << params.GetMatrix() << DELIMIT << params.GetExpect() << endl;
				if (!m_silent) cerr << "RPSBlast session " << objCounter << " start..." << endl;
				const CBlastOutput::TIterations &rIters = objBlastOutput.GetIterations();
      
				vector<PssmId_t> missed;
				for (CBlastOutput::TIterations::const_iterator iter = rIters.begin(), iterEnd = rIters.end(); iterEnd != iter; ++iter)
				{
					if (!m_silent) cerr << "Calculating...." << endl;
					
					_TOfflDomQuery cdqVal;
					
					// -- this already included calculation
					proc.ParseBlastOutput(cdqVal, **iter, missed, m_evalue);
					PrintDomQuery(cdqVal, objCounter);
					++qCounter;
				}
				(*m_ostream) << SESSIONEND << DELIMIT << objCounter << endl;
				if (!m_silent) cerr << "RPSBlast session " << objCounter << " done..." << endl;
						
			}
		}
		else	//by default, asn
		{
			list<TDomQuery> qobjs;
			while (m_istream->good())
			{
				CBlast4_archive objBlastOutput;
				try
				{
					ObjStreamIn<CBlast4_archive> (*m_istream, objBlastOutput, eSerial_AsnText);
				}
				catch (...)
				{
					break;
				}
				if (!m_silent) cerr << "RPSBlast session " << objCounter << " start..." << endl;
				
				const CBioseq_set *pQuerySeqs = nullptr;
				const CSeq_align_set *pAligns = nullptr;
				
				int gcode = 1;	//standard
				
				// -- need to translate to this format
				// -- assume one TMaskedQueryRegions for each query
				TSeqLocInfoVector vecMasks;
    		
				if (objBlastOutput.IsSetRequest() && objBlastOutput.CanGetRequest())
				{
					const CBlast4_archive::TRequest &req = objBlastOutput.GetRequest();
						
					const CBlast4_archive::TRequest::TBody &reqbody = req.GetBody();
					
					switch (reqbody.Which())
					{
					case CBlast4_request_body::e_Queue_search:
						{
							const CBlast4_queue_search_request &qsreq = reqbody.GetQueue_search();
							
							// -- start session output
							(*m_ostream) << SESSIONSTART << DELIMIT << ++objCounter << DELIMIT << qsreq.GetProgram();
							
							if (req.IsSetIdent() && req.CanGetIdent())
								(*m_ostream) << DELIMIT << req.GetIdent();
							
							(*m_ostream) << DELIMIT << qsreq.GetSubject().GetDatabase();
							
							if (qsreq.IsSetAlgorithm_options() && qsreq.CanGetAlgorithm_options())
							{
								const CBlast4_parameters &algoParams = qsreq.GetAlgorithm_options();
								CRef<CBlast4_parameter> refGCode = algoParams.GetParamByName("MatrixName");
								if (!refGCode.IsNull())
									(*m_ostream) << DELIMIT << refGCode->GetValue().GetString();
								
								refGCode = algoParams.GetParamByName("EvalueThreshold");
								if (!refGCode.IsNull())
									(*m_ostream) << DELIMIT << refGCode->GetValue().GetCutoff().GetE_value();
							}
							
							(*m_ostream) << endl;
							
							
							const CBlast4_queries &blast_queries = qsreq.GetQueries();
							
							switch (blast_queries.Which())
							{
							case CBlast4_queries::e_Bioseq_set:
								pQuerySeqs = &(blast_queries.GetBioseq_set());
								break;
							default:
								LOG_POST_X(e_InputDataError, "Wrong type of request data: CBlast4_queries::e_Bioseq_set expected");
								m_app_status = e_InputDataError;
								goto labelReturn;
							}	//switch (blast_queries.Which())
						}
						break;
					default:
						LOG_POST_X(e_InputDataError, "Wrong type of request data: CBlast4_request_body::e_Queue_search expected");
						m_app_status = e_InputDataError;
						goto labelReturn;
					}	//switch (reqbody.Which())
					
					
					if (objBlastOutput.IsSetResults() && objBlastOutput.CanGetResults())
					{
						const CBlast4_archive::TResults & resobj = objBlastOutput.GetResults();	//
							
						if (resobj.IsSetMasks() && resobj.CanGetMasks())
						{
							const list< CRef< CBlast4_mask > > & blmasks = resobj.GetMasks();
    		
							if (!blmasks.empty())
								ConvertBlastMaskListToSeqLocInfoVector(blmasks, vecMasks);
						}	
						
						if (resobj.IsSetAlignments() && resobj.CanGetAlignments())
						{
							pAligns = &(resobj.GetAlignments());
						}
						else
						{
							LOG_POST_X(e_InputDataError, "Wrong type of results data: CBlast4_get_search_results_reply::e_alignments expected");
							
							goto labelNextObj;
						}
						
					}
					else
					{
						LOG_POST_X(e_InputDataError, "Unable to get results object from input data");
						m_app_status = e_InputDataError;
						goto labelReturn;
					}
				}
				else
				{
					LOG_POST_X(e_InputDataError, "Unable to get request object from input data");
					m_app_status = e_InputDataError;
					goto labelReturn;
				}
				
				if (!m_silent) cerr << "Calculating...." << endl;
				qobjs.clear();
				proc.ProcessBlastResults(qobjs, pQuerySeqs->GetSeq_set(), vecMasks, pAligns->Get(), gcode);
	  		
				for (const auto & v: qobjs)
				{
					PrintDomQuery(v, objCounter);
					++qCounter;
				}
				
			labelNextObj:			
				(*m_ostream) << SESSIONEND << DELIMIT << objCounter << endl;
				if (!m_silent) cerr << "RPSBlast session " << objCounter << " done..." << endl;
			}
		}
			
		
		(*m_ostream) << DATAEND << endl;
		if (!m_silent)
			cerr << "All done, " << qCounter << " queries processed" << endl << endl;
		// -- do real job, if anything goes wrong, set m_app_status and goto labelReturn;
	}
labelReturn:
	return m_app_status;
}

int CRpsbProcApp::DryRun(void)
{
	if (e_OK == m_app_status)
		cerr << "Dryrun passed, all resources are present and loaded successfully." << endl;
	else
		cerr << "Dryrun failed, error subcode = " << m_app_status << endl;
	
	return m_app_status;
}


void CRpsbProcApp::Exit(void)
{
	// -- clean up
	// -- last
	CNcbiApplication::Exit();
}

CRpsbProcApp::~CRpsbProcApp(void)
{
	// -- clean up
}

void CRpsbProcApp::PrintDomQuery(const TDomQuery &q, size_t idxBlObj) const
{
	static constexpr const SeqLen_t codonEnd = READINGFRAME::RF_SIZE - 1;
	
	(*m_ostream) << QUERYSTART << DELIMIT << q.m_strAccession << DELIMIT;
//const char * const QUERY_TYPE_PEPTIDE = "Peptide";
//const char * const QUERY_TYPE_NUCLEOTIDE = "Nucleotide";

	//if (CSeq_inst::eMol_aa == q.m_iMolType)
	if (!q.m_bIsNa)
	{
		(*m_ostream) << QUERY_TYPE_PEPTIDE << DELIMIT << q.m_uiSeqLen << DELIMIT << q.m_strTitle << endl;
		vector<TDomSeqAlignIndex::__TCdAlignRecord> vecDomAligns, vecFeatAligns;	//vecDomFams for output of superfamilies of domain hits
		q.m_dimSplitAligns[0].CreateRecordSets(q.m_vecAlignments, m_dom_cluster_src, vecDomAligns, vecFeatAligns, m_dmode);
		
		// - so that we don't output redundent domain families
		map<int, TDomSeqAlignIndex::__TCdAlignRecord > mapDomFams;

		if (TTargetData::e_feats != m_tdata)
		{
			if (!vecDomAligns.empty())
			{
				(*m_ostream) << DOMSTART << endl;
				if (TDataModes::e_rep == m_dmode)
				{
					for (vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterRec = vecDomAligns.begin(), iterRecEnd = vecDomAligns.end(); iterRecEnd != iterRec; ++iterRec)
					{
						if (NULL == iterRec->pCdInfo) continue;
						(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT;
						if (1 == iterRec->pAlign->m_iRepClass)	//multi, should be no more
							PrintDomLine(HITTYPE_MULTIDOM, *iterRec);
						else if (iterRec->pAlign->m_bSpecQualified)
						{
							PrintDomLine(HITTYPE_SPECIFIC, *iterRec);
							if (NULL != iterRec->pClst)
							{
								int key = iterRec->pAlign->m_iRegionIdx * OVERLAPLEADING + iterRec->pCdInfo->m_uiClusterPssmId;
								//if (mapDomFams.end() == mapDomFams.find(key))
								mapDomFams.emplace(key, *iterRec);
							}
						}
						else if (NULL != iterRec->pClst)
							PrintClstLine(*iterRec);
						else	//not qualified for specific, but no cluster -- non-specific
							PrintDomLine(HITTYPE_NONSPECIFIC, *iterRec);
						(*m_ostream) << endl;
					}	//dom loops end
				}	//rep mode
				else	//nonrep mode
				{
					for (vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterRec = vecDomAligns.begin(), iterRecEnd = vecDomAligns.end(); iterRecEnd != iterRec; ++iterRec)
					{
						if (NULL == iterRec->pCdInfo) continue;
						(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT;
						if (1 == iterRec->pAlign->m_iRepClass)	//multi
							PrintDomLine(HITTYPE_MULTIDOM, *iterRec);
						else if (iterRec->pAlign->m_bRep && iterRec->pAlign->m_bSpecQualified)
							PrintDomLine(HITTYPE_SPECIFIC, *iterRec);
						else
							PrintDomLine(HITTYPE_NONSPECIFIC, *iterRec);
						if (NULL != iterRec->pClst)
						{
							int key = iterRec->pAlign->m_iRegionIdx * OVERLAPLEADING + iterRec->pCdInfo->m_uiClusterPssmId;
							//if (mapDomFams.end() == mapDomFams.find(key))
							mapDomFams.emplace(key, *iterRec);
						}
						(*m_ostream) << endl;
					}
				}
				
				(*m_ostream) << DOMEND << endl;
				
				if (m_show_clusters)	//user want to see all superfams
				{
					(*m_ostream) << FAMSTART << endl;
					for (const auto & v : mapDomFams)
					{
						(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT;
						PrintClstLine(v.second);
						(*m_ostream) << endl;
					}
					(*m_ostream) << FAMEND << endl;
				}
			}
		}
		
		if (TTargetData::e_doms != m_tdata)
		{
			vector<TDomSeqAlignIndex::__MotifType_base> vecMotifRecs;
			
			vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterFeatAlign = vecFeatAligns.begin(), iterFeatAlignEnd = vecFeatAligns.end();
			
			if (iterFeatAlignEnd != iterFeatAlign)	//not empty())
			{
				if (!iterFeatAlign->pCdInfo->m_bIsStructDom)	//has regular domains
				{
					(*m_ostream) << FEATSTART << endl;
					for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					{
						if (iterFeatAlign->pCdInfo->m_bIsStructDom) break;
							
						bool bIsSpecific = iterFeatAlign->pAlign->m_bRep && iterFeatAlign->pAlign->m_bSpecQualified;
						const char * pType = ANNOTTYPE_SPECIFIC;
						const list <TDomSite> * pFeats = &(iterFeatAlign->pCdInfo->m_lstSpecificFeatures);
						unsigned int uiSrcPssmId = iterFeatAlign->pAlign->m_uiPssmId;
						
						if (!bIsSpecific && NULL != iterFeatAlign->pRootCdInfo)
						{
							pType = ANNOTTYPE_GENERIC;
							pFeats = &(iterFeatAlign->pCdInfo->m_lstGenericFeatures);
							uiSrcPssmId = iterFeatAlign->pCdInfo->m_uiHierarchyRoot;
						}
							
						for (list<TDomSite> :: const_iterator iterFeat = pFeats->begin(); iterFeat != pFeats->end(); ++iterFeat)
						{
							if (TDomSite::eType_StructMotif == iterFeat->m_iType)
							{
								vecMotifRecs.emplace_back(iterFeat, iterFeatAlign, bIsSpecific, uiSrcPssmId);
								continue;
							}
							
							CSegSet featsegs(*iterFeat);
							iterFeatAlign->pAlign->MapSegSet(featsegs, false);
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterFeat->GetCompleteSize() > 0.8))
							{
								vector<TSeg_base::TResiduePos> vecMappedPos;
								iterFeatAlign->pAlign->GetTranslatedPosMap(featsegs, q.m_uiSeqLen, vecMappedPos);
    	        	
								if (iterFeat->MotifCheck(vecMappedPos, q.m_strSeqData) > 0) continue;	//failed motif check
									
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT << pType << DELIMIT << iterFeat->m_strTitle << DELIMIT;
								
								const CSegSet::TSegs& segs = featsegs.GetSegs();
								
								size_t mapped = 0;
								
								char dimDelimit[2] = {0, 0};
								for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(); iterSeg != segs.end(); ++iterSeg)
								{
									for (int res = iterSeg->from; res <= iterSeg->to; ++res)
									{
										(*m_ostream) << dimDelimit << (char)toupper(q.m_strSeqData[res]) << (res + COORDSBASE);
										dimDelimit[0] = COORDELIMIT;
										++mapped;
									}
								}
								(*m_ostream) << DELIMIT << iterFeat->GetTotalResidues() << DELIMIT << mapped << DELIMIT << uiSrcPssmId << endl;
							}
						}
					}
					
					// -- non-motif features from SD
					
					for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					{
						//if (iterFeatAlign->pCdInfo->m_bIsStructDom) break;
							
						//bool bIsSpecific = iterFeatAlign->pAlign->m_bRep && iterFeatAlign->pAlign->m_bSpecQualified;
						//const char * pType = ANNOTTYPE_SPECIFIC;
						//const list <TDomSite> * pFeats = &(iterFeatAlign->pCdInfo->m_lstSpecificFeatures);;
						//unsigned int uiSrcPssmId = iterFeatAlign->pAlign->m_uiPssmId;
						
						//if (!bIsSpecific && NULL != iterFeatAlign->pRootCdInfo)
						//{
						//	pType = ANNOTTYPE_GENERIC;
						//	pFeats = &(iterFeatAlign->pCdInfo->m_lstGenericFeatures);
						//	uiSrcPssmId = iterFeatAlign->pCdInfo->m_uiHierarchyRoot;
						//}
							
						for (list<TDomSite> :: const_iterator iterFeat = iterFeatAlign->pCdInfo->m_lstSpecificFeatures.begin(); iterFeat != iterFeatAlign->pCdInfo->m_lstSpecificFeatures.end(); ++iterFeat)
						{
							if (TDomSite::eType_StructMotif == iterFeat->m_iType)
							{
								vecMotifRecs.emplace_back(iterFeat, iterFeatAlign, true, 0);
								continue;
							}
							
							CSegSet featsegs(*iterFeat);
							iterFeatAlign->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterFeat->GetCompleteSize() > 0.8))
							{
								vector<TSeg_base::TResiduePos> vecMappedPos;
								iterFeatAlign->pAlign->GetTranslatedPosMap(featsegs, q.m_uiSeqLen, vecMappedPos);
    	        	
								if (iterFeat->MotifCheck(vecMappedPos, q.m_strSeqData) > 0) continue;	//failed motif check
    	        	
									
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT << ANNOTTYPE_SPECIFIC << DELIMIT << iterFeat->m_strTitle << DELIMIT;
								
								const CSegSet::TSegs& segs = featsegs.GetSegs();
								
								size_t mapped = 0;
								
								char dimDelimit[2] = {0, 0};
								for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(); iterSeg != segs.end(); ++iterSeg)
								{
									for (int res = iterSeg->from; res <= iterSeg->to; ++res)
									{
										(*m_ostream) << dimDelimit << (char)toupper(q.m_strSeqData[res]) << (res + COORDSBASE);
										dimDelimit[0] = COORDELIMIT;
										++mapped;
									}
								}
								(*m_ostream) << DELIMIT << iterFeat->GetTotalResidues() << DELIMIT << mapped << DELIMIT << 0/*iterFeatAlign->pAlign->m_uiPssmId*/ << endl;
							}
						}
					}
					
					(*m_ostream) << FEATEND << endl;
				}
				
				// -- Motif part
				if (!vecMotifRecs.empty())
				{
					// -- start SD
					// -- features
					(*m_ostream) << MOTIFSTART << endl;
					vector<TDomSeqAlignIndex::__MotifType_base> :: const_iterator iterM = vecMotifRecs.begin(), iterMEnd = vecMotifRecs.end();
					for ( ; iterMEnd != iterM; ++iterM)
					{
						if (iterM->iterAlignRec->pCdInfo->m_bIsStructDom) break;
							
						CSegSet featsegs(*iterM->iterMotifFeat);
						iterM->iterAlignRec->pAlign->MapSegSet(featsegs);
						
						if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterM->iterMotifFeat->GetCompleteSize() > 0.8))
						{
							(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT << iterM->iterMotifFeat->m_strTitle << DELIMIT;
							int res0 = featsegs.GetLeft(), res1 = featsegs.GetRight();
							(*m_ostream) << (char)toupper(q.m_strSeqData[res0]) << res0 + COORDSBASE << DELIMIT << res1 + COORDSBASE << (char)toupper(q.m_strSeqData[res1]) << DELIMIT << iterM->uiSrcPssmId << endl;
						}
					}
					
					// Motif from SD
					for ( ; iterMEnd != iterM; ++iterM)
					{
						CSegSet featsegs(*iterM->iterMotifFeat);
						if (!iterM->iterAlignRec->pAlign->m_ClipSet.IsEmpty())
							featsegs.Cross(iterM->iterAlignRec->pAlign->m_ClipSet);
						
						iterM->iterAlignRec->pAlign->MapSegSet(featsegs);
						
						if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterM->iterMotifFeat->GetCompleteSize() > 0.8))
						{
							(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT << iterM->iterMotifFeat->m_strTitle << DELIMIT;
							int res0 = featsegs.GetLeft(), res1 = featsegs.GetRight();
							(*m_ostream) << (char)toupper(q.m_strSeqData[res0]) << res0 + COORDSBASE << DELIMIT << res1 + COORDSBASE << (char)toupper(q.m_strSeqData[res1]) << DELIMIT << iterM->uiSrcPssmId << endl;
						}
					}
					
					// -- now start SD
					//for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					//{
					//	int rfidx = iterFeatAlign->pAlign->GetRFIdx(q.m_uiSeqLen);
					//	
					//	for (list<TDomSite> :: const_iterator iterFeat = iterFeatAlign->pCdInfo->m_lstSpecificFeatures.begin(); iterFeat != iterFeatAlign->pCdInfo->m_lstSpecificFeatures.end(); ++iterFeat)
					//	{
					//		
					//		CSegSet featsegs(*iterFeat);
					//		iterFeatAlign->pAlign->MapSegSet(featsegs);
					//		if (!featsegs.IsEmpty())
					//		{
					//			(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT << iterFeat->m_strTitle << DELIMIT;
					//			//int rfidx = iterFeatAlign->pAlign->GetRFIdx(q.m_uiSeqLen);
					//			int res0 = featsegs.GetLeft(), res1 = featsegs.GetRight();
					//			(*m_ostream) << (char)toupper(q.m_dimTranslated[rfidx][res0]) << res0 + COORDSBASE << DELIMIT << res1 + COORDSBASE << (char)toupper(q.m_dimTranslated[rfidx][res1]) << DELIMIT << '-' << endl;
					//		}
					//	}
					//}
					
					(*m_ostream) << MOTIFEND << endl;
				}
			}
		}
	}
	else	//na
	{
		(*m_ostream) << QUERY_TYPE_NUCLEOTIDE << DELIMIT << q.m_uiSeqLen << DELIMIT << q.m_strTitle << endl;
		
		vector<TDomSeqAlignIndex::__TCdAlignRecord> dimDomAligns[READINGFRAME::TOTAL_RFS], dimFeatVecs[READINGFRAME::TOTAL_RFS];
		
		bool bHasFeats = false, bHasRegFeats = false;

		for (READINGFRAME::TFRAMEINDEX rfidx = 0; rfidx < READINGFRAME::TOTAL_RFS; ++rfidx)
		{
			q.m_dimSplitAligns[rfidx].CreateRecordSets(q.m_vecAlignments, m_dom_cluster_src, dimDomAligns[rfidx], dimFeatVecs[rfidx], m_dmode);
			bHasFeats = bHasFeats || !dimFeatVecs[rfidx].empty();
			bHasRegFeats = (bHasRegFeats || !(dimFeatVecs[rfidx].empty() || dimFeatVecs[rfidx][0].pCdInfo->m_bIsStructDom));
		}

		if (TTargetData::e_feats != m_tdata)
		{
			map<int, TDomSeqAlignIndex::__TCdAlignRecord > dimDomFams[READINGFRAME::TOTAL_RFS];
			
			(*m_ostream) << DOMSTART << endl;
			for (READINGFRAME::TFRAMEINDEX rfidx = 0; rfidx < READINGFRAME::TOTAL_RFS; ++rfidx)
			{
				READINGFRAME::TFRAMEID rf = READINGFRAME::RF_IDS[rfidx];
				if (!dimDomAligns[rfidx].empty())
				{
					if (TDataModes::e_rep == m_dmode)
					{
						for (vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterRec = dimDomAligns[rfidx].begin(), iterRecEnd = dimDomAligns[rfidx].end(); iterRecEnd != iterRec; ++iterRec)
						{
							if (NULL == iterRec->pCdInfo) continue;
							(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT;
							if (1 == iterRec->pAlign->m_iRepClass)	//multi
								PrintDomLine(HITTYPE_MULTIDOM, *iterRec);
							else if (iterRec->pAlign->m_bSpecQualified)
							{
								PrintDomLine(HITTYPE_SPECIFIC, *iterRec);
								if (NULL != iterRec->pClst)
								{
									int key = iterRec->pAlign->m_iRegionIdx * OVERLAPLEADING + iterRec->pCdInfo->m_uiClusterPssmId;
									//if (dimDomFams[rfidx].end() == dimDomFams[rfidx].find(key))
									dimDomFams[rfidx].emplace(key, *iterRec);
								}
							}
							else if (NULL != iterRec->pClst)
								PrintClstLine(*iterRec);
							else	//not qualified for specific, but no cluster -- non-specific
								PrintDomLine(HITTYPE_NONSPECIFIC, *iterRec);
							(*m_ostream) << endl;
						}	//dom loops end
					}	//rep mode
					else	//nonrep mode
					{
						for (vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterRec = dimDomAligns[rfidx].begin(), iterRecEnd = dimDomAligns[rfidx].end(); iterRecEnd != iterRec; ++iterRec)
						{
							if (NULL == iterRec->pCdInfo) continue;
							(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT;
							if (1 == iterRec->pAlign->m_iRepClass)	//multi
								PrintDomLine(HITTYPE_MULTIDOM, *iterRec);
							else if (iterRec->pAlign->m_bRep && iterRec->pAlign->m_bSpecQualified)
								PrintDomLine(HITTYPE_SPECIFIC, *iterRec);
							else
								PrintDomLine(HITTYPE_NONSPECIFIC, *iterRec);
								
							if (NULL != iterRec->pClst)
							{
								int key = iterRec->pAlign->m_iRegionIdx * OVERLAPLEADING + iterRec->pCdInfo->m_uiClusterPssmId;
								//if (dimDomFams[rfidx].end() == dimDomFams[rfidx].find(key))
								dimDomFams[rfidx].emplace(key, *iterRec);
							}
							
							(*m_ostream) << endl;
						}
					}
				}
			}
			(*m_ostream) << DOMEND << endl;
			
			if (m_show_clusters)	//user want to see all superfams
			{
				(*m_ostream) << FAMSTART << endl;
				for (READINGFRAME::TFRAMEINDEX rfidx = 0; rfidx < READINGFRAME::TOTAL_RFS; ++rfidx)
				{
					//int rf = READINGFRAME::RF_IDS[rfidx];
					
					for (const auto & v : dimDomFams[rfidx])
					{
						(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << DELIMIT;
						PrintClstLine(v.second);
						(*m_ostream) << endl;
					}
					
				}
				(*m_ostream) << FAMEND << endl;
			}
		}
			
		if (TTargetData::e_doms != m_tdata)
		{

			if (bHasFeats)
			{

				const _TOfflDomQuery * p_ofl_q = dynamic_cast< const _TOfflDomQuery * > (&q);
				string __dimTranslated[READINGFRAME::TOTAL_RFS];
				
				const string *dimTranslated = __dimTranslated;
				if (nullptr == p_ofl_q)	//not _TOfflDomQuery
				{
					TranslateAll(q.m_strSeqData, q.m_iGenCode, __dimTranslated);
				}
				else
					dimTranslated = p_ofl_q->m_dimTranslated;
				
				
				//const string (&dimTranslated)[READINGFRAME::TOTAL_RFS] = *p_dimTranslated;
				
				
				//if (eSerial_Xml == m_sfmt)	//
				//	p_dimTranslated = q.m_dimTranslated;
				//else
				//	TranslateAll(q.m_strSeqData, q.m_iGenCode, dimTranslated);
				//	
				//const string (&dimTranslated)[READINGFRAME::TOTAL_RFS] = *p_dimTranslated;
					
				vector<TDomSeqAlignIndex::__MotifType_base> dimMotifTypes[READINGFRAME::TOTAL_RFS];
//				vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator dimSDIter[READINGFRAME::TOTAL_RFS];
				
				bool bHasMotifs = false;
				
				if (bHasRegFeats)
					(*m_ostream) << FEATSTART << endl;
				
				int iNegRF = READINGFRAME::TOTAL_RFS / 2;
				for (READINGFRAME::TFRAMEINDEX rfidx = 0; rfidx < iNegRF; ++rfidx)	//plus strand reading frames
				{

					READINGFRAME::TFRAMEID rf = READINGFRAME::Idx2Id(rfidx);

					vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterFeatAlign = dimFeatVecs[rfidx].begin(), iterFeatAlignEnd = dimFeatVecs[rfidx].end();
					//dimSDIter[rfidx] = iterFeatAlignEnd;
					for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					{
						if (iterFeatAlign->pCdInfo->m_bIsStructDom)
						{
							//dimSDIter[rfidx] = iterFeatAlign;
							//bHasMotifs = true;
							break;
						}
						
						bool bIsSpecific = iterFeatAlign->pAlign->m_bRep && iterFeatAlign->pAlign->m_bSpecQualified;
						const char * pType = ANNOTTYPE_SPECIFIC;
						const list <TDomSite> * pFeats = &(iterFeatAlign->pCdInfo->m_lstSpecificFeatures);;
						unsigned int uiSrcPssmId = iterFeatAlign->pAlign->m_uiPssmId;
						
						if (!bIsSpecific && NULL != iterFeatAlign->pRootCdInfo)
						{
							pType = ANNOTTYPE_GENERIC;
							pFeats = &(iterFeatAlign->pCdInfo->m_lstGenericFeatures);
							uiSrcPssmId = iterFeatAlign->pCdInfo->m_uiHierarchyRoot;
						}
							
						for (list<TDomSite> :: const_iterator iterFeat = pFeats->begin(); iterFeat != pFeats->end(); ++iterFeat)
						{
							if (TDomSite::eType_StructMotif == iterFeat->m_iType)
							{
								dimMotifTypes[rfidx].emplace_back(iterFeat, iterFeatAlign, bIsSpecific, uiSrcPssmId);
								bHasMotifs = true;
								continue;
							}
							
							CSegSet featsegs(*iterFeat);
							iterFeatAlign->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterFeat->GetCompleteSize() > 0.8))
							{
								vector<TSeg_base::TResiduePos> vecMappedPos;
								iterFeatAlign->pAlign->GetTranslatedPosMap(featsegs, q.m_uiSeqLen, vecMappedPos);
      	  	  	
								if (iterFeat->MotifCheck(vecMappedPos, dimTranslated[rfidx]) > 0) continue;	//failed motif check
									
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << pType << DELIMIT << iterFeat->m_strTitle << DELIMIT;
								
								size_t mapped = 0;
								char dimDelimit[2] = {0, 0};
								
								
								for (vector<TSeg_base::TResiduePos> :: const_iterator iterRP = vecMappedPos.begin(), iterEnd = vecMappedPos.end(); iterEnd != iterRP; ++iterRP)
								{
									SeqPos_t xres = READINGFRAME::PlusPr2PlusNA(iterRP->curr, rfidx, q.m_uiSeqLen);
									(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][iterRP->curr]) << (xres + COORDSBASE) << '-' << (xres + codonEnd + COORDSBASE);
									dimDelimit[0] = COORDELIMIT;
								}
								
								//const CSegSet::TSegs &segs = featsegs.GetSegs();
								//
								//
								//
								//for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(); iterSeg != segs.end(); ++iterSeg)
								//{
								//	int xres = READINGFRAME::PlusPr2PlusNA(iterSeg->from, rfidx, q.m_uiSeqLen);
								//	for (int res = iterSeg->from; res <= iterSeg->to; ++res)
								//	{
								//		(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][res]) << (xres + COORDSBASE) << '-';
								//		xres += READINGFRAME::RF_SIZE - 1;
								//		(*m_ostream) << (xres + COORDSBASE);
								//		++xres;
								//		dimDelimit[0] = COORDELIMIT;
								//		++mapped;
								//	}
								//}
								(*m_ostream) << DELIMIT << iterFeat->GetTotalResidues() << DELIMIT << mapped << DELIMIT << uiSrcPssmId << endl;
							}
						}
					}
					
					// -- non-motif from sd domains
					for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					{
						//if (iterFeatAlign->pCdInfo->m_bIsStructDom)
						//{
						//	dimSDIter[rfidx] = iterFeatAlign;
						//	bHasMotifs = true;
						//	break;
						//}
						
						//bool bIsSpecific = iterFeatAlign->pAlign->m_bRep && iterFeatAlign->pAlign->m_bSpecQualified;
						//const char * pType = ANNOTTYPE_SPECIFIC;
						//const list <TDomSite> * pFeats = &(iterFeatAlign->pCdInfo->m_lstSpecificFeatures);;
						//unsigned int uiSrcPssmId = iterFeatAlign->pAlign->m_uiPssmId;
						//
						//if (!bIsSpecific && NULL != iterFeatAlign->pRootCdInfo)
						//{
						//	pType = ANNOTTYPE_GENERIC;
						//	pFeats = &(iterFeatAlign->pCdInfo->m_lstGenericFeatures);
						//	uiSrcPssmId = iterFeatAlign->pCdInfo->m_uiHierarchyRoot;
						//}
							
						for (list<TDomSite> :: const_iterator iterFeat = iterFeatAlign->pCdInfo->m_lstSpecificFeatures.begin(); iterFeat != iterFeatAlign->pCdInfo->m_lstSpecificFeatures.end(); ++iterFeat)
						{
							if (TDomSite::eType_StructMotif == iterFeat->m_iType)
							{
								dimMotifTypes[rfidx].emplace_back(iterFeat, iterFeatAlign, true, 0);
								bHasMotifs = true;
								continue;
							}
							
							CSegSet featsegs(*iterFeat);
							iterFeatAlign->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterFeat->GetCompleteSize() > 0.8))
							{
								vector<TSeg_base::TResiduePos> vecMappedPos;
								iterFeatAlign->pAlign->GetTranslatedPosMap(featsegs, q.m_uiSeqLen, vecMappedPos);
      	  	  	
								if (iterFeat->MotifCheck(vecMappedPos, dimTranslated[rfidx]) > 0) continue;	//failed motif check
									
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << ANNOTTYPE_SPECIFIC << DELIMIT << iterFeat->m_strTitle << DELIMIT;
								
								//const CSegSet::TSegs &segs = featsegs.GetSegs();
								
								size_t mapped = 0;
								char dimDelimit[2] = {0, 0};
								
								for (vector<TSeg_base::TResiduePos> :: const_iterator iterRP = vecMappedPos.begin(), iterEnd = vecMappedPos.end(); iterEnd != iterRP; ++iterRP)
								{
									SeqPos_t xres = READINGFRAME::PlusPr2PlusNA(iterRP->curr, rfidx, q.m_uiSeqLen);
									(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][iterRP->curr]) << (xres + COORDSBASE) << '-' << (xres + codonEnd + COORDSBASE);
									dimDelimit[0] = COORDELIMIT;
								}
								
								//for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(); iterSeg != segs.end(); ++iterSeg)
								//{
								//	int xres = READINGFRAME::PlusPr2PlusNA(iterSeg->from, rfidx, q.m_uiSeqLen);
								//	for (int res = iterSeg->from; res <= iterSeg->to; ++res)
								//	{
								//		(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][res]) << (xres + COORDSBASE) << '-';
								//		xres += READINGFRAME::RF_SIZE - 1;
								//		(*m_ostream) << (xres + COORDSBASE);
								//		++xres;
								//		dimDelimit[0] = COORDELIMIT;
								//		++mapped;
								//	}
								//}
								(*m_ostream) << DELIMIT << iterFeat->GetTotalResidues() << DELIMIT << mapped << DELIMIT << 0/*iterFeatAlign->pAlign->m_uiPssmId*/ << endl;
							}
						}
					}
				}
				
				for (READINGFRAME::TFRAMEINDEX rfidx = iNegRF; rfidx < READINGFRAME::TOTAL_RFS; ++rfidx)	//minus strand reading frames
				{
					READINGFRAME::TFRAMEID rf = READINGFRAME::Idx2Id(rfidx);
					
					vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterFeatAlign = dimFeatVecs[rfidx].begin(), iterFeatAlignEnd = dimFeatVecs[rfidx].end();
					//SeqLen_t alnLen = iterFeatAlign->pAlign->m_ReadingFrame >> 2, alnLenAdjust = dimTranslated[rfidx].size() - alnLen;
					
					for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					{
						if (iterFeatAlign->pCdInfo->m_bIsStructDom)
						{
							//dimSDIter[rfidx] = iterFeatAlign;
							//bHasMotifs = true;
							break;
						}
						
						bool bIsSpecific = iterFeatAlign->pAlign->m_bRep && iterFeatAlign->pAlign->m_bSpecQualified;
						const char * pType = ANNOTTYPE_SPECIFIC;
						const list <TDomSite> * pFeats = &(iterFeatAlign->pCdInfo->m_lstSpecificFeatures);;
						unsigned int uiSrcPssmId = iterFeatAlign->pAlign->m_uiPssmId;
						
						if (!bIsSpecific && NULL != iterFeatAlign->pRootCdInfo)
						{
							pType = ANNOTTYPE_GENERIC;
							pFeats = &(iterFeatAlign->pCdInfo->m_lstGenericFeatures);
							uiSrcPssmId = iterFeatAlign->pCdInfo->m_uiHierarchyRoot;
						}
							
						for (list<TDomSite> :: const_iterator iterFeat = pFeats->begin(); iterFeat != pFeats->end(); ++iterFeat)
						{
							if (TDomSite::eType_StructMotif == iterFeat->m_iType)
							{
								dimMotifTypes[rfidx].emplace_back(iterFeat, iterFeatAlign, bIsSpecific, uiSrcPssmId);
								bHasMotifs = true;
								continue;
							}
						
							CSegSet featsegs(*iterFeat);
							iterFeatAlign->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterFeat->GetCompleteSize() > 0.8))
							{
	
								vector<TSeg_base::TResiduePos> vecMappedPos;
								iterFeatAlign->pAlign->GetTranslatedPosMap(featsegs, q.m_uiSeqLen, vecMappedPos);
      	  	  	
								if (iterFeat->MotifCheck(vecMappedPos, dimTranslated[rfidx]) > 0) continue;	//failed motif check
									
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << pType << DELIMIT << iterFeat->m_strTitle << DELIMIT;
								
								//const CSegSet::TSegs &segs = featsegs.GetSegs();
								
								
								size_t mapped = 0;
								char dimDelimit[2] = {0, 0};
						
								for (vector<TSeg_base::TResiduePos> :: const_iterator iterRP = vecMappedPos.begin(), iterEnd = vecMappedPos.end(); iterEnd != iterRP; ++iterRP)
								{
									SeqPos_t xres = READINGFRAME::MinusPr2PlusNA(iterRP->curr, rfidx, q.m_uiSeqLen);

									(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][iterRP->curr]) << (xres + COORDSBASE) << '-' << (xres - codonEnd + COORDSBASE);
									dimDelimit[0] = COORDELIMIT;
								}
								
								//for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(); iterSeg != segs.end(); ++iterSeg)
								//{
								//	int xres = READINGFRAME::MinusPr2PlusNA(iterSeg->from + alnLenAdjust, rfidx, q.m_uiSeqLen);
								//	for (int res = iterSeg->from; res <= iterSeg->to; ++res)
								//	{
								//		(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][res + alnLenAdjust]) << (xres + COORDSBASE) << '-';
								//		xres -= READINGFRAME::RF_SIZE - 1;
								//		(*m_ostream) << (xres + COORDSBASE);
								//		--xres;
								//		dimDelimit[0] = COORDELIMIT;
								//		++mapped;
								//	}
								//}
								(*m_ostream) << DELIMIT << iterFeat->GetTotalResidues() << DELIMIT << mapped << DELIMIT << uiSrcPssmId << endl;
							}
						}
					}
					
					// -- non-motif features from SD domain
					for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
					{
						//if (iterFeatAlign->pCdInfo->m_bIsStructDom)
						//{
						//	//dimSDIter[rfidx] = iterFeatAlign;
						//	//bHasMotifs = true;
						//	break;
						//}
						
						//bool bIsSpecific = iterFeatAlign->pAlign->m_bRep && iterFeatAlign->pAlign->m_bSpecQualified;
						//const char * pType = ANNOTTYPE_SPECIFIC;
						//const list <TDomSite> * pFeats = &(iterFeatAlign->pCdInfo->m_lstSpecificFeatures);;
						//unsigned int uiSrcPssmId = iterFeatAlign->pAlign->m_uiPssmId;
						//
						//if (!bIsSpecific && NULL != iterFeatAlign->pRootCdInfo)
						//{
						//	pType = ANNOTTYPE_GENERIC;
						//	pFeats = &(iterFeatAlign->pCdInfo->m_lstGenericFeatures);
						//	uiSrcPssmId = iterFeatAlign->pCdInfo->m_uiHierarchyRoot;
						//}
							
						for (list<TDomSite> :: const_iterator iterFeat = iterFeatAlign->pCdInfo->m_lstSpecificFeatures.begin(); iterFeat != iterFeatAlign->pCdInfo->m_lstSpecificFeatures.end(); ++iterFeat)
						{
							if (TDomSite::eType_StructMotif == iterFeat->m_iType)
							{
								dimMotifTypes[rfidx].emplace_back(iterFeat, iterFeatAlign, true, 0);
								bHasMotifs = true;
								continue;
							}
							
							CSegSet featsegs(*iterFeat);
							iterFeatAlign->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterFeat->GetCompleteSize() > 0.8))
							{
								vector<TSeg_base::TResiduePos> vecMappedPos;
								iterFeatAlign->pAlign->GetTranslatedPosMap(featsegs, q.m_uiSeqLen, vecMappedPos);
      	  	  	
								if (iterFeat->MotifCheck(vecMappedPos, dimTranslated[rfidx]) > 0) continue;	//failed motif check
									
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << ANNOTTYPE_SPECIFIC << DELIMIT << iterFeat->m_strTitle << DELIMIT;
								
								const CSegSet::TSegs &segs = featsegs.GetSegs();
								
								size_t mapped = 0;
								char dimDelimit[2] = {0, 0};
							
								for (vector<TSeg_base::TResiduePos> :: const_iterator iterRP = vecMappedPos.begin(), iterEnd = vecMappedPos.end(); iterEnd != iterRP; ++iterRP)
								{
									SeqPos_t xres = READINGFRAME::MinusPr2PlusNA(iterRP->curr, rfidx, q.m_uiSeqLen);
									(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][iterRP->curr]) << (xres + COORDSBASE) << '-' << (xres - codonEnd + COORDSBASE);
									dimDelimit[0] = COORDELIMIT;
								}
								//for (CSegSet::TSegs::const_iterator iterSeg = segs.begin(); iterSeg != segs.end(); ++iterSeg)
								//{
								//	int xres = READINGFRAME::MinusPr2PlusNA(iterSeg->from + alnLenAdjust, rfidx, q.m_uiSeqLen);
								//	for (int res = iterSeg->from; res <= iterSeg->to; ++res)
								//	{
								//		(*m_ostream) << dimDelimit << (char)toupper(dimTranslated[rfidx][res + alnLenAdjust]) << (xres + COORDSBASE) << '-';
								//		xres -= READINGFRAME::RF_SIZE - 1;
								//		(*m_ostream) << (xres + COORDSBASE);
								//		--xres;
								//		dimDelimit[0] = COORDELIMIT;
								//		++mapped;
								//	}
								//}
								(*m_ostream) << DELIMIT << iterFeat->GetTotalResidues() << DELIMIT << mapped << DELIMIT << 0/*uiSrcPssmId*/ << endl;
							}
						}
					}
				}	//negative strand reading frames
				
				if (bHasRegFeats)
					(*m_ostream) << FEATEND << endl;
					
				if (bHasMotifs)
				{
					(*m_ostream) << MOTIFSTART << endl;
					
					// -- plus strand
					for (READINGFRAME::TFRAMEINDEX rfidx = 0; rfidx < iNegRF; ++rfidx)
					{
						READINGFRAME::TFRAMEID rf = READINGFRAME::Idx2Id(rfidx);
						for (vector<TDomSeqAlignIndex::__MotifType_base> :: const_iterator iterM = dimMotifTypes[rfidx].begin(), iterMEnd = dimMotifTypes[rfidx].end(); iterMEnd != iterM; ++iterM)
						{
							CSegSet featsegs(*iterM->iterMotifFeat);
							iterM->iterAlignRec->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterM->iterMotifFeat->GetCompleteSize() > 0.8))
							{
								iterM->iterAlignRec->pAlign->Pr2NaConvert(featsegs);
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << iterM->iterMotifFeat->m_strTitle << DELIMIT << featsegs.GetLeft() + COORDSBASE << DELIMIT << featsegs.GetRight() + codonEnd + COORDSBASE << DELIMIT << iterM->uiSrcPssmId << endl;
								//SeqPos_t res0 = READINGFRAME::PlusPr2PlusNA(featsegs.GetLeft(), rfidx, q.m_uiSeqLen),
								//res1 = READINGFRAME::PlusPr2PlusNA(featsegs.GetRight(), rfidx, q.m_uiSeqLen);
								//int res0 = featsegs.GetLeft(), res1 = featsegs.GetRight();
							}
						}
						
						// -- now start SD
						//vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterFeatAlign = dimSDIter[rfidx], iterFeatAlignEnd = dimFeatVecs[rfidx].end();
						//for ( ; iterFeatAlignEnd != iterFeatAlign; ++iterFeatAlign)
						//{
						//	//int rfidx = iterFeatAlign->pAlign->GetRFIdx(q.m_uiSeqLen);
						//	for (list<TDomSite> :: const_iterator iterFeat = iterFeatAlign->pCdInfo->m_lstSpecificFeatures.begin(); iterFeat != iterFeatAlign->pCdInfo->m_lstSpecificFeatures.end(); ++iterFeat)
						//	{
						//		CSegSet featsegs(*iterFeat);
						//		iterFeatAlign->pAlign->MapSegSet(featsegs);
						//		if (!featsegs.IsEmpty())
						//		{
						//			(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << iterFeat->m_strTitle << DELIMIT;
						//			//int rfidx = iterFeatAlign->pAlign->GetRFIdx(q.m_uiSeqLen);
						//			int res0 = featsegs.GetLeft(), res1 = featsegs.GetRight();
						//			(*m_ostream) << res0 + COORDSBASE << DELIMIT << res1 + READINGFRAME::RF_SIZE - 1 + COORDSBASE << DELIMIT << '-' << endl;
						//		}
						//	}
						//}
					}
					
					// -- minus strand
					for (READINGFRAME::TFRAMEINDEX rfidx = iNegRF; rfidx < READINGFRAME::TOTAL_RFS; ++rfidx)
					{
						int rf = 2 - rfidx;
						vector<TDomSeqAlignIndex::__TCdAlignRecord> :: const_iterator iterFeatAlign = dimFeatVecs[rfidx].begin(), iterFeatAlignEnd = dimFeatVecs[rfidx].end();
						SeqLen_t alnLen = iterFeatAlign->pAlign->m_ReadingFrame >> 2, alnLenAdjust = dimTranslated[rfidx].size() - alnLen;
					
						for (vector<TDomSeqAlignIndex::__MotifType_base> :: const_iterator iterM = dimMotifTypes[rfidx].begin(), iterMEnd = dimMotifTypes[rfidx].end(); iterMEnd != iterM; ++iterM)
						{
							CSegSet featsegs(*iterM->iterMotifFeat);
							iterM->iterAlignRec->pAlign->MapSegSet(featsegs, false);
							
							if (!featsegs.IsEmpty() && ((double)featsegs.GetTotalResidues() / (double)iterM->iterMotifFeat->GetCompleteSize() > 0.8))
							{
								iterM->iterAlignRec->pAlign->Pr2NaConvert(featsegs);
								(*m_ostream) << idxBlObj << DELIMIT << q.m_strAccession << '[' << rf << ']' << DELIMIT << iterM->iterMotifFeat->m_strTitle << DELIMIT << featsegs.GetLeft() + COORDSBASE << DELIMIT << featsegs.GetRight() - codonEnd + COORDSBASE << DELIMIT << iterM->uiSrcPssmId << endl;

							}
						}

					}
					(*m_ostream) << MOTIFEND << endl;
				}
			}
		}
	}
	
	(*m_ostream) << QUERYEND << endl;
	if (!m_silent) cerr << "End processing Query " << q.m_strTitle << endl;
}



void CRpsbProcApp::PrintDomLine(const char *pType, const TDomSeqAlignIndex::__TCdAlignRecord &rec) const
{
	(*m_ostream) << pType << DELIMIT << rec.pAlign->m_uiPssmId << DELIMIT << rec.pAlign->m_iFrom + COORDSBASE << DELIMIT << rec.pAlign->m_iTo + COORDSBASE << DELIMIT << rec.pAlign->m_dEValue << DELIMIT << rec.pAlign->m_dBitScore << DELIMIT << rec.pCdInfo->m_strAccession << DELIMIT << rec.pCdInfo->m_strShortName << DELIMIT;
	bool bTmMiss = false;
	if (rec.pAlign->m_dNMissing > 0.2)
	{
		(*m_ostream) << 'N';
		bTmMiss = true;
	}
	if (rec.pAlign->m_dCMissing > 0.2)
	{
		(*m_ostream) << 'C';
		bTmMiss = true;
	}
	if (!bTmMiss)
		(*m_ostream) << '-';
	(*m_ostream) << DELIMIT << (NULL == rec.pClst ? '-' :  rec.pClst->m_uiPssmId);

}

void CRpsbProcApp::PrintClstLine(const TDomSeqAlignIndex::__TCdAlignRecord &rec) const
{
	(*m_ostream) << HITTYPE_CLUSTER << DELIMIT << rec.pCdInfo->m_uiClusterPssmId << DELIMIT << rec.pAlign->m_iFrom + COORDSBASE << DELIMIT << rec.pAlign->m_iTo + COORDSBASE << DELIMIT << rec.pAlign->m_dEValue << DELIMIT << rec.pAlign->m_dBitScore << DELIMIT << rec.pClst->m_strAccession << DELIMIT << rec.pClst->m_strShortName << DELIMIT;
	bool bTmMiss = false;
	if (rec.pAlign->m_dNMissing > 0.2)
	{
		(*m_ostream) << 'N';
		bTmMiss = true;
	}
	if (rec.pAlign->m_dCMissing > 0.2)
	{
		(*m_ostream) << 'C';
		bTmMiss = true;
	}
	if (!bTmMiss)
		(*m_ostream) << '-';
	(*m_ostream) << DELIMIT << '-';
}

int main(int argc, char * argv[])
{
	string launchAlias = CDirEntry::NormalizePath(argv[0]);
	string base, ext;
	CDirEntry::SplitPath(launchAlias, &CRpsbProcApp::m_st_launch_path, &base, &ext);
	if (!CRpsbProcApp::m_st_launch_path.empty())
		CRpsbProcApp::m_st_launch_path.pop_back();	//get rid of the tailing '/'
	// -- this is deliberately leave alone
	CRpsbProcApp::m_st_exec_name = base + ext;
	
	CDir launchPathDir(launchAlias);
	launchPathDir.DereferencePath();
	
	CDirEntry::SplitPath(CDirEntry::CreateAbsolutePath(launchPathDir.GetPath(), CDirEntry::eRelativeToCwd), &CRpsbProcApp::m_st_real_path);
	if (!CRpsbProcApp::m_st_real_path.empty())
		CRpsbProcApp::m_st_real_path.pop_back();

	return CRpsbProcApp().AppMain(argc, argv);
}
