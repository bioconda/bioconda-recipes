/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                           ;
;                         BIONJ program                                     ;
;                                                                           ;
;                         Olivier Gascuel                                   ;
;                                                                           ;
;                         GERAD - Montreal- Canada                          ;
;                         olivierg@crt.umontreal.ca                         ;
;                                                                           ;
;                         LIRMM - Montpellier- France                       ;
;                         gascuel@lirmm.fr                                  ;
;                                                                           ;
;                         UNIX version, written in C                        ;
;                         by Hoa Sien Cuong (Univ. Montreal)                ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

// Test case 1

#include "Divvier.h"
#include "Tree.h"
#include <stdlib.h>
#include <stdio.h>
#include <cstring>

using namespace::std;


#define PREC 8                             /* precision of branch-lengths  */
#define PRC  100
#define LEN  10000                            /* length of taxon names        */

typedef struct word
{
  char name[LEN];
  struct word *suiv;
}WORD;

typedef struct pointers
{
  WORD *head;
  WORD *tail;
}POINTERS;


void   Initialize(double  **delta, FILE *input, int n, POINTERS *trees);

void   Compute_sums_Sx(double  **delta, int n);

void   Best_pair(double  **delta, int r, int *a, int *b, int n);

string Finish(double  **delta, int n, POINTERS *trees);

void   Concatenate(char chain1[LEN], int ind, POINTERS *trees, int post);

string Print_output(int i, POINTERS *trees);

double  Distance(int i, int j, double  **delta);

double  Variance(int i, int j, double  **delta);

double  Sum_S(int i, double  **delta);

double  Agglomerative_criterion(int i, int j, double  **delta, int r);

double  Branch_length(int a, int b, double  **delta, int r);

double  Reduction4(int a, double  la, int b, double  lb, int i, double  lamda,
		 double  **delta);

double  Reduction10(int a, int b, int i, double  lamda, double  vab, double
		  **delta);
double  Lamda(int a, int b, double  vab, double  **delta, int n, int r);

double  Finish_branch_length(int i, int j, int k, double  **delta);

int    Emptied(int i, double  **delta);

int    Symmetrize(double  **delta, int n);

/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                           ;
;                         Main program                                      ;
;                                                                           ;
;                         argc is the number of arguments                   ;
;                         **argv contains the arguments:                    ;
;                         the first argument has to be BIONJ;               ;
;                         the second is the inptu-file;                     ;
;                         the third is the output-file.                     ;
;                         When the input and output files are               ;
;                         not given, the user is asked for them.            ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

