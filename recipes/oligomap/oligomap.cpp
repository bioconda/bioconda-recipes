#include <iostream>
#include <string>
#include <map>
#include <fstream>
#include <list>
#include <vector>
#include <dirent.h>

using std::ifstream;
using std::ofstream;
using std::string;
using std::cout;
using std::cerr;
using std::map;
using std::list;
using std::vector;

// oligomap: mapping a large number of small sequences to the genome
//
// Finds perfect and 1 mismatch alignments. Optimal performance is achieved 
// at about 500000 query sequences.(2GB of memory)
//
// Author: Dimos Gaidatzis
//
// techinal details:
// - only Q mismatch sequences are inserted. Only T turtles divide
// - Output redundancy removed. no multiple hits at the same locus for a sequence with 
//   either the same genomic start or end coordinate
// - queries can only contain nucleotides ACGT/U and at most one N.
// - queries need to be shorter or equal to 124nt 
// - targets can contain any character (non regular nucleotides are treated as Ns)


#define maxChrLineLength 1000 // maximal length of one line in the targets file
#define maxSeqLength 127      // maximal length of a query sequence
#define maxTurtles 20000      // maximal number of turtles

//----------------------------------------------------------------------------------------
// all the datastructures

struct Opts{
  bool targetDir; //  0: take single target file as input   1: read all fasta files in directory (.fa)
  bool bothStr;   //  0: only plus strand, 1: both strands (default)
  int maxHits;    //  maximum hits per seq. (maxAln P and maxAln M)
  string hitReport;// creates an output file with the number of hits for each seq. "": none
};

struct TreeNode{
  unsigned int id;
  TreeNode *nextNuc[4]; // 4 pointers to A C G T
};

struct Turtle{
  int alnFrom;     // start coordinate of the alignment (genomic coord)
  int cloneCoord;  // coordinate in the clone
  char gapMode;    // P:Perfect, Q:Bulge on the Query, T:Bulge on the Target, L:Loop
  char skippedNuc; // nucleotide in the genome that is skipped by turtle -1 for anything but ACGT (0,1,2,3)
  Turtle *left;    // left pointer to build double linked list
  Turtle *right;   // right pointer to build double linked list
  TreeNode *tn;    // current turtle position in the tree
};

struct TurtleQ{
  Turtle *head;
  Turtle *tail;
  Turtle *iter;
  Turtle *lastPerfectTurtle; // left most perfect turtle in the queue
  int turtlesInQ;
};


struct SeqInfo{
  string seqName; // name of the sequence
  int pHits;      // number of perfect hits
  int mHits;      // number of mismatch hits
};

// map of vector to keep track of multiple insertion tree events
typedef map<unsigned int,  vector<unsigned int> > MOV;

// stores information to remove redundancy for alignments that start at the same genomic position.
typedef map<unsigned int, unsigned int> STRE;

// this struct is used to code 3 variables into one unsigned int with word size 4
// 1 bit strand
// 7 bit mismatch position
// 24bit sequence id
typedef union bitfield
{
  unsigned int id;
  struct 
  {
    unsigned  int seqId : 24; // identifier
    unsigned  int mpos : 7;  // mismatch position
    unsigned  int strand : 1;	// strand
  } fields;
}; 

//----------------------------------------------------------------------------------------

// functions used for the turtle queue
// Queue iterator goes through the elements from head to tail
// P turtles are always inserted at the head which T turtles are inserted at the tail
// tail <-> head
// left <-> right
// the empty queue has one dummy turtle in it to which head and tail point
//
// initTurtleQ
// resetIterInQ
// iterGetNextTurtleFromQ
// getHeadTurtleFromQ
// addTurtleToQHead
// addTurtleToQTail
// removeTurtleFromQ
// insertTurtlesIntoQ
// activateTurtleFromRepositoryHead
// activateTurtleFromRepositoryTail
// moveAllTurtlesToRepository

void initTurtleQ(TurtleQ& tQ){
  // create a dummy turtle that represents the empty cueue
  Turtle *dummyTurtle=new Turtle();
  tQ.head=dummyTurtle;
  tQ.tail=dummyTurtle;
  tQ.turtlesInQ=0;
  tQ.iter=tQ.tail;
  tQ.lastPerfectTurtle=NULL;
}

void resetIterInQ(TurtleQ& tQ){
  tQ.iter=tQ.head;
}

// returns NULL if there is no element anymore
Turtle * iterGetNextTurtleFromQ(TurtleQ& tQ){
  Turtle *turtle=tQ.iter;

  if(turtle != tQ.tail){
    tQ.iter=tQ.iter->left;
    return turtle;
  }else{
    return NULL;
  }

}

Turtle * getHeadTurtleFromQ(TurtleQ& tQ){
  return tQ.head;
}

void addTurtleToQHead(TurtleQ& tQ,Turtle *turtle){
  tQ.head->right=turtle;  // attach the new turtle at the head (right)
  turtle->right=NULL;     // set right pointer of the head to NULL
  turtle->left=tQ.head;   // set left backpointer
  tQ.head=turtle;         // move the head pointer
  tQ.turtlesInQ++;        // increment the number of elements in queue
}

