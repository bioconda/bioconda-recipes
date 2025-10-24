/* TM-align: sequence-independent structure alignment of monomer proteins by
 * TM-score superposition. Please report issues to zhanglab@zhanggroup.org
 * 
 * References to cite:
 * Y Zhang, J Skolnick. Nucl Acids Res 33, 2302-9 (2005)
 *
 * DISCLAIMER:
 *  Permission to use, copy, modify, and distribute the Software for any
 *  purpose, with or without fee, is hereby granted, provided that the
 *  notices on the head, the reference information, and this copyright
 *  notice appear in all copies or substantial portions of the Software.
 *  It is provided "as is" without express or implied warranty.
 *
 * ==========================
 * How to install the program
 * ==========================
 * The following command compiles the program in your Linux computer:
 *
 *     g++ -static -O3 -ffast-math -lm -o TMalign TMalign.cpp
 *
 * The '-static' flag should be removed on Mac OS, which does not support
 * building static executables.
 *
 * ======================
 * How to use the program
 * ======================
 * You can run the program without argument to obtain the document.
 * Briefly, you can compare two structures by:
 *
 *     ./TMalign structure1.pdb structure2.pdb
 *
 * ==============
 * Update history
 * ==============
 * 2012/01/24: A C/C++ code of TM-align was constructed by Jianyi Yang
 * 2016/05/21: Several updates of this program were made by Jianji Wu:
 *            (1) fixed several compiling bugs
 *            (2) made I/O of C/C++ version consistent with the Fortran version
 *            (3) added outputs including full-atom and ligand structures
 *            (4) added options of '-i', '-I' and '-m'
 * 2016/05/25: Fixed a bug on PDB file reading
 * 2018/06/04: Several updates were made by Chengxin Zhang, including
 *            (1) Fixed bug in reading PDB files with negative residue index,
 *            (2) Implemented the fTM-align algorithm (by the '-fast' option)
 *                as described in R Dong, S Pan, Z Peng, Y Zhang, J Yang
 *                (2018) Nucleic acids research. gky430.
 *            (3) Included option to perform TM-align against a whole 
 *                folder of PDB files. A full list of options not available
 *                in the Fortran version can be explored by TMalign -h
 * 2018/07/27: Added the -byresi option for TM-score superposition without
 *             re-alignment as in TMscore and TMscore -c
 * 2018/08/07: Added the -dir option
 * 2018/08/14: Added the -split option
 * 2018/08/16: Added the -infmt1, -infmt2 options.
 * 2019/01/07: Added support for PDBx/mmCIF format.
 * 2019/02/09: Fixed asymmetric alignment bug.
 * 2019/03/17: Added the -cp option for circular permutation
 * 2019/07/23: Supported RasMol output by '-o' option
 * 2019/07/24: Fixed bug on PyMOL format output by '-o' option with mmCIF input
 * 2019/08/18: Fixed bug on RasMol format output file *_atm. Removed excessive
 *             circular permutation alignment by -cp
 * 2019/08/20: Clarified PyMOL syntax.
 * 2019/08/22: Added four additional PyMOL scripts.
 * 2020/12/12: Fixed bug in double precision coordinate cif file alignment.
 * 2021/02/24: Fixed file format issue for new incentive PyMOL.
 * 2022/04/12: Compatible with AlphaFold CIF
 */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>
#include <iterator>
#include <algorithm>
#include <string>
#include <map>

using namespace std;

void print_version()
{
    cout << 
"\n"
" *********************************************************************\n"
" * TM-align (Version 20220412): protein structure alignment          *\n"
" * References: Y Zhang, J Skolnick. Nucl Acids Res 33, 2302-9 (2005) *\n"
" * Please email comments and suggestions to zhanglab@zhanggroup.org   *\n"
" *********************************************************************"
    << endl;
}

void print_extra_help()
{
    cout <<
"Additional options:\n"
"    -dir     Perform all-against-all alignment among the list of PDB\n"
"             chains listed by 'chain_list' under 'chain_folder'. Note\n"
"             that the slash is necessary.\n"
"             $ TMalign -dir chain_folder/ chain_list\n"
"\n"
"    -dir1    Use chain2 to search a list of PDB chains listed by 'chain1_list'\n"
"             under 'chain1_folder'. Note that the slash is necessary.\n"
"             $ TMalign -dir1 chain1_folder/ chain1_list chain2\n"
"\n"
"    -dir2    Use chain1 to search a list of PDB chains listed by 'chain2_list'\n"
"             under 'chain2_folder'\n"
"             $ TMalign chain1 -dir2 chain2_folder/ chain2_list\n"
"\n"
"    -suffix  (Only when -dir1 and/or -dir2 are set, default is empty)\n"
"             add file name suffix to files listed by chain1_list or chain2_list\n"
"\n"
"    -atom    4-character atom name used to represent a residue.\n"
"             Default is \" CA \" for proteins\n"
"             (note the spaces before and after CA).\n"
"\n"
"    -ter     Strings to mark the end of a chain\n"
"             3: (default) TER, ENDMDL, END or different chain ID\n"
"             2: ENDMDL, END, or different chain ID\n"
"             1: ENDMDL or END\n"
"             0: (default in the first C++ TMalign) end of file\n"
"\n"
"    -split   Whether to split PDB file into multiple chains\n"
"             0: (default) treat the whole structure as one single chain\n"
"             1: treat each MODEL as a separate chain (-ter should be 0)\n"
"             2: treat each chain as a seperate chain (-ter should be <=1)\n"
"\n"
"    -outfmt  Output format\n"
"             0: (default) full output\n"
"             1: fasta format compact output\n"
"             2: tabular format very compact output\n"
"            -1: full output, but without version or citation information\n"
"\n"
"    -byresi  Whether to assume residue index correspondence between the\n" 
"             two structures.\n"
"             0: (default) sequence independent alignment\n"
"             1: (same as TMscore program) sequence-dependent superposition,\n"
"                i.e. align by residue index\n"
"             2: (same as TMscore -c, should be used with -ter <=1)\n"
"                align by residue index and chain ID\n"
"             3: (similar to TMscore -c, should be used with -ter <=1)\n"
"                align by residue index and order of chain\n"
"\n"
"    -TMcut   -1: (default) do not consider TMcut\n"
"             Values in [0.5,1): Do not proceed with TM-align for this\n"
"                 structure pair if TM-score is unlikely to reach TMcut.\n"
"                 TMcut is normalized is set by -a option:\n"
"                 -2: normalized by longer structure length\n"
"                 -1: normalized by shorter structure length\n"
"                  0: (default, same as F) normalized by second structure\n"
"                  1: same as T, normalized by average structure length\n"
"\n"
"    -mirror  Whether to align the mirror image of input structure\n"
"             0: (default) do not align mirrored structure\n"
"             1: align mirror of chain1 to origin chain2\n"
"\n"
"    -het     Whether to align residues marked as 'HETATM' in addition to 'ATOM  '\n"
"             0: (default) only align 'ATOM  ' residues\n"
"             1: align both 'ATOM  ' and 'HETATM' residues\n"
"\n"
"    -infmt1  Input format for chain1\n"
"    -infmt2  Input format for chain2\n"
"            -1: (default) automatically detect PDB or PDBx/mmCIF format\n"
"             0: PDB format\n"
"             1: SPICKER format\n"
"             2: xyz format\n"
"             3: PDBx/mmCIF format\n"
    <<endl;
}

void print_help(bool h_opt=false)
{
    print_version();
    cout <<
"\n"
"Usage: TMalign PDB1.pdb PDB2.pdb [Options]\n"
"\n"
"Options:\n"
"    -u    TM-score normalized by user assigned length (the same as -L)\n"
"          warning: it should be >= minimum length of the two structures\n"
"          otherwise, TM-score may be >1\n"
"\n"
"    -a    TM-score normalized by the average length of two structures\n"
"          T or F, (default F)\n"
"\n"
"    -i    Start with an alignment specified in fasta file 'align.txt'\n"
"\n"
"    -I    Stick to the alignment specified in 'align.txt'\n"
"\n"
"    -m    Output TM-align rotation matrix\n"
"\n"
"    -d    TM-score scaled by an assigned d0, e.g. 5 Angstroms\n"
"\n"
"    -o    Output the superposition to 'TM_sup*'\n"
"            $ TMalign PDB1.pdb PDB2.pdb -o TM_sup\n"
"          View superposed C-alpha traces of aligned regions by RasMol or PyMOL:\n"
"            $ rasmol -script TM_sup\n"
"            $ pymol -d @TM_sup.pml\n"
"          View superposed C-alpha traces of all regions:\n"
"            $ rasmol -script TM_sup_all\n"
"            $ pymol -d @TM_sup_all.pml\n"
"          View superposed full-atom structures of aligned regions:\n"
"            $ rasmol -script TM_sup_atm\n"
"            $ pymol -d @TM_sup_atm.pml\n"
"          View superposed full-atom structures of all regions:\n"
"            $ rasmol -script TM_sup_all_atm\n"
"            $ pymol -d @TM_sup_all_atm.pml\n"
"          View superposed full-atom structures and ligands of all regions\n"
"            $ rasmol -script TM_sup_all_atm_lig\n"
"            $ pymol -d @TM_sup_all_atm_lig.pml\n"
"\n"
" -fast    Fast but slightly inaccurate alignment by fTM-align algorithm\n"
"\n"
"   -cp    Alignment with circular permutation\n"
"\n"
"    -v    Print the version of TM-align\n"
"\n"
"    -h    Print the full help message, including additional options\n"
"\n"
"    (Options -u, -a, -d, -o will not change the final structure alignment)\n\n"
"Example usages:\n"
"    TMalign PDB1.pdb PDB2.pdb\n"
"    TMalign PDB1.pdb PDB2.pdb -u 100 -d 5.0\n"
"    TMalign PDB1.pdb PDB2.pdb -a T -o PDB1.sup\n"
"    TMalign PDB1.pdb PDB2.pdb -i align.txt\n"
"    TMalign PDB1.pdb PDB2.pdb -m matrix.txt\n"
"    TMalign PDB1.pdb PDB2.pdb -fast\n"
"    TMalign PDB1.pdb PDB2.pdb -cp\n"
    <<endl;

    if (h_opt) print_extra_help();

    exit(EXIT_SUCCESS);
}


/* Functions for the core TMalign algorithm, including the entry function
 * TMalign_main */

void PrintErrorAndQuit(const string sErrorString)
{
    cout << sErrorString << endl;
    exit(1);
}

template <typename T> inline T getmin(const T &a, const T &b)
{
    return b<a?b:a;
}

template <class A> void NewArray(A *** array, int Narray1, int Narray2)
{
    *array=new A* [Narray1];
    for(int i=0; i<Narray1; i++) *(*array+i)=new A [Narray2];
}

template <class A> void DeleteArray(A *** array, int Narray)
{
    for(int i=0; i<Narray; i++)
        if(*(*array+i)) delete [] *(*array+i);
    if(Narray) delete [] (*array);
    (*array)=NULL;
}

string AAmap(char A)
{
    if (A=='A') return "ALA";
    if (A=='B') return "ASX";
    if (A=='C') return "CYS";
    if (A=='D') return "ASP";
    if (A=='E') return "GLU";
    if (A=='F') return "PHE";
    if (A=='G') return "GLY";
    if (A=='H') return "HIS";
    if (A=='I') return "ILE";
    if (A=='K') return "LYS";
    if (A=='L') return "LEU";
    if (A=='M') return "MET";
    if (A=='N') return "ASN";
    if (A=='O') return "PYL";
    if (A=='P') return "PRO";
    if (A=='Q') return "GLN";
    if (A=='R') return "ARG";
    if (A=='S') return "SER";
    if (A=='T') return "THR";
    if (A=='U') return "SEC";
    if (A=='V') return "VAL";
    if (A=='W') return "TRP";    
    if (A=='Y') return "TYR";
    if (A=='Z') return "GLX";
    return "UNK";
}

char AAmap(const string &AA)
{
    if (AA.compare("ALA")==0 || AA.compare("DAL")==0) return 'A';
    if (AA.compare("ASX")==0) return 'B';
    if (AA.compare("CYS")==0 || AA.compare("DCY")==0) return 'C';
    if (AA.compare("ASP")==0 || AA.compare("DAS")==0) return 'D';
    if (AA.compare("GLU")==0 || AA.compare("DGL")==0) return 'E';
    if (AA.compare("PHE")==0 || AA.compare("DPN")==0) return 'F';
    if (AA.compare("GLY")==0) return 'G';
    if (AA.compare("HIS")==0 || AA.compare("DHI")==0) return 'H';
    if (AA.compare("ILE")==0 || AA.compare("DIL")==0) return 'I';
    if (AA.compare("LYS")==0 || AA.compare("DLY")==0) return 'K';
    if (AA.compare("LEU")==0 || AA.compare("DLE")==0) return 'L';
    if (AA.compare("MET")==0 || AA.compare("MED")==0 ||
        AA.compare("MSE")==0) return 'M';
    if (AA.compare("ASN")==0 || AA.compare("DSG")==0) return 'N';
    if (AA.compare("PYL")==0) return 'O';
    if (AA.compare("PRO")==0 || AA.compare("DPR")==0) return 'P';
    if (AA.compare("GLN")==0 || AA.compare("DGN")==0) return 'Q';
    if (AA.compare("ARG")==0 || AA.compare("DAR")==0) return 'R';
    if (AA.compare("SER")==0 || AA.compare("DSN")==0) return 'S';
    if (AA.compare("THR")==0 || AA.compare("DTH")==0) return 'T';
    if (AA.compare("SEC")==0) return 'U';
    if (AA.compare("VAL")==0 || AA.compare("DVA")==0) return 'V';
    if (AA.compare("TRP")==0 || AA.compare("DTR")==0) return 'W';    
    if (AA.compare("TYR")==0 || AA.compare("DTY")==0) return 'Y';
    if (AA.compare("GLX")==0) return 'Z';
    return 'X';
}

/* split a long string into vectors by whitespace 
 * line          - input string
 * line_vec      - output vector 
 * delimiter     - delimiter */
void split(const string &line, vector<string> &line_vec,
    const char delimiter=' ')
{
    bool within_word = false;
    for (int pos=0;pos<line.size();pos++)
    {
        if (line[pos]==delimiter)
        {
            within_word = false;
            continue;
        }
        if (!within_word)
        {
            within_word = true;
            line_vec.push_back("");
        }
        line_vec.back()+=line[pos];
    }
}

/* strip white space at the begining or end of string */
string Trim(const string &inputString)
{
    string result = inputString;
    int idxBegin = inputString.find_first_not_of(" \n\r\t");
    int idxEnd = inputString.find_last_not_of(" \n\r\t");
    if (idxBegin >= 0 && idxEnd >= 0)
        result = inputString.substr(idxBegin, idxEnd + 1 - idxBegin);
    return result;
}

/* split a long string into vectors by whitespace, return both whitespaces
 * and non-whitespaces
 * line          - input string
 * line_vec      - output vector
 * space_vec     - output vector 
 * delimiter     - delimiter */
void split_white(const string &line, vector<string> &line_vec,
    vector<string>&white_vec, const char delimiter=' ')
{
    bool within_word = false;
    for (int pos=0;pos<line.size();pos++)
    {
        if (line[pos]==delimiter)
        {
            if (within_word==true)
            {
                white_vec.push_back("");
                within_word = false;
            }
            white_vec.back()+=delimiter;
        }
        else
        {
            if (within_word==false)
            {
                line_vec.push_back("");
                within_word = true;
            }
            line_vec.back()+=line[pos];
        }
    }
}

size_t get_PDB_lines(const string filename,
    vector<vector<string> >&PDB_lines, vector<string> &chainID_list,
    vector<int> &mol_vec, const int ter_opt, const int infmt_opt,
    const string atom_opt, const int split_opt, const int het_opt)
{
    size_t i=0; // resi i.e. atom index
    string line;
    char chainID=0;
    string resi="";
    bool select_atom=false;
    size_t model_idx=0;
    vector<string> tmp_str_vec;
    
    ifstream fin;
    fin.open(filename.c_str());

    if (infmt_opt==0||infmt_opt==-1) // PDB format
    {
        while (fin.good())
        {
            getline(fin, line);
            if (infmt_opt==-1 && line.compare(0,5,"loop_")==0) // PDBx/mmCIF
                return get_PDB_lines(filename,PDB_lines,chainID_list,
                    mol_vec, ter_opt, 3, atom_opt, split_opt,het_opt);
            if (i > 0)
            {
                if      (ter_opt>=1 && line.compare(0,3,"END")==0) break;
                else if (ter_opt>=3 && line.compare(0,3,"TER")==0) break;
            }
            if (split_opt && line.compare(0,3,"END")==0) chainID=0;
            if ((line.compare(0, 6, "ATOM  ")==0 || 
                (line.compare(0, 6, "HETATM")==0 && het_opt))
                && line.size()>=54 && (line[16]==' ' || line[16]=='A'))
            {
                if (atom_opt=="auto")
                        select_atom=(line.compare(12,4," CA ")==0);
                else    select_atom=(line.compare(12,4,atom_opt)==0);
                if (select_atom)
                {
                    if (!chainID)
                    {
                        chainID=line[21];
                        model_idx++;
                        stringstream i8_stream;
                        i=0;
                        if (split_opt==2) // split by chain
                        {
                            if (chainID==' ')
                            {
                                if (ter_opt>=1) i8_stream << ":_";
                                else i8_stream<<':'<<model_idx<<":_";
                            }
                            else
                            {
                                if (ter_opt>=1) i8_stream << ':' << chainID;
                                else i8_stream<<':'<<model_idx<<':'<<chainID;
                            }
                            chainID_list.push_back(i8_stream.str());
                        }
                        else if (split_opt==1) // split by model
                        {
                            i8_stream << ':' << model_idx;
                            chainID_list.push_back(i8_stream.str());
                        }
                        PDB_lines.push_back(tmp_str_vec);
                        mol_vec.push_back(0);
                    }
                    else if (ter_opt>=2 && chainID!=line[21]) break;
                    if (split_opt==2 && chainID!=line[21])
                    {
                        chainID=line[21];
                        i=0;
                        stringstream i8_stream;
                        if (chainID==' ')
                        {
                            if (ter_opt>=1) i8_stream << ":_";
                            else i8_stream<<':'<<model_idx<<":_";
                        }
                        else
                        {
                            if (ter_opt>=1) i8_stream << ':' << chainID;
                            else i8_stream<<':'<<model_idx<<':'<<chainID;
                        }
                        chainID_list.push_back(i8_stream.str());
                        PDB_lines.push_back(tmp_str_vec);
                        mol_vec.push_back(0);
                    }

                    if (resi==line.substr(22,5))
                        cerr<<"Warning! Duplicated residue "<<resi<<endl;
                    resi=line.substr(22,5); // including insertion code

                    PDB_lines.back().push_back(line);
                    if (line[17]==' ' && (line[18]=='D'||line[18]==' ')) mol_vec.back()++;
                    else mol_vec.back()--;
                    i++;
                }
            }
        }
    }
    else if (infmt_opt==1) // SPICKER format
    {
        int L=0;
        float x,y,z;
        stringstream i8_stream;
        while (fin.good())
        {
            fin   >>L>>x>>y>>z;
            getline(fin, line);
            if (!fin.good()) break;
            model_idx++;
            stringstream i8_stream;
            i8_stream << ':' << model_idx;
            chainID_list.push_back(i8_stream.str());
            PDB_lines.push_back(tmp_str_vec);
            mol_vec.push_back(0);
            for (i=0;i<L;i++)
            {
                fin   >>x>>y>>z;
                i8_stream<<"ATOM   "<<setw(4)<<i+1<<"  CA  UNK  "<<setw(4)
                    <<i+1<<"    "<<setiosflags(ios::fixed)<<setprecision(3)
                    <<setw(8)<<x<<setw(8)<<y<<setw(8)<<z;
                line=i8_stream.str();
                i8_stream.str(string());
                PDB_lines.back().push_back(line);
            }
            getline(fin, line);
        }
    }
    else if (infmt_opt==2) // xyz format
    {
        int L=0;
        char A;
        stringstream i8_stream;
        while (fin.good())
        {
            getline(fin, line);
            L=atoi(line.c_str());
            getline(fin, line);
            for (i=0;i<line.size();i++)
                if (line[i]==' '||line[i]=='\t') break;
            if (!fin.good()) break;
            chainID_list.push_back(':'+line.substr(0,i));
            PDB_lines.push_back(tmp_str_vec);
            mol_vec.push_back(0);
            for (i=0;i<L;i++)
            {
                getline(fin, line);
                i8_stream<<"ATOM   "<<setw(4)<<i+1<<"  CA  "
                    <<AAmap(line[0])<<"  "<<setw(4)<<i+1<<"    "
                    <<line.substr(2,8)<<line.substr(11,8)<<line.substr(20,8);
                line=i8_stream.str();
                i8_stream.str(string());
                PDB_lines.back().push_back(line);
                if (line[0]>='a' && line[0]<='z') mol_vec.back()++; // RNA
                else mol_vec.back()--;
            }
        }
    }
    else if (infmt_opt==3) // PDBx/mmCIF format
    {
        bool loop_ = false; // not reading following content
        map<string,int> _atom_site;
        int atom_site_pos;
        vector<string> line_vec;
        string alt_id=".";  // alternative location indicator
        string asym_id="."; // this is similar to chainID, except that
                            // chainID is char while asym_id is a string
                            // with possibly multiple char
        string prev_asym_id="";
        string AA="";       // residue name
        string atom="";
        string prev_resi="";
        string model_index=""; // the same as model_idx but type is string
        stringstream i8_stream;
        while (fin.good())
        {
            getline(fin, line);
            if (line.size()==0) continue;
            if (loop_) loop_ = (line.size()>=2)?(line.compare(0,2,"# ")):(line.compare(0,1,"#"));
            if (!loop_)
            {
                if (line.compare(0,5,"loop_")) continue;
                while(1)
                {
                    if (fin.good()) getline(fin, line);
                    else PrintErrorAndQuit("ERROR! Unexpected end of "+filename);
                    if (line.size()) break;
                }
                if (line.compare(0,11,"_atom_site.")) continue;

                loop_=true;
                _atom_site.clear();
                atom_site_pos=0;
                _atom_site[Trim(line.substr(11))]=atom_site_pos;

                while(1)
                {
                    if (fin.good()) getline(fin, line);
                    else PrintErrorAndQuit("ERROR! Unexpected end of "+filename);
                    if (line.size()==0) continue;
                    if (line.compare(0,11,"_atom_site.")) break;
                    _atom_site[Trim(line.substr(11))]=++atom_site_pos;
                }


                if (_atom_site.count("group_PDB")*
                    _atom_site.count("label_atom_id")*
                    _atom_site.count("label_comp_id")*
                   (_atom_site.count("auth_asym_id")+
                    _atom_site.count("label_asym_id"))*
                   (_atom_site.count("auth_seq_id")+
                    _atom_site.count("label_seq_id"))*
                    _atom_site.count("Cartn_x")*
                    _atom_site.count("Cartn_y")*
                    _atom_site.count("Cartn_z")==0)
                {
                    loop_ = false;
                    cerr<<"Warning! Missing one of the following _atom_site data items: group_PDB, label_atom_id, label_atom_id, auth_asym_id/label_asym_id, auth_seq_id/label_seq_id, Cartn_x, Cartn_y, Cartn_z"<<endl;
                    continue;
                }
            }

            line_vec.clear();
            split(line,line_vec);
            if (line_vec[_atom_site["group_PDB"]]!="ATOM" && (het_opt==0 ||
                line_vec[_atom_site["group_PDB"]]!="HETATM")) continue;
            
            alt_id=".";
            if (_atom_site.count("label_alt_id")) // in 39.4 % of entries
                alt_id=line_vec[_atom_site["label_alt_id"]];
            if (alt_id!="." && alt_id!="A") continue;

            atom=line_vec[_atom_site["label_atom_id"]];
            if (atom[0]=='"') atom=atom.substr(1);
            if (atom.size() && atom[atom.size()-1]=='"')
                atom=atom.substr(0,atom.size()-1);
            if (atom.size()==0) continue;
            if      (atom.size()==1) atom=" "+atom+"  ";
            else if (atom.size()==2) atom=" "+atom+" "; // wrong for sidechain H
            else if (atom.size()==3) atom=" "+atom;
            else if (atom.size()>=5) continue;

            AA=line_vec[_atom_site["label_comp_id"]]; // residue name
            if      (AA.size()==1) AA="  "+AA;
            else if (AA.size()==2) AA=" " +AA;
            else if (AA.size()>=4) continue;

            if (atom_opt=="auto")
                    select_atom=(atom==" CA ");
            else    select_atom=(atom==atom_opt);

            if (!select_atom) continue;

            if (_atom_site.count("auth_asym_id"))
                 asym_id=line_vec[_atom_site["auth_asym_id"]];
            else asym_id=line_vec[_atom_site["label_asym_id"]];
            if (asym_id==".") asym_id=" ";
            
            if (_atom_site.count("pdbx_PDB_model_num") && 
                model_index!=line_vec[_atom_site["pdbx_PDB_model_num"]])
            {
                model_index=line_vec[_atom_site["pdbx_PDB_model_num"]];
                if (PDB_lines.size() && ter_opt>=1) break;
                if (PDB_lines.size()==0 || split_opt>=1)
                {
                    PDB_lines.push_back(tmp_str_vec);
                    mol_vec.push_back(0);
                    prev_asym_id=asym_id;

                    if (split_opt==1 && ter_opt==0) chainID_list.push_back(
                        ':'+model_index);
                    else if (split_opt==2 && ter_opt==0)
                        chainID_list.push_back(':'+model_index+':'+asym_id);
                    else if (split_opt==2 && ter_opt==1)
                        chainID_list.push_back(':'+asym_id);
                }
            }

            if (prev_asym_id!=asym_id)
            {
                if (prev_asym_id!="" && ter_opt>=2) break;
                if (split_opt>=2)
                {
                    PDB_lines.push_back(tmp_str_vec);
                    mol_vec.push_back(0);

                    if (split_opt==1 && ter_opt==0) chainID_list.push_back(
                        ':'+model_index);
                    else if (split_opt==2 && ter_opt==0)
                        chainID_list.push_back(':'+model_index+':'+asym_id);
                    else if (split_opt==2 && ter_opt==1)
                        chainID_list.push_back(':'+asym_id);
                }
            }
            if (prev_asym_id!=asym_id) prev_asym_id=asym_id;

            if (AA[0]==' ' && (AA[1]=='D'||AA[1]==' ')) mol_vec.back()++;
            else mol_vec.back()--;

            if (_atom_site.count("auth_seq_id"))
                 resi=line_vec[_atom_site["auth_seq_id"]];
            else resi=line_vec[_atom_site["label_seq_id"]];
            if (_atom_site.count("pdbx_PDB_ins_code") && 
                line_vec[_atom_site["pdbx_PDB_ins_code"]]!="?")
                resi+=line_vec[_atom_site["pdbx_PDB_ins_code"]][0];
            else resi+=" ";

            if (prev_resi==resi)
                cerr<<"Warning! Duplicated residue "<<resi<<endl;
            prev_resi=resi;

            i++;
            i8_stream<<"ATOM  "
                <<setw(5)<<i<<" "<<atom<<" "<<AA<<" "<<asym_id[0]
                <<setw(5)<<resi.substr(0,5)<<"   "
                <<setw(8)<<line_vec[_atom_site["Cartn_x"]].substr(0,8)
                <<setw(8)<<line_vec[_atom_site["Cartn_y"]].substr(0,8)
                <<setw(8)<<line_vec[_atom_site["Cartn_z"]].substr(0,8);
            PDB_lines.back().push_back(i8_stream.str());
            i8_stream.str(string());
        }
        _atom_site.clear();
        line_vec.clear();
        alt_id.clear();
        asym_id.clear();
        AA.clear();
    }

    fin.close();
    line.clear();
    if (!split_opt) chainID_list.push_back("");
    return PDB_lines.size();
}