string DoBioNJ(vector <double> PWdists, vector <string> Names, bool DoNumbers)	{
	POINTERS *trees;                        /* list of subtrees            */
	WORD *name;								/* Used for transferring sequence names */
	char *Name_fich1;                       /* name of the input file      */
	char *Name_fich2;                       /* name of the output file     */
	char *chain1;                           /* stringized branch-length    */
	char *chain2;                           /* idem                        */
	int *a, *b;                             /* pair to be agglomerated     */
	double  la;                               /* first taxon�s branch-length */
	double  lb;                               /* second taxon�s branch-length*/
	double  vab;                              /* variance of Dab             */
	double  lamda;
	double **delta;
	int i,j,k,r,x,y,n = (int) Names.size();
	string return_tree;

	/*   Allocation of memories    */
	Name_fich1=(char*)calloc(LEN,sizeof(char));
	Name_fich2=(char*)calloc(LEN,sizeof(char));
	a=(int*)calloc(1,sizeof(int));
	b=(int*)calloc(1,sizeof(int));
	chain1=(char *)calloc(LEN,sizeof(char));
	chain2=(char *)calloc(LEN,sizeof(char));
	GET_MEM(delta,double*,n+1); FOR(i,n+1) { GET_MEM(delta[i],double,n+1); }
	FOR(i,n+1){ delta[0][i] = 0.0; delta[i][0] = 0.0; }
	k=0; for(i=1;i<=n;i++) { for(j=1;j<=n;j++) { delta[i][j] = PWdists[k++]; }	}

	// Assign names
	trees=(POINTERS *)calloc(n+1,sizeof(POINTERS));
	for(i = 1; i <= n; i++)	{
		name = (WORD *) calloc(1,sizeof(WORD));
		if(DoNumbers) { strcpy(name->name,int_to_string(i).c_str());
		} else { strcpy(name->name,Names[i-1].c_str()); }
		assert(name != NULL);
		name->suiv = NULL;
		trees[i].head = name;
		trees[i].tail = name;
	}
	/*   initialise and symmetrize the running delta matrix    */
	r=n;
	*a=0;
	*b=0;

	// Do bionj
	while (r > 3)	{   /* until r=3                 */
		Compute_sums_Sx(delta, n);             /* compute the sum Sx       */
		Best_pair(delta, r, a, b, n);          /* find the best pair by    */
		vab=Variance(*a, *b, delta);           /* minimizing (1)           */
		la=Branch_length(*a, *b, delta, r);    /* compute branch-lengths   */
		lb=Branch_length(*b, *a, delta, r);    /* using formula (2)        */
		lamda=Lamda(*a, *b, vab, delta, n, r); /* compute lambda* using (9)*/
		for(i=1; i <= n; i++)	{
			if(!Emptied(i,delta) && (i != *a) && (i != *b)) {
				if(*a > i)	{ x=*a; y=i; }
				else		{ x=i; y=*a; } /* apply reduction formulae */
			                                  /* 4 and 10 to delta        */
 				delta[x][y]=Reduction4(*a, la, *b, lb, i, lamda, delta);
 				delta[y][x]=Reduction10(*a, *b, i, lamda, vab, delta);
		}	}

		strcpy(chain1,"");                     /* agglomerate the subtrees */
		strcat(chain1,"(");                    /* a and b together with the*/
		Concatenate(chain1, *a, trees, 0);     /* branch-lengths according */
		strcpy(chain1,"");                     /* to the NEWSWICK format   */
		strcat(chain1,":");
		sprintf(chain1+strlen(chain1),"%f",my_max(la,0));
		strcat(chain1,",");
		Concatenate(chain1,*a, trees, 1);
		trees[*a].tail->suiv=trees[*b].head;
		trees[*a].tail=trees[*b].tail;
		strcpy(chain1,"");
		strcat(chain1,":");
		sprintf(chain1+strlen(chain1),"%f",my_max(lb,0));
		strcat(chain1,")");
		Concatenate(chain1, *a, trees, 1);
		delta[*b][0]=1.0;                     /* make the b line empty     */
		trees[*b].head=NULL;
		trees[*b].tail=NULL;
		r--;                                /* decrease r                */
	}
	return_tree = Finish(delta, n, trees);       /* compute the branch-lengths*/
	for(i=1; i<=n; i++)	{			/* of the last three subtrees*/
		delta[i][0]=0.0;			/* and print the tree in the */
		trees[i].head=NULL;			/* output-file               */
		trees[i].tail=NULL;
	}
	// Clear memory (added by SW)
	free(trees);
	free(a); free(b); free(Name_fich1); free(Name_fich2);
	free(chain1); free(chain2);
	FOR(i,n+1) { delete [] delta[i]; } delete [] delta;
	return return_tree;
}


/*;;;;;;;;;;;  INPUT, OUTPUT, INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                           ;
;                                                                           ;
;              The delta matrix is read from the input-file.                ;
;              It is recommended to put it and the executable in            ;
;              a special directory. The input-file and output-file          ;
;              can be given as arguments to the executable by               ;
;              typing them after the executable (Bionj input-file           ;
;              output-file) or by typing them when asked by the             ;
;              program. The input-file has to be formated according         ;
;              the PHYLIP standard. The output file is formated             ;
;              according to the NEWSWICK standard.                          ;
;                                                                           ;
;              The lower-half of the delta matrix is occupied by            ;
;              dissimilarities. The upper-half of the matrix is             ;
;              occupied by variances. The first column                      ;
;              is initialized as 0; during the algorithm some               ;
;              indices are no more used, and the corresponding              ;
;              positions in the first column are set to 1.                  ;
;                                                                           ;
;              This delta matix is made symmetrical using the rule:         ;
;              Dij = Dji <- (Dij + Dji)/2. The diagonal is set to 0;        ;
;              during the further steps of the algorithm, it is used        ;
;              to store the sums Sx.                                        ;
;                                                                           ;
;              A second array, trees, is used to store taxon names.         ;
;              During the further steps of the algoritm, some               ;
;              positions in this array are emptied while the others         ;
;              are used to store subtrees.                                  ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/


/*;;;;;;;;;;;;;;;;;;;;;;;;;; Initialize        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
; Description : This function reads an input file and return the            ;
;               delta matrix and trees: the list of taxa.                   ;
;                                                                           ;
; input       :                                                             ;
;              double  **delta : delta matrix                                 ;
;              FILE *input    : pointer to input file                       ;
;              int n          : number of taxa                              ;
;              char **trees   : list of taxa                                ;
;                                                                           ;
; return value:                                                             ;
;              double  **delta : delta matrix                                 ;
;              char *trees    : list of taxa                                ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

void Initialize(double  **delta, FILE *input, int n, POINTERS *trees)
{
  int lig;                                          /* matrix line       */
  int col;                                          /* matrix column     */
  double  distance;
  char name_taxon[LEN];                             /* taxon�s name      */
  WORD *name;

  for(lig=1; lig <= n; lig++)
    {
      fscanf(input,"%s",name_taxon);                  /* read taxon�s name */
      name=(WORD *)calloc(1,sizeof(WORD));            /* taxon�s name is   */
      if(name == NULL)                                /* put in trees      */
	{
	  printf("Out of memories !!");
	  exit(0);
	}
      else
	{
	  strcpy(name->name,name_taxon);
	  name->suiv=NULL;
	  trees[lig].head=name;
	  trees[lig].tail=name;
	  for(col= 1; col <= n; col++)
	    {
	      fscanf(input,"%lf",&distance);             /* read the distance  */
	      delta[lig][col]=distance;
	    }
	}
    }
}