void addTurtleToQTail(TurtleQ& tQ,Turtle *turtle){
  if(tQ.turtlesInQ == 0){
    tQ.tail->right=turtle;
    turtle->left=tQ.tail;
    turtle->right=NULL;
    tQ.head=turtle;
    tQ.turtlesInQ++;
  }else{
    tQ.tail->right->left=turtle;
    turtle->right=tQ.tail->right;
    tQ.tail->right=turtle;
    turtle->left=tQ.tail;
    tQ.turtlesInQ++;
  }
}


void addTurtleToQMiddle(TurtleQ& tQ,Turtle *turtle){
  
  if((tQ.turtlesInQ != 0) and (tQ.lastPerfectTurtle != NULL)){

    turtle->left=tQ.lastPerfectTurtle->left;
    turtle->right=tQ.lastPerfectTurtle;
    tQ.lastPerfectTurtle->left->right=turtle;
    tQ.lastPerfectTurtle->left=turtle;
    tQ.lastPerfectTurtle=turtle;
    tQ.turtlesInQ++;
  }else{
    addTurtleToQHead(tQ,turtle);
    tQ.lastPerfectTurtle=tQ.head;
  }
}


void removeTurtleFromQ(TurtleQ& tQ,Turtle *turtle){
  // removing is everywhere the same except if the turtle is the head
  // !! you have to pass a turtle that really is in the queue !!

  if(tQ.turtlesInQ == 0){cerr << "Error 001: No More Turtles in repository\n";exit(0);}

  if(turtle->right != NULL){
    // removing internal turtle
    turtle->left->right=turtle->right; // looping out turtle from left to right
    turtle->right->left=turtle->left;  // looping out turtle from right to left
    if (tQ.iter==turtle){tQ.iter=turtle->left;} // if the iterator is pointing to the turtle that has to be removed
    if (tQ.lastPerfectTurtle==turtle){tQ.lastPerfectTurtle=turtle->right;} // reset left most perfect turtle pointer
    turtle->left=NULL;     // set the left arm of the removed turtle to NULL
    turtle->right=NULL;    // set the right arm of the removed turtle to NULL
  }else{
    // removing turtle at the head
    tQ.head=turtle->left;  // move the head pointer to the left
    tQ.head->right=NULL;   // mark the end of the queue
    tQ.iter=tQ.head;
    if (tQ.iter==turtle){tQ.iter=tQ.head;}
    if (tQ.lastPerfectTurtle==turtle){tQ.lastPerfectTurtle=NULL;} // no perfect turtle anymore
    turtle->left=NULL;     // set the left arm of the removed turtle to NULL
    turtle->right=NULL;    // set the right arm of the removed turtle to NULL
  }
  tQ.turtlesInQ--;        // reduce the number of elements in queue
}


void insertTurtlesIntoQ(TurtleQ& tQ,int n){
  for(int i=0;i<n;i++){
    Turtle *turtle=new Turtle();  // create new turtle
    turtle->tn=NULL;              // fill a field of the new turtle
    addTurtleToQHead(tQ,turtle);      // add the turtle to the queue
  }
}

// call this functio at the end of the target traversal to release the memory that the turtles occupy
void deleteTurtlesFromQ(TurtleQ& tQ){
  while(tQ.turtlesInQ > 0){
    Turtle *turtle=tQ.head;
    removeTurtleFromQ(tQ,turtle);
    delete turtle;
  }

}

// takes a turtle from the repository and places it into the active queue head
Turtle *  activateTurtleFromRepositoryHead(TurtleQ& actTurtleQ,TurtleQ& repTurtleQ){
  Turtle *turtle=repTurtleQ.head;
  removeTurtleFromQ(repTurtleQ,turtle);
  addTurtleToQHead(actTurtleQ,turtle);

  return turtle;
}

// takes a turtle from the repository and places it into the active queue tail
Turtle *  activateTurtleFromRepositoryTail(TurtleQ& actTurtleQ,TurtleQ& repTurtleQ){
  Turtle *turtle=repTurtleQ.head;
  removeTurtleFromQ(repTurtleQ,turtle);
  addTurtleToQTail(actTurtleQ,turtle);

  return turtle;
}


// takes a turtle from the repository and places it into the active queue left of most left perfect turtle
// use this only to insert P turtles
Turtle *  activateTurtleFromRepositoryMiddle(TurtleQ& actTurtleQ,TurtleQ& repTurtleQ){
  Turtle *turtle=repTurtleQ.head;
  removeTurtleFromQ(repTurtleQ,turtle);
  addTurtleToQMiddle(actTurtleQ,turtle);

  return turtle;
}

// moves all turtles from the active queue to the repository
void moveAllTurtlesToRepository(TurtleQ& actTurtleQ,TurtleQ& repTurtleQ){
  if(actTurtleQ.turtlesInQ>0){
    repTurtleQ.head->right=actTurtleQ.tail->right;
    actTurtleQ.tail->right->left=repTurtleQ.head;
    actTurtleQ.tail->right=NULL;
    repTurtleQ.head=actTurtleQ.head;
    actTurtleQ.head=actTurtleQ.tail;
    actTurtleQ.iter=actTurtleQ.head;

    repTurtleQ.turtlesInQ=actTurtleQ.turtlesInQ+repTurtleQ.turtlesInQ;
    actTurtleQ.turtlesInQ=0;
  }
}