/* read fasta file from filename. sequence is stored into FASTA_lines
 * while sequence name is stored into chainID_list.
 * if ter_opt >=1, only read the first sequence.
 * if ter_opt ==0, read all sequences.
 * if split_opt >=1 and ter_opt ==0, each sequence is a separate entry.
 * if split_opt ==0 and ter_opt ==0, all sequences are combined into one */
size_t get_FASTA_lines(const string filename,
    vector<vector<string> >&FASTA_lines, vector<string> &chainID_list,
    vector<int> &mol_vec, const int ter_opt=3, const int split_opt=0)
{
    string line;
    vector<string> tmp_str_vec;
    int l;
    
    ifstream fin;
    fin.open(filename.c_str());

    while (fin.good())
    {
        getline(fin, line);
        if (line.size()==0 || line[0]=='#') continue;

        if (line[0]=='>')
        {
            if (FASTA_lines.size())
            {
                if (ter_opt) break;
                if (split_opt==0) continue;
            }
            FASTA_lines.push_back(tmp_str_vec);
            FASTA_lines.back().push_back("");
            mol_vec.push_back(0);
            if (ter_opt==0 && split_opt)
            {
                line[0]=':';
                chainID_list.push_back(line);
            }
            else chainID_list.push_back("");
        }
        else
        {
            FASTA_lines.back()[0]+=line;
            for (l=0;l<line.size();l++) mol_vec.back()+=
                ('a'<=line[l] && line[l]<='z')-('A'<=line[l] && line[l]<='Z');
        }
    }

    line.clear();
    fin.close();
    return FASTA_lines.size();
}


/* extract pairwise sequence alignment from residue index vectors,
 * assuming that "sequence" contains two empty strings.
 * return length of alignment, including gap. */
int extract_aln_from_resi(vector<string> &sequence, char *seqx, char *seqy,
    const vector<string> resi_vec1, const vector<string> resi_vec2,
    const int byresi_opt)
{
    sequence.clear();
    sequence.push_back("");
    sequence.push_back("");

    int i1=0; // positions in resi_vec1
    int i2=0; // positions in resi_vec2
    int xlen=resi_vec1.size();
    int ylen=resi_vec2.size();
    map<char,int> chainID_map1;
    map<char,int> chainID_map2;
    if (byresi_opt==3)
    {
        vector<char> chainID_vec;
        char chainID;
        int i;
        for (i=0;i<xlen;i++)
        {
            chainID=resi_vec1[i][5];
            if (!chainID_vec.size()|| chainID_vec.back()!=chainID)
            {
                chainID_vec.push_back(chainID);
                chainID_map1[chainID]=chainID_vec.size();
            }
        }
        chainID_vec.clear();
        for (i=0;i<ylen;i++)
        {
            chainID=resi_vec2[i][5];
            if (!chainID_vec.size()|| chainID_vec.back()!=chainID)
            {
                chainID_vec.push_back(chainID);
                chainID_map2[chainID]=chainID_vec.size();
            }
        }
        chainID_vec.clear();
    }
    while(i1<xlen && i2<ylen)
    {
        if ((byresi_opt<=2 && resi_vec1[i1]==resi_vec2[i2]) || (byresi_opt==3
             && resi_vec1[i1].substr(0,5)==resi_vec2[i2].substr(0,5)
             && chainID_map1[resi_vec1[i1][5]]==chainID_map2[resi_vec2[i2][5]]))
        {
            sequence[0]+=seqx[i1++];
            sequence[1]+=seqy[i2++];
        }
        else if (atoi(resi_vec1[i1].substr(0,4).c_str())<=
                 atoi(resi_vec2[i2].substr(0,4).c_str()))
        {
            sequence[0]+=seqx[i1++];
            sequence[1]+='-';
        }
        else
        {
            sequence[0]+='-';
            sequence[1]+=seqy[i2++];
        }
    }
    chainID_map1.clear();
    chainID_map2.clear();
    return sequence[0].size();
}

int read_PDB(const vector<string> &PDB_lines, double **a, char *seq,
    vector<string> &resi_vec, const int byresi_opt)
{
    int i;
    for (i=0;i<PDB_lines.size();i++)
    {
        a[i][0] = atof(PDB_lines[i].substr(30, 8).c_str());
        a[i][1] = atof(PDB_lines[i].substr(38, 8).c_str());
        a[i][2] = atof(PDB_lines[i].substr(46, 8).c_str());
        seq[i]  = AAmap(PDB_lines[i].substr(17, 3));

        if (byresi_opt>=2) resi_vec.push_back(PDB_lines[i].substr(22,5)+
                                              PDB_lines[i][21]);
        if (byresi_opt==1) resi_vec.push_back(PDB_lines[i].substr(22,5));
    }
    seq[i]='\0'; 
    return i;
}

double dist(double x[3], double y[3])
{
    double d1=x[0]-y[0];
    double d2=x[1]-y[1];
    double d3=x[2]-y[2];
 
    return (d1*d1 + d2*d2 + d3*d3);
}

double dot(double *a, double *b)
{
    return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]);
}

void transform(double t[3], double u[3][3], double *x, double *x1)
{
    x1[0]=t[0]+dot(&u[0][0], x);
    x1[1]=t[1]+dot(&u[1][0], x);
    x1[2]=t[2]+dot(&u[2][0], x);
}

void do_rotation(double **x, double **x1, int len, double t[3], double u[3][3])
{
    for(int i=0; i<len; i++)
    {
        transform(t, u, &x[i][0], &x1[i][0]);
    }    
}

/* read user specified pairwise alignment from 'fname_lign' to 'sequence'.
 * This function should only be called by main function, as it will
 * terminate a program if wrong alignment is given */
void read_user_alignment(vector<string>&sequence, const string &fname_lign,
    const int i_opt)
{
    if (fname_lign == "")
        PrintErrorAndQuit("Please provide a file name for option -i!");
    // open alignment file
    int n_p = 0;// number of structures in alignment file
    string line;
    
    ifstream fileIn(fname_lign.c_str());
    if (fileIn.is_open())
    {
        while (fileIn.good())
        {
            getline(fileIn, line);
            if (line.compare(0, 1, ">") == 0)// Flag for a new structure
            {
                if (n_p >= 2) break;
                sequence.push_back("");
                n_p++;
            }
            else if (n_p > 0 && line!="") sequence.back()+=line;
        }
        fileIn.close();
    }
    else PrintErrorAndQuit("ERROR! Alignment file does not exist.");
    
    if (n_p < 2)
        PrintErrorAndQuit("ERROR: Fasta format is wrong, two proteins should be included.");
    if (sequence[0].size() != sequence[1].size())
        PrintErrorAndQuit("ERROR! FASTA file is wrong. The length in alignment should be equal for the two aligned proteins.");
    if (i_opt==3)
    {
        int aligned_resNum=0;
        for (int i=0;i<sequence[0].size();i++) 
            aligned_resNum+=(sequence[0][i]!='-' && sequence[1][i]!='-');
        if (aligned_resNum<3)
            PrintErrorAndQuit("ERROR! Superposition is undefined for <3 aligned residues.");
    }
    line.clear();
    return;
}

/* read list of entries from 'name' to 'chain_list'.
 * dir_opt is the folder name (prefix).
 * suffix_opt is the file name extension (suffix_opt).
 * This function should only be called by main function, as it will
 * terminate a program if wrong alignment is given */
void file2chainlist(vector<string>&chain_list, const string &name,
    const string &dir_opt, const string &suffix_opt)
{
    ifstream fp(name.c_str());
    if (! fp.is_open())
        PrintErrorAndQuit(("Can not open file: "+name+'\n').c_str());
    string line;
    while (fp.good())
    {
        getline(fp, line);
        if (! line.size()) continue;
        chain_list.push_back(dir_opt+Trim(line)+suffix_opt);
    }
    fp.close();
    line.clear();
}

/**************************************************************************
Implemetation of Kabsch algoritm for finding the best rotation matrix
---------------------------------------------------------------------------
x    - x(i,m) are coordinates of atom m in set x            (input)
y    - y(i,m) are coordinates of atom m in set y            (input)
n    - n is number of atom pairs                            (input)
mode  - 0:calculate rms only                                (input)
1:calculate u,t only                                (takes medium)
2:calculate rms,u,t                                 (takes longer)
rms   - sum of w*(ux+t-y)**2 over all atom pairs            (output)
u    - u(i,j) is   rotation  matrix for best superposition  (output)
t    - t(i)   is translation vector for best superposition  (output)
**************************************************************************/
bool Kabsch(double **x, double **y, int n, int mode, double *rms,
    double t[3], double u[3][3])
{
    int i, j, m, m1, l, k;
    double e0, rms1, d, h, g;
    double cth, sth, sqrth, p, det, sigma;
    double xc[3], yc[3];
    double a[3][3], b[3][3], r[3][3], e[3], rr[6], ss[6];
    double sqrt3 = 1.73205080756888, tol = 0.01;
    int ip[] = { 0, 1, 3, 1, 2, 4, 3, 4, 5 };
    int ip2312[] = { 1, 2, 0, 1 };

    int a_failed = 0, b_failed = 0;
    double epsilon = 0.00000001;

    //initializtation
    *rms = 0;
    rms1 = 0;
    e0 = 0;
    double c1[3], c2[3];
    double s1[3], s2[3];
    double sx[3], sy[3], sz[3];
    for (i = 0; i < 3; i++)
    {
        s1[i] = 0.0;
        s2[i] = 0.0;

        sx[i] = 0.0;
        sy[i] = 0.0;
        sz[i] = 0.0;
    }

    for (i = 0; i<3; i++)
    {
        xc[i] = 0.0;
        yc[i] = 0.0;
        t[i] = 0.0;
        for (j = 0; j<3; j++)
        {
            u[i][j] = 0.0;
            r[i][j] = 0.0;
            a[i][j] = 0.0;
            if (i == j)
            {
                u[i][j] = 1.0;
                a[i][j] = 1.0;
            }
        }
    }

    if (n<1) return false;

    //compute centers for vector sets x, y
    for (i = 0; i<n; i++)
    {
        for (j = 0; j < 3; j++)
        {
            c1[j] = x[i][j];
            c2[j] = y[i][j];

            s1[j] += c1[j];
            s2[j] += c2[j];
        }

        for (j = 0; j < 3; j++)
        {
            sx[j] += c1[0] * c2[j];
            sy[j] += c1[1] * c2[j];
            sz[j] += c1[2] * c2[j];
        }
    }
    for (i = 0; i < 3; i++)
    {
        xc[i] = s1[i] / n;
        yc[i] = s2[i] / n;
    }
    if (mode == 2 || mode == 0)
        for (int mm = 0; mm < n; mm++)
            for (int nn = 0; nn < 3; nn++)
                e0 += (x[mm][nn] - xc[nn]) * (x[mm][nn] - xc[nn]) + 
                      (y[mm][nn] - yc[nn]) * (y[mm][nn] - yc[nn]);
    for (j = 0; j < 3; j++)
    {
        r[j][0] = sx[j] - s1[0] * s2[j] / n;
        r[j][1] = sy[j] - s1[1] * s2[j] / n;
        r[j][2] = sz[j] - s1[2] * s2[j] / n;
    }

    //compute determinat of matrix r
    det = r[0][0] * (r[1][1] * r[2][2] - r[1][2] * r[2][1])\
        - r[0][1] * (r[1][0] * r[2][2] - r[1][2] * r[2][0])\
        + r[0][2] * (r[1][0] * r[2][1] - r[1][1] * r[2][0]);
    sigma = det;

    //compute tras(r)*r
    m = 0;
    for (j = 0; j<3; j++)
    {
        for (i = 0; i <= j; i++)
        {
            rr[m] = r[0][i] * r[0][j] + r[1][i] * r[1][j] + r[2][i] * r[2][j];
            m++;
        }
    }

    double spur = (rr[0] + rr[2] + rr[5]) / 3.0;
    double cof = (((((rr[2] * rr[5] - rr[4] * rr[4]) + rr[0] * rr[5])\
        - rr[3] * rr[3]) + rr[0] * rr[2]) - rr[1] * rr[1]) / 3.0;
    det = det*det;

    for (i = 0; i<3; i++) e[i] = spur;

    if (spur>0)
    {
        d = spur*spur;
        h = d - cof;
        g = (spur*cof - det) / 2.0 - spur*h;

        if (h>0)
        {
            sqrth = sqrt(h);
            d = h*h*h - g*g;
            if (d<0.0) d = 0.0;
            d = atan2(sqrt(d), -g) / 3.0;
            cth = sqrth * cos(d);
            sth = sqrth*sqrt3*sin(d);
            e[0] = (spur + cth) + cth;
            e[1] = (spur - cth) + sth;
            e[2] = (spur - cth) - sth;

            if (mode != 0)
            {//compute a                
                for (l = 0; l<3; l = l + 2)
                {
                    d = e[l];
                    ss[0] = (d - rr[2]) * (d - rr[5]) - rr[4] * rr[4];
                    ss[1] = (d - rr[5]) * rr[1] + rr[3] * rr[4];
                    ss[2] = (d - rr[0]) * (d - rr[5]) - rr[3] * rr[3];
                    ss[3] = (d - rr[2]) * rr[3] + rr[1] * rr[4];
                    ss[4] = (d - rr[0]) * rr[4] + rr[1] * rr[3];
                    ss[5] = (d - rr[0]) * (d - rr[2]) - rr[1] * rr[1];

                    if (fabs(ss[0]) <= epsilon) ss[0] = 0.0;
                    if (fabs(ss[1]) <= epsilon) ss[1] = 0.0;
                    if (fabs(ss[2]) <= epsilon) ss[2] = 0.0;
                    if (fabs(ss[3]) <= epsilon) ss[3] = 0.0;
                    if (fabs(ss[4]) <= epsilon) ss[4] = 0.0;
                    if (fabs(ss[5]) <= epsilon) ss[5] = 0.0;

                    if (fabs(ss[0]) >= fabs(ss[2]))
                    {
                        j = 0;
                        if (fabs(ss[0]) < fabs(ss[5])) j = 2;
                    }
                    else if (fabs(ss[2]) >= fabs(ss[5])) j = 1;
                    else j = 2;

                    d = 0.0;
                    j = 3 * j;
                    for (i = 0; i<3; i++)
                    {
                        k = ip[i + j];
                        a[i][l] = ss[k];
                        d = d + ss[k] * ss[k];
                    }


                    //if( d > 0.0 ) d = 1.0 / sqrt(d);
                    if (d > epsilon) d = 1.0 / sqrt(d);
                    else d = 0.0;
                    for (i = 0; i<3; i++) a[i][l] = a[i][l] * d;
                }//for l

                d = a[0][0] * a[0][2] + a[1][0] * a[1][2] + a[2][0] * a[2][2];
                if ((e[0] - e[1]) >(e[1] - e[2]))
                {
                    m1 = 2;
                    m = 0;
                }
                else
                {
                    m1 = 0;
                    m = 2;
                }
                p = 0;
                for (i = 0; i<3; i++)
                {
                    a[i][m1] = a[i][m1] - d*a[i][m];
                    p = p + a[i][m1] * a[i][m1];
                }
                if (p <= tol)
                {
                    p = 1.0;
                    for (i = 0; i<3; i++)
                    {
                        if (p < fabs(a[i][m])) continue;
                        p = fabs(a[i][m]);
                        j = i;
                    }
                    k = ip2312[j];
                    l = ip2312[j + 1];
                    p = sqrt(a[k][m] * a[k][m] + a[l][m] * a[l][m]);
                    if (p > tol)
                    {
                        a[j][m1] = 0.0;
                        a[k][m1] = -a[l][m] / p;
                        a[l][m1] = a[k][m] / p;
                    }
                    else a_failed = 1;
                }//if p<=tol
                else
                {
                    p = 1.0 / sqrt(p);
                    for (i = 0; i<3; i++) a[i][m1] = a[i][m1] * p;
                }//else p<=tol  
                if (a_failed != 1)
                {
                    a[0][1] = a[1][2] * a[2][0] - a[1][0] * a[2][2];
                    a[1][1] = a[2][2] * a[0][0] - a[2][0] * a[0][2];
                    a[2][1] = a[0][2] * a[1][0] - a[0][0] * a[1][2];
                }
            }//if(mode!=0)       
        }//h>0

        //compute b anyway
        if (mode != 0 && a_failed != 1)//a is computed correctly
        {
            //compute b
            for (l = 0; l<2; l++)
            {
                d = 0.0;
                for (i = 0; i<3; i++)
                {
                    b[i][l] = r[i][0] * a[0][l] + 
                              r[i][1] * a[1][l] + r[i][2] * a[2][l];
                    d = d + b[i][l] * b[i][l];
                }
                //if( d > 0 ) d = 1.0 / sqrt(d);
                if (d > epsilon) d = 1.0 / sqrt(d);
                else d = 0.0;
                for (i = 0; i<3; i++) b[i][l] = b[i][l] * d;
            }
            d = b[0][0] * b[0][1] + b[1][0] * b[1][1] + b[2][0] * b[2][1];
            p = 0.0;

            for (i = 0; i<3; i++)
            {
                b[i][1] = b[i][1] - d*b[i][0];
                p += b[i][1] * b[i][1];
            }

            if (p <= tol)
            {
                p = 1.0;
                for (i = 0; i<3; i++)
                {
                    if (p<fabs(b[i][0])) continue;
                    p = fabs(b[i][0]);
                    j = i;
                }
                k = ip2312[j];
                l = ip2312[j + 1];
                p = sqrt(b[k][0] * b[k][0] + b[l][0] * b[l][0]);
                if (p > tol)
                {
                    b[j][1] = 0.0;
                    b[k][1] = -b[l][0] / p;
                    b[l][1] = b[k][0] / p;
                }
                else b_failed = 1;
            }//if( p <= tol )
            else
            {
                p = 1.0 / sqrt(p);
                for (i = 0; i<3; i++) b[i][1] = b[i][1] * p;
            }
            if (b_failed != 1)
            {
                b[0][2] = b[1][0] * b[2][1] - b[1][1] * b[2][0];
                b[1][2] = b[2][0] * b[0][1] - b[2][1] * b[0][0];
                b[2][2] = b[0][0] * b[1][1] - b[0][1] * b[1][0];
                //compute u
                for (i = 0; i<3; i++)
                    for (j = 0; j<3; j++)
                        u[i][j] = b[i][0] * a[j][0] + 
                                  b[i][1] * a[j][1] + b[i][2] * a[j][2];
            }

            //compute t
            for (i = 0; i<3; i++)
                t[i] = ((yc[i] - u[i][0] * xc[0]) - u[i][1] * xc[1]) - 
                                                    u[i][2] * xc[2];
        }//if(mode!=0 && a_failed!=1)
    }//spur>0
    else //just compute t and errors
    {
        //compute t
        for (i = 0; i<3; i++)
            t[i] = ((yc[i] - u[i][0] * xc[0]) - u[i][1] * xc[1]) - 
                                                u[i][2] * xc[2];
    }//else spur>0 

    //compute rms
    for (i = 0; i<3; i++)
    {
        if (e[i] < 0) e[i] = 0;
        e[i] = sqrt(e[i]);
    }
    d = e[2];
    if (sigma < 0.0) d = -d;
    d = (d + e[1]) + e[0];

    if (mode == 2 || mode == 0)
    {
        rms1 = (e0 - d) - d;
        if (rms1 < 0.0) rms1 = 0.0;
    }

    *rms = rms1;
    return true;
}