/*;;;;;;;;;;;;;;;;;;;;;;;;;;; Print_output;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;                                                                           ;
; Description : This function prints out the tree in the output file.       ;
;                                                                           ;
; input       :                                                             ;
;              POINTERS *trees : pointer to the subtrees.                   ;
;              int i          : indicate the subtree i to be printed.       ;
:              FILE *output   : pointer to the output file.                 ;
;                                                                           ;
; return value: The phylogenetic tree in the output file.                   ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/


string Print_output(int i, POINTERS *trees)
{
	stringstream out;
  WORD *parcour;
  parcour=trees[i].head;
  while(parcour != NULL)
    {
	  out << parcour->name;
      parcour=parcour->suiv;
    }
	return out.str();
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;                             Utilities                                     ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/



/*;;;;;;;;;;;;;;;;;;;;;;;;;;; Symmetrize  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
; Description : This function verifies if the delta matrix is symmetric;    ;
;               if not the matrix is made symmetric.                        ;
;                                                                           ;
; input       :                                                             ;
;              double  **delta : delta matrix                                 ;
;              int n          : number of taxa                              ;
;                                                                           ;
; return value:                                                             ;
;              int symmetric  : indicate if the matrix has been made        ;
;                               symmetric or not                            ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

int Symmetrize(double  **delta, int n)
{
  int lig;                                         /* matrix line        */
  int col;                                         /* matrix column      */
  double  value;                                     /* symmetrized value  */
  int symmetric;

  symmetric=1;
  for(lig=1; lig  <=  n; lig++)
    {
      for(col=1; col< lig; col++)
	{
	  if(delta[lig][col] != delta[col][lig])
	    {
	      value= (delta[lig][col]+delta[col][lig])/2;
	      delta[lig][col]=value;
	      delta[col][lig]=value;
	      symmetric=0;
	    }
        }
    }
  if(!symmetric)
    printf("The matrix is not symmetric");
  return(symmetric);
}