//-------------------------------------------------------------------------------
// converting a character to the index

int charToIndexALL(char c){
  int cNr=-1;    
  switch ( c ){
    case 'A':
      cNr=0;
      break;
    case 'C':
      cNr=1;
      break;
    case 'G':
      cNr=2;
      break; 
    case 'T':
      cNr=3;
      break;
    case 'U':
      cNr=3;
      break;
    case 'a':
      cNr=0;
      break;
    case 'c':
      cNr=1;
      break;
    case 'g':
      cNr=2;
      break; 
    case 't':
      cNr=3;
      break;
    case 'u':
      cNr=3;
      break;
  }  

  return cNr;
}


//--------------------------------------------------------------------------------
// scanning routines to update turtles, locate and print hits

void deleteSubTree(TreeNode *node){
  
  // check if there is a child
  for (int i=0;i<4;i++){
    if (node->nextNuc[i] != NULL){deleteSubTree(node->nextNuc[i]);}
  }
  delete node;
}


void printAlignmentHit(string& seqName,int seqLen,string& targetSeqID,int tAlnFrom,char strand,char mmMode,string& queryPr,string& alnPr,string& targetPr,int pos){

  // pos hold the position of the mismatch (in the case of Q,T,L)
  // which is used to rearrange the gaps in the alignment

  int qAlnFrom=1;
  int qAlnTo=seqLen;
  int tAlnTo=tAlnFrom+seqLen-1;
  int errors=1;

  if(strand == '-'){qAlnFrom=seqLen;qAlnTo=1;}
  if(mmMode == 'Q'){tAlnTo--;}
  if(mmMode == 'T'){tAlnTo++;}
  if(mmMode == 'P'){errors=0;}
  if(mmMode == 'L'){
    if(targetPr.at(0)=='-'){tAlnFrom++;} // in case of a mismatch at first target position
    if(targetPr.at(targetPr.length()-1)=='-'){tAlnTo--;} // in case of a mismatch at last target position
  }

  //return;
  //cout << seqName << " " << seqLen << " " << targetSeqID  <<" "<< tAlnFrom <<" "<< strand <<" "<< mmMode << "\n";
  //cout << mmMode << "\n";


  // alignments at a particular locus can be ambiguous. in the case where there is a gap
  // there might be a better alignment when shifting the gap to the left
  // this has to be taken care of only for Q. In the case of T shifting the gaps to either of the ends
  // would result in a perfect hit wich is caught anyways
  // shifting a gap to the right does not have to be checked as well

  if((mmMode == 'Q') and (pos != 1) and (pos != targetPr.length())){

    // test examples
    //pos=2;
    //queryPr ="GGAAGGAAGGAAGGAAGGAAG";  // GGAAGGAAGGAAGGAAGGAAG
    //alnPr   ="| |||||||||||||||||||";  //  ||||||||||||||||||||
    //targetPr="G-AAGGAAGGAAGGAAGGAAG";  // -GAAGGAAGGAAGGAAGGAAG

    // try to shift the gap one by one in direction left
    bool shiftGapToLeftSuccessful=true;
    for(int i=0;i<pos-1;i++){if (targetPr.at(i) != queryPr.at(i+1)){shiftGapToLeftSuccessful=false;i=pos-1;}}
  
    if(shiftGapToLeftSuccessful){ // a shift to the left is possible
      for(int i=0;i<pos-1;i++){targetPr.at(i+1)=targetPr.at(i);alnPr.at(i+1)=alnPr.at(i);}
      targetPr.at(0)='-';alnPr.at(0)=' ';
    }
  }


  cout << seqName << " (" << seqLen << " nc) " << qAlnFrom << ".." << qAlnTo << "\t" << targetSeqID << "\t" << tAlnFrom << ".." << tAlnTo << "\n";
  cout << targetSeqID << "\n";
  cout << "errors: " << errors << " orientation: " << strand << "\n";
  cout << queryPr << "\n" << alnPr << "\n" << targetPr << "\n\n";

}