/* Partial implementation of Needleman-Wunsch (NW) dymanamic programming for
 * global alignment. The three NWDP_TM functions below are not complete
 * implementation of NW algorithm because gap jumping in the standard Gotoh
 * algorithm is not considered. Since the gap opening and gap extension is
 * the same, this is not a problem. This code was exploited in TM-align
 * because it is about 1.5 times faster than a complete NW implementation.
 * Nevertheless, if gap openning != gap extension shall be implemented in
 * the future, the Gotoh algorithm must be implemented. In rare scenarios,
 * it is also possible to have asymmetric alignment (i.e. 
 * TMalign A.pdb B.pdb and TMalign B.pdb A.pdb have different TM_A and TM_B
 * values) caused by the NWPD_TM implement.
 */

/* Input: score[1:len1, 1:len2], and gap_open
 * Output: j2i[1:len2] \in {1:len1} U {-1}
 * path[0:len1, 0:len2]=1,2,3, from diagonal, horizontal, vertical */
void NWDP_TM(double **score, bool **path, double **val,
    int len1, int len2, double gap_open, int j2i[])
{

    int i, j;
    double h, v, d;

    //initialization
    for(i=0; i<=len1; i++)
    {
        val[i][0]=0;
        //val[i][0]=i*gap_open;
        path[i][0]=false; //not from diagonal
    }

    for(j=0; j<=len2; j++)
    {
        val[0][j]=0;
        //val[0][j]=j*gap_open;
        path[0][j]=false; //not from diagonal
        j2i[j]=-1;    //all are not aligned, only use j2i[1:len2]
    }      


    //decide matrix and path
    for(i=1; i<=len1; i++)
    {
        for(j=1; j<=len2; j++)
        {
            d=val[i-1][j-1]+score[i][j]; //diagonal

            //symbol insertion in horizontal (= a gap in vertical)
            h=val[i-1][j];
            if(path[i-1][j]) h += gap_open; //aligned in last position

            //symbol insertion in vertical
            v=val[i][j-1];
            if(path[i][j-1]) v += gap_open; //aligned in last position


            if(d>=h && d>=v)
            {
                path[i][j]=true; //from diagonal
                val[i][j]=d;
            }
            else 
            {
                path[i][j]=false; //from horizontal
                if(v>=h) val[i][j]=v;
                else val[i][j]=h;
            }
        } //for i
    } //for j

    //trace back to extract the alignment
    i=len1;
    j=len2;
    while(i>0 && j>0)
    {
        if(path[i][j]) //from diagonal
        {
            j2i[j-1]=i-1;
            i--;
            j--;
        }
        else 
        {
            h=val[i-1][j];
            if(path[i-1][j]) h +=gap_open;

            v=val[i][j-1];
            if(path[i][j-1]) v +=gap_open;

            if(v>=h) j--;
            else i--;
        }
    }
}

/* Input: vectors x, y, rotation matrix t, u, scale factor d02, and gap_open
 * Output: j2i[1:len2] \in {1:len1} U {-1}
 * path[0:len1, 0:len2]=1,2,3, from diagonal, horizontal, vertical */
void NWDP_TM(bool **path, double **val, double **x, double **y,
    int len1, int len2, double t[3], double u[3][3],
    double d02, double gap_open, int j2i[])
{
    int i, j;
    double h, v, d;

    //initialization. use old val[i][0] and val[0][j] initialization
    //to minimize difference from TMalign fortran version
    for(i=0; i<=len1; i++)
    {
        val[i][0]=0;
        //val[i][0]=i*gap_open;
        path[i][0]=false; //not from diagonal
    }

    for(j=0; j<=len2; j++)
    {
        val[0][j]=0;
        //val[0][j]=j*gap_open;
        path[0][j]=false; //not from diagonal
        j2i[j]=-1;    //all are not aligned, only use j2i[1:len2]
    }      
    double xx[3], dij;


    //decide matrix and path
    for(i=1; i<=len1; i++)
    {
        transform(t, u, &x[i-1][0], xx);
        for(j=1; j<=len2; j++)
        {
            dij=dist(xx, &y[j-1][0]);    
            d=val[i-1][j-1] +  1.0/(1+dij/d02);

            //symbol insertion in horizontal (= a gap in vertical)
            h=val[i-1][j];
            if(path[i-1][j]) h += gap_open; //aligned in last position

            //symbol insertion in vertical
            v=val[i][j-1];
            if(path[i][j-1]) v += gap_open; //aligned in last position


            if(d>=h && d>=v)
            {
                path[i][j]=true; //from diagonal
                val[i][j]=d;
            }
            else 
            {
                path[i][j]=false; //from horizontal
                if(v>=h) val[i][j]=v;
                else val[i][j]=h;
            }
        } //for i
    } //for j

    //trace back to extract the alignment
    i=len1;
    j=len2;
    while(i>0 && j>0)
    {
        if(path[i][j]) //from diagonal
        {
            j2i[j-1]=i-1;
            i--;
            j--;
        }
        else 
        {
            h=val[i-1][j];
            if(path[i-1][j]) h +=gap_open;

            v=val[i][j-1];
            if(path[i][j-1]) v +=gap_open;

            if(v>=h) j--;
            else i--;
        }
    }
}

/* This is the same as the previous NWDP_TM, except for the lack of rotation
 * Input: vectors x, y, scale factor d02, and gap_open
 * Output: j2i[1:len2] \in {1:len1} U {-1}
 * path[0:len1, 0:len2]=1,2,3, from diagonal, horizontal, vertical */
void NWDP_SE(bool **path, double **val, double **x, double **y,
    int len1, int len2, double d02, double gap_open, int j2i[])
{
    int i, j;
    double h, v, d;

    for(i=0; i<=len1; i++)
    {
        val[i][0]=0;
        path[i][0]=false; //not from diagonal
    }

    for(j=0; j<=len2; j++)
    {
        val[0][j]=0;
        path[0][j]=false; //not from diagonal
        j2i[j]=-1;    //all are not aligned, only use j2i[1:len2]
    }      
    double dij;

    //decide matrix and path
    for(i=1; i<=len1; i++)
    {
        for(j=1; j<=len2; j++)
        {
            dij=dist(&x[i-1][0], &y[j-1][0]);    
            d=val[i-1][j-1] +  1.0/(1+dij/d02);

            //symbol insertion in horizontal (= a gap in vertical)
            h=val[i-1][j];
            if(path[i-1][j]) h += gap_open; //aligned in last position

            //symbol insertion in vertical
            v=val[i][j-1];
            if(path[i][j-1]) v += gap_open; //aligned in last position


            if(d>=h && d>=v)
            {
                path[i][j]=true; //from diagonal
                val[i][j]=d;
            }
            else 
            {
                path[i][j]=false; //from horizontal
                if(v>=h) val[i][j]=v;
                else val[i][j]=h;
            }
        } //for i
    } //for j

    //trace back to extract the alignment
    i=len1;
    j=len2;
    while(i>0 && j>0)
    {
        if(path[i][j]) //from diagonal
        {
            j2i[j-1]=i-1;
            i--;
            j--;
        }
        else 
        {
            h=val[i-1][j];
            if(path[i-1][j]) h +=gap_open;

            v=val[i][j-1];
            if(path[i][j-1]) v +=gap_open;

            if(v>=h) j--;
            else i--;
        }
    }
}

/* +ss
 * Input: secondary structure secx, secy, and gap_open
 * Output: j2i[1:len2] \in {1:len1} U {-1}
 * path[0:len1, 0:len2]=1,2,3, from diagonal, horizontal, vertical */
void NWDP_TM(bool **path, double **val, const char *secx, const char *secy,
    const int len1, const int len2, const double gap_open, int j2i[])
{

    int i, j;
    double h, v, d;

    //initialization
    for(i=0; i<=len1; i++)
    {
        val[i][0]=0;
        //val[i][0]=i*gap_open;
        path[i][0]=false; //not from diagonal
    }

    for(j=0; j<=len2; j++)
    {
        val[0][j]=0;
        //val[0][j]=j*gap_open;
        path[0][j]=false; //not from diagonal
        j2i[j]=-1;    //all are not aligned, only use j2i[1:len2]
    }      

    //decide matrix and path
    for(i=1; i<=len1; i++)
    {
        for(j=1; j<=len2; j++)
        {
            d=val[i-1][j-1] + 1.0*(secx[i-1]==secy[j-1]);

            //symbol insertion in horizontal (= a gap in vertical)
            h=val[i-1][j];
            if(path[i-1][j]) h += gap_open; //aligned in last position

            //symbol insertion in vertical
            v=val[i][j-1];
            if(path[i][j-1]) v += gap_open; //aligned in last position

            if(d>=h && d>=v)
            {
                path[i][j]=true; //from diagonal
                val[i][j]=d;
            }
            else 
            {
                path[i][j]=false; //from horizontal
                if(v>=h) val[i][j]=v;
                else val[i][j]=h;
            }
        } //for i
    } //for j

    //trace back to extract the alignment
    i=len1;
    j=len2;
    while(i>0 && j>0)
    {
        if(path[i][j]) //from diagonal
        {
            j2i[j-1]=i-1;
            i--;
            j--;
        }
        else 
        {
            h=val[i-1][j];
            if(path[i-1][j]) h +=gap_open;

            v=val[i][j-1];
            if(path[i][j-1]) v +=gap_open;

            if(v>=h) j--;
            else i--;
        }
    }
}

void parameter_set4search(const int xlen, const int ylen,
    double &D0_MIN, double &Lnorm,
    double &score_d8, double &d0, double &d0_search, double &dcu0)
{
    //parameter initilization for searching: D0_MIN, Lnorm, d0, d0_search, score_d8
    D0_MIN=0.5; 
    dcu0=4.25;                       //update 3.85-->4.25
 
    Lnorm=getmin(xlen, ylen);        //normaliz TMscore by this in searching
    if (Lnorm<=19)                    //update 15-->19
        d0=0.168;                   //update 0.5-->0.168
    else d0=(1.24*pow((Lnorm*1.0-15), 1.0/3)-1.8);
    D0_MIN=d0+0.8;              //this should be moved to above
    d0=D0_MIN;                  //update: best for search    

    d0_search=d0;
    if (d0_search>8)   d0_search=8;
    if (d0_search<4.5) d0_search=4.5;

    score_d8=1.5*pow(Lnorm*1.0, 0.3)+3.5; //remove pairs with dis>d8 during search & final
}

void parameter_set4final_C3prime(const double len, double &D0_MIN,
    double &Lnorm, double &d0, double &d0_search)
{
    D0_MIN=0.3; 
 
    Lnorm=len;            //normaliz TMscore by this in searching
    if(Lnorm<=11) d0=0.3;
    else if(Lnorm>11&&Lnorm<=15) d0=0.4;
    else if(Lnorm>15&&Lnorm<=19) d0=0.5;
    else if(Lnorm>19&&Lnorm<=23) d0=0.6;
    else if(Lnorm>23&&Lnorm<30)  d0=0.7;
    else d0=(0.6*pow((Lnorm*1.0-0.5), 1.0/2)-2.5);

    d0_search=d0;
    if (d0_search>8)   d0_search=8;
    if (d0_search<4.5) d0_search=4.5;
}

void parameter_set4final(const double len, double &D0_MIN, double &Lnorm,
    double &d0, double &d0_search, const int mol_type)
{
    if (mol_type>0) // RNA
    {
        parameter_set4final_C3prime(len, D0_MIN, Lnorm,
            d0, d0_search);
        return;
    }
    D0_MIN=0.5; 
 
    Lnorm=len;            //normaliz TMscore by this in searching
    if (Lnorm<=21) d0=0.5;          
    else d0=(1.24*pow((Lnorm*1.0-15), 1.0/3)-1.8);
    if (d0<D0_MIN) d0=D0_MIN;   
    d0_search=d0;
    if (d0_search>8)   d0_search=8;
    if (d0_search<4.5) d0_search=4.5;
}

void parameter_set4scale(const int len, const double d_s, double &Lnorm,
    double &d0, double &d0_search)
{
    d0=d_s;          
    Lnorm=len;            //normaliz TMscore by this in searching
    d0_search=d0;
    if (d0_search>8)   d0_search=8;
    if (d0_search<4.5) d0_search=4.5;  
}

//     1, collect those residues with dis<d;
//     2, calculate TMscore
int score_fun8( double **xa, double **ya, int n_ali, double d, int i_ali[],
    double *score1, int score_sum_method, const double Lnorm, 
    const double score_d8, const double d0)
{
    double score_sum=0, di;
    double d_tmp=d*d;
    double d02=d0*d0;
    double score_d8_cut = score_d8*score_d8;
    
    int i, n_cut, inc=0;

    while(1)
    {
        n_cut=0;
        score_sum=0;
        for(i=0; i<n_ali; i++)
        {
            di = dist(xa[i], ya[i]);
            if(di<d_tmp)
            {
                i_ali[n_cut]=i;
                n_cut++;
            }
            if(score_sum_method==8)
            {                
                if(di<=score_d8_cut) score_sum += 1/(1+di/d02);
            }
            else score_sum += 1/(1+di/d02);
        }
        //there are not enough feasible pairs, reliefe the threshold         
        if(n_cut<3 && n_ali>3)
        {
            inc++;
            double dinc=(d+inc*0.5);
            d_tmp = dinc * dinc;
        }
        else break;
    }  

    *score1=score_sum/Lnorm;
    return n_cut;
}

int score_fun8_standard(double **xa, double **ya, int n_ali, double d,
    int i_ali[], double *score1, int score_sum_method,
    double score_d8, double d0)
{
    double score_sum = 0, di;
    double d_tmp = d*d;
    double d02 = d0*d0;
    double score_d8_cut = score_d8*score_d8;

    int i, n_cut, inc = 0;
    while (1)
    {
        n_cut = 0;
        score_sum = 0;
        for (i = 0; i<n_ali; i++)
        {
            di = dist(xa[i], ya[i]);
            if (di<d_tmp)
            {
                i_ali[n_cut] = i;
                n_cut++;
            }
            if (score_sum_method == 8)
            {
                if (di <= score_d8_cut) score_sum += 1 / (1 + di / d02);
            }
            else
            {
                score_sum += 1 / (1 + di / d02);
            }
        }
        //there are not enough feasible pairs, reliefe the threshold         
        if (n_cut<3 && n_ali>3)
        {
            inc++;
            double dinc = (d + inc*0.5);
            d_tmp = dinc * dinc;
        }
        else break;
    }

    *score1 = score_sum / n_ali;
    return n_cut;
}

double TMscore8_search(double **r1, double **r2, double **xtm, double **ytm,
    double **xt, int Lali, double t0[3], double u0[3][3], int simplify_step,
    int score_sum_method, double *Rcomm, double local_d0_search, double Lnorm,
    double score_d8, double d0)
{
    int i, m;
    double score_max, score, rmsd;    
    const int kmax=Lali;    
    int k_ali[kmax], ka, k;
    double t[3];
    double u[3][3];
    double d;
    

    //iterative parameters
    int n_it=20;            //maximum number of iterations
    int n_init_max=6; //maximum number of different fragment length 
    int L_ini[n_init_max];  //fragment lengths, Lali, Lali/2, Lali/4 ... 4   
    int L_ini_min=4;
    if(Lali<L_ini_min) L_ini_min=Lali;   

    int n_init=0, i_init;      
    for(i=0; i<n_init_max-1; i++)
    {
        n_init++;
        L_ini[i]=(int) (Lali/pow(2.0, (double) i));
        if(L_ini[i]<=L_ini_min)
        {
            L_ini[i]=L_ini_min;
            break;
        }
    }
    if(i==n_init_max-1)
    {
        n_init++;
        L_ini[i]=L_ini_min;
    }
    
    score_max=-1;
    //find the maximum score starting from local structures superposition
    int i_ali[kmax], n_cut;
    int L_frag; //fragment length
    int iL_max; //maximum starting postion for the fragment
    
    for(i_init=0; i_init<n_init; i_init++)
    {
        L_frag=L_ini[i_init];
        iL_max=Lali-L_frag;
      
        i=0;   
        while(1)
        {
            //extract the fragment starting from position i 
            ka=0;
            for(k=0; k<L_frag; k++)
            {
                int kk=k+i;
                r1[k][0]=xtm[kk][0];  
                r1[k][1]=xtm[kk][1]; 
                r1[k][2]=xtm[kk][2];   
                
                r2[k][0]=ytm[kk][0];  
                r2[k][1]=ytm[kk][1]; 
                r2[k][2]=ytm[kk][2];
                
                k_ali[ka]=kk;
                ka++;
            }
            
            //extract rotation matrix based on the fragment
            Kabsch(r1, r2, L_frag, 1, &rmsd, t, u);
            if (simplify_step != 1)
                *Rcomm = 0;
            do_rotation(xtm, xt, Lali, t, u);
            
            //get subsegment of this fragment
            d = local_d0_search - 1;
            n_cut=score_fun8(xt, ytm, Lali, d, i_ali, &score, 
                score_sum_method, Lnorm, score_d8, d0);
            if(score>score_max)
            {
                score_max=score;
                
                //save the rotation matrix
                for(k=0; k<3; k++)
                {
                    t0[k]=t[k];
                    u0[k][0]=u[k][0];
                    u0[k][1]=u[k][1];
                    u0[k][2]=u[k][2];
                }
            }
            
            //try to extend the alignment iteratively            
            d = local_d0_search + 1;
            for(int it=0; it<n_it; it++)            
            {
                ka=0;
                for(k=0; k<n_cut; k++)
                {
                    m=i_ali[k];
                    r1[k][0]=xtm[m][0];  
                    r1[k][1]=xtm[m][1]; 
                    r1[k][2]=xtm[m][2];
                    
                    r2[k][0]=ytm[m][0];  
                    r2[k][1]=ytm[m][1]; 
                    r2[k][2]=ytm[m][2];
                    
                    k_ali[ka]=m;
                    ka++;
                } 
                //extract rotation matrix based on the fragment                
                Kabsch(r1, r2, n_cut, 1, &rmsd, t, u);
                do_rotation(xtm, xt, Lali, t, u);
                n_cut=score_fun8(xt, ytm, Lali, d, i_ali, &score, 
                    score_sum_method, Lnorm, score_d8, d0);
                if(score>score_max)
                {
                    score_max=score;

                    //save the rotation matrix
                    for(k=0; k<3; k++)
                    {
                        t0[k]=t[k];
                        u0[k][0]=u[k][0];
                        u0[k][1]=u[k][1];
                        u0[k][2]=u[k][2];
                    }                     
                }
                
                //check if it converges            
                if(n_cut==ka)
                {                
                    for(k=0; k<n_cut; k++)
                    {
                        if(i_ali[k]!=k_ali[k]) break;
                    }
                    if(k==n_cut) break;
                }                                                               
            } //for iteration            

            if(i<iL_max)
            {
                i=i+simplify_step; //shift the fragment        
                if(i>iL_max) i=iL_max;  //do this to use the last missed fragment
            }
            else if(i>=iL_max) break;
        }//while(1)
        //end of one fragment
    }//for(i_init
    return score_max;
}


double TMscore8_search_standard( double **r1, double **r2,
    double **xtm, double **ytm, double **xt, int Lali,
    double t0[3], double u0[3][3], int simplify_step, int score_sum_method,
    double *Rcomm, double local_d0_search, double score_d8, double d0)
{
    int i, m;
    double score_max, score, rmsd;
    const int kmax = Lali;
    int k_ali[kmax], ka, k;
    double t[3];
    double u[3][3];
    double d;

    //iterative parameters
    int n_it = 20;            //maximum number of iterations
    int n_init_max = 6; //maximum number of different fragment length 
    int L_ini[n_init_max];  //fragment lengths, Lali, Lali/2, Lali/4 ... 4   
    int L_ini_min = 4;
    if (Lali<L_ini_min) L_ini_min = Lali;

    int n_init = 0, i_init;
    for (i = 0; i<n_init_max - 1; i++)
    {
        n_init++;
        L_ini[i] = (int)(Lali / pow(2.0, (double)i));
        if (L_ini[i] <= L_ini_min)
        {
            L_ini[i] = L_ini_min;
            break;
        }
    }
    if (i == n_init_max - 1)
    {
        n_init++;
        L_ini[i] = L_ini_min;
    }

    score_max = -1;
    //find the maximum score starting from local structures superposition
    int i_ali[kmax], n_cut;
    int L_frag; //fragment length
    int iL_max; //maximum starting postion for the fragment

    for (i_init = 0; i_init<n_init; i_init++)
    {
        L_frag = L_ini[i_init];
        iL_max = Lali - L_frag;

        i = 0;
        while (1)
        {
            //extract the fragment starting from position i 
            ka = 0;
            for (k = 0; k<L_frag; k++)
            {
                int kk = k + i;
                r1[k][0] = xtm[kk][0];
                r1[k][1] = xtm[kk][1];
                r1[k][2] = xtm[kk][2];

                r2[k][0] = ytm[kk][0];
                r2[k][1] = ytm[kk][1];
                r2[k][2] = ytm[kk][2];

                k_ali[ka] = kk;
                ka++;
            }
            //extract rotation matrix based on the fragment
            Kabsch(r1, r2, L_frag, 1, &rmsd, t, u);
            if (simplify_step != 1)
                *Rcomm = 0;
            do_rotation(xtm, xt, Lali, t, u);

            //get subsegment of this fragment
            d = local_d0_search - 1;
            n_cut = score_fun8_standard(xt, ytm, Lali, d, i_ali, &score,
                score_sum_method, score_d8, d0);

            if (score>score_max)
            {
                score_max = score;

                //save the rotation matrix
                for (k = 0; k<3; k++)
                {
                    t0[k] = t[k];
                    u0[k][0] = u[k][0];
                    u0[k][1] = u[k][1];
                    u0[k][2] = u[k][2];
                }
            }

            //try to extend the alignment iteratively            
            d = local_d0_search + 1;
            for (int it = 0; it<n_it; it++)
            {
                ka = 0;
                for (k = 0; k<n_cut; k++)
                {
                    m = i_ali[k];
                    r1[k][0] = xtm[m][0];
                    r1[k][1] = xtm[m][1];
                    r1[k][2] = xtm[m][2];

                    r2[k][0] = ytm[m][0];
                    r2[k][1] = ytm[m][1];
                    r2[k][2] = ytm[m][2];

                    k_ali[ka] = m;
                    ka++;
                }
                //extract rotation matrix based on the fragment                
                Kabsch(r1, r2, n_cut, 1, &rmsd, t, u);
                do_rotation(xtm, xt, Lali, t, u);
                n_cut = score_fun8_standard(xt, ytm, Lali, d, i_ali, &score,
                    score_sum_method, score_d8, d0);
                if (score>score_max)
                {
                    score_max = score;

                    //save the rotation matrix
                    for (k = 0; k<3; k++)
                    {
                        t0[k] = t[k];
                        u0[k][0] = u[k][0];
                        u0[k][1] = u[k][1];
                        u0[k][2] = u[k][2];
                    }
                }

                //check if it converges            
                if (n_cut == ka)
                {
                    for (k = 0; k<n_cut; k++)
                    {
                        if (i_ali[k] != k_ali[k]) break;
                    }
                    if (k == n_cut) break;
                }
            } //for iteration            

            if (i<iL_max)
            {
                i = i + simplify_step; //shift the fragment        
                if (i>iL_max) i = iL_max;  //do this to use the last missed fragment
            }
            else if (i >= iL_max) break;
        }//while(1)
        //end of one fragment
    }//for(i_init
    return score_max;
}

