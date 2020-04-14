#if !defined(__ARG_WRAPPER__)
#define __ARG_WRAPPER__

#include <corelib/ncbiargs.hpp>
#include <corelib/ncbitype.h>
#include <corelib/ncbienv.hpp>
#include <corelib/ncbifile.hpp>
#include <string>
#include <list>

//enum ncbi::CArgDescriptions::EType
//{
//	eString = 0, ///< An arbitrary string
//	eBoolean,    ///< {'true', 't', 'false', 'f'},  case-insensitive
//	eInt8,       ///< Convertible into an integer number (Int8 only)
//	eInteger,    ///< Convertible into an integer number (int or Int8)
//	eDouble,     ///< Convertible into a floating point number (double)
//	eInputFile,  ///< Name of file (must exist and be readable)
//	eOutputFile, ///< Name of file (must be writable)
//	eIOFile,     ///< Name of file (must be writable)
//	eDirectory,  ///< Name of file directory
//	eDataSize,   ///< Integer number with possible "software" qualifiers (KB, KiB, et al)
//	eDateTime,   ///< DateTime string, formats:
//	             ///< "M/D/Y h:m:s", "Y-M-DTh:m:g", "Y/M/D h:m:g", "Y-M-D h:m:g".
//	             ///< Time string can have trailing 'Z' symbol, specifying that
//	             ///< it represent time in the UTC format.
//	k_EType_Size ///< For internal use only
//};

//enum ncbi::CArgDescriptions::EFlags
//{
//	// File related flags:
//	
//	/// Open file right away; for eInputFile, eOutputFile, eIOFile
//	fPreOpen = (1 << 0),
//	/// Open as binary file; for eInputFile, eOutputFile, eIOFile
//	fBinary  = (1 << 1), 
//	/// Append to end-of-file; for eOutputFile or eIOFile 
//	fAppend    = (1 << 2),
//	/// Delete contents of an existing file; for eOutputFile or eIOFile 
//	fTruncate  = (1 << 12),
//	/// If the file does not exist, do not create it; for eOutputFile or eIOFile 
//	fNoCreate = (1 << 11),
//	/// If needed, create directory where the file is located
//	fCreatePath = (1 << 8),
//	
//	/// Mask for all file-related flags
//	fFileFlags = fPreOpen | fBinary | fAppend | fTruncate | fNoCreate | fCreatePath,
//	// multiple keys flag:
//	
//	/// Repeated key arguments are legal (use with AddKey)
//	fAllowMultiple = (1 << 3),
//	
//	// Error handling flags:
//	
//	/// Ignore invalid argument values. If not set, exceptions will be
//	/// thrown on invalid values.
//	fIgnoreInvalidValue = (1 << 4),
//	/// Post warning when an invalid value is ignored (no effect
//	/// if fIgnoreInvalidValue is not set).
//	fWarnOnInvalidValue = (1 << 5),
//	
//	/// Allow to ignore separator between the argument's name and value.
//	/// Usual ' ' or '=' separators can still be used with the argument.
//	/// The following restrictions apply to a no-separator argument:
//	///   - the argument must be a key (including optional or default);
//	///   - the argument's name must be a single char;
//	///   - no other argument's name can start with the same char,
//	///     unless fOptionalSeparatorAllowConflict is also specified.
//	fOptionalSeparator = (1 << 6),
//	/// For arguments with fOptionalSeparator flag, allow
//	/// other arguments which names begin with the same char.
//	fOptionalSeparatorAllowConflict = (1 << 9),
//	
//	/// Require '=' separator
//	fMandatorySeparator = (1 << 7),
//	
//	/// Hide it in Usage
//	fHidden = (1 << 10),
//	
//	/// Confidential argument
//	/// Such arguments can be read from command line, from file, or from
//	/// console.
//	/// On command line, they can appear in one of the following forms:
//	///   -key                 -- read value from console, with automatically
//	///                           generated prompt
//	///   -key-file fname      -- read value from file 'fname',
//	///                           if 'fname' equals '-',  read value from
//	///                           standard input (stdin) without any prompt
//	///   -key-verbatim value  -- read value from the command line, as is
//	fConfidential  = (1 << 13)
//};


// -- old POD 
struct TArgDefinition
{
	enum EArgCategory
	{
		eKey,
		ePos,	//Positional
		eOpenPos,	//Opening positional
		eFlag,
		eNegFlag
	};
	static const char EMPTYSTR[];
	
	const char * name;
	EArgCategory cat;
	ncbi::CArgDescriptions::EType type;
	const char * descr;
	bool optional;	//with eFlag, this field serve as enum EFlagValue {eFlagHasValueIfMissed = 0, eFlagHasValueIfSet = 1}
	const char * synopsis;
	const char * alias;
	ncbi::CArgDescriptions::TFlags flags;	//flags
	const char * val_env;	//environment contains the value
	const char * def_val;	//default value for optional arguments
	ncbi::CArgAllow * constraint;
	ncbi::CArgDescriptions::EConstraintNegate neg_constraint;
};