// returns true if it printed an alignment
bool processTurtleHit(Turtle *turtle,vector<string>& seqs,vector<SeqInfo>& seqsInfo,Opts& opts,string& targetSeqID,unsigned int id,char * buf,int bufI){

  int tPos=turtle->cloneCoord-turtle->alnFrom+1;
  char tGap=turtle->gapMode;
  char tSkippedNuc=turtle->skippedNuc;

  bitfield bf;
  bf.id=id;
  unsigned int strandBin=bf.fields.strand;
  unsigned int mPos=bf.fields.mpos;
  unsigned int seqId=bf.fields.seqId;

  // exit immediately if this condition is true and save time
  if((tGap=='T') and (mPos>0) and (tPos!=mPos)){return false;}

  string seq=seqs[(opts.bothStr+1)*(seqId-1)+strandBin];
  int sTL=seq.length()-mPos;
  // string seqName=seqIds[seqId-1];
  string seqName=seqsInfo[seqId-1].seqName;				   

  string targetPr; // genomic sequence for printing
  string queryPr;  // small rna sequence for printing 
  string alnPr;    // alignment string 

  char strand='+';
  if(strandBin == 1){strand='-';}

  // infer the type of hit
  if((tGap=='P') and (mPos==0)){// pefect match
    if(seqsInfo[seqId-1].pHits<opts.maxHits){
      for(int i=seq.length();i>0;i--){targetPr.push_back(buf[(bufI+i-1) % (maxSeqLength+1)]);alnPr.push_back('|');}
      queryPr=seq;
      printAlignmentHit(seqName,seq.length(),targetSeqID,turtle->alnFrom,strand,'P',queryPr,alnPr,targetPr,0);
    }
    seqsInfo[seqId-1].pHits++;
    return true;
  }

  else if((tGap=='P') and (mPos>1) and (mPos<seq.length()) and (seq.substr(mPos-1,sTL) != seq.substr(mPos,sTL))){// Q match
    if(seqsInfo[seqId-1].mHits<opts.maxHits){
      for(int i=seq.length()-1;i>0;i--){
	if(seq.length()-i == mPos){targetPr.push_back('-');alnPr.push_back(' ');}
	targetPr.push_back(buf[(bufI+i-1) % (maxSeqLength+1)]);alnPr.push_back('|');
      }
      queryPr=seq;
      printAlignmentHit(seqName,seq.length(),targetSeqID,turtle->alnFrom,strand,'Q',queryPr,alnPr,targetPr,mPos);
    }
    seqsInfo[seqId-1].mHits++;
    return true;
  }
  else if((tGap=='T') and (mPos==0) and (tPos>1) and (tPos<seq.length()+1)){// T match
    if(seqsInfo[seqId-1].mHits<opts.maxHits){
      for(int i=seq.length()+1;i>0;i--){targetPr.push_back(buf[(bufI+i-1) % (maxSeqLength+1)]);}

      for(int i=0;i<seq.length();i++){
	if(i+1 == tPos){queryPr.push_back('-');alnPr.push_back(' ');}
	queryPr.push_back(seq.at(i));alnPr.push_back('|');
      }
      printAlignmentHit(seqName,seq.length(),targetSeqID,turtle->alnFrom,strand,'T',queryPr,alnPr,targetPr,tPos);
     }
     seqsInfo[seqId-1].mHits++;
     return true;
  }
  // L match
  else if((tGap=='T') and (mPos>0) and (tPos==mPos) and ((seq.at(mPos-1) != turtle->skippedNuc) or (seq.at(mPos-1)=='N'))){
    if(seqsInfo[seqId-1].mHits<opts.maxHits){
      for(int i=seq.length();i>0;i--){
	targetPr.push_back(buf[(bufI+i-1) % (maxSeqLength+1)]);
      }
      for(int i=0;i<seq.length();i++){
	if(i+1==mPos){alnPr.push_back(' ');}else{alnPr.push_back('|');}
      }
      queryPr=seq;
      
      printAlignmentHit(seqName,seq.length(),targetSeqID,turtle->alnFrom,strand,'L',queryPr,alnPr,targetPr,mPos);
    }
    seqsInfo[seqId-1].mHits++;
    return true;
  }else{
    return false;
  }
}



void processTurtleHits(TreeNode *treeNode,Turtle *turtle,vector<string>& seqs,vector<SeqInfo>& seqsInfo,Opts& opts,string& targetSeqID,char * buf,int bufI,MOV& vecMap){

  unsigned int id=treeNode->id; // this is the composite id.
  bool pri;

  // print the main hit from the tree
  pri=processTurtleHit(turtle,seqs,seqsInfo,opts,targetSeqID,id,buf,bufI);

  // check if there are more hits to be printed 
  MOV::iterator iter;
  iter=vecMap.find(id);
  if (!(iter==vecMap.end())){ // the key exists
    for(int i=0;i<iter->second.size();i++){
      unsigned int secId=iter->second[i];
      pri=processTurtleHit(turtle,seqs,seqsInfo,opts,targetSeqID,secId,buf,bufI);
    }
  }
}



void processTurtleHitsNR(Turtle *turtle,int pos,vector<string>& seqs,vector<SeqInfo>& seqsInfo,Opts& opts,string& targetSeqID,char * buf,int bufI,MOV& vecMap,map<unsigned int,unsigned int>& multiAln,STRE * sbu){

  unsigned int id=turtle->tn->id; // this is the composite id.
  bitfield bf;
  bf.id=id;
  unsigned int seqId=bf.fields.seqId;
  bool pri;
  int tAlnFrom=turtle->alnFrom;
  int d=pos-tAlnFrom;
  int sbuInd=(bufI+d) % (maxSeqLength+1);


  map<unsigned int,unsigned int>::iterator multiIter;


  // check if seqId is not yet in the hash
  multiIter=multiAln.find(seqId);
  if (multiIter==multiAln.end()){ // the key does not exist (alignment end test)
    multiIter=sbu[sbuInd].find(seqId);
    if (multiIter==sbu[sbuInd].end()){ // the key does not exist (alignment start test)
      pri=processTurtleHit(turtle,seqs,seqsInfo,opts,targetSeqID,id,buf,bufI); // check if there is a hit
      if(pri){multiAln[seqId]=1;sbu[sbuInd][seqId]=1;}  // if there was an output produced insert keys
    }
  }


  // check if there are more hits to be printed 
  MOV::iterator iter;
  iter=vecMap.find(id);
  if (!(iter==vecMap.end())){ // the key exists
    for(int i=0;i<iter->second.size();i++){
      unsigned int auxId=iter->second[i];
      bf.id=auxId;
      seqId=bf.fields.seqId;
      
      // check if seqId is not yet in the hash
      multiIter=multiAln.find(seqId);
      if (multiIter==multiAln.end()){ // the key does not exist (alignment end test)
	multiIter=sbu[sbuInd].find(seqId);
	if (multiIter==sbu[sbuInd].end()){ // the key does not exist (alignment start test)
	  pri=processTurtleHit(turtle,seqs,seqsInfo,opts,targetSeqID,auxId,buf,bufI);
	  if(pri){multiAln[seqId]=1;sbu[sbuInd][seqId]=1;}// if there was an output produced insert keys
	}
      }
    }
  }
}