//Comprehensive TMscore search engine
// input:   two vector sets: x, y
//          an alignment invmap0[] between x and y
//          simplify_step: 1 or 40 or other integers
//          score_sum_method: 0 for score over all pairs
//                            8 for socre over the pairs with dist<score_d8
// output:  the best rotaion matrix t, u that results in highest TMscore
double detailed_search(double **r1, double **r2, double **xtm, double **ytm,
    double **xt, double **x, double **y, int xlen, int ylen, 
    int invmap0[], double t[3], double u[3][3], int simplify_step,
    int score_sum_method, double local_d0_search, double Lnorm,
    double score_d8, double d0)
{
    //x is model, y is template, try to superpose onto y
    int i, j, k;     
    double tmscore;
    double rmsd;

    k=0;
    for(i=0; i<ylen; i++) 
    {
        j=invmap0[i];
        if(j>=0) //aligned
        {
            xtm[k][0]=x[j][0];
            xtm[k][1]=x[j][1];
            xtm[k][2]=x[j][2];
                
            ytm[k][0]=y[i][0];
            ytm[k][1]=y[i][1];
            ytm[k][2]=y[i][2];
            k++;
        }
    }

    //detailed search 40-->1
    tmscore = TMscore8_search(r1, r2, xtm, ytm, xt, k, t, u, simplify_step,
        score_sum_method, &rmsd, local_d0_search, Lnorm, score_d8, d0);
    return tmscore;
}

double detailed_search_standard( double **r1, double **r2,
    double **xtm, double **ytm, double **xt, double **x, double **y,
    int xlen, int ylen, int invmap0[], double t[3], double u[3][3],
    int simplify_step, int score_sum_method, double local_d0_search,
    const bool& bNormalize, double Lnorm, double score_d8, double d0)
{
    //x is model, y is template, try to superpose onto y
    int i, j, k;     
    double tmscore;
    double rmsd;

    k=0;
    for(i=0; i<ylen; i++) 
    {
        j=invmap0[i];
        if(j>=0) //aligned
        {
            xtm[k][0]=x[j][0];
            xtm[k][1]=x[j][1];
            xtm[k][2]=x[j][2];
                
            ytm[k][0]=y[i][0];
            ytm[k][1]=y[i][1];
            ytm[k][2]=y[i][2];
            k++;
        }
    }

    //detailed search 40-->1
    tmscore = TMscore8_search_standard( r1, r2, xtm, ytm, xt, k, t, u,
        simplify_step, score_sum_method, &rmsd, local_d0_search, score_d8, d0);
    if (bNormalize)// "-i", to use standard_TMscore, then bNormalize=true, else bNormalize=false; 
        tmscore = tmscore * k / Lnorm;

    return tmscore;
}

//compute the score quickly in three iterations
double get_score_fast( double **r1, double **r2, double **xtm, double **ytm,
    double **x, double **y, int xlen, int ylen, int invmap[],
    double d0, double d0_search, double t[3], double u[3][3])
{
    double rms, tmscore, tmscore1, tmscore2;
    int i, j, k;

    k=0;
    for(j=0; j<ylen; j++)
    {
        i=invmap[j];
        if(i>=0)
        {
            r1[k][0]=x[i][0];
            r1[k][1]=x[i][1];
            r1[k][2]=x[i][2];

            r2[k][0]=y[j][0];
            r2[k][1]=y[j][1];
            r2[k][2]=y[j][2];
            
            xtm[k][0]=x[i][0];
            xtm[k][1]=x[i][1];
            xtm[k][2]=x[i][2];
            
            ytm[k][0]=y[j][0];
            ytm[k][1]=y[j][1];
            ytm[k][2]=y[j][2];                  
            
            k++;
        }
        else if(i!=-1) PrintErrorAndQuit("Wrong map!\n");
    }
    Kabsch(r1, r2, k, 1, &rms, t, u);
    
    //evaluate score   
    double di;
    const int len=k;
    double dis[len];    
    double d00=d0_search;
    double d002=d00*d00;
    double d02=d0*d0;
    
    int n_ali=k;
    double xrot[3];
    tmscore=0;
    for(k=0; k<n_ali; k++)
    {
        transform(t, u, &xtm[k][0], xrot);        
        di=dist(xrot, &ytm[k][0]);
        dis[k]=di;
        tmscore += 1/(1+di/d02);
    }
    
   
   
   //second iteration 
    double d002t=d002;
    while(1)
    {
        j=0;
        for(k=0; k<n_ali; k++)
        {            
            if(dis[k]<=d002t)
            {
                r1[j][0]=xtm[k][0];
                r1[j][1]=xtm[k][1];
                r1[j][2]=xtm[k][2];
                
                r2[j][0]=ytm[k][0];
                r2[j][1]=ytm[k][1];
                r2[j][2]=ytm[k][2];
                
                j++;
            }
        }
        //there are not enough feasible pairs, relieve the threshold 
        if(j<3 && n_ali>3) d002t += 0.5;
        else break;
    }
    
    if(n_ali!=j)
    {
        Kabsch(r1, r2, j, 1, &rms, t, u);
        tmscore1=0;
        for(k=0; k<n_ali; k++)
        {
            transform(t, u, &xtm[k][0], xrot);        
            di=dist(xrot, &ytm[k][0]);
            dis[k]=di;
            tmscore1 += 1/(1+di/d02);
        }
        
        //third iteration
        d002t=d002+1;
       
        while(1)
        {
            j=0;
            for(k=0; k<n_ali; k++)
            {            
                if(dis[k]<=d002t)
                {
                    r1[j][0]=xtm[k][0];
                    r1[j][1]=xtm[k][1];
                    r1[j][2]=xtm[k][2];
                    
                    r2[j][0]=ytm[k][0];
                    r2[j][1]=ytm[k][1];
                    r2[j][2]=ytm[k][2];
                                        
                    j++;
                }
            }
            //there are not enough feasible pairs, relieve the threshold 
            if(j<3 && n_ali>3) d002t += 0.5;
            else break;
        }

        //evaluate the score
        Kabsch(r1, r2, j, 1, &rms, t, u);
        tmscore2=0;
        for(k=0; k<n_ali; k++)
        {
            transform(t, u, &xtm[k][0], xrot);
            di=dist(xrot, &ytm[k][0]);
            tmscore2 += 1/(1+di/d02);
        }    
    }
    else
    {
        tmscore1=tmscore;
        tmscore2=tmscore;
    }
    
    if(tmscore1>=tmscore) tmscore=tmscore1;
    if(tmscore2>=tmscore) tmscore=tmscore2;
    return tmscore; // no need to normalize this score because it will not be used for latter scoring
}


//perform gapless threading to find the best initial alignment
//input: x, y, xlen, ylen
//output: y2x0 stores the best alignment: e.g., 
//y2x0[j]=i means:
//the jth element in y is aligned to the ith element in x if i>=0 
//the jth element in y is aligned to a gap in x if i==-1
double get_initial(double **r1, double **r2, double **xtm, double **ytm,
    double **x, double **y, int xlen, int ylen, int *y2x,
    double d0, double d0_search, const bool fast_opt,
    double t[3], double u[3][3])
{
    int min_len=getmin(xlen, ylen);
    if(min_len<3) PrintErrorAndQuit("Sequence is too short <3!\n");
    
    int min_ali= min_len/2;              //minimum size of considered fragment 
    if(min_ali<=5)  min_ali=5;    
    int n1, n2;
    n1 = -ylen+min_ali; 
    n2 = xlen-min_ali;

    int i, j, k, k_best;
    double tmscore, tmscore_max=-1;

    k_best=n1;
    for(k=n1; k<=n2; k+=(fast_opt)?5:1)
    {
        //get the map
        for(j=0; j<ylen; j++)
        {
            i=j+k;
            if(i>=0 && i<xlen) y2x[j]=i;
            else y2x[j]=-1;
        }
        
        //evaluate the map quickly in three iterations
        //this is not real tmscore, it is used to evaluate the goodness of the initial alignment
        tmscore=get_score_fast(r1, r2, xtm, ytm,
            x, y, xlen, ylen, y2x, d0,d0_search, t, u);
        if(tmscore>=tmscore_max)
        {
            tmscore_max=tmscore;
            k_best=k;
        }
    }
    
    //extract the best map
    k=k_best;
    for(j=0; j<ylen; j++)
    {
        i=j+k;
        if(i>=0 && i<xlen) y2x[j]=i;
        else y2x[j]=-1;
    }    

    return tmscore_max;
}

void smooth(int *sec, int len)
{
    int i, j;
    //smooth single  --x-- => -----
    for (i=2; i<len-2; i++)
    {
        if(sec[i]==2 || sec[i]==4)
        {
            j=sec[i];
            if (sec[i-2]!=j && sec[i-1]!=j && sec[i+1]!=j && sec[i+2]!=j)
                sec[i]=1;
        }
    }

    //   smooth double 
    //   --xx-- => ------
    for (i=0; i<len-5; i++)
    {
        //helix
        if (sec[i]!=2   && sec[i+1]!=2 && sec[i+2]==2 && sec[i+3]==2 &&
            sec[i+4]!=2 && sec[i+5]!= 2)
        {
            sec[i+2]=1;
            sec[i+3]=1;
        }

        //beta
        if (sec[i]!=4   && sec[i+1]!=4 && sec[i+2]==4 && sec[i+3]==4 &&
            sec[i+4]!=4 && sec[i+5]!= 4)
        {
            sec[i+2]=1;
            sec[i+3]=1;
        }
    }

    //smooth connect
    for (i=0; i<len-2; i++)
    {        
        if (sec[i]==2 && sec[i+1]!=2 && sec[i+2]==2) sec[i+1]=2;
        else if(sec[i]==4 && sec[i+1]!=4 && sec[i+2]==4) sec[i+1]=4;
    }

}

char sec_str(double dis13, double dis14, double dis15,
            double dis24, double dis25, double dis35)
{
    char s='C';
    
    double delta=2.1;
    if (fabs(dis15-6.37)<delta && fabs(dis14-5.18)<delta && 
        fabs(dis25-5.18)<delta && fabs(dis13-5.45)<delta &&
        fabs(dis24-5.45)<delta && fabs(dis35-5.45)<delta)
    {
        s='H'; //helix                        
        return s;
    }

    delta=1.42;
    if (fabs(dis15-13  )<delta && fabs(dis14-10.4)<delta &&
        fabs(dis25-10.4)<delta && fabs(dis13-6.1 )<delta &&
        fabs(dis24-6.1 )<delta && fabs(dis35-6.1 )<delta)
    {
        s='E'; //strand
        return s;
    }

    if (dis15 < 8) s='T'; //turn
    return s;
}


/* secondary stucture assignment for protein:
 * 1->coil, 2->helix, 3->turn, 4->strand */
void make_sec(double **x, int len, char *sec)
{
    int j1, j2, j3, j4, j5;
    double d13, d14, d15, d24, d25, d35;
    for(int i=0; i<len; i++)
    {     
        sec[i]='C';
        j1=i-2;
        j2=i-1;
        j3=i;
        j4=i+1;
        j5=i+2;        
        
        if(j1>=0 && j5<len)
        {
            d13=sqrt(dist(x[j1], x[j3]));
            d14=sqrt(dist(x[j1], x[j4]));
            d15=sqrt(dist(x[j1], x[j5]));
            d24=sqrt(dist(x[j2], x[j4]));
            d25=sqrt(dist(x[j2], x[j5]));
            d35=sqrt(dist(x[j3], x[j5]));
            sec[i]=sec_str(d13, d14, d15, d24, d25, d35);            
        }    
    } 
    sec[len]=0;
}

//get initial alignment from secondary structure alignment
//input: x, y, xlen, ylen
//output: y2x stores the best alignment: e.g., 
//y2x[j]=i means:
//the jth element in y is aligned to the ith element in x if i>=0 
//the jth element in y is aligned to a gap in x if i==-1
void get_initial_ss(bool **path, double **val,
    const char *secx, const char *secy, int xlen, int ylen, int *y2x)
{
    double gap_open=-1.0;
    NWDP_TM(path, val, secx, secy, xlen, ylen, gap_open, y2x);
}


// get_initial5 in TMalign fortran, get_initial_local in TMalign c by yangji
//get initial alignment of local structure superposition
//input: x, y, xlen, ylen
//output: y2x stores the best alignment: e.g., 
//y2x[j]=i means:
//the jth element in y is aligned to the ith element in x if i>=0 
//the jth element in y is aligned to a gap in x if i==-1
bool get_initial5( double **r1, double **r2, double **xtm, double **ytm,
    bool **path, double **val,
    double **x, double **y, int xlen, int ylen, int *y2x,
    double d0, double d0_search, const bool fast_opt, const double D0_MIN)
{
    double GL, rmsd;
    double t[3];
    double u[3][3];

    double d01 = d0 + 1.5;
    if (d01 < D0_MIN) d01 = D0_MIN;
    double d02 = d01*d01;

    double GLmax = 0;
    int aL = getmin(xlen, ylen);
    int *invmap = new int[ylen + 1];

    // jump on sequence1-------------->
    int n_jump1 = 0;
    if (xlen > 250)
        n_jump1 = 45;
    else if (xlen > 200)
        n_jump1 = 35;
    else if (xlen > 150)
        n_jump1 = 25;
    else
        n_jump1 = 15;
    if (n_jump1 > (xlen / 3))
        n_jump1 = xlen / 3;

    // jump on sequence2-------------->
    int n_jump2 = 0;
    if (ylen > 250)
        n_jump2 = 45;
    else if (ylen > 200)
        n_jump2 = 35;
    else if (ylen > 150)
        n_jump2 = 25;
    else
        n_jump2 = 15;
    if (n_jump2 > (ylen / 3))
        n_jump2 = ylen / 3;

    // fragment to superimpose-------------->
    int n_frag[2] = { 20, 100 };
    if (n_frag[0] > (aL / 3))
        n_frag[0] = aL / 3;
    if (n_frag[1] > (aL / 2))
        n_frag[1] = aL / 2;

    // start superimpose search-------------->
    if (fast_opt)
    {
        n_jump1*=5;
        n_jump2*=5;
    }
    bool flag = false;
    for (int i_frag = 0; i_frag < 2; i_frag++)
    {
        int m1 = xlen - n_frag[i_frag] + 1;
        int m2 = ylen - n_frag[i_frag] + 1;

        for (int i = 0; i<m1; i = i + n_jump1) //index starts from 0, different from FORTRAN
        {
            for (int j = 0; j<m2; j = j + n_jump2)
            {
                for (int k = 0; k<n_frag[i_frag]; k++) //fragment in y
                {
                    r1[k][0] = x[k + i][0];
                    r1[k][1] = x[k + i][1];
                    r1[k][2] = x[k + i][2];

                    r2[k][0] = y[k + j][0];
                    r2[k][1] = y[k + j][1];
                    r2[k][2] = y[k + j][2];
                }

                // superpose the two structures and rotate it
                Kabsch(r1, r2, n_frag[i_frag], 1, &rmsd, t, u);

                double gap_open = 0.0;
                NWDP_TM(path, val, x, y, xlen, ylen,
                    t, u, d02, gap_open, invmap);
                GL = get_score_fast(r1, r2, xtm, ytm, x, y, xlen, ylen,
                    invmap, d0, d0_search, t, u);
                if (GL>GLmax)
                {
                    GLmax = GL;
                    for (int ii = 0; ii<ylen; ii++) y2x[ii] = invmap[ii];
                    flag = true;
                }
            }
        }
    }

    delete[] invmap;
    return flag;
}

void score_matrix_rmsd_sec( double **r1, double **r2, double **score,
    const char *secx, const char *secy, double **x, double **y,
    int xlen, int ylen, int *y2x, const double D0_MIN, double d0)
{
    double t[3], u[3][3];
    double rmsd, dij;
    double d01=d0+1.5;
    if(d01 < D0_MIN) d01=D0_MIN;
    double d02=d01*d01;

    double xx[3];
    int i, k=0;
    for(int j=0; j<ylen; j++)
    {
        i=y2x[j];
        if(i>=0)
        {
            r1[k][0]=x[i][0];  
            r1[k][1]=x[i][1]; 
            r1[k][2]=x[i][2];   
            
            r2[k][0]=y[j][0];  
            r2[k][1]=y[j][1]; 
            r2[k][2]=y[j][2];
            
            k++;
        }
    }
    Kabsch(r1, r2, k, 1, &rmsd, t, u);

    
    for(int ii=0; ii<xlen; ii++)
    {        
        transform(t, u, &x[ii][0], xx);
        for(int jj=0; jj<ylen; jj++)
        {
            dij=dist(xx, &y[jj][0]); 
            if (secx[ii]==secy[jj])
                score[ii+1][jj+1] = 1.0/(1+dij/d02) + 0.5;
            else
                score[ii+1][jj+1] = 1.0/(1+dij/d02);
        }
    }
}


//get initial alignment from secondary structure and previous alignments
//input: x, y, xlen, ylen
//output: y2x stores the best alignment: e.g., 
//y2x[j]=i means:
//the jth element in y is aligned to the ith element in x if i>=0 
//the jth element in y is aligned to a gap in x if i==-1
void get_initial_ssplus(double **r1, double **r2, double **score, bool **path,
    double **val, const char *secx, const char *secy, double **x, double **y,
    int xlen, int ylen, int *y2x0, int *y2x, const double D0_MIN, double d0)
{
    //create score matrix for DP
    score_matrix_rmsd_sec(r1, r2, score, secx, secy, x, y, xlen, ylen,
        y2x0, D0_MIN,d0);
    
    double gap_open=-1.0;
    NWDP_TM(score, path, val, xlen, ylen, gap_open, y2x);
}


void find_max_frag(double **x, int len, int *start_max,
    int *end_max, double dcu0, const bool fast_opt)
{
    int r_min, fra_min=4;           //minimum fragment for search
    if (fast_opt) fra_min=8;
    int start;
    int Lfr_max=0;

    r_min= (int) (len*1.0/3.0); //minimum fragment, in case too small protein
    if(r_min > fra_min) r_min=fra_min;
    
    int inc=0;
    double dcu0_cut=dcu0*dcu0;;
    double dcu_cut=dcu0_cut;

    while(Lfr_max < r_min)
    {        
        Lfr_max=0;            
        int j=1;    //number of residues at nf-fragment
        start=0;
        for(int i=1; i<len; i++)
        {
            if(dist(x[i-1], x[i]) < dcu_cut)
            {
                j++;

                if(i==(len-1))
                {
                    if(j > Lfr_max) 
                    {
                        Lfr_max=j;
                        *start_max=start;
                        *end_max=i;                        
                    }
                    j=1;
                }
            }
            else
            {
                if(j>Lfr_max) 
                {
                    Lfr_max=j;
                    *start_max=start;
                    *end_max=i-1;                                        
                }

                j=1;
                start=i;
            }
        }// for i;
        
        if(Lfr_max < r_min)
        {
            inc++;
            double dinc=pow(1.1, (double) inc) * dcu0;
            dcu_cut= dinc*dinc;
        }
    }//while <;    
}