/*;;;;;;;;;;;;;;;;;;;;;;;;;;; Concatenate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;                                                                           ;
; Description : This function concatenates a string to another.             ;
;                                                                           ;
; input       :                                                             ;
;      char *chain1    : the string to be concatenated.                     ;
;      int ind         : indicate the subtree to which concatenate the      ;
;                        string                                             ;
;      POINTERS *trees  : pointer to subtrees.                              ;
;      int post        : position to which concatenate (front (0) or        ;
;                        end (1))                                           ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

void Concatenate(char chain1[LEN], int ind, POINTERS *trees, int post)
{
  WORD *bran;
  bran=(WORD *)calloc(1,sizeof(WORD));
  if(bran == NULL)
    {
      printf("Out of memories");
      exit(0);
    }
  else
    {
      strcpy(bran->name,chain1);
      bran->suiv=NULL;
    }



  if(post == 0)
    {
      bran->suiv=trees[ind].head;
      trees[ind].head=bran;
    }
  else
    {
      trees[ind].tail->suiv=bran;
      trees[ind].tail=trees[ind].tail->suiv;
    }
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Distance;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
; Description : This function retrieve ant return de distance between taxa  ;
;               i and j from the delta matrix.                              ;
;                                                                           ;
; input       :                                                             ;
;               int i          : taxon i                                    ;
;               int j          : taxon j                                    ;
;               double  **delta : the delta matrix                            ;
;                                                                           ;
; return value:                                                             ;
;               double  distance : dissimilarity between the two taxa         ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

double  Distance(int i, int j, double  **delta)
{
  if(i > j)
    return(delta[i][j]);
  else
    return(delta[j][i]);
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Variance;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
; Description : This function retrieve and return the variance of the       ;
;               distance between i and j, from the delta matrix.            ;
;                                                                           ;
; input       :                                                             ;
;               int i           : taxon i                                   ;
;               int j           : taxon j                                   ;
;               double  **delta  : the delta matrix                           ;
;                                                                           ;
; return value:                                                             ;
;               double  distance : the variance of  Dij                       ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

double  Variance(int i, int j, double  **delta)
{
  if(i > j)
    return(delta[j][i]);
  else
    return(delta[i][j]);
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Emptied ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
; Description : This function verifie if a line is emptied or not.          ;
;                                                                           ;
; input       :                                                             ;
;               int i          : subtree (or line) i                        ;
;               double  **delta : the delta matrix                            ;
;                                                                           ;
; return value:                                                             ;
;               0              : if not emptied.                            ;
;               1              : if emptied.                                ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

int Emptied(int i, double  **delta)      /* test if the ith line is emptied */
{
  return((int)delta[i][0]);
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Sum_S;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;  Description : This function retrieves the sum Sx from the diagonal       ;
;                of the delta matrix.                                       ;
;                                                                           ;
;  input       :                                                            ;
;               int i          : subtree i                                  ;
;               double  **delta : the delta matrix                            ;
;                                                                           ;
;  return value:                                                            ;
;                double  delta[i][i] : sum Si                                 ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

double  Sum_S(int i, double  **delta)          /* get sum Si form the diagonal */
{
  return(delta[i][i]);
}


/*;;;;;;;;;;;;;;;;;;;;;;;Compute_sums_Sx;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
; Description : This function computes the sums Sx and store them in the    ;
;               diagonal the delta matrix.                                  ;
;                                                                           ;
; input       :                                                             ;
;     	         double  **delta : the delta matrix.                      ;
;     	         int n          : the number of taxa                    ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

void Compute_sums_Sx(double  **delta, int n)
{
  double  sum = 0;
  int i;
  int j;

  for(i= 1; i <= n ; i++)
    {
      if(!Emptied(i,delta))
	{
	  sum=0;
	  for(j=1; j <=n; j++)
	    {
	      if(i != j && !Emptied(j,delta))           /* compute the sum Si */
		sum=sum + Distance(i,j,delta);
	    }
	}
      delta[i][i]=sum;                           /* store the sum Si in */
    }                                               /* delta�s diagonal    */
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Best_pair;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;  Description : This function finds the best pair to be agglomerated by    ;
;                minimizing the agglomerative criterion (1).                ;
;                                                                           ;
;  input       :                                                            ;
;                double  **delta : the delta matrix                           ;
;                int r          : number of subtrees                        ;
;                int *a         : contain the first taxon of the pair       ;
;                int *b         : contain the second taxon of the pair      ;
;                int n          : number of taxa                            ;
;                                                                           ;
;  return value:                                                            ;
;                int *a         : the first taxon of the pair               ;
;                int *b         : the second taxon of the pair              ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

void Best_pair(double  **delta, int r, int *a, int *b, int n)
{
  double  Qxy;                         /* value of the criterion calculated*/
  int x,y;                           /* the pair which is tested         */
  double  Qmin;                        /* current minimun of the criterion */

  Qmin=BIG_NUMBER;
  for(x=1; x <= n; x++)
    {
      if(!Emptied(x,delta))
        {
	  for(y=1; y < x; y++)
	    {
	      if(!Emptied(y,delta))
		{
		  Qxy=Agglomerative_criterion(x,y,delta,r);
		  if(Qxy < Qmin-0.000001)
		    {
		      Qmin=Qxy;
		      *a=x;
		      *b=y;
		    }
		}
	    }
        }
    }
}