struct TExtraArg
{
	unsigned int n_mandatory;
	unsigned int n_optional;
	const char * descr;
	ncbi::CArgDescriptions::EType type;
	ncbi::CArgDescriptions::TFlags flags;	//flags	
};

template <typename TEnumLitType>
ncbi::CArgAllow * AllowEnumLits()
{
	if (0 == TEnumLitType::eEnumStop) return nullptr;
	
	ncbi::CArgAllow_Strings * pAllowed = new ncbi::CArgAllow_Strings;
	for (int i = 0; i < TEnumLitType::eEnumStop; ++i)
		pAllowed->AllowValue(TEnumLitType::dimLits[i]);
	
	return pAllowed;
}

// -- numeric to default literature
template <typename TNumeric>
const char * NumericDefVal(TNumeric n)
{
	static std::list<std::string> st_storage;
	st_storage.push_back(std::to_string(n));
	return st_storage.back().c_str();
}



// -- binname = the binary name, usually argv[0]


//enum EMiscFlags
//{
//	fNoUsage        = 1 << 0,  ///< Do not print USAGE on argument error.
//	fUsageIfNoArgs  = 1 << 1,  ///< Force printing USAGE (and then exit)
//	                           ///< if no command line args are present.
//	fUsageSortArgs  = 1 << 2,  ///< Sort args when printing USAGE.
//	fDupErrToCerr   = 1 << 3,  ///< Print arg error to both log and cerr.
//	
//	fMisc_Default   = 0
//};