//perform fragment gapless threading to find the best initial alignment
//input: x, y, xlen, ylen
//output: y2x0 stores the best alignment: e.g., 
//y2x0[j]=i means:
//the jth element in y is aligned to the ith element in x if i>=0 
//the jth element in y is aligned to a gap in x if i==-1
double get_initial_fgt(double **r1, double **r2, double **xtm, double **ytm,
    double **x, double **y, int xlen, int ylen, 
    int *y2x, double d0, double d0_search,
    double dcu0, const bool fast_opt, double t[3], double u[3][3])
{
    int fra_min=4;           //minimum fragment for search
    if (fast_opt) fra_min=8;
    int fra_min1=fra_min-1;  //cutoff for shift, save time

    int xstart=0, ystart=0, xend=0, yend=0;

    find_max_frag(x, xlen, &xstart, &xend, dcu0, fast_opt);
    find_max_frag(y, ylen, &ystart, &yend, dcu0, fast_opt);


    int Lx = xend-xstart+1;
    int Ly = yend-ystart+1;
    int *ifr, *y2x_;
    int L_fr=getmin(Lx, Ly);
    ifr= new int[L_fr];
    y2x_= new int[ylen+1];

    //select what piece will be used. The original implement may cause 
    //asymetry, but only when xlen==ylen and Lx==Ly
    //if L1=Lfr1 and L2=Lfr2 (normal proteins), it will be the same as initial1

    if(Lx<Ly || (Lx==Ly && xlen<ylen))
    {        
        for(int i=0; i<L_fr; i++) ifr[i]=xstart+i;
    }
    else if(Lx>Ly || (Lx==Ly && xlen>ylen))
    {        
        for(int i=0; i<L_fr; i++) ifr[i]=ystart+i;
    }
    else // solve asymetric for 1x5gA vs 2q7nA5
    {
        /* In this case, L0==xlen==ylen; L_fr==Lx==Ly */
        int L0=xlen;
        double tmscore, tmscore_max=-1;
        int i, j, k;
        int n1, n2;
        int min_len;
        int min_ali;

        /* part 1, normalized by xlen */
        for(i=0; i<L_fr; i++) ifr[i]=xstart+i;

        if(L_fr==L0)
        {
            n1= (int)(L0*0.1); //my index starts from 0
            n2= (int)(L0*0.89);
            j=0;
            for(i=n1; i<= n2; i++)
            {
                ifr[j]=ifr[i];
                j++;
            }
            L_fr=j;
        }

        int L1=L_fr;
        min_len=getmin(L1, ylen);    
        min_ali= (int) (min_len/2.5); //minimum size of considered fragment 
        if(min_ali<=fra_min1)  min_ali=fra_min1;    
        n1 = -ylen+min_ali; 
        n2 = L1-min_ali;

        for(k=n1; k<=n2; k+=(fast_opt)?3:1)
        {
            //get the map
            for(j=0; j<ylen; j++)
            {
                i=j+k;
                if(i>=0 && i<L1) y2x_[j]=ifr[i];
                else             y2x_[j]=-1;
            }

            //evaluate the map quickly in three iterations
            tmscore=get_score_fast(r1, r2, xtm, ytm, x, y, xlen, ylen, y2x_,
                d0, d0_search, t, u);

            if(tmscore>=tmscore_max)
            {
                tmscore_max=tmscore;
                for(j=0; j<ylen; j++) y2x[j]=y2x_[j];
            }
        }

        /* part 2, normalized by ylen */
        L_fr=Ly;
        for(i=0; i<L_fr; i++) ifr[i]=ystart+i;

        if (L_fr==L0)
        {
            n1= (int)(L0*0.1); //my index starts from 0
            n2= (int)(L0*0.89);

            j=0;
            for(i=n1; i<= n2; i++)
            {
                ifr[j]=ifr[i];
                j++;
            }
            L_fr=j;
        }

        int L2=L_fr;
        min_len=getmin(xlen, L2);    
        min_ali= (int) (min_len/2.5); //minimum size of considered fragment 
        if(min_ali<=fra_min1)  min_ali=fra_min1;    
        n1 = -L2+min_ali; 
        n2 = xlen-min_ali;

        for(k=n1; k<=n2; k++)
        {
            //get the map
            for(j=0; j<ylen; j++) y2x_[j]=-1;

            for(j=0; j<L2; j++)
            {
                i=j+k;
                if(i>=0 && i<xlen) y2x_[ifr[j]]=i;
            }
        
            //evaluate the map quickly in three iterations
            tmscore=get_score_fast(r1, r2, xtm, ytm,
                x, y, xlen, ylen, y2x_, d0,d0_search, t, u);
            if(tmscore>=tmscore_max)
            {
                tmscore_max=tmscore;
                for(j=0; j<ylen; j++) y2x[j]=y2x_[j];
            }
        }

        delete [] ifr;
        delete [] y2x_;
        return tmscore_max;
    }

    
    int L0=getmin(xlen, ylen); //non-redundant to get_initial1
    if(L_fr==L0)
    {
        int n1= (int)(L0*0.1); //my index starts from 0
        int n2= (int)(L0*0.89);

        int j=0;
        for(int i=n1; i<= n2; i++)
        {
            ifr[j]=ifr[i];
            j++;
        }
        L_fr=j;
    }


    //gapless threading for the extracted fragment
    double tmscore, tmscore_max=-1;

    if(Lx<Ly || (Lx==Ly && xlen<=ylen))
    {
        int L1=L_fr;
        int min_len=getmin(L1, ylen);    
        int min_ali= (int) (min_len/2.5);              //minimum size of considered fragment 
        if(min_ali<=fra_min1)  min_ali=fra_min1;    
        int n1, n2;
        n1 = -ylen+min_ali; 
        n2 = L1-min_ali;

        int i, j, k;
        for(k=n1; k<=n2; k+=(fast_opt)?3:1)
        {
            //get the map
            for(j=0; j<ylen; j++)
            {
                i=j+k;
                if(i>=0 && i<L1) y2x_[j]=ifr[i];
                else             y2x_[j]=-1;
            }

            //evaluate the map quickly in three iterations
            tmscore=get_score_fast(r1, r2, xtm, ytm, x, y, xlen, ylen, y2x_,
                d0, d0_search, t, u);

            if(tmscore>=tmscore_max)
            {
                tmscore_max=tmscore;
                for(j=0; j<ylen; j++) y2x[j]=y2x_[j];
            }
        }
    }
    else
    {
        int L2=L_fr;
        int min_len=getmin(xlen, L2);    
        int min_ali= (int) (min_len/2.5);              //minimum size of considered fragment 
        if(min_ali<=fra_min1)  min_ali=fra_min1;    
        int n1, n2;
        n1 = -L2+min_ali; 
        n2 = xlen-min_ali;

        int i, j, k;    

        for(k=n1; k<=n2; k++)
        {
            //get the map
            for(j=0; j<ylen; j++) y2x_[j]=-1;

            for(j=0; j<L2; j++)
            {
                i=j+k;
                if(i>=0 && i<xlen) y2x_[ifr[j]]=i;
            }
        
            //evaluate the map quickly in three iterations
            tmscore=get_score_fast(r1, r2, xtm, ytm,
                x, y, xlen, ylen, y2x_, d0,d0_search, t, u);
            if(tmscore>=tmscore_max)
            {
                tmscore_max=tmscore;
                for(j=0; j<ylen; j++) y2x[j]=y2x_[j];
            }
        }
    }    


    delete [] ifr;
    delete [] y2x_;
    return tmscore_max;
}

//heuristic run of dynamic programing iteratively to find the best alignment
//input: initial rotation matrix t, u
//       vectors x and y, d0
//output: best alignment that maximizes the TMscore, will be stored in invmap
double DP_iter(double **r1, double **r2, double **xtm, double **ytm,
    double **xt, bool **path, double **val, double **x, double **y,
    int xlen, int ylen, double t[3], double u[3][3], int invmap0[],
    int g1, int g2, int iteration_max, double local_d0_search,
    double D0_MIN, double Lnorm, double d0, double score_d8)
{
    double gap_open[2]={-0.6, 0};
    double rmsd; 
    int *invmap=new int[ylen+1];
    
    int iteration, i, j, k;
    double tmscore, tmscore_max, tmscore_old=0;    
    int score_sum_method=8, simplify_step=40;
    tmscore_max=-1;

    //double d01=d0+1.5;
    double d02=d0*d0;
    for(int g=g1; g<g2; g++)
    {
        for(iteration=0; iteration<iteration_max; iteration++)
        {           
            NWDP_TM(path, val, x, y, xlen, ylen,
                t, u, d02, gap_open[g], invmap);
            
            k=0;
            for(j=0; j<ylen; j++) 
            {
                i=invmap[j];

                if(i>=0) //aligned
                {
                    xtm[k][0]=x[i][0];
                    xtm[k][1]=x[i][1];
                    xtm[k][2]=x[i][2];
                    
                    ytm[k][0]=y[j][0];
                    ytm[k][1]=y[j][1];
                    ytm[k][2]=y[j][2];
                    k++;
                }
            }

            tmscore = TMscore8_search(r1, r2, xtm, ytm, xt, k, t, u,
                simplify_step, score_sum_method, &rmsd, local_d0_search,
                Lnorm, score_d8, d0);

           
            if(tmscore>tmscore_max)
            {
                tmscore_max=tmscore;
                for(i=0; i<ylen; i++) invmap0[i]=invmap[i];
            }
    
            if(iteration>0)
            {
                if(fabs(tmscore_old-tmscore)<0.000001) break;       
            }
            tmscore_old=tmscore;
        }// for iteration           
        
    }//for gapopen
    
    
    delete []invmap;
    return tmscore_max;
}


void output_superpose(const string xname, const string yname,
    const string fname_super,
    double t[3], double u[3][3], const int ter_opt, const int mirror_opt,
    const char *seqM, const char *seqxA, const char *seqyA,
    const vector<string>&resi_vec1, const vector<string>&resi_vec2,
    const char *chainID1, const char *chainID2,
    const int xlen, const int ylen, const double d0A, const int n_ali8,
    const double rmsd, const double TM1, const double Liden)
{
    stringstream buf;
    stringstream buf_all;
    stringstream buf_atm;
    stringstream buf_all_atm;
    stringstream buf_all_atm_lig;
    stringstream buf_pdb;
    stringstream buf_pymol;
    stringstream buf_tm;
    string line;
    double x[3];  // before transform
    double x1[3]; // after transform
    bool after_ter; // true if passed the "TER" line in PDB
    string asym_id; // chain ID

    buf_tm<<"REMARK TM-align"
        <<"\nREMARK Chain 1:"<<setw(11)<<left<<xname+chainID1<<" Size= "<<xlen
        <<"\nREMARK Chain 2:"<<setw(11)<<yname+chainID2<<right<<" Size= "<<ylen
        <<" (TM-score is normalized by "<<setw(4)<<ylen<<", d0="
        <<setiosflags(ios::fixed)<<setprecision(2)<<setw(6)<<d0A<<")"
        <<"\nREMARK Aligned length="<<setw(4)<<n_ali8<<", RMSD="
        <<setw(6)<<setiosflags(ios::fixed)<<setprecision(2)<<rmsd
        <<", TM-score="<<setw(7)<<setiosflags(ios::fixed)<<setprecision(5)<<TM1
        <<", ID="<<setw(5)<<setiosflags(ios::fixed)<<setprecision(3)
        <<((n_ali8>0)?Liden/n_ali8:0)<<endl;
    string rasmol_CA_header="load inline\nselect *A\nwireframe .45\nselect *B\nwireframe .20\nselect all\ncolor white\n";
    string rasmol_cartoon_header="load inline\nselect all\ncartoon\nselect *A\ncolor blue\nselect *B\ncolor red\nselect ligand\nwireframe 0.25\nselect solvent\nspacefill 0.25\nselect all\nexit\n"+buf_tm.str();
    buf<<rasmol_CA_header;
    buf_all<<rasmol_CA_header;
    buf_atm<<rasmol_cartoon_header;
    buf_all_atm<<rasmol_cartoon_header;
    buf_all_atm_lig<<rasmol_cartoon_header;

    /* for PDBx/mmCIF only */
    map<string,int> _atom_site;
    int atom_site_pos;
    vector<string> line_vec;
    string atom; // 4-character atom name
    string AA;   // 3-character residue name
    string resi; // 4-character residue sequence number
    string inscode; // 1-character insertion code
    string model_index; // model index
    bool is_mmcif=false;
    int chain_num=0;

    /* used for CONECT record of chain1 */
    int ca_idx1=0; // all CA atoms
    int lig_idx1=0; // all atoms
    vector <int> idx_vec;

    /* used for CONECT record of chain2 */
    int ca_idx2=0; // all CA atoms
    int lig_idx2=0; // all atoms

    /* extract aligned region */
    vector<string> resi_aln1;
    vector<string> resi_aln2;
    int i1=-1;
    int i2=-1;
    int i;
    for (i=0;i<strlen(seqM);i++)
    {
        i1+=(seqxA[i]!='-');
        i2+=(seqyA[i]!='-');
        if (seqM[i]==' ') continue;
        resi_aln1.push_back(resi_vec1[i1].substr(0,4));
        resi_aln2.push_back(resi_vec2[i2].substr(0,4));
        if (seqM[i]!=':') continue;
        buf    <<"select "<<resi_aln1.back()<<":A,"
               <<resi_aln2.back()<<":B\ncolor red\n";
        buf_all<<"select "<<resi_aln1.back()<<":A,"
               <<resi_aln2.back()<<":B\ncolor red\n";
    }
    buf<<"select all\nexit\n"<<buf_tm.str();
    buf_all<<"select all\nexit\n"<<buf_tm.str();

    ifstream fin;
    /* read first file */
    after_ter=false;
    asym_id="";
    fin.open(xname.c_str());
    while (fin.good())
    {
        getline(fin, line);
        if (ter_opt>=3 && line.compare(0,3,"TER")==0) after_ter=true;
        if (is_mmcif==false && line.size()>=54 &&
           (line.compare(0, 6, "ATOM  ")==0 ||
            line.compare(0, 6, "HETATM")==0)) // PDB format
        {
            x[0]=atof(line.substr(30,8).c_str());
            x[1]=atof(line.substr(38,8).c_str());
            x[2]=atof(line.substr(46,8).c_str());
            if (mirror_opt) x[2]=-x[2];
            transform(t, u, x, x1);
            buf_pdb<<line.substr(0,30)<<setiosflags(ios::fixed)
                <<setprecision(3)
                <<setw(8)<<x1[0] <<setw(8)<<x1[1] <<setw(8)<<x1[2]
                <<line.substr(54)<<'\n';

            if (line[16]!='A' && line[16]!=' ') continue;
            if (after_ter && line.compare(0,6,"ATOM  ")==0) continue;
            lig_idx1++;
            buf_all_atm_lig<<line.substr(0,6)<<setw(5)<<lig_idx1
                <<line.substr(11,9)<<" A"<<line.substr(22,8)
                <<setiosflags(ios::fixed)<<setprecision(3)
                <<setw(8)<<x1[0]<<setw(8)<<x1[1] <<setw(8)<<x1[2]<<'\n';
            if (after_ter || line.compare(0,6,"ATOM  ")) continue;
            if (ter_opt>=2)
            {
                if (ca_idx1 && asym_id.size() && asym_id!=line.substr(21,1)) 
                {
                    after_ter=true;
                    continue;
                }
                asym_id=line[21];
            }
            buf_all_atm<<"ATOM  "<<setw(5)<<lig_idx1
                <<line.substr(11,9)<<" A"<<line.substr(22,8)
                <<setiosflags(ios::fixed)<<setprecision(3)
                <<setw(8)<<x1[0]<<setw(8)<<x1[1] <<setw(8)<<x1[2]<<'\n';
            if (find(resi_aln1.begin(),resi_aln1.end(),line.substr(22,4)
                )!=resi_aln1.end())
            {
                buf_atm<<"ATOM  "<<setw(5)<<lig_idx1
                    <<line.substr(11,9)<<" A"<<line.substr(22,8)
                    <<setiosflags(ios::fixed)<<setprecision(3)
                    <<setw(8)<<x1[0]<<setw(8)<<x1[1] <<setw(8)<<x1[2]<<'\n';
            }
            if (line.substr(12,4)!=" CA ") continue;
            ca_idx1++;
            buf_all<<"ATOM  "<<setw(5)<<ca_idx1
                <<"  CA  "<<line.substr(17,3)<<" A"<<line.substr(22,8)
                <<setiosflags(ios::fixed)<<setprecision(3)
                <<setw(8)<<x1[0]<<setw(8)<<x1[1]<<setw(8)<<x1[2]<<'\n';
            if (find(resi_aln1.begin(),resi_aln1.end(),line.substr(22,4)
                )==resi_aln1.end()) continue;
            buf<<"ATOM  "<<setw(5)<<ca_idx1
                <<"  CA  "<<line.substr(17,3)<<" A"<<line.substr(22,8)
                <<setiosflags(ios::fixed)<<setprecision(3)
                <<setw(8)<<x1[0]<<setw(8)<<x1[1]<<setw(8)<<x1[2]<<'\n';
            idx_vec.push_back(ca_idx1);
        }
        else if (line.compare(0,5,"loop_")==0) // PDBx/mmCIF
        {
            while(1)
            {
                if (fin.good()) getline(fin, line);
                else PrintErrorAndQuit("ERROR! Unexpected end of "+xname);
                if (line.size()) break;
            }
            if (line.compare(0,11,"_atom_site.")) continue;
            _atom_site.clear();
            atom_site_pos=0;
            _atom_site[line.substr(11,line.size()-12)]=atom_site_pos;
            while(1)
            {
                if (fin.good()) getline(fin, line);
                else PrintErrorAndQuit("ERROR! Unexpected end of "+xname);
                if (line.size()==0) continue;
                if (line.compare(0,11,"_atom_site.")) break;
                _atom_site[line.substr(11,line.size()-12)]=++atom_site_pos;
            }

            if (is_mmcif==false)
            {
                buf_pdb.str(string());
                is_mmcif=true;
            }

            while(1)
            {
                line_vec.clear();
                split(line,line_vec);
                if (line_vec[_atom_site["group_PDB"]]!="ATOM" &&
                    line_vec[_atom_site["group_PDB"]]!="HETATM") break;
                if (_atom_site.count("pdbx_PDB_model_num"))
                {
                    if (model_index.size() && model_index!=
                        line_vec[_atom_site["pdbx_PDB_model_num"]])
                        break;
                    model_index=line_vec[_atom_site["pdbx_PDB_model_num"]];
                }

                x[0]=atof(line_vec[_atom_site["Cartn_x"]].c_str());
                x[1]=atof(line_vec[_atom_site["Cartn_y"]].c_str());
                x[2]=atof(line_vec[_atom_site["Cartn_z"]].c_str());
                if (mirror_opt) x[2]=-x[2];
                transform(t, u, x, x1);

                if (_atom_site.count("label_alt_id")==0 || 
                    line_vec[_atom_site["label_alt_id"]]=="." ||
                    line_vec[_atom_site["label_alt_id"]]=="A")
                {
                    atom=line_vec[_atom_site["label_atom_id"]];
                    if (atom[0]=='"') atom=atom.substr(1);
                    if (atom.size() && atom[atom.size()-1]=='"')
                        atom=atom.substr(0,atom.size()-1);
                    if      (atom.size()==0) atom="    ";
                    else if (atom.size()==1) atom=" "+atom+"  ";
                    else if (atom.size()==2) atom=" "+atom+" ";
                    else if (atom.size()==3) atom=" "+atom;
                    else if (atom.size()>=5) atom=atom.substr(0,4);
            
                    AA=line_vec[_atom_site["label_comp_id"]]; // residue name
                    if      (AA.size()==1) AA="  "+AA;
                    else if (AA.size()==2) AA=" " +AA;
                    else if (AA.size()>=4) AA=AA.substr(0,3);
                
                    if (_atom_site.count("auth_seq_id"))
                        resi=line_vec[_atom_site["auth_seq_id"]];
                    else resi=line_vec[_atom_site["label_seq_id"]];
                    while (resi.size()<4) resi=' '+resi;
                    if (resi.size()>4) resi=resi.substr(0,4);
                
                    inscode=' ';
                    if (_atom_site.count("pdbx_PDB_ins_code") && 
                        line_vec[_atom_site["pdbx_PDB_ins_code"]]!="?")
                        inscode=line_vec[_atom_site["pdbx_PDB_ins_code"]][0];
                    
                    if (_atom_site.count("auth_asym_id"))
                    {
                        if (ter_opt>=2 && ca_idx1 && asym_id.size() && 
                            asym_id!=line_vec[_atom_site["auth_asym_id"]])
                            after_ter=true;
                        asym_id=line_vec[_atom_site["auth_asym_id"]];
                    }
                    else if (_atom_site.count("label_asym_id"))
                    {
                        if (ter_opt>=2 && ca_idx1 && asym_id.size() && 
                            asym_id!=line_vec[_atom_site["label_asym_id"]])
                            after_ter=true;
                        asym_id=line_vec[_atom_site["label_asym_id"]];
                    }
                    buf_pdb<<left<<setw(6)
                        <<line_vec[_atom_site["group_PDB"]]<<right
                        <<setw(5)<<lig_idx1%100000<<' '<<atom<<' '
                        <<AA<<" "<<asym_id[asym_id.size()-1]
                        <<resi<<inscode<<"   "
                        <<setiosflags(ios::fixed)<<setprecision(3)
                        <<setw(8)<<x1[0]
                        <<setw(8)<<x1[1]
                        <<setw(8)<<x1[2]<<'\n';

                    if (after_ter==false ||
                        line_vec[_atom_site["group_pdb"]]=="HETATM")
                    {
                        lig_idx1++;
                        buf_all_atm_lig<<left<<setw(6)
                            <<line_vec[_atom_site["group_PDB"]]<<right
                            <<setw(5)<<lig_idx1%100000<<' '<<atom<<' '
                            <<AA<<" A"<<resi<<inscode<<"   "
                            <<setiosflags(ios::fixed)<<setprecision(3)
                            <<setw(8)<<x1[0]
                            <<setw(8)<<x1[1]
                            <<setw(8)<<x1[2]<<'\n';
                        if (after_ter==false &&
                            line_vec[_atom_site["group_PDB"]]=="ATOM")
                        {
                            buf_all_atm<<"ATOM  "<<setw(6)
                                <<setw(5)<<lig_idx1%100000<<' '<<atom<<' '
                                <<AA<<" A"<<resi<<inscode<<"   "
                                <<setiosflags(ios::fixed)<<setprecision(3)
                                <<setw(8)<<x1[0]
                                <<setw(8)<<x1[1]
                                <<setw(8)<<x1[2]<<'\n';
                            if (find(resi_aln1.begin(),resi_aln1.end(),resi
                                )!=resi_aln1.end())
                            {
                                buf_atm<<"ATOM  "<<setw(6)
                                    <<setw(5)<<lig_idx1%100000<<' '
                                    <<atom<<' '<<AA<<" A"<<resi<<inscode<<"   "
                                    <<setiosflags(ios::fixed)<<setprecision(3)
                                    <<setw(8)<<x1[0]
                                    <<setw(8)<<x1[1]
                                    <<setw(8)<<x1[2]<<'\n';
                            }
                            if (atom==" CA ")
                            {
                                ca_idx1++;
                                buf_all<<"ATOM  "<<setw(6)
                                    <<setw(5)<<ca_idx1%100000<<"  CA  "
                                    <<AA<<" A"<<resi<<inscode<<"   "
                                    <<setiosflags(ios::fixed)<<setprecision(3)
                                    <<setw(8)<<x1[0]
                                    <<setw(8)<<x1[1]
                                    <<setw(8)<<x1[2]<<'\n';
                                if (find(resi_aln1.begin(),resi_aln1.end(),resi
                                    )!=resi_aln1.end())
                                {
                                    buf<<"ATOM  "<<setw(6)
                                    <<setw(5)<<ca_idx1%100000<<"  CA  "
                                    <<AA<<" A"<<resi<<inscode<<"   "
                                    <<setiosflags(ios::fixed)<<setprecision(3)
                                    <<setw(8)<<x1[0]
                                    <<setw(8)<<x1[1]
                                    <<setw(8)<<x1[2]<<'\n';
                                    idx_vec.push_back(ca_idx1);
                                }
                            }
                        }
                    }
                }

                while(1)
                {
                    if (fin.good()) getline(fin, line);
                    else break;
                    if (line.size()) break;
                }
            }
        }
        else if (line.size() && is_mmcif==false)
        {
            buf_pdb<<line<<'\n';
            if (ter_opt>=1 && line.compare(0,3,"END")==0) break;
        }
    }
    fin.close();
    buf<<"TER\n";
    buf_all<<"TER\n";
    buf_atm<<"TER\n";
    buf_all_atm<<"TER\n";
    buf_all_atm_lig<<"TER\n";
    for (i=1;i<ca_idx1;i++) buf_all<<"CONECT"
        <<setw(5)<<i%100000<<setw(5)<<(i+1)%100000<<'\n';
    for (i=1;i<idx_vec.size();i++) buf<<"CONECT"
        <<setw(5)<<idx_vec[i-1]%100000<<setw(5)<<idx_vec[i]%100000<<'\n';
    idx_vec.clear();

    /* read second file */
    after_ter=false;
    asym_id="";
    fin.open(yname.c_str());
    while (fin.good())
    {
        getline(fin, line);
        if (ter_opt>=3 && line.compare(0,3,"TER")==0) after_ter=true;
        if (line.size()>=54 && (line.compare(0, 6, "ATOM  ")==0 ||
            line.compare(0, 6, "HETATM")==0)) // PDB format
        {
            if (line[16]!='A' && line[16]!=' ') continue;
            if (after_ter && line.compare(0,6,"ATOM  ")==0) continue;
            lig_idx2++;
            buf_all_atm_lig<<line.substr(0,6)<<setw(5)<<lig_idx1+lig_idx2
                <<line.substr(11,9)<<" B"<<line.substr(22,32)<<'\n';
            if (after_ter || line.compare(0,6,"ATOM  ")) continue;
            if (ter_opt>=2)
            {
                if (ca_idx2 && asym_id.size() && asym_id!=line.substr(21,1))
                {
                    after_ter=true;
                    continue;
                }
                asym_id=line[21];
            }
            buf_all_atm<<"ATOM  "<<setw(5)<<lig_idx1+lig_idx2
                <<line.substr(11,9)<<" B"<<line.substr(22,32)<<'\n';
            if (find(resi_aln2.begin(),resi_aln2.end(),line.substr(22,4)
                )!=resi_aln2.end())
            {
                buf_atm<<"ATOM  "<<setw(5)<<lig_idx1+lig_idx2
                    <<line.substr(11,9)<<" B"<<line.substr(22,32)<<'\n';
            }
            if (line.substr(12,4)!=" CA ") continue;
            ca_idx2++;
            buf_all<<"ATOM  "<<setw(5)<<ca_idx1+ca_idx2<<"  CA  "
                <<line.substr(17,3)<<" B"<<line.substr(22,32)<<'\n';
            if (find(resi_aln2.begin(),resi_aln2.end(),line.substr(22,4)
                )==resi_aln2.end()) continue;
            buf<<"ATOM  "<<setw(5)<<ca_idx1+ca_idx2<<"  CA  "
                <<line.substr(17,3)<<" B"<<line.substr(22,32)<<'\n';
            idx_vec.push_back(ca_idx1+ca_idx2);
        }
        else if (line.compare(0,5,"loop_")==0) // PDBx/mmCIF
        {
            while(1)
            {
                if (fin.good()) getline(fin, line);
                else PrintErrorAndQuit("ERROR! Unexpected end of "+yname);
                if (line.size()) break;
            }
            if (line.compare(0,11,"_atom_site.")) continue;
            _atom_site.clear();
            atom_site_pos=0;
            _atom_site[line.substr(11,line.size()-12)]=atom_site_pos;
            while(1)
            {
                if (fin.good()) getline(fin, line);
                else PrintErrorAndQuit("ERROR! Unexpected end of "+yname);
                if (line.size()==0) continue;
                if (line.compare(0,11,"_atom_site.")) break;
                _atom_site[line.substr(11,line.size()-12)]=++atom_site_pos;
            }

            while(1)
            {
                line_vec.clear();
                split(line,line_vec);
                if (line_vec[_atom_site["group_PDB"]]!="ATOM" &&
                    line_vec[_atom_site["group_PDB"]]!="HETATM") break;
                if (_atom_site.count("pdbx_PDB_model_num"))
                {
                    if (model_index.size() && model_index!=
                        line_vec[_atom_site["pdbx_PDB_model_num"]])
                        break;
                    model_index=line_vec[_atom_site["pdbx_PDB_model_num"]];
                }

                if (_atom_site.count("label_alt_id")==0 || 
                    line_vec[_atom_site["label_alt_id"]]=="." ||
                    line_vec[_atom_site["label_alt_id"]]=="A")
                {
                    atom=line_vec[_atom_site["label_atom_id"]];
                    if (atom[0]=='"') atom=atom.substr(1);
                    if (atom.size() && atom[atom.size()-1]=='"')
                        atom=atom.substr(0,atom.size()-1);
                    if      (atom.size()==0) atom="    ";
                    else if (atom.size()==1) atom=" "+atom+"  ";
                    else if (atom.size()==2) atom=" "+atom+" ";
                    else if (atom.size()==3) atom=" "+atom;
                    else if (atom.size()>=5) atom=atom.substr(0,4);
            
                    AA=line_vec[_atom_site["label_comp_id"]]; // residue name
                    if      (AA.size()==1) AA="  "+AA;
                    else if (AA.size()==2) AA=" " +AA;
                    else if (AA.size()>=4) AA=AA.substr(0,3);
                
                    if (_atom_site.count("auth_seq_id"))
                        resi=line_vec[_atom_site["auth_seq_id"]];
                    else resi=line_vec[_atom_site["label_seq_id"]];
                    while (resi.size()<4) resi=' '+resi;
                    if (resi.size()>4) resi=resi.substr(0,4);
                
                    inscode=' ';
                    if (_atom_site.count("pdbx_PDB_ins_code") && 
                        line_vec[_atom_site["pdbx_PDB_ins_code"]]!="?")
                        inscode=line_vec[_atom_site["pdbx_PDB_ins_code"]][0];
                    
                    if (ter_opt>=2)
                    {
                        if (_atom_site.count("auth_asym_id"))
                        {
                            if (ca_idx2 && asym_id.size() && 
                                asym_id!=line_vec[_atom_site["auth_asym_id"]])
                                after_ter=true;
                            else
                                asym_id=line_vec[_atom_site["auth_asym_id"]];
                        }
                        else if (_atom_site.count("label_asym_id"))
                        {
                            if (ca_idx2 && asym_id.size() && 
                                asym_id!=line_vec[_atom_site["label_asym_id"]])
                                after_ter=true;
                            else
                                asym_id=line_vec[_atom_site["label_asym_id"]];
                        }
                    }
                    if (after_ter==false || 
                        line_vec[_atom_site["group_PDB"]]=="HETATM")
                    {
                        lig_idx2++;
                        buf_all_atm_lig<<left<<setw(6)
                            <<line_vec[_atom_site["group_PDB"]]<<right
                            <<setw(5)<<(lig_idx1+lig_idx2)%100000<<' '
                            <<atom<<' '<<AA<<" B"<<resi<<inscode<<"   "
                            <<setw(8)<<line_vec[_atom_site["Cartn_x"]]
                            <<setw(8)<<line_vec[_atom_site["Cartn_y"]]
                            <<setw(8)<<line_vec[_atom_site["Cartn_z"]]
                            <<'\n';
                        if (after_ter==false &&
                            line_vec[_atom_site["group_PDB"]]=="ATOM")
                        {
                            buf_all_atm<<"ATOM  "<<setw(6)
                                <<setw(5)<<(lig_idx1+lig_idx2)%100000<<' '
                                <<atom<<' '<<AA<<" B"<<resi<<inscode<<"   "
                                <<setw(8)<<line_vec[_atom_site["Cartn_x"]]
                                <<setw(8)<<line_vec[_atom_site["Cartn_y"]]
                                <<setw(8)<<line_vec[_atom_site["Cartn_z"]]
                                <<'\n';
                            if (find(resi_aln2.begin(),resi_aln2.end(),resi
                                    )!=resi_aln2.end())
                            {
                                buf_atm<<"ATOM  "<<setw(6)
                                    <<setw(5)<<(lig_idx1+lig_idx2)%100000<<' '
                                    <<atom<<' '<<AA<<" B"<<resi<<inscode<<"   "
                                    <<setw(8)<<line_vec[_atom_site["Cartn_x"]]
                                    <<setw(8)<<line_vec[_atom_site["Cartn_y"]]
                                    <<setw(8)<<line_vec[_atom_site["Cartn_z"]]
                                    <<'\n';
                            }
                            if (atom==" CA ")
                            {
                                ca_idx2++;
                                buf_all<<"ATOM  "<<setw(6)
                                    <<setw(5)<<(ca_idx1+ca_idx2)%100000
                                    <<"  CA  "<<AA<<" B"<<resi<<inscode<<"   "
                                    <<setw(8)<<line_vec[_atom_site["Cartn_x"]]
                                    <<setw(8)<<line_vec[_atom_site["Cartn_y"]]
                                    <<setw(8)<<line_vec[_atom_site["Cartn_z"]]
                                    <<'\n';
                                if (find(resi_aln2.begin(),resi_aln2.end(),resi
                                    )!=resi_aln2.end())
                                {
                                    buf<<"ATOM  "<<setw(6)
                                    <<setw(5)<<(ca_idx1+ca_idx2)%100000
                                    <<"  CA  "<<AA<<" B"<<resi<<inscode<<"   "
                                    <<setw(8)<<line_vec[_atom_site["Cartn_x"]]
                                    <<setw(8)<<line_vec[_atom_site["Cartn_y"]]
                                    <<setw(8)<<line_vec[_atom_site["Cartn_z"]]
                                    <<'\n';
                                    idx_vec.push_back(ca_idx1+ca_idx2);
                                }
                            }
                        }
                    }
                }

                if (fin.good()) getline(fin, line);
                else break;
            }
        }
        else if (line.size())
        {
            if (ter_opt>=1 && line.compare(0,3,"END")==0) break;
        }
    }
    fin.close();
    buf<<"TER\n";
    buf_all<<"TER\n";
    buf_atm<<"TER\n";
    buf_all_atm<<"TER\n";
    buf_all_atm_lig<<"TER\n";
    for (i=ca_idx1+1;i<ca_idx1+ca_idx2;i++) buf_all<<"CONECT"
        <<setw(5)<<i%100000<<setw(5)<<(i+1)%100000<<'\n';
    for (i=1;i<idx_vec.size();i++) buf<<"CONECT"
        <<setw(5)<<idx_vec[i-1]%100000<<setw(5)<<idx_vec[i]%100000<<'\n';
    idx_vec.clear();

    /* write pymol script */
    ofstream fp;
    vector<string> pml_list;
    pml_list.push_back(fname_super+"");
    pml_list.push_back(fname_super+"_atm");
    pml_list.push_back(fname_super+"_all");
    pml_list.push_back(fname_super+"_all_atm");
    pml_list.push_back(fname_super+"_all_atm_lig");
    for (i=0;i<pml_list.size();i++)
    {
        buf_pymol<<"#!/usr/bin/env pymol\n"
            <<"load "<<pml_list[i]<<", format=pdb\n"
            <<"hide all\n"
            <<((i==0 || i==2)?("show stick\n"):("show cartoon\n"))
            <<"color blue, chain A\n"
            <<"color red, chain B\n"
            <<"set ray_shadow, 0\n"
            <<"set stick_radius, 0.3\n"
            <<"set sphere_scale, 0.25\n"
            <<"show stick, not polymer\n"
            <<"show sphere, not polymer\n"
            <<"bg_color white\n"
            <<"set transparency=0.2\n"
            <<"zoom polymer\n"
            <<endl;
        fp.open((pml_list[i]+".pml").c_str());
        fp<<buf_pymol.str();
        fp.close();
        buf_pymol.str(string());
        pml_list[i].clear();
    }
    pml_list.clear();
    
    /* write rasmol script */
    fp.open((fname_super).c_str());
    fp<<buf.str();
    fp.close();
    fp.open((fname_super+"_all").c_str());
    fp<<buf_all.str();
    fp.close();
    fp.open((fname_super+"_atm").c_str());
    fp<<buf_atm.str();
    fp.close();
    fp.open((fname_super+"_all_atm").c_str());
    fp<<buf_all_atm.str();
    fp.close();
    fp.open((fname_super+"_all_atm_lig").c_str());
    fp<<buf_all_atm_lig.str();
    fp.close();
    fp.open((fname_super+".pdb").c_str());
    fp<<buf_pdb.str();
    fp.close();

    /* clear stream */
    buf.str(string());
    buf_all.str(string());
    buf_atm.str(string());
    buf_all_atm.str(string());
    buf_all_atm_lig.str(string());
    buf_pdb.str(string());
    buf_tm.str(string());
    resi_aln1.clear();
    resi_aln2.clear();
    asym_id.clear();
    line_vec.clear();
    atom.clear();
    AA.clear();
    resi.clear();
    inscode.clear();
    model_index.clear();
}