void processNewNucleotideM(TreeNode *root,int cNr,int pos,vector<string>& seqs,vector<SeqInfo>& seqsInfo,Opts& opts,string& targetSeqID,TurtleQ& actTurtleQ,TurtleQ& repTurtleQ,char * buf,int bufI,MOV& vecMap,STRE * sbu){

  // get new turtle from the repository
  //Turtle *turtle=activateTurtleFromRepositoryHead(actTurtleQ,repTurtleQ);
  Turtle *turtle=activateTurtleFromRepositoryMiddle(actTurtleQ,repTurtleQ); //insert the new P turtle left of the leftmost P turtle
  // intialize the turtle
  turtle->alnFrom=pos;turtle->cloneCoord=pos;turtle->gapMode='P';turtle->tn=root;
  
  Turtle *iterTurtle;
  TreeNode *nextTreeNode;

  int turtlesInQbeforeMMinsertion=actTurtleQ.turtlesInQ;

  // create a hash that tracks every seq that was printed at a particular position
  // this is used to remove multiple hits for a seq at the same locus
  map<unsigned int,unsigned int> multiAln;

  // create all the mismatch turtles for perfect turtles
  resetIterInQ(actTurtleQ);
  for(int i=0;i<turtlesInQbeforeMMinsertion;i++){
    iterTurtle=iterGetNextTurtleFromQ(actTurtleQ);

    if(iterTurtle->gapMode =='P'){
      // T: create 1 turtle
      nextTreeNode=iterTurtle->tn;
      Turtle *turtleQ=activateTurtleFromRepositoryTail(actTurtleQ,repTurtleQ);
      turtleQ->alnFrom=iterTurtle->alnFrom;turtleQ->cloneCoord=pos;turtleQ->gapMode='T';turtleQ->tn=nextTreeNode;turtleQ->skippedNuc=buf[bufI];
      
      if(nextTreeNode->id !=0){
	//processTurtleHits(nextTreeNode,turtleQ,seqs,seqsInfo,opts,targetSeqID,buf,bufI,vecMap);
	processTurtleHitsNR(turtleQ,pos,seqs,seqsInfo,opts,targetSeqID,buf,bufI,vecMap,multiAln,sbu);
      }
    }else{i=turtlesInQbeforeMMinsertion;} // since turtles are sorted (first P) stop dividing

  }

  
  // move the OLD turtles and check for hits and out of tree events
  resetIterInQ(actTurtleQ);
  // if non regular nucleotide: remove all old turtles. they cannot produce a hit
  // else update the old turtles
  if (cNr == -1){
    for(int i=0;i<turtlesInQbeforeMMinsertion;i++){
      iterTurtle=iterGetNextTurtleFromQ(actTurtleQ);
      removeTurtleFromQ(actTurtleQ,iterTurtle);
      addTurtleToQHead(repTurtleQ,iterTurtle);
    }
  }else{
    resetIterInQ(actTurtleQ);

    // create a hash that tracks every seq that was printed at a particular position
    // this is used to remove multiple hits for a seq at the same locus
    //map<unsigned int,unsigned int> multiAln;

    for(int i=0;i<turtlesInQbeforeMMinsertion;i++){
      iterTurtle=iterGetNextTurtleFromQ(actTurtleQ);
      nextTreeNode=iterTurtle->tn->nextNuc[cNr];

      // move the turtle
      iterTurtle->tn=nextTreeNode;
      // check if the turtle has fallen out of the tree
      if (nextTreeNode == NULL){
	removeTurtleFromQ(actTurtleQ,iterTurtle);
	addTurtleToQHead(repTurtleQ,iterTurtle);
      }else{
	if(nextTreeNode->id !=0){
	  processTurtleHitsNR(iterTurtle,pos,seqs,seqsInfo,opts,targetSeqID,buf,bufI,vecMap,multiAln,sbu);
	  //processTurtleHits(nextTreeNode,iterTurtle,seqs,seqsInfo,opts,targetSeqID,buf,bufI,vecMap);
	}
      }
      //cout << iterTurtle->gapMode << " ";
    }
    //cout << "\n";
  }
}