ncbi:: CArgDescriptions * ProcessArgDefinitions(const std::string &binname, const std::string &usage, const std::string &descr, const TArgDefinition *pDefs, size_t ndef, const TExtraArg *pExtra = nullptr, size_t nextra = 0, ncbi::CArgDescriptions::EMiscFlags miscflgs = ncbi::CArgDescriptions::fMisc_Default);
#endif
/*************************************************************************
*	Sample code for apps using this setup
// ***********************************************************************
//#include <ncbi_pch.hpp>
#include <NcbiBase/argwrapper.hpp>
#include <corelib/ncbiapp.hpp>
#include <corelib/ncbifile.hpp>
#include <corelib/ncbireg.hpp>

#include <sstream>
//customize Argument definition
static const char *PROGRAM_USAGE = "testapp";
static const char *PROGRAM_DESCRIPTION =	//multiline
"Test app";

#define VERDEF 0,1,0

static constexpr const struct TVER
{
	int major;
	int minor;
	int patch_level;
} VER = {VERDEF};

// -- define error subcodes
// -- Define error codes
enum EErrorSubCode
{
	e_OK = 0,
	
	e_InputError,
	//-----------------------
	eErr_TotalErrorCodes
};


//This macro must be used inside ncbi namespace
BEGIN_NCBI_SCOPE
NCBI_DEFINE_ERRCODE_X(MyApp_job, 255, eErr_TotalErrorCodes - 1);
END_NCBI_SCOPE


// -- example of log messages:
//LOG_POST_X(e_InputError, "Cannot open " << input_file);


USING_NCBI_SCOPE;
//using namespace objects;

// -- must be defined for ERR_POST_X
#define NCBI_USE_ERRCODE_X MyApp_job


//// -- define constants that may be used in argument definitions
//struct TOutputFormat
//{
//	enum EIndex: TENUMIDX
//	{
//		eEnumStart = 0,
//		e_xml = eEnumStart,
//		e_fasta = e_xml + 1,
//		//
//		eEnumStop = e_fasta + 1
//	};
//	
//	static const EIndex eDefault = e_xml;
//	static const char* dimLits[eEnumStop - eEnumStart];
//};
//
//// -- define
//const char* TOutputFormat::dimLits[] = {"xml", "fasta"};
	





// -- give argument index names
enum EArgIndice: unsigned int
{
	//// -- name-indice here. C++ standard, if no value explicitly assigned, enumerators start from 0 and increase by 1
	//argEVCutoff,
	//argOutFormat,
	//// ------------------------
	TOTALARGS	//This natually as arg count.
};

static TArgDefinition dimValidArgs[] = 
{
	//// -- define your valid arguments
	//// -- do not use nullptr. use EMPTYSTR as empty string
	//{
	//	"e",	//argEVCutoff
	//	TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
	//	ncbi::CArgDescriptions::eDouble,	//ncbi::CArgDescriptions::EType(process type)
	//	"Specify E-Value cut off. Default is 0.01",	//string (description)
	//	true,	//if optional
	//	TArgDefinition::EMPTYSTR,	//Synopsis (short description)
	//	"-evcut",	//alias (can be used to specify at command line but not indexed in program
	//	0,	//ncbi::CArgDescriptions::EFlags
	//	TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
	//	NumericDefVal(DEF_EVALCUTOFF),	//Default Value
	//	nullptr,	//ncbi::CArgAllow * , constraint
	//	ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	//},
	//{
	//	"t",	//argOutFormat
	//	TArgDefinition::eKey,	//enum TArgDefinition::EArgCategory(argument type: eKey, ePos, eOpenPos, eFlag, eNegFlag)
	//	ncbi::CArgDescriptions::eString,	//ncbi::CArgDescriptions::EType(process type)
	//	"Specify output format.",	//string (description)
	//	true,	//if optional
	//	TArgDefinition::EMPTYSTR,	//Synopsis (short description)
	//	"-outfmt",	//alias (can be used to specify at command line but not indexed in program
	//	0,	//ncbi::CArgDescriptions::EFlags
	//	TArgDefinition::EMPTYSTR,	//value environment var (read arg value from this environment variable)
	//	GetDefaultLit<TOutputFormat> (),	//Default Value
	//	AllowEnumLits<TOutputFormat> (),	//ncbi::CArgAllow * , constraint
	//	ncbi::CArgDescriptions::eConstraint	//ncbi::CArgDescriptions::EConstraintNegate, eConstraint or eConstraintInvert
	//}
};

// -- positional arguments
static const size_t TOTALEXTRAARGS = 0;
static TExtraArg dimValidExtraArgs[] = 
{
	//{0, kMax_UInt, "Files that contain genomic sequence data. If none specified, read sequence data from stdin.", ncbi::CArgDescriptions::eInputFile, 0}
};


class CMyApp: public CNcbiApplication
{
public:
	
	// -- just a sample of syntax to define pointers to member function
	//typedef void (CSparcLabelApp :: * TLPFNFunc) (...);
	// -- to declare: TLPFNFunc lpfnFunc = &CMyApp::DoTheJob;
	// -- to call: (this->*lpfnFunc)(...);
	
	static string m_st_exec_name;	//binary full path
	static string m_st_launch_path;	//binary launch path
	static string m_st_real_path;	//binary true path
	
	
	CMyApp(void);
	virtual void Init(void);
	virtual int Run(void);
	virtual int DryRun(void);
	virtual void Exit(void);
	~CMyApp(void);

private:
	// -- common data members
	CNcbiRegistry &m_reg;
	int m_app_status;	//application status, hold value from defined EErrorSubCode
	stringstream m_init_msg;
	
	// -- arguments generated data
	//double m_evcutoff;
	//TENUMIDX m_outmode;	//xml or fasta
	
	
	
	// -- functions that does real jobs
	void DoTheJob(void);
	
};

string CMyApp::m_st_exec_name;
string CMyApp::m_st_launch_path;
string CMyApp::m_st_real_path;


CMyApp::CMyApp(void): CNcbiApplication(), m_reg(GetConfig()), m_app_status(e_OK), m_init_msg()
	//, m_evcutoff(DEF_EVALCUTOFF), m_outmode(TOutputFormat::eDefault)
{
	SetVersion(CVersionInfo(VER.major, VER.minor, VER.patch_level));
}

void CMyApp::Init(void)
{
	// -- first
	CNcbiApplication::Init();
	SetupArgDescriptions(ProcessArgDefinitions(CMyApp::m_st_exec_name, PROGRAM_USAGE, PROGRAM_DESCRIPTION, dimValidArgs, TOTALARGS, dimValidExtraArgs, TOTALEXTRAARGS));
	
	//// -- start to process parameters
	//const CArgs & args = GetArgs();
	//
	//const CArgValue
	//	&AV_EvalCutoff = args[dimValidArgs[argEVCutoff].name],
	//	&AV_OutFormat = args[dimValidArgs[argOutFormat].name];
	//	
	//m_evcutoff = AV_EvalCutoff.AsDouble();
	//m_outmode = GetIdx<TOutputFormat>(AV_OutFormat.AsString());
	
	//size_t nposargs = args.GetNExtra();
	
	// -- last: set status. If all ok:
	m_app_status = e_OK;
}

int CMyApp::Run(void)
{
	if (e_OK == m_app_status)
	{
		// -- do real job, if anything goes wrong, set m_app_status and goto labelReturn;
		DoTheJob();
	}
	return m_app_status;
}

int CMyApp::DryRun(void)
{
	if (e_OK == m_app_status)
	{
		// -- do test here, set m_app_status
	}
	return m_app_status;
}

void CMyApp::Exit(void)
{
	// -- clean up
	// -- last
	CNcbiApplication::Exit();
}

CMyApp::~CMyApp(void)
{
	// -- clean up
}

void CMyApp::DoTheJob(void)
{
	
}

int main(int argc, char * argv[])
{
	string launchAlias = CDirEntry::NormalizePath(argv[0]);
	string base, ext;
	CDirEntry::SplitPath(launchAlias, &CMyApp::m_st_launch_path, &base, &ext);
	if (!CMyApp::m_st_launch_path.empty())
		CMyApp::m_st_launch_path.pop_back();	//get rid of the tailing '/'
	// -- this is deliberately left alone
	CMyApp::m_st_exec_name = base + ext;
	
	CDir launchPathDir(launchAlias);
	launchPathDir.DereferencePath();
	
	CDirEntry::SplitPath(CDirEntry::CreateAbsolutePath(launchPathDir.GetPath(), CDirEntry::eRelativeToCwd), &CMyApp::m_st_real_path);
	if (!CMyApp::m_st_real_path.empty())
		CMyApp::m_st_real_path.pop_back();

	return CMyApp().AppMain(argc, argv);
	
}

// ***********************************************************************/