/* extract rotation matrix based on TMscore8 */
void output_rotation_matrix(const char* fname_matrix,
    const double t[3], const double u[3][3])
{
    fstream fout;
    fout.open(fname_matrix, ios::out | ios::trunc);
    if (fout)// succeed
    {
        fout << "------ The rotation matrix to rotate Chain_1 to Chain_2 ------\n";
        char dest[1000];
        sprintf(dest, "m %18s %14s %14s %14s\n", "t[m]", "u[m][0]", "u[m][1]", "u[m][2]");
        fout << string(dest);
        for (int k = 0; k < 3; k++)
        {
            sprintf(dest, "%d %18.10f %14.10f %14.10f %14.10f\n", k, t[k], u[k][0], u[k][1], u[k][2]);
            fout << string(dest);
        }
        fout << "\nCode for rotating Structure A from (x,y,z) to (X,Y,Z):\n"
                "for(i=0; i<L; i++)\n"
                "{\n"
                "   X[i] = t[0] + u[0][0]*x[i] + u[0][1]*y[i] + u[0][2]*z[i];\n"
                "   Y[i] = t[1] + u[1][0]*x[i] + u[1][1]*y[i] + u[1][2]*z[i];\n"
                "   Z[i] = t[2] + u[2][0]*x[i] + u[2][1]*y[i] + u[2][2]*z[i];\n"
                "}\n";
        fout.close();
    }
    else
        cout << "Open file to output rotation matrix fail.\n";
}

//output the final results
void output_results(
    const string xname, const string yname,
    const char *chainID1, const char *chainID2,
    const int xlen, const int ylen, double t[3], double u[3][3],
    const double TM1, const double TM2,
    const double TM3, const double TM4, const double TM5,
    const double rmsd, const double d0_out,
    const char *seqM, const char *seqxA, const char *seqyA, const double Liden,
    const int n_ali8, const int L_ali,
    const double TM_ali, const double rmsd_ali, const double TM_0,
    const double d0_0, const double d0A, const double d0B,
    const double Lnorm_ass, const double d0_scale, 
    const double d0a, const double d0u, const char* fname_matrix,
    const int outfmt_opt, const int ter_opt, const string fname_super,
    const int i_opt, const int a_opt, const bool u_opt, const bool d_opt,
    const int mirror_opt,
    const vector<string>&resi_vec1, const vector<string>&resi_vec2)
{
    if (outfmt_opt<=0)
    {
        printf("\nName of Chain_1: %s%s (to be superimposed onto Chain_2)\n",
            xname.c_str(), chainID1);
        printf("Name of Chain_2: %s%s\n", yname.c_str(), chainID2);
        printf("Length of Chain_1: %d residues\n", xlen);
        printf("Length of Chain_2: %d residues\n\n", ylen);

        if (i_opt)
            printf("User-specified initial alignment: TM/Lali/rmsd = %7.5lf, %4d, %6.3lf\n", TM_ali, L_ali, rmsd_ali);

        printf("Aligned length= %d, RMSD= %6.2f, Seq_ID=n_identical/n_aligned= %4.3f\n", n_ali8, rmsd, (n_ali8>0)?Liden/n_ali8:0);
        printf("TM-score= %6.5f (if normalized by length of Chain_1, i.e., LN=%d, d0=%.2f)\n", TM2, xlen, d0B);
        printf("TM-score= %6.5f (if normalized by length of Chain_2, i.e., LN=%d, d0=%.2f)\n", TM1, ylen, d0A);

        if (a_opt==1)
            printf("TM-score= %6.5f (if normalized by average length of two structures, i.e., LN= %.1f, d0= %.2f)\n", TM3, (xlen+ylen)*0.5, d0a);
        if (u_opt)
            printf("TM-score= %6.5f (if normalized by user-specified LN=%.2f and d0=%.2f)\n", TM4, Lnorm_ass, d0u);
        if (d_opt)
            printf("TM-score= %6.5f (if scaled by user-specified d0= %.2f, and LN= %d)\n", TM5, d0_scale, ylen);
        printf("(You should use TM-score normalized by length of the reference structure)\n");
    
        //output alignment
        printf("\n(\":\" denotes residue pairs of d < %4.1f Angstrom, ", d0_out);
        printf("\".\" denotes other aligned residues)\n");
        printf("%s\n", seqxA);
        printf("%s\n", seqM);
        printf("%s\n", seqyA);
    }
    else if (outfmt_opt==1)
    {
        printf(">%s%s\tL=%d\td0=%.2f\tseqID=%.3f\tTM-score=%.5f\n",
            xname.c_str(), chainID1, xlen, d0B, Liden/xlen, TM2);
        printf("%s\n", seqxA);
        printf(">%s%s\tL=%d\td0=%.2f\tseqID=%.3f\tTM-score=%.5f\n",
            yname.c_str(), chainID2, ylen, d0A, Liden/ylen, TM1);
        printf("%s\n", seqyA);

        printf("# Lali=%d\tRMSD=%.2f\tseqID_ali=%.3f\n",
            n_ali8, rmsd, (n_ali8>0)?Liden/n_ali8:0);

        if (i_opt)
            printf("# User-specified initial alignment: TM=%.5lf\tLali=%4d\trmsd=%.3lf\n", TM_ali, L_ali, rmsd_ali);

        if(a_opt)
            printf("# TM-score=%.5f (normalized by average length of two structures: L=%.1f\td0=%.2f)\n", TM3, (xlen+ylen)*0.5, d0a);

        if(u_opt)
            printf("# TM-score=%.5f (normalized by user-specified L=%.2f\td0=%.2f)\n", TM4, Lnorm_ass, d0u);

        if(d_opt)
            printf("# TM-score=%.5f (scaled by user-specified d0=%.2f\tL=%d)\n", TM5, d0_scale, ylen);

        printf("$$$$\n");
    }
    else if (outfmt_opt==2)
    {
        printf("%s%s\t%s%s\t%.4f\t%.4f\t%.2f\t%4.3f\t%4.3f\t%4.3f\t%d\t%d\t%d",
            xname.c_str(), chainID1, yname.c_str(), chainID2, TM2, TM1, rmsd,
            Liden/xlen, Liden/ylen, (n_ali8>0)?Liden/n_ali8:0,
            xlen, ylen, n_ali8);
    }
    cout << endl;

    if (strlen(fname_matrix)) 
        output_rotation_matrix(fname_matrix, t, u);
    if (fname_super.size())
        output_superpose(xname, yname, fname_super, t, u, ter_opt, mirror_opt,
            seqM, seqxA, seqyA, resi_vec1, resi_vec2, chainID1, chainID2,
            xlen, ylen, d0A, n_ali8, rmsd, TM1, Liden);
}

double standard_TMscore(double **r1, double **r2, double **xtm, double **ytm,
    double **xt, double **x, double **y, int xlen, int ylen, int invmap[],
    int& L_ali, double& RMSD, double D0_MIN, double Lnorm, double d0,
    double d0_search, double score_d8, double t[3], double u[3][3],
    const int mol_type)
{
    D0_MIN = 0.5;
    Lnorm = ylen;
    if (mol_type>0) // RNA
    {
        if     (Lnorm<=11) d0=0.3; 
        else if(Lnorm>11 && Lnorm<=15) d0=0.4;
        else if(Lnorm>15 && Lnorm<=19) d0=0.5;
        else if(Lnorm>19 && Lnorm<=23) d0=0.6;
        else if(Lnorm>23 && Lnorm<30)  d0=0.7;
        else d0=(0.6*pow((Lnorm*1.0-0.5), 1.0/2)-2.5);
    }
    else
    {
        if (Lnorm > 21) d0=(1.24*pow((Lnorm*1.0-15), 1.0/3) -1.8);
        else d0 = D0_MIN;
        if (d0 < D0_MIN) d0 = D0_MIN;
    }
    double d0_input = d0;// Scaled by seq_min

    double tmscore;// collected alined residues from invmap
    int n_al = 0;
    int i;
    for (int j = 0; j<ylen; j++)
    {
        i = invmap[j];
        if (i >= 0)
        {
            xtm[n_al][0] = x[i][0];
            xtm[n_al][1] = x[i][1];
            xtm[n_al][2] = x[i][2];

            ytm[n_al][0] = y[j][0];
            ytm[n_al][1] = y[j][1];
            ytm[n_al][2] = y[j][2];

            r1[n_al][0] = x[i][0];
            r1[n_al][1] = x[i][1];
            r1[n_al][2] = x[i][2];

            r2[n_al][0] = y[j][0];
            r2[n_al][1] = y[j][1];
            r2[n_al][2] = y[j][2];

            n_al++;
        }
        else if (i != -1) PrintErrorAndQuit("Wrong map!\n");
    }
    L_ali = n_al;

    Kabsch(r1, r2, n_al, 0, &RMSD, t, u);
    RMSD = sqrt( RMSD/(1.0*n_al) );
    
    int temp_simplify_step = 1;
    int temp_score_sum_method = 0;
    d0_search = d0_input;
    double rms = 0.0;
    tmscore = TMscore8_search_standard(r1, r2, xtm, ytm, xt, n_al, t, u,
        temp_simplify_step, temp_score_sum_method, &rms, d0_input,
        score_d8, d0);
    tmscore = tmscore * n_al / (1.0*Lnorm);

    return tmscore;
}

/* copy the value of t and u into t0,u0 */
void copy_t_u(double t[3], double u[3][3], double t0[3], double u0[3][3])
{
    int i,j;
    for (i=0;i<3;i++)
    {
        t0[i]=t[i];
        for (j=0;j<3;j++) u0[i][j]=u[i][j];
    }
}

/* calculate approximate TM-score given rotation matrix */
double approx_TM(const int xlen, const int ylen, const int a_opt,
    double **xa, double **ya, double t[3], double u[3][3],
    const int invmap0[], const int mol_type)
{
    double Lnorm_0=ylen; // normalized by the second protein
    if (a_opt==-2 && xlen>ylen) Lnorm_0=xlen;      // longer
    else if (a_opt==-1 && xlen<ylen) Lnorm_0=xlen; // shorter
    else if (a_opt==1) Lnorm_0=(xlen+ylen)/2.;     // average
    
    double D0_MIN;
    double Lnorm;
    double d0;
    double d0_search;
    parameter_set4final(Lnorm_0, D0_MIN, Lnorm, d0, d0_search, mol_type);
    double TMtmp=0;
    double d;
    double xtmp[3]={0,0,0};

    for(int i=0,j=0; j<ylen; j++)
    {
        i=invmap0[j];
        if(i>=0)//aligned
        {
            transform(t, u, &xa[i][0], &xtmp[0]);
            d=sqrt(dist(&xtmp[0], &ya[j][0]));
            TMtmp+=1/(1+(d/d0)*(d/d0));
            //if (d <= score_d8) TMtmp+=1/(1+(d/d0)*(d/d0));
        }
    }
    TMtmp/=Lnorm_0;
    return TMtmp;
}

void clean_up_after_approx_TM(int *invmap0, int *invmap,
    double **score, bool **path, double **val, double **xtm, double **ytm,
    double **xt, double **r1, double **r2, const int xlen, const int minlen)
{
    delete [] invmap0;
    delete [] invmap;
    DeleteArray(&score, xlen+1);
    DeleteArray(&path, xlen+1);
    DeleteArray(&val, xlen+1);
    DeleteArray(&xtm, minlen);
    DeleteArray(&ytm, minlen);
    DeleteArray(&xt, xlen);
    DeleteArray(&r1, minlen);
    DeleteArray(&r2, minlen);
    return;
}

/* Entry function for TM-align. Return TM-score calculation status:
 * 0   - full TM-score calculation 
 * 1   - terminated due to exception
 * 2-7 - pre-terminated due to low TM-score */