void scanChromosome(TreeNode *root,string filename,vector<string>& seqs,vector<SeqInfo>& seqsInfo,Opts& opts,MOV& vecMap){
  ifstream fin(filename.c_str());

  if(!fin) {cerr << "Error 002: Cannot Open " << filename <<  " for reading\n";exit(0);}

  // initialize the active and repository turtle queues
  TurtleQ actTurtleQ;
  initTurtleQ(actTurtleQ);

  TurtleQ repTurtleQ;
  initTurtleQ(repTurtleQ);
  insertTurtlesIntoQ(repTurtleQ,maxTurtles);

  char line[maxChrLineLength+1];
  string targetSeqID("undef");
  int pos=1;
  int cNr;
  char c;

  STRE sbu[maxSeqLength+1];  // buffer to store start positions of alignments
  char buf[maxSeqLength+1];  // buffer for the genomic sequence before 127nt before pos (filled up in reverse order)
  int bufI=maxSeqLength;

  while (fin.good()){
    fin.getline(line, maxChrLineLength);
    
    if (line[0] == '>'){ 
      // place a gap at the end of the target. this is needed to find matches that are 1 nucleotide 
      // outside of the target
      buf[bufI]='-';
      processNewNucleotideM(root,-1,pos,seqs,seqsInfo,opts,targetSeqID,actTurtleQ,repTurtleQ,buf,bufI,vecMap,sbu);

      // clear everything if new sequence occurs
      moveAllTurtlesToRepository(actTurtleQ,repTurtleQ);
      for(int i=0;i<maxSeqLength+1;i++){buf[i]='-';sbu[i].clear();}
      bufI=maxSeqLength;

      // extract the id from the fasta header
      string S1(line);
      S1.erase(0, 1);
      string S2("");
      for(int j=0;j<S1.size();j++){
	if (S1[j] == ' '){
	  j=100000;
	  }else{
	  S2.append(&S1[j],1);
	  }
	}
      targetSeqID=S2;
      pos=1;

      // place a gap at the beginning of the target. this is needed to find matches that are 1 nucleotide 
      // outside of the target
      processNewNucleotideM(root,-1,0,seqs,seqsInfo,opts,targetSeqID,actTurtleQ,repTurtleQ,buf,bufI,vecMap,sbu);

    }else{      
    

      int counter=0;
      while (line[counter] != '\0'){
	c=line[counter];
	cNr=charToIndexALL(c);
	buf[bufI]=toupper(c);
	if((c == 'u') or (c == 'U')){buf[bufI]='T';}

	processNewNucleotideM(root,cNr,pos,seqs,seqsInfo,opts,targetSeqID,actTurtleQ,repTurtleQ,buf,bufI,vecMap,sbu);

	pos++;
	//if (pos % 1000000 == 0){cout << pos << "\n";}
	counter++;
	bufI=bufI-1;
	if(bufI<0){bufI=maxSeqLength;}

	sbu[bufI].clear(); // clear the start redundancy buffer for next round

	if(counter > maxChrLineLength-3){
	  cerr << "Error 010: The target file " << filename << " contains more than " << maxChrLineLength << " characters per line\n";exit(0);
	}

      }
    }
  }
  // place a gap at the end of the target. this is needed to find matches that are 1 nucleotide 
  // outside of the target
  buf[bufI]='-';
  processNewNucleotideM(root,-1,pos,seqs,seqsInfo,opts,targetSeqID,actTurtleQ,repTurtleQ,buf,bufI,vecMap,sbu);

  // free the memory used by the turtles in the repositories
  deleteTurtlesFromQ(actTurtleQ);
  deleteTurtlesFromQ(repTurtleQ);

}

//--------------------------------------------------------------------------------
// routines to fill the tree with the query sequences

void insertSequenceIntoTree(TreeNode *root,string &seq,unsigned int id,MOV& vecMap){

  TreeNode *treeNodePointer=root;
  char c;
  int nucIndex=0;
  // insert the sequence into the tree
  for(int i=0;i<seq.length();i++){
    c=seq[i];
    nucIndex=charToIndexALL(c);
    
    if (treeNodePointer->nextNuc[nucIndex]==NULL){
      // create a new node
      TreeNode *nodeNew;

      try{
	nodeNew = new TreeNode();
      }catch(std::bad_alloc&){
	cerr << "Error 008: Not enough memory to load all sequences\n";exit(0);
      }

      nodeNew->id=0;
      for (int i=0;i<4;i++){nodeNew->nextNuc[i]=NULL;}

      treeNodePointer->nextNuc[nucIndex]=nodeNew;
      treeNodePointer=treeNodePointer->nextNuc[nucIndex];
    }else{
      // follow the existing one
      treeNodePointer=treeNodePointer->nextNuc[nucIndex];
    }
  }

  if (treeNodePointer->id == 0){
    treeNodePointer->id=id;
  }else{
    // trying to insert a sequence that already exists
    // store the overlap information in vecMap

    MOV::iterator iter;
    iter=vecMap.find(treeNodePointer->id);
    if (!(iter==vecMap.end())){ // the key already exists, just add new entry in vector
      iter->second.push_back(id);
    }else{ // the key does not exist at all, create
      vector<unsigned int> vec;
      vec.push_back(id);
      vecMap[treeNodePointer->id] = vec;
    }
  }
}



