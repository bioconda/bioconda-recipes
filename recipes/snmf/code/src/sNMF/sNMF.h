/**
 * @addtogroup sNMF
 * @ingroup sNMF
 * @{
 * @file sNMF.h
 *
 * @brief function for sNMF paramater calculation
 * 
 * The ploidy is the number of possible genotype. For example, for biallelic marker, the possible genotypes
 * are 0,1,2. By consequence, the ploidy is 3.
 */

#include"../bituint/bituint.h"

#ifndef SNMF_H
#define SNMF_H

/**
 * pointer to snmf_param struct
 */
typedef struct _snmf_param *sNMF_param;

/**
 * run sNMF 
 *
 * @param param	parameter structure
 */
void sNMF(sNMF_param param); 

/**
 * @brief Structure containing all parameters for sNMF
 */
typedef struct _snmf_param {
        // data size parameters
        int K;                  /**< @brief the number of ancestral populations */
        int n;                  /**< @brief the number of individuals */
        int L;                  /**< @brief the number of loci */
	int nc;			/**< @brief ploidy + 1, 3 if 0,1,2 , 2 if 0,1 (number of factors) */
	int Mc;			/**< @brief number of binary elements per line */
	int m;			/**< @brief ploidy + 1, 3 if 0,1,2 , 2 if 0,1 (number of factors) */
	int Mp;			/**< @brief the number of columns of X */
	int Mpi;		/**< @brief the number of columns of Xi */

        // algorithm parameters
        int maxiter;            /**< @brief the maximal number of iterations*/
        int num_thrd;           /**< @brief the number of processes used */
        int init;               /**< @brief if true, random init. Otherwise, init with zeros */
	double tolerance;	/**< @brief the tolerance criterion. The algorithm stops when
				this tolerance is reached */
	double pourcentage;	/**< @brief pourcentage of masked data */ 

        // model parameters
        double alpha;     	/**< @brief the regularization parameter */

        // init parameters
        int I;                  /**< @brief if not nul, init with a sNMF rum of a random subset of SNPs */ 
        long long seed;         /**< @brief seed values */

        // matrix parameters
        double *Q;              /**< @brief the matrix for ancestral admixture coefficients (of size nxK) */
        double *F;              /**< @brief matrix for ancestral allele frequencies (of size M x nc xK) */
        bituint *X;             /**< @brief the data matrix (of size nxMp) */
        bituint *Xi;             /**< @brief the init data matrix (of size nxMpi) */

        // io parameters
        char output_file_F[512];  /**< @brief output file for F */
        char output_file_Q[512];  /**< @brief output file for Q */
        char input_file_Q[512];  /**< @brief input file for Q (for initialization) */
        char input_file[512];   /**< @brief input file */
        char data_file[512];     /**< @brief data file */

        // output criterion parameters
        double all_ce;             /**< @brief cross-entropy of all data */
        double masked_ce;             /**< @brief cross-entropy of the masked dat */

	// temporary variables (uggly names)
	double *temp1;		/**< @brief temporary variable (of size KxK)*/
	double *tempQ;		/**< @brief temporary variable (of size KxN)*/
	double *temp3;		/**< @brief temporary variable (of size KxN)*/
	double *Y;		/**< @brief temporary variable (of size KxN)*/
} snmf_param;




#endif // SNMF_H

/** @} */