int TMalign_main(double **xa, double **ya,
    const char *seqx, const char *seqy, const char *secx, const char *secy,
    double t0[3], double u0[3][3],
    double &TM1, double &TM2, double &TM3, double &TM4, double &TM5,
    double &d0_0, double &TM_0,
    double &d0A, double &d0B, double &d0u, double &d0a, double &d0_out,
    string &seqM, string &seqxA, string &seqyA,
    double &rmsd0, int &L_ali, double &Liden,
    double &TM_ali, double &rmsd_ali, int &n_ali, int &n_ali8,
    const int xlen, const int ylen,
    const vector<string> sequence, const double Lnorm_ass,
    const double d0_scale, const int i_opt, const int a_opt,
    const bool u_opt, const bool d_opt, const bool fast_opt,
    const int mol_type, const double TMcut=-1)
{
    double D0_MIN;        //for d0
    double Lnorm;         //normalization length
    double score_d8,d0,d0_search,dcu0;//for TMscore search
    double t[3], u[3][3]; //Kabsch translation vector and rotation matrix
    double **score;       // Input score table for dynamic programming
    bool   **path;        // for dynamic programming  
    double **val;         // for dynamic programming  
    double **xtm, **ytm;  // for TMscore search engine
    double **xt;          //for saving the superposed version of r_1 or xtm
    double **r1, **r2;    // for Kabsch rotation

    /***********************/
    /* allocate memory     */
    /***********************/
    int minlen = min(xlen, ylen);
    NewArray(&score, xlen+1, ylen+1);
    NewArray(&path, xlen+1, ylen+1);
    NewArray(&val, xlen+1, ylen+1);
    NewArray(&xtm, minlen, 3);
    NewArray(&ytm, minlen, 3);
    NewArray(&xt, xlen, 3);
    NewArray(&r1, minlen, 3);
    NewArray(&r2, minlen, 3);

    /***********************/
    /*    parameter set    */
    /***********************/
    parameter_set4search(xlen, ylen, D0_MIN, Lnorm, 
        score_d8, d0, d0_search, dcu0);
    int simplify_step    = 40; //for similified search engine
    int score_sum_method = 8;  //for scoring method, whether only sum over pairs with dis<score_d8

    int i;
    int *invmap0         = new int[ylen+1];
    int *invmap          = new int[ylen+1];
    double TM, TMmax=-1;
    for(i=0; i<ylen; i++) invmap0[i]=-1;

    double ddcc=0.4;
    if (Lnorm <= 40) ddcc=0.1;   //Lnorm was setted in parameter_set4search
    double local_d0_search = d0_search;

    //************************************************//
    //    get initial alignment from user's input:    //
    //    Stick to the initial alignment              //
    //************************************************//
    bool bAlignStick = false;
    if (i_opt==3)// if input has set parameter for "-I"
    {
        // In the original code, this loop starts from 1, which is
        // incorrect. Fortran starts from 1 but C++ should starts from 0.
        for (int j = 0; j < ylen; j++)// Set aligned position to be "-1"
            invmap[j] = -1;

        int i1 = -1;// in C version, index starts from zero, not from one
        int i2 = -1;
        int L1 = sequence[0].size();
        int L2 = sequence[1].size();
        int L = min(L1, L2);// Get positions for aligned residues
        for (int kk1 = 0; kk1 < L; kk1++)
        {
            if (sequence[0][kk1] != '-') i1++;
            if (sequence[1][kk1] != '-')
            {
                i2++;
                if (i2 >= ylen || i1 >= xlen) kk1 = L;
                else if (sequence[0][kk1] != '-') invmap[i2] = i1;
            }
        }

        //--------------- 2. Align proteins from original alignment
        double prevD0_MIN = D0_MIN;// stored for later use
        int prevLnorm = Lnorm;
        double prevd0 = d0;
        TM_ali = standard_TMscore(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen,
            invmap, L_ali, rmsd_ali, D0_MIN, Lnorm, d0, d0_search, score_d8,
            t, u, mol_type);
        D0_MIN = prevD0_MIN;
        Lnorm = prevLnorm;
        d0 = prevd0;
        TM = detailed_search_standard(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen,
            invmap, t, u, 40, 8, local_d0_search, true, Lnorm, score_d8, d0);
        if (TM > TMmax)
        {
            TMmax = TM;
            for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
        }
        bAlignStick = true;
    }

    /******************************************************/
    /*    get initial alignment with gapless threading    */
    /******************************************************/
    if (!bAlignStick)
    {
        get_initial(r1, r2, xtm, ytm, xa, ya, xlen, ylen, invmap0, d0,
            d0_search, fast_opt, t, u);
        TM = detailed_search(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen, invmap0,
            t, u, simplify_step, score_sum_method, local_d0_search, Lnorm,
            score_d8, d0);
        if (TM>TMmax) TMmax = TM;
        if (TMcut>0) copy_t_u(t, u, t0, u0);
        //run dynamic programing iteratively to find the best alignment
        TM = DP_iter(r1, r2, xtm, ytm, xt, path, val, xa, ya, xlen, ylen,
             t, u, invmap, 0, 2, (fast_opt)?2:30, local_d0_search,
             D0_MIN, Lnorm, d0, score_d8);
        if (TM>TMmax)
        {
            TMmax = TM;
            for (int i = 0; i<ylen; i++) invmap0[i] = invmap[i];
            if (TMcut>0) copy_t_u(t, u, t0, u0);
        }

        if (TMcut>0) // pre-terminate if TM-score is too low
        {
            double TMtmp=approx_TM(xlen, ylen, a_opt,
                xa, ya, t0, u0, invmap0, mol_type);

            if (TMtmp<0.5*TMcut)
            {
                TM1=TM2=TM3=TM4=TM5=TMtmp;
                clean_up_after_approx_TM(invmap0, invmap, score, path, val,
                    xtm, ytm, xt, r1, r2, xlen, minlen);
                return 2;
            }
        }

        /************************************************************/
        /*    get initial alignment based on secondary structure    */
        /************************************************************/
        get_initial_ss(path, val, secx, secy, xlen, ylen, invmap);
        TM = detailed_search(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen, invmap,
            t, u, simplify_step, score_sum_method, local_d0_search, Lnorm,
            score_d8, d0);
        if (TM>TMmax)
        {
            TMmax = TM;
            for (int i = 0; i<ylen; i++) invmap0[i] = invmap[i];
            if (TMcut>0) copy_t_u(t, u, t0, u0);
        }
        if (TM > TMmax*0.2)
        {
            TM = DP_iter(r1, r2, xtm, ytm, xt, path, val, xa, ya,
                xlen, ylen, t, u, invmap, 0, 2, (fast_opt)?2:30,
                local_d0_search, D0_MIN, Lnorm, d0, score_d8);
            if (TM>TMmax)
            {
                TMmax = TM;
                for (int i = 0; i<ylen; i++) invmap0[i] = invmap[i];
                if (TMcut>0) copy_t_u(t, u, t0, u0);
            }
        }

        if (TMcut>0) // pre-terminate if TM-score is too low
        {
            double TMtmp=approx_TM(xlen, ylen, a_opt,
                xa, ya, t0, u0, invmap0, mol_type);

            if (TMtmp<0.52*TMcut)
            {
                TM1=TM2=TM3=TM4=TM5=TMtmp;
                clean_up_after_approx_TM(invmap0, invmap, score, path, val,
                    xtm, ytm, xt, r1, r2, xlen, minlen);
                return 3;
            }
        }

        /************************************************************/
        /*    get initial alignment based on local superposition    */
        /************************************************************/
        //=initial5 in original TM-align
        if (get_initial5( r1, r2, xtm, ytm, path, val, xa, ya,
            xlen, ylen, invmap, d0, d0_search, fast_opt, D0_MIN))
        {
            TM = detailed_search(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen,
                invmap, t, u, simplify_step, score_sum_method,
                local_d0_search, Lnorm, score_d8, d0);
            if (TM>TMmax)
            {
                TMmax = TM;
                for (int i = 0; i<ylen; i++) invmap0[i] = invmap[i];
                if (TMcut>0) copy_t_u(t, u, t0, u0);
            }
            if (TM > TMmax*ddcc)
            {
                TM = DP_iter(r1, r2, xtm, ytm, xt, path, val, xa, ya,
                    xlen, ylen, t, u, invmap, 0, 2, 2, local_d0_search,
                    D0_MIN, Lnorm, d0, score_d8);
                if (TM>TMmax)
                {
                    TMmax = TM;
                    for (int i = 0; i<ylen; i++) invmap0[i] = invmap[i];
                    if (TMcut>0) copy_t_u(t, u, t0, u0);
                }
            }
        }
        else
            cerr << "\n\nWarning: initial alignment from local superposition fail!\n\n" << endl;

        if (TMcut>0) // pre-terminate if TM-score is too low
        {
            double TMtmp=approx_TM(xlen, ylen, a_opt,
                xa, ya, t0, u0, invmap0, mol_type);

            if (TMtmp<0.54*TMcut)
            {
                TM1=TM2=TM3=TM4=TM5=TMtmp;
                clean_up_after_approx_TM(invmap0, invmap, score, path, val,
                    xtm, ytm, xt, r1, r2, xlen, minlen);
                return 4;
            }
        }

        /********************************************************************/
        /* get initial alignment by local superposition+secondary structure */
        /********************************************************************/
        //=initial3 in original TM-align
        get_initial_ssplus(r1, r2, score, path, val, secx, secy, xa, ya,
            xlen, ylen, invmap0, invmap, D0_MIN, d0);
        TM = detailed_search(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen, invmap,
             t, u, simplify_step, score_sum_method, local_d0_search, Lnorm,
             score_d8, d0);
        if (TM>TMmax)
        {
            TMmax = TM;
            for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
            if (TMcut>0) copy_t_u(t, u, t0, u0);
        }
        if (TM > TMmax*ddcc)
        {
            TM = DP_iter(r1, r2, xtm, ytm, xt, path, val, xa, ya,
                xlen, ylen, t, u, invmap, 0, 2, (fast_opt)?2:30,
                local_d0_search, D0_MIN, Lnorm, d0, score_d8);
            if (TM>TMmax)
            {
                TMmax = TM;
                for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
                if (TMcut>0) copy_t_u(t, u, t0, u0);
            }
        }

        if (TMcut>0) // pre-terminate if TM-score is too low
        {
            double TMtmp=approx_TM(xlen, ylen, a_opt,
                xa, ya, t0, u0, invmap0, mol_type);

            if (TMtmp<0.56*TMcut)
            {
                TM1=TM2=TM3=TM4=TM5=TMtmp;
                clean_up_after_approx_TM(invmap0, invmap, score, path, val,
                    xtm, ytm, xt, r1, r2, xlen, minlen);
                return 5;
            }
        }

        /*******************************************************************/
        /*    get initial alignment based on fragment gapless threading    */
        /*******************************************************************/
        //=initial4 in original TM-align
        get_initial_fgt(r1, r2, xtm, ytm, xa, ya, xlen, ylen,
            invmap, d0, d0_search, dcu0, fast_opt, t, u);
        TM = detailed_search(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen, invmap,
            t, u, simplify_step, score_sum_method, local_d0_search, Lnorm,
            score_d8, d0);
        if (TM>TMmax)
        {
            TMmax = TM;
            for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
            if (TMcut>0) copy_t_u(t, u, t0, u0);
        }
        if (TM > TMmax*ddcc)
        {
            TM = DP_iter(r1, r2, xtm, ytm, xt, path, val, xa, ya,
                xlen, ylen, t, u, invmap, 1, 2, 2, local_d0_search, D0_MIN,
                Lnorm, d0, score_d8);
            if (TM>TMmax)
            {
                TMmax = TM;
                for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
                if (TMcut>0) copy_t_u(t, u, t0, u0);
            }
        }

        if (TMcut>0) // pre-terminate if TM-score is too low
        {
            double TMtmp=approx_TM(xlen, ylen, a_opt,
                xa, ya, t0, u0, invmap0, mol_type);

            if (TMtmp<0.58*TMcut)
            {
                TM1=TM2=TM3=TM4=TM5=TMtmp;
                clean_up_after_approx_TM(invmap0, invmap, score, path, val,
                    xtm, ytm, xt, r1, r2, xlen, minlen);
                return 6;
            }
        }

        //************************************************//
        //    get initial alignment from user's input:    //
        //************************************************//
        if (i_opt==1)// if input has set parameter for "-i"
        {
            for (int j = 0; j < ylen; j++)// Set aligned position to be "-1"
                invmap[j] = -1;

            int i1 = -1;// in C version, index starts from zero, not from one
            int i2 = -1;
            int L1 = sequence[0].size();
            int L2 = sequence[1].size();
            int L = min(L1, L2);// Get positions for aligned residues
            for (int kk1 = 0; kk1 < L; kk1++)
            {
                if (sequence[0][kk1] != '-')
                    i1++;
                if (sequence[1][kk1] != '-')
                {
                    i2++;
                    if (i2 >= ylen || i1 >= xlen) kk1 = L;
                    else if (sequence[0][kk1] != '-') invmap[i2] = i1;
                }
            }

            //--------------- 2. Align proteins from original alignment
            double prevD0_MIN = D0_MIN;// stored for later use
            int prevLnorm = Lnorm;
            double prevd0 = d0;
            TM_ali = standard_TMscore(r1, r2, xtm, ytm, xt, xa, ya,
                xlen, ylen, invmap, L_ali, rmsd_ali, D0_MIN, Lnorm, d0,
                d0_search, score_d8, t, u, mol_type);
            D0_MIN = prevD0_MIN;
            Lnorm = prevLnorm;
            d0 = prevd0;

            TM = detailed_search_standard(r1, r2, xtm, ytm, xt, xa, ya,
                xlen, ylen, invmap, t, u, 40, 8, local_d0_search, true, Lnorm,
                score_d8, d0);
            if (TM > TMmax)
            {
                TMmax = TM;
                for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
            }
            // Different from get_initial, get_initial_ss and get_initial_ssplus
            TM = DP_iter(r1, r2, xtm, ytm, xt, path, val, xa, ya,
                xlen, ylen, t, u, invmap, 0, 2, (fast_opt)?2:30,
                local_d0_search, D0_MIN, Lnorm, d0, score_d8);
            if (TM>TMmax)
            {
                TMmax = TM;
                for (i = 0; i<ylen; i++) invmap0[i] = invmap[i];
            }
        }
    }



    //*******************************************************************//
    //    The alignment will not be changed any more in the following    //
    //*******************************************************************//
    //check if the initial alignment is generated approriately
    bool flag=false;
    for(i=0; i<ylen; i++)
    {
        if(invmap0[i]>=0)
        {
            flag=true;
            break;
        }
    }
    if(!flag)
    {
        cout << "There is no alignment between the two proteins!" << endl;
        cout << "Program stop with no result!" << endl;
        return 1;
    }

    /* last TM-score pre-termination */
    if (TMcut>0)
    {
        double TMtmp=approx_TM(xlen, ylen, a_opt,
            xa, ya, t0, u0, invmap0, mol_type);

        if (TMtmp<0.6*TMcut)
        {
            TM1=TM2=TM3=TM4=TM5=TMtmp;
            clean_up_after_approx_TM(invmap0, invmap, score, path, val,
                xtm, ytm, xt, r1, r2, xlen, minlen);
            return 7;
        }
    }

    //********************************************************************//
    //    Detailed TMscore search engine --> prepare for final TMscore    //
    //********************************************************************//
    //run detailed TMscore search engine for the best alignment, and
    //extract the best rotation matrix (t, u) for the best alginment
    simplify_step=1;
    if (fast_opt) simplify_step=40;
    score_sum_method=8;
    TM = detailed_search_standard(r1, r2, xtm, ytm, xt, xa, ya, xlen, ylen,
        invmap0, t, u, simplify_step, score_sum_method, local_d0_search,
        false, Lnorm, score_d8, d0);

    //select pairs with dis<d8 for final TMscore computation and output alignment
    int k=0;
    int *m1, *m2;
    double d;
    m1=new int[xlen]; //alignd index in x
    m2=new int[ylen]; //alignd index in y
    do_rotation(xa, xt, xlen, t, u);
    k=0;
    for(int j=0; j<ylen; j++)
    {
        i=invmap0[j];
        if(i>=0)//aligned
        {
            n_ali++;
            d=sqrt(dist(&xt[i][0], &ya[j][0]));
            if (d <= score_d8 || (i_opt == 3))
            {
                m1[k]=i;
                m2[k]=j;

                xtm[k][0]=xa[i][0];
                xtm[k][1]=xa[i][1];
                xtm[k][2]=xa[i][2];

                ytm[k][0]=ya[j][0];
                ytm[k][1]=ya[j][1];
                ytm[k][2]=ya[j][2];

                r1[k][0] = xt[i][0];
                r1[k][1] = xt[i][1];
                r1[k][2] = xt[i][2];
                r2[k][0] = ya[j][0];
                r2[k][1] = ya[j][1];
                r2[k][2] = ya[j][2];

                k++;
            }
        }
    }
    n_ali8=k;

    Kabsch(r1, r2, n_ali8, 0, &rmsd0, t, u);// rmsd0 is used for final output, only recalculate rmsd0, not t & u
    rmsd0 = sqrt(rmsd0 / n_ali8);


    //****************************************//
    //              Final TMscore             //
    //    Please set parameters for output    //
    //****************************************//
    double rmsd;
    simplify_step=1;
    score_sum_method=0;
    double Lnorm_0=ylen;


    //normalized by length of structure A
    parameter_set4final(Lnorm_0, D0_MIN, Lnorm, d0, d0_search, mol_type);
    d0A=d0;
    d0_0=d0A;
    local_d0_search = d0_search;
    TM1 = TMscore8_search(r1, r2, xtm, ytm, xt, n_ali8, t0, u0, simplify_step,
        score_sum_method, &rmsd, local_d0_search, Lnorm, score_d8, d0);
    TM_0 = TM1;

    //normalized by length of structure B
    parameter_set4final(xlen+0.0, D0_MIN, Lnorm, d0, d0_search, mol_type);
    d0B=d0;
    local_d0_search = d0_search;
    TM2 = TMscore8_search(r1, r2, xtm, ytm, xt, n_ali8, t, u, simplify_step,
        score_sum_method, &rmsd, local_d0_search, Lnorm, score_d8, d0);

    double Lnorm_d0;
    if (a_opt>0)
    {
        //normalized by average length of structures A, B
        Lnorm_0=(xlen+ylen)*0.5;
        parameter_set4final(Lnorm_0, D0_MIN, Lnorm, d0, d0_search, mol_type);
        d0a=d0;
        d0_0=d0a;
        local_d0_search = d0_search;

        TM3 = TMscore8_search(r1, r2, xtm, ytm, xt, n_ali8, t0, u0,
            simplify_step, score_sum_method, &rmsd, local_d0_search, Lnorm,
            score_d8, d0);
        TM_0=TM3;
    }
    if (u_opt)
    {
        //normalized by user assigned length
        parameter_set4final(Lnorm_ass, D0_MIN, Lnorm,
            d0, d0_search, mol_type);
        d0u=d0;
        d0_0=d0u;
        Lnorm_0=Lnorm_ass;
        local_d0_search = d0_search;
        TM4 = TMscore8_search(r1, r2, xtm, ytm, xt, n_ali8, t0, u0,
            simplify_step, score_sum_method, &rmsd, local_d0_search, Lnorm,
            score_d8, d0);
        TM_0=TM4;
    }
    if (d_opt)
    {
        //scaled by user assigned d0
        parameter_set4scale(ylen, d0_scale, Lnorm, d0, d0_search);
        d0_out=d0_scale;
        d0_0=d0_scale;
        //Lnorm_0=ylen;
        Lnorm_d0=Lnorm_0;
        local_d0_search = d0_search;
        TM5 = TMscore8_search(r1, r2, xtm, ytm, xt, n_ali8, t0, u0,
            simplify_step, score_sum_method, &rmsd, local_d0_search, Lnorm,
            score_d8, d0);
        TM_0=TM5;
    }

    /* derive alignment from superposition */
    int ali_len=xlen+ylen; //maximum length of alignment
    seqxA.assign(ali_len,'-');
    seqM.assign( ali_len,' ');
    seqyA.assign(ali_len,'-');
    
    //do_rotation(xa, xt, xlen, t, u);
    do_rotation(xa, xt, xlen, t0, u0);

    int kk=0, i_old=0, j_old=0;
    d=0;
    for(int k=0; k<n_ali8; k++)
    {
        for(int i=i_old; i<m1[k]; i++)
        {
            //align x to gap
            seqxA[kk]=seqx[i];
            seqyA[kk]='-';
            seqM[kk]=' ';                    
            kk++;
        }

        for(int j=j_old; j<m2[k]; j++)
        {
            //align y to gap
            seqxA[kk]='-';
            seqyA[kk]=seqy[j];
            seqM[kk]=' ';
            kk++;
        }

        seqxA[kk]=seqx[m1[k]];
        seqyA[kk]=seqy[m2[k]];
        Liden+=(seqxA[kk]==seqyA[kk]);
        d=sqrt(dist(&xt[m1[k]][0], &ya[m2[k]][0]));
        if(d<d0_out) seqM[kk]=':';
        else         seqM[kk]='.';
        kk++;  
        i_old=m1[k]+1;
        j_old=m2[k]+1;
    }

    //tail
    for(int i=i_old; i<xlen; i++)
    {
        //align x to gap
        seqxA[kk]=seqx[i];
        seqyA[kk]='-';
        seqM[kk]=' ';
        kk++;
    }    
    for(int j=j_old; j<ylen; j++)
    {
        //align y to gap
        seqxA[kk]='-';
        seqyA[kk]=seqy[j];
        seqM[kk]=' ';
        kk++;
    }
    seqxA=seqxA.substr(0,kk);
    seqyA=seqyA.substr(0,kk);
    seqM =seqM.substr(0,kk);

    /* free memory */
    clean_up_after_approx_TM(invmap0, invmap, score, path, val,
        xtm, ytm, xt, r1, r2, xlen, minlen);
    delete [] m1;
    delete [] m2;
    return 0; // zero for no exception
}

/* entry function for TM-align with circular permutation
 * i_opt, a_opt, u_opt, d_opt, TMcut are not implemented yet */