void insertMismatchSequencesIntoTree(TreeNode *root,vector<string>& seqs,Opts& opts,MOV& vecMap){

  bitfield bf;
  unsigned int strand;
  unsigned int seqId;

  for(int i=0; i < seqs.size();i++){
      string seq=seqs[i];
      seqId=i/(opts.bothStr+1)+1;
      strand=i % (opts.bothStr+1);

      // check if the sequence contains an N
      string::size_type loc = seq.find( "N", 0 );
      if( loc == string::npos ){ // no N in sequence, insert mismatches into tree

	string tSeq=seq.substr(1,seq.length()-1);
	bf.fields.seqId=seqId;
	bf.fields.mpos=1;
	bf.fields.strand=strand;
	unsigned int id=bf.id; // grab the composite id and continue with it

	insertSequenceIntoTree(root,tSeq,id,vecMap);

	for(int m=0;m<tSeq.length();m++){
	  tSeq.at(m)=seq.at(m);

	  bf.fields.seqId=seqId;
	  bf.fields.mpos=m+2;
	  bf.fields.strand=strand;
	  unsigned int id=bf.id;  // grab the composite id and continue with it
	  
	  insertSequenceIntoTree(root,tSeq,id,vecMap);
	}
      }else{ // there is one N in the sequence. insert the one mismatch seq that has the N bulged out
	string tSeq(seq);
	bf.fields.seqId=seqId;
	bf.fields.mpos=loc+1;
	bf.fields.strand=strand;
	unsigned int id=bf.id; // grab the composite id and continue with it

	tSeq.erase(loc,1); // remove the N from the sequence
	insertSequenceIntoTree(root,tSeq,id,vecMap);
	//cout << seq << " " << loc << " " << tSeq << "\n";
      }
  }
}



TreeNode * insertSequencesIntoTree(vector<string>& seqs,Opts& opts,MOV& vecMap){

  // create the tree root
  TreeNode *root = new TreeNode();
  root->id=0;
  for (int i=0;i<4;i++){root->nextNuc[i]=NULL;}

  bitfield bf;
  unsigned int strand;
  unsigned int seqId;

  // insert perfect match sequences
  for(int i=0; i < seqs.size();i++){
      string seq=seqs[i];
  
      // check if the sequence contains an N
      string::size_type loc = seq.find( "N", 0 );
      if( loc == string::npos ){ // no N in sequence, insert into tree
	   
	seqId=i/(opts.bothStr+1)+1;
	strand=i % (opts.bothStr+1);
	
	bf.fields.seqId=seqId;
	bf.fields.mpos=0;
	bf.fields.strand=strand;
	unsigned int id=bf.id;  // grab the composite id and continue with it
	
	insertSequenceIntoTree(root,seq,id,vecMap);
      }
  }

  return root;
}


// reads a fasta file of small sequences (one line per sequence).
void readSequencesFromFile(char * filename,Opts& opts,vector<string>& seqs,vector<SeqInfo>& seqsInfo){
  map<char,char> regMap;
  map<char,char> rcMap;
  map<char,char>::iterator iter;

  regMap['A']='A';regMap['C']='C';regMap['G']='G';regMap['T']='T';regMap['U']='T';
  regMap['a']='A';regMap['c']='C';regMap['g']='G';regMap['t']='T';regMap['u']='T';regMap['n']='N';regMap['N']='N';

  rcMap['A']='T';rcMap['C']='G';rcMap['G']='C';rcMap['T']='A';rcMap['N']='N';

  ifstream fin(filename);
  if(!fin) {cerr << "Error 003: Cannot Open " << filename <<  " for reading\n";exit(0);}

  char header[maxSeqLength+1];
  char seq[maxSeqLength+1];

  int id=0;
  while (fin.good()){
    fin.getline(header, maxSeqLength);
    fin.getline(seq, maxSeqLength);

    if (header[0] != '\0'){
      if (header[0] == '>'){
	id++;
      }else{cerr << "Error 004: Input sequences are not in one line per sequence fasta format\n " << id;exit(0);} // cannot happen if input is a valid fasta file
      
      string headerString(header);
      string seqString(seq);
      string idString="";
   
      // parse header, extract id and store into the id vector
      for(int i=1;i<headerString.length();i++){
	if((headerString.at(i) != ' ') and (headerString.at(i) != '\t')){idString+=headerString.at(i);}else{i=headerString.length();}
      }
      SeqInfo si;
      si.seqName=idString;
      si.pHits=0;
      si.mHits=0;
      seqsInfo.push_back(si);

      if(seqString.length() > maxSeqLength-3){
	cerr << "Error 011: Input sequence "<< headerString << " is longer than " << maxSeqLength-3 << " nucleotides\n";exit(0);
      }


      int numberOfNs=0;
      // parse the input string and check if it is correct
      for(int i=0;i<seqString.length();i++){
	char c=seqString.at(i);
	iter=regMap.find(c); // check if there are non regular nucleotides
	if (!(iter==regMap.end())){
	  char cK=iter->second;
	  seqString.at(i)=cK;
	  if(cK=='N'){numberOfNs++;}
	}else{cerr << "Error 005: Input sequence "<< headerString << " contains non regular nucleotides\n";exit(0);}
      }
      if(numberOfNs>1){cerr << "Error 006: Input sequence "<< headerString << " contains more than one N nucleotide\n";exit(0);}

      seqs.push_back(seqString);

      // if eq 1 then also insert the reverse complement
      if(opts.bothStr==1){
	string seqStringRC(seqString);
	for(int i=0;i<seqString.length();i++){
	  char c=seqString.at(i);
	  char cRC=rcMap[c];
	  seqStringRC.at(seqString.length()-i-1)=cRC;
	}
	seqs.push_back(seqStringRC);
      }
    }
  }
}