/*;;;;;;;;;;;;;;;;;;;;;;Finish_branch_length;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;  Description :  Compute the length of the branch attached                 ;
;                 to the subtree i, during the final step                   ;
;                                                                           ;
;  input       :                                                            ;
;                int i          : position of subtree i                     ;
;                int j          : position of subtree j                     ;
;                int k          : position of subtree k                     ;
;                double  **delta :                                            ;
;                                                                           ;
;  return value:                                                            ;
;                double  length  : The length of the branch                   ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

double  Finish_branch_length(int i, int j, int k, double  **delta)
{
  double  length;
  length=0.5*(Distance(i,j,delta) + Distance(i,k,delta)
	      -Distance(j,k,delta));
  return length;
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Finish;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;  Description : This function compute the length of the lasts three        ;
;                subtrees and write the tree in the output file.            ;
;                                                                           ;
;  input       :                                                            ;
;                double  **delta  : the delta matrix                          ;
;                int n           : the number of taxa                       ;
;                WORD *trees   : list of subtrees                           ;
;                                                                           ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/

string Finish(double  **delta, int n, POINTERS *trees)	{
  int l=1;
  int i=0;
  double  length;
  char *str;
  WORD *bidon;
  WORD *ele;
  int last[3];                            /* the last three subtrees     */
  stringstream out;

  str=(char *)calloc(LEN,sizeof(char));

  if(str == NULL) { printf("Out of memories !!"); exit(0);  }
  while(l <= n)	{	/* find the last tree subtree  */
      if(!Emptied(l, delta)) { last[i]=l; i++; }
      l++;
  }
  length=Finish_branch_length(last[0],last[1],last[2],delta);
  out << "(" << Print_output(last[0],trees) << ":" << my_max(0,length) << ",";
  length=Finish_branch_length(last[1],last[0],last[2],delta);
  out << Print_output(last[1],trees) << ":" << my_max(0,length) << ",";   // fprintf(output,":"); fprintf(output,"%f,",length);
  length=Finish_branch_length(last[2],last[1],last[0],delta);
  out << Print_output(last[2],trees) << ":" << my_max(0,length) << ");";
  FOR(i,3) {
      bidon=trees[last[i]].head;
      ele=bidon;
      while(bidon!=NULL)
	{
	  ele=ele->suiv;
	  free(bidon);
	  bidon=ele;
	}
    }
  free(str);
  return out.str();
}


/*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*\
;                                                                           ;
;                          Formulae                                         ;
;                                                                           ;
\*;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;*/


double  Agglomerative_criterion(int i, int j, double  **delta, int r)
{
  double  Qij;
  Qij=(r-2)*Distance(i,j,delta)                           /* Formula (1) */
    -Sum_S(i,delta)
    -Sum_S(j,delta);

  return(Qij);
}


double  Branch_length(int a, int b, double  **delta, int r)
{
  double  length;
  length=0.5*(Distance(a,b,delta)                         /* Formula (2) */
	      +(Sum_S(a,delta)
		-Sum_S(b,delta))/(r-2));
  return(length);
}


double  Reduction4(int a, double  la, int b, double  lb, int i, double  lamda,
		 double  **delta)
{
  double  Dui;
  Dui=lamda*(Distance(a,i,delta)-la)
    +(1-lamda)*(Distance(b,i,delta)-lb);                /* Formula (4) */
  return(Dui);
}


double  Reduction10(int a, int b, int i, double  lamda, double  vab,
		  double  **delta)
{
  double  Vci;
  Vci=lamda*Variance(a,i,delta)+(1-lamda)*Variance(b,i,delta)
    -lamda*(1-lamda)*vab;                              /*Formula (10)  */
  return(Vci);
}

double  Lamda(int a, int b, double  vab, double  **delta, int n, int r)
{
  double  lamda=0.0;
  int i;

  if(vab==0.0)
    lamda=0.5;
  else
    {
      for(i=1; i <= n ; i++)
	{
          if(a != i && b != i && !Emptied(i,delta))
            lamda=lamda + (Variance(b,i,delta) - Variance(a,i,delta));
	}
      lamda=0.5 + lamda/(2*(r-2)*vab);
    }                                              /* Formula (9) and the  */
  if(lamda > 1.0)                                /* constraint that lamda*/
    lamda = 1.0;                             /* belongs to [0,1]     */
  if(lamda < 0.0)
    lamda=0.0;
  return(lamda);
}