int CPalign_main(double **xa, double **ya,
    const char *seqx, const char *seqy, const char *secx, const char *secy,
    double t0[3], double u0[3][3],
    double &TM1, double &TM2, double &TM3, double &TM4, double &TM5,
    double &d0_0, double &TM_0,
    double &d0A, double &d0B, double &d0u, double &d0a, double &d0_out,
    string &seqM, string &seqxA, string &seqyA,
    double &rmsd0, int &L_ali, double &Liden,
    double &TM_ali, double &rmsd_ali, int &n_ali, int &n_ali8,
    const int xlen, const int ylen,
    const vector<string> sequence, const double Lnorm_ass,
    const double d0_scale, const int i_opt, const int a_opt,
    const bool u_opt, const bool d_opt, const bool fast_opt,
    const int mol_type, const double TMcut=-1)
{
    char   *seqx_cp, *seqy_cp; // for the protein sequence 
    char   *secx_cp, *secy_cp; // for the secondary structure 
    double **xa_cp, **ya_cp;   // coordinates
    string seqxA_cp,seqyA_cp;  // alignment
    int    i,r;
    int    cp_point=0;    // position of circular permutation
    int    cp_aln_best=0; // amount of aligned residue in sliding window
    int    cp_aln_current;// amount of aligned residue in sliding window

    /* duplicate structure */
    NewArray(&xa_cp, xlen*2, 3);
    seqx_cp = new char[xlen*2 + 1];
    secx_cp = new char[xlen*2 + 1];
    for (r=0;r<xlen;r++)
    {
        xa_cp[r+xlen][0]=xa_cp[r][0]=xa[r][0];
        xa_cp[r+xlen][1]=xa_cp[r][1]=xa[r][1];
        xa_cp[r+xlen][2]=xa_cp[r][2]=xa[r][2];
        seqx_cp[r+xlen]=seqx_cp[r]=seqx[r];
        secx_cp[r+xlen]=secx_cp[r]=secx[r];
    }
    seqx_cp[2*xlen]=0;
    secx_cp[2*xlen]=0;
    
    /* fTM-align alignment */
    double TM1_cp,TM2_cp;
    TMalign_main(xa_cp, ya, seqx_cp, seqy, secx_cp, secy,
        t0, u0, TM1_cp, TM2_cp, TM3, TM4, TM5,
        d0_0, TM_0, d0A, d0B, d0u, d0a, d0_out, seqM, seqxA_cp, seqyA_cp,
        rmsd0, L_ali, Liden, TM_ali, rmsd_ali, n_ali, n_ali8,
        xlen*2, ylen, sequence, Lnorm_ass, d0_scale,
        0, false, false, false, true, mol_type, -1);

    /* delete gap in seqxA_cp */
    r=0;
    seqxA=seqxA_cp;
    seqyA=seqyA_cp;
    for (i=0;i<seqxA_cp.size();i++)
    {
        if (seqxA_cp[i]!='-')
        {
            seqxA[r]=seqxA_cp[i];
            seqyA[r]=seqyA_cp[i];
            r++;
        }
    }
    seqxA=seqxA.substr(0,r);
    seqyA=seqyA.substr(0,r);

    /* count the number of aligned residues in each window
     * r - residue index in the original unaligned sequence 
     * i - position in the alignment */
    for (r=0;r<xlen-1;r++)
    {
        cp_aln_current=0;
        for (i=r;i<r+xlen;i++) cp_aln_current+=(seqyA[i]!='-');

        if (cp_aln_current>cp_aln_best)
        {
            cp_aln_best=cp_aln_current;
            cp_point=r;
        }
    }
    seqM.clear();
    seqxA.clear();
    seqyA.clear();
    seqxA_cp.clear();
    seqyA_cp.clear();
    rmsd0=Liden=n_ali=n_ali8=0;

    /* fTM-align alignment */
    TMalign_main(xa, ya, seqx, seqy, secx, secy,
        t0, u0, TM1, TM2, TM3, TM4, TM5,
        d0_0, TM_0, d0A, d0B, d0u, d0a, d0_out, seqM, seqxA, seqyA,
        rmsd0, L_ali, Liden, TM_ali, rmsd_ali, n_ali, n_ali8,
        xlen, ylen, sequence, Lnorm_ass, d0_scale,
        0, false, false, false, true, mol_type, -1);

    /* do not use cricular permutation of number of aligned residues is not
     * larger than sequence-order dependent alignment */
    if (n_ali8>cp_aln_best) cp_point=0;

    /* prepare structure for final alignment */
    seqM.clear();
    seqxA.clear();
    seqyA.clear();
    rmsd0=Liden=n_ali=n_ali8=0;
    if (cp_point!=0)
    {
        for (r=0;r<xlen;r++)
        {
            xa_cp[r][0]=xa_cp[r+cp_point][0];
            xa_cp[r][1]=xa_cp[r+cp_point][1];
            xa_cp[r][2]=xa_cp[r+cp_point][2];
            seqx_cp[r]=seqx_cp[r+cp_point];
            secx_cp[r]=secx_cp[r+cp_point];
        }
    }
    seqx_cp[xlen]=0;
    secx_cp[xlen]=0;

    /* full TM-align */
    TMalign_main(xa_cp, ya, seqx_cp, seqy, secx_cp, secy,
        t0, u0, TM1, TM2, TM3, TM4, TM5,
        d0_0, TM_0, d0A, d0B, d0u, d0a, d0_out, seqM, seqxA_cp, seqyA_cp,
        rmsd0, L_ali, Liden, TM_ali, rmsd_ali, n_ali, n_ali8,
        xlen, ylen, sequence, Lnorm_ass, d0_scale,
        i_opt, a_opt, u_opt, d_opt, fast_opt, mol_type, TMcut);

    /* correct alignment
     * r - residue index in the original unaligned sequence 
     * i - position in the alignment */
    if (cp_point>0)
    {
        r=0;
        for (i=0;i<seqxA_cp.size();i++)
        {
            r+=(seqxA_cp[i]!='-');
            if (r>=(xlen-cp_point)) 
            {
                i++;
                break;
            }
        }
        seqxA=seqxA_cp.substr(0,i)+'*'+seqxA_cp.substr(i);
        seqM =seqM.substr(0,i)    +' '+seqM.substr(i);
        seqyA=seqyA_cp.substr(0,i)+'-'+seqyA_cp.substr(i);
    }
    else
    {
        seqxA=seqxA_cp;
        seqyA=seqyA_cp;
    }

    /* clean up */
    delete[]seqx_cp;
    delete[]secx_cp;
    DeleteArray(&xa_cp,xlen*2);
    seqxA_cp.clear();
    seqyA_cp.clear();
    return cp_point;
}

int main(int argc, char *argv[])
{
    if (argc < 2) print_help();


    clock_t t1, t2;
    t1 = clock();

    /**********************/
    /*    get argument    */
    /**********************/
    string xname       = "";
    string yname       = "";
    string fname_super = ""; // file name for superposed structure
    string fname_lign  = ""; // file name for user alignment
    string fname_matrix= ""; // file name for output matrix
    vector<string> sequence; // get value from alignment file
    double Lnorm_ass, d0_scale;

    bool h_opt = false; // print full help message
    bool v_opt = false; // print version
    bool m_opt = false; // flag for -m, output rotation matrix
    int  i_opt = 0;     // 1 for -i, 3 for -I
    bool o_opt = false; // flag for -o, output superposed structure
    int  a_opt = 0;     // flag for -a, do not normalized by average length
    bool u_opt = false; // flag for -u, normalized by user specified length
    bool d_opt = false; // flag for -d, user specified d0

    double TMcut     =-1;
    int    infmt1_opt=-1;    // PDB or PDBx/mmCIF format for chain_1
    int    infmt2_opt=-1;    // PDB or PDBx/mmCIF format for chain_2
    int    ter_opt   =3;     // TER, END, or different chainID
    int    split_opt =0;     // do not split chain
    int    outfmt_opt=0;     // set -outfmt to full output
    bool   fast_opt  =false; // flags for -fast, fTM-align algorithm
    int    cp_opt    =0;     // do not check circular permutation
    int    mirror_opt=0;     // do not align mirror
    int    het_opt=0;        // do not read HETATM residues
    string atom_opt  ="auto";// use C alpha atom for protein and C3' for RNA
    string mol_opt   ="auto";// auto-detect the molecule type as protein/RNA
    string suffix_opt="";    // set -suffix to empty
    string dir_opt   ="";    // set -dir to empty
    string dir1_opt  ="";    // set -dir1 to empty
    string dir2_opt  ="";    // set -dir2 to empty
    int    byresi_opt=0;     // set -byresi to 0
    vector<string> chain1_list; // only when -dir1 is set
    vector<string> chain2_list; // only when -dir2 is set

    for(int i = 1; i < argc; i++)
    {
        if ( !strcmp(argv[i],"-o") && i < (argc-1) )
        {
            fname_super = argv[i + 1];     o_opt = true; i++;
        }
        else if ( (!strcmp(argv[i],"-u") || 
                   !strcmp(argv[i],"-L")) && i < (argc-1) )
        {
            Lnorm_ass = atof(argv[i + 1]); u_opt = true; i++;
        }
        else if ( !strcmp(argv[i],"-a") && i < (argc-1) )
        {
            if (!strcmp(argv[i + 1], "T"))      a_opt=true;
            else if (!strcmp(argv[i + 1], "F")) a_opt=false;
            else 
            {
                a_opt=atoi(argv[i + 1]);
                if (a_opt!=-2 && a_opt!=-1 && a_opt!=1)
                    PrintErrorAndQuit("-a must be -2, -1, 1, T or F");
            }
            i++;
        }
        else if ( !strcmp(argv[i],"-d") && i < (argc-1) )
        {
            d0_scale = atof(argv[i + 1]); d_opt = true; i++;
        }
        else if ( !strcmp(argv[i],"-v") )
        {
            v_opt = true;
        }
        else if ( !strcmp(argv[i],"-h") )
        {
            h_opt = true;
        }
        else if ( !strcmp(argv[i],"-i") && i < (argc-1) )
        {
            if (i_opt==3)
                PrintErrorAndQuit("ERROR! -i and -I cannot be used together");
            fname_lign = argv[i + 1];      i_opt = 1; i++;
        }
        else if (!strcmp(argv[i], "-I") && i < (argc-1) )
        {
            if (i_opt==1)
                PrintErrorAndQuit("ERROR! -I and -i cannot be used together");
            fname_lign = argv[i + 1];      i_opt = 3; i++;
        }
        else if (!strcmp(argv[i], "-m") && i < (argc-1) )
        {
            fname_matrix = argv[i + 1];    m_opt = true; i++;
        }// get filename for rotation matrix
        else if (!strcmp(argv[i], "-fast"))
        {
            fast_opt = true;
        }
        else if ( !strcmp(argv[i],"-infmt1") && i < (argc-1) )
        {
            infmt1_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-infmt2") && i < (argc-1) )
        {
            infmt2_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-ter") && i < (argc-1) )
        {
            ter_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-split") && i < (argc-1) )
        {
            split_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-atom") && i < (argc-1) )
        {
            atom_opt=argv[i + 1]; i++;
        }
        else if ( !strcmp(argv[i],"-mol") && i < (argc-1) )
        {
            mol_opt=argv[i + 1]; i++;
        }
        else if ( !strcmp(argv[i],"-dir") && i < (argc-1) )
        {
            dir_opt=argv[i + 1]; i++;
        }
        else if ( !strcmp(argv[i],"-dir1") && i < (argc-1) )
        {
            dir1_opt=argv[i + 1]; i++;
        }
        else if ( !strcmp(argv[i],"-dir2") && i < (argc-1) )
        {
            dir2_opt=argv[i + 1]; i++;
        }
        else if ( !strcmp(argv[i],"-suffix") && i < (argc-1) )
        {
            suffix_opt=argv[i + 1]; i++;
        }
        else if ( !strcmp(argv[i],"-outfmt") && i < (argc-1) )
        {
            outfmt_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-TMcut") && i < (argc-1) )
        {
            TMcut=atof(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-byresi") && i < (argc-1) )
        {
            byresi_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-cp") )
        {
            cp_opt=1;
        }
        else if ( !strcmp(argv[i],"-mirror") && i < (argc-1) )
        {
            mirror_opt=atoi(argv[i + 1]); i++;
        }
        else if ( !strcmp(argv[i],"-het") && i < (argc-1) )
        {
            het_opt=atoi(argv[i + 1]); i++;
        }
        else if (xname.size() == 0) xname=argv[i];
        else if (yname.size() == 0) yname=argv[i];
        else PrintErrorAndQuit(string("ERROR! Undefined option ")+argv[i]);
    }

    if(xname.size()==0 || (yname.size()==0 && dir_opt.size()==0) || 
                          (yname.size()    && dir_opt.size()))
    {
        if (h_opt) print_help(h_opt);
        if (v_opt)
        {
            print_version();
            exit(EXIT_FAILURE);
        }
        if (xname.size()==0)
            PrintErrorAndQuit("Please provide input structures");
        else if (yname.size()==0 && dir_opt.size()==0)
            PrintErrorAndQuit("Please provide structure B");
        else if (yname.size() && dir_opt.size())
            PrintErrorAndQuit("Please provide only one file name if -dir is set");
    }

    if (suffix_opt.size() && dir_opt.size()+dir1_opt.size()+dir2_opt.size()==0)
        PrintErrorAndQuit("-suffix is only valid if -dir, -dir1 or -dir2 is set");
    if ((dir_opt.size() || dir1_opt.size() || dir2_opt.size()))
    {
        if (m_opt || o_opt)
            PrintErrorAndQuit("-m or -o cannot be set with -dir, -dir1 or -dir2");
        else if (dir_opt.size() && (dir1_opt.size() || dir2_opt.size()))
            PrintErrorAndQuit("-dir cannot be set with -dir1 or -dir2");
    }
    if (atom_opt.size()!=4)
        PrintErrorAndQuit("ERROR! atom name must have 4 characters, including space.");
    if (mol_opt!="auto" && mol_opt!="protein" && mol_opt!="RNA")
        PrintErrorAndQuit("ERROR! molecule type must be either RNA or protein.");
    else if (mol_opt=="protein" && atom_opt=="auto")
        atom_opt=" CA ";
    else if (mol_opt=="RNA" && atom_opt=="auto")
        atom_opt=" C3'";

    if (u_opt && Lnorm_ass<=0)
        PrintErrorAndQuit("Wrong value for option -u!  It should be >0");
    if (d_opt && d0_scale<=0)
        PrintErrorAndQuit("Wrong value for option -d!  It should be >0");
    if (outfmt_opt>=2 && (a_opt || u_opt || d_opt))
        PrintErrorAndQuit("-outfmt 2 cannot be used with -a, -u, -L, -d");
    if (byresi_opt!=0)
    {
        if (i_opt)
            PrintErrorAndQuit("-byresi >=1 cannot be used with -i or -I");
        if (byresi_opt<0 || byresi_opt>3)
            PrintErrorAndQuit("-byresi can only be 0, 1, 2 or 3");
        if (byresi_opt>=2 && ter_opt>=2)
            PrintErrorAndQuit("-byresi >=2 should be used with -ter <=1");
    }
    if (split_opt==1 && ter_opt!=0)
        PrintErrorAndQuit("-split 1 should be used with -ter 0");
    else if (split_opt==2 && ter_opt!=0 && ter_opt!=1)
        PrintErrorAndQuit("-split 2 should be used with -ter 0 or 1");
    if (split_opt<0 || split_opt>2)
        PrintErrorAndQuit("-split can only be 0, 1 or 2");
    if (cp_opt!=0 && cp_opt!=1)
        PrintErrorAndQuit("-cp can only be 0 or 1");
    if (cp_opt && i_opt)
        PrintErrorAndQuit("-cp cannot be used with -i or -I");

    /* read initial alignment file from 'align.txt' */
    if (i_opt) read_user_alignment(sequence, fname_lign, i_opt);

    if (byresi_opt) i_opt=3;

    if (m_opt && fname_matrix == "") // Output rotation matrix: matrix.txt
        PrintErrorAndQuit("ERROR! Please provide a file name for option -m!");

    /* parse file list */
    if (dir1_opt.size()+dir_opt.size()==0) chain1_list.push_back(xname);
    else file2chainlist(chain1_list, xname, dir_opt+dir1_opt, suffix_opt);

    if (dir_opt.size())
        for (int i=0;i<chain1_list.size();i++)
            chain2_list.push_back(chain1_list[i]);
    else if (dir2_opt.size()==0) chain2_list.push_back(yname);
    else file2chainlist(chain2_list, yname, dir2_opt, suffix_opt);

    if (outfmt_opt==2)
        cout<<"#PDBchain1\tPDBchain2\tTM1\tTM2\t"
            <<"RMSD\tID1\tID2\tIDali\tL1\tL2\tLali"<<endl;

    /* declare previously global variables */
    vector<vector<string> >PDB_lines1; // text of chain1
    vector<vector<string> >PDB_lines2; // text of chain2
    vector<int> mol_vec1;              // molecule type of chain1, RNA if >0
    vector<int> mol_vec2;              // molecule type of chain2, RNA if >0
    vector<string> chainID_list1;      // list of chainID1
    vector<string> chainID_list2;      // list of chainID2
    int    i,j;                // file index
    int    chain_i,chain_j;    // chain index
    int    r;                  // residue index
    int    xlen, ylen;         // chain length
    int    xchainnum,ychainnum;// number of chains in a PDB file
    char   *seqx, *seqy;       // for the protein sequence 
    char   *secx, *secy;       // for the secondary structure 
    double **xa, **ya;         // for input vectors xa[0...xlen-1][0..2] and
                               // ya[0...ylen-1][0..2], in general,
                               // ya is regarded as native structure 
                               // --> superpose xa onto ya
    vector<string> resi_vec1;  // residue index for chain1
    vector<string> resi_vec2;  // residue index for chain2

    /* loop over file names */
    for (i=0;i<chain1_list.size();i++)
    {
        /* parse chain 1 */
        xname=chain1_list[i];
        xchainnum=get_PDB_lines(xname, PDB_lines1, chainID_list1,
            mol_vec1, ter_opt, infmt1_opt, atom_opt, split_opt, het_opt);
        if (!xchainnum)
        {
            cerr<<"Warning! Cannot parse file: "<<xname
                <<". Chain number 0."<<endl;
            continue;
        }
        for (chain_i=0;chain_i<xchainnum;chain_i++)
        {
            xlen=PDB_lines1[chain_i].size();
            mol_vec1[chain_i]=-1;
            if (!xlen)
            {
                cerr<<"Warning! Cannot parse file: "<<xname
                    <<". Chain length 0."<<endl;
                continue;
            }
            else if (xlen<3)
            {
                cerr<<"Sequence is too short <3!: "<<xname<<endl;
                continue;
            }
            NewArray(&xa, xlen, 3);
            seqx = new char[xlen + 1];
            secx = new char[xlen + 1];
            xlen = read_PDB(PDB_lines1[chain_i], xa, seqx, 
                resi_vec1, byresi_opt?byresi_opt:o_opt);
            if (mirror_opt) for (r=0;r<xlen;r++) xa[r][2]=-xa[r][2];
            make_sec(xa, xlen, secx); // secondary structure assignment

            for (j=(dir_opt.size()>0)*(i+1);j<chain2_list.size();j++)
            {
                /* parse chain 2 */
                if (PDB_lines2.size()==0)
                {
                    yname=chain2_list[j];
                    ychainnum=get_PDB_lines(yname, PDB_lines2, chainID_list2,
                        mol_vec2, ter_opt, infmt2_opt, atom_opt, split_opt,
                        het_opt);
                    if (!ychainnum)
                    {
                        cerr<<"Warning! Cannot parse file: "<<yname
                            <<". Chain number 0."<<endl;
                        continue;
                    }
                }
                for (chain_j=0;chain_j<ychainnum;chain_j++)
                {
                    ylen=PDB_lines2[chain_j].size();
                    mol_vec2[chain_j]=-1;
                    if (!ylen)
                    {
                        cerr<<"Warning! Cannot parse file: "<<yname
                            <<". Chain length 0."<<endl;
                        continue;
                    }
                    else if (ylen<3)
                    {
                        cerr<<"Sequence is too short <3!: "<<yname<<endl;
                        continue;
                    }
                    NewArray(&ya, ylen, 3);
                    seqy = new char[ylen + 1];
                    secy = new char[ylen + 1];
                    ylen = read_PDB(PDB_lines2[chain_j], ya, seqy,
                        resi_vec2, byresi_opt?byresi_opt:o_opt);
                    make_sec(ya, ylen, secy);
                    if (byresi_opt) extract_aln_from_resi(sequence,
                        seqx,seqy,resi_vec1,resi_vec2,byresi_opt);

                    /* declare variable specific to this pair of TMalign */
                    double t0[3], u0[3][3];
                    double TM1, TM2;
                    double TM3, TM4, TM5;     // for a_opt, u_opt, d_opt
                    double d0_0, TM_0;
                    double d0A, d0B, d0u, d0a;
                    double d0_out=5.0;
                    string seqM, seqxA, seqyA;// for output alignment
                    double rmsd0 = 0.0;
                    int L_ali;                // Aligned length in standard_TMscore
                    double Liden=0;
                    double TM_ali, rmsd_ali;  // TMscore and rmsd in standard_TMscore
                    int n_ali=0;
                    int n_ali8=0;

                    /* entry function for structure alignment */
                    if (cp_opt) CPalign_main(
                        xa, ya, seqx, seqy, secx, secy,
                        t0, u0, TM1, TM2, TM3, TM4, TM5,
                        d0_0, TM_0, d0A, d0B, d0u, d0a, d0_out,
                        seqM, seqxA, seqyA,
                        rmsd0, L_ali, Liden, TM_ali, rmsd_ali, n_ali, n_ali8,
                        xlen, ylen, sequence, Lnorm_ass, d0_scale,
                        i_opt, a_opt, u_opt, d_opt, fast_opt,
                        mol_vec1[chain_i]+mol_vec2[chain_j],TMcut);
                    else TMalign_main(
                        xa, ya, seqx, seqy, secx, secy,
                        t0, u0, TM1, TM2, TM3, TM4, TM5,
                        d0_0, TM_0, d0A, d0B, d0u, d0a, d0_out,
                        seqM, seqxA, seqyA,
                        rmsd0, L_ali, Liden, TM_ali, rmsd_ali, n_ali, n_ali8,
                        xlen, ylen, sequence, Lnorm_ass, d0_scale,
                        i_opt, a_opt, u_opt, d_opt, fast_opt,
                        mol_vec1[chain_i]+mol_vec2[chain_j],TMcut);

                    /* print result */
                    if (outfmt_opt==0) print_version();
                    output_results(
                        xname.substr(dir1_opt.size()),
                        yname.substr(dir2_opt.size()),
                        chainID_list1[chain_i].c_str(),
                        chainID_list2[chain_j].c_str(),
                        xlen, ylen, t0, u0, TM1, TM2, 
                        TM3, TM4, TM5, rmsd0, d0_out,
                        seqM.c_str(), seqxA.c_str(), seqyA.c_str(), Liden,
                        n_ali8, L_ali, TM_ali, rmsd_ali,
                        TM_0, d0_0, d0A, d0B,
                        Lnorm_ass, d0_scale, d0a, d0u, 
                        (m_opt?fname_matrix+chainID_list1[chain_i]:"").c_str(),
                        outfmt_opt, ter_opt, 
                        (o_opt?fname_super+chainID_list1[chain_i]:"").c_str(),
                        i_opt, a_opt, u_opt, d_opt,mirror_opt,
                        resi_vec1,resi_vec2);

                    /* Done! Free memory */
                    seqM.clear();
                    seqxA.clear();
                    seqyA.clear();
                    DeleteArray(&ya, ylen);
                    delete [] seqy;
                    delete [] secy;
                    resi_vec2.clear();
                } // chain_j
                if (chain2_list.size()>1)
                {
                    yname.clear();
                    for (chain_j=0;chain_j<ychainnum;chain_j++)
                        PDB_lines2[chain_j].clear();
                    PDB_lines2.clear();
                    chainID_list2.clear();
                    mol_vec2.clear();
                }
            } // j
            PDB_lines1[chain_i].clear();
            DeleteArray(&xa, xlen);
            delete [] seqx;
            delete [] secx;
            resi_vec1.clear();
        } // chain_i
        xname.clear();
        PDB_lines1.clear();
        chainID_list1.clear();
        mol_vec1.clear();
    } // i
    if (chain2_list.size()==1)
    {
        yname.clear();
        for (chain_j=0;chain_j<ychainnum;chain_j++)
            PDB_lines2[chain_j].clear();
        PDB_lines2.clear();
        resi_vec2.clear();
        chainID_list2.clear();
        mol_vec2.clear();
    }
    chain1_list.clear();
    chain2_list.clear();
    sequence.clear();

    t2 = clock();
    float diff = ((float)t2 - (float)t1)/CLOCKS_PER_SEC;
    printf("Total CPU time is %5.2f seconds\n", diff);
    return 0;
}