//

void saveHitReport(vector<SeqInfo>& seqsInfo,string filename){
  if(filename != ""){
    ofstream fileH;
    fileH.open(filename.c_str());
    for(int i=0;i<seqsInfo.size();i++){
      string seqName=seqsInfo[i].seqName;
      int pHits=seqsInfo[i].pHits;    
      int mHits=seqsInfo[i].mHits; 

      fileH << seqName << "\t" << pHits << "\t" << mHits << "\n";
    }
    fileH.close();
  }
}


//--------------------------------------------------------------------------------

// test the bitfield
void testBitfield(){

  bitfield bf;
  bf.fields.strand=0;
  bf.fields.mpos=120;
  bf.fields.seqId=3200000;

  if((bf.fields.strand != 0) or (bf.fields.mpos !=120) or (bf.fields.seqId != 3200000) or(bf.id != 2016465920)){
    cerr << "Error 009: Software is not compatible to this plattform\n"; exit(0);
  }
}


bool readCommandLineArgs(int argc, char *argv[],Opts& opts){

  if(argc < 3){return false;} // at least two files have to be specified
  for(int i=3;i<argc;i++){
    string arg(argv[i]);
    if(arg == "-s"){ // -s: map only to plus strand
      opts.bothStr=0;
    }else if(arg == "-d"){ // -d: read all fasta files (.fa) in directory as targets
      opts.targetDir=1;
    }else if(arg == "-r"){ // -r create output report
      if(i+1<argc){
	string filename(argv[i+1]);
	opts.hitReport=filename;
	i++;
      }else{return false;}
    }else if(arg == "-m"){
      if(i+1<argc){
	//string maxHitsString(argv[i+1]);
	int maxHits = atoi(argv[i+1]);
	opts.maxHits=maxHits;
	i++;
      }else{return false;}
    }else{
      return false;
    }
  }
  return true;
}


int main(int argc, char *argv[]) {

  string fastaSUFFIX=".fa"; // suffix for a file to be recognized as a fasta target file

  // set default options
  Opts opts;
  opts.targetDir=0; // read a single file as a target
  opts.bothStr=1; // 1: both strands (default)
  opts.maxHits=100000000; // maximum number of hits for a sequence
  opts.hitReport=""; // no hit report file

  bool inputArgsOK=readCommandLineArgs(argc,argv,opts);
  if(!inputArgsOK){
    cerr << "Usage:\n" << argv[0] << " target.fa query.fa [-s] [-d] [-r filename] [-m maxhits]\n\n";
    cerr << "  -s             scan only plus strand of the target\n";
    cerr << "  -d             scan all .fa target files in a directory (target must be a directory)\n";
    cerr << "  -r filename    create a match report at the end\n";
    cerr << "  -m maxhits     maximum hits for one query to print\n\n";

    exit(1);
  }
  testBitfield(); // test if the bitfield works in runtime

  char *target_filename = argv[1];
  char *query_filename = argv[2];

  vector<string> seqs; // all sequences that have to be mapped
  vector<SeqInfo> seqsInfo; // all sequence ids together with nr of hits info
  MOV vecMap; // stores all mismatch sequences that exist multiple times

  readSequencesFromFile(query_filename,opts,seqs,seqsInfo);
  TreeNode *root=insertSequencesIntoTree(seqs,opts,vecMap);
  insertMismatchSequencesIntoTree(root,seqs,opts,vecMap);

  if(opts.targetDir == 0){ // input file is given as one fasta file
    string target_filename_str(target_filename);
    scanChromosome(root,target_filename_str,seqs,seqsInfo,opts,vecMap);
  }else{ // read all fasta files in directory and process
    string dir(target_filename);
    DIR *hdir = opendir(target_filename);
    struct dirent *entry;

    if(NULL==hdir){
      cerr << "Error 007: Directory not found\n"; exit(0);
    }else{
      while(NULL!=(entry=readdir(hdir))){ // iterate through all files in the directory
	string filename=entry->d_name;
	string fullFilename=dir+"/"+filename;

	string::size_type loc = filename.find(fastaSUFFIX, 0 );
	if( (loc != string::npos) and (filename.length()-loc==fastaSUFFIX.length()) ){ // its a fasta file
	  scanChromosome(root,fullFilename,seqs,seqsInfo,opts,vecMap);
	}
      }
    }
  }
  deleteSubTree(root);  // delete the tree
 
  saveHitReport(seqsInfo,opts.hitReport); // save number of hits report

  return 0;
}

