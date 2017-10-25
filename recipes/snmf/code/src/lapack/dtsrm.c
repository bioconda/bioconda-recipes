
/*  -- translated by f2c (version 19940927).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Subroutine */ int dtrsm_(char *side, char *uplo, char *transa, char *diag, 
	integer *m, integer *n, doublereal *alpha, doublereal *a, integer *
	lda, doublereal *b, integer *ldb)
{


    /* System generated locals */
    //integer a_dim1, a_offset, b_dim1, b_offset, i__1, i__2, i__3;

    /* Local variables */
    static integer info;
    static doublereal temp;
    static integer i, j, k;
    static logical lside;
    extern logical lsame_(char *, char *);
    static integer nrowa;
    static logical upper;
    extern /* Subroutine */ int xerbla_(char *, integer *);
    static logical nounit;


/*  Purpose   
    =======   

    DTRSM  solves one of the matrix equations   

       op( A )*X = alpha*B,   or   X*op( A ) = alpha*B,   

    where alpha is a scalar, X and B are m by n matrices, A is a unit, or 
  
    non-unit,  upper or lower triangular matrix  and  op( A )  is one  of 
  

       op( A ) = A   or   op( A ) = A'.   

    The matrix X is overwritten on B.   

    Parameters   
    ==========   

    SIDE   - CHARACTER*1.   
             On entry, SIDE specifies whether op( A ) appears on the left 
  
             or right of X as follows:   

                SIDE = 'L' or 'l'   op( A )*X = alpha*B.   

                SIDE = 'R' or 'r'   X*op( A ) = alpha*B.   

             Unchanged on exit.   

    UPLO   - CHARACTER*1.   
             On entry, UPLO specifies whether the matrix A is an upper or 
  
             lower triangular matrix as follows:   

                UPLO = 'U' or 'u'   A is an upper triangular matrix.   

                UPLO = 'L' or 'l'   A is a lower triangular matrix.   

             Unchanged on exit.   

    TRANSA - CHARACTER*1.   
             On entry, TRANSA specifies the form of op( A ) to be used in 
  
             the matrix multiplication as follows:   

                TRANSA = 'N' or 'n'   op( A ) = A.   

                TRANSA = 'T' or 't'   op( A ) = A'.   

                TRANSA = 'C' or 'c'   op( A ) = A'.   

             Unchanged on exit.   

    DIAG   - CHARACTER*1.   
             On entry, DIAG specifies whether or not A is unit triangular 
  
             as follows:   

                DIAG = 'U' or 'u'   A is assumed to be unit triangular.   

                DIAG = 'N' or 'n'   A is not assumed to be unit   
                                    triangular.   

             Unchanged on exit.   

    M      - INTEGER.   
             On entry, M specifies the number of rows of B. M must be at 
  
             least zero.   
             Unchanged on exit.   

    N      - INTEGER.   
             On entry, N specifies the number of columns of B.  N must be 
  
             at least zero.   
             Unchanged on exit.   

    ALPHA  - DOUBLE PRECISION.   
             On entry,  ALPHA specifies the scalar  alpha. When  alpha is 
  
             zero then  A is not referenced and  B need not be set before 
  
             entry.   
             Unchanged on exit.   

    A      - DOUBLE PRECISION array of DIMENSION ( LDA, k ), where k is m 
  
             when  SIDE = 'L' or 'l'  and is  n  when  SIDE = 'R' or 'r'. 
  
             Before entry  with  UPLO = 'U' or 'u',  the  leading  k by k 
  
             upper triangular part of the array  A must contain the upper 
  
             triangular matrix  and the strictly lower triangular part of 
  
             A is not referenced.   
             Before entry  with  UPLO = 'L' or 'l',  the  leading  k by k 
  
             lower triangular part of the array  A must contain the lower 
  
             triangular matrix  and the strictly upper triangular part of 
  
             A is not referenced.   
             Note that when  DIAG = 'U' or 'u',  the diagonal elements of 
  
             A  are not referenced either,  but are assumed to be  unity. 
  
             Unchanged on exit.   

    LDA    - INTEGER.   
             On entry, LDA specifies the first dimension of A as declared 
  
             in the calling (sub) program.  When  SIDE = 'L' or 'l'  then 
  
             LDA  must be at least  max( 1, m ),  when  SIDE = 'R' or 'r' 
  
             then LDA must be at least max( 1, n ).   
             Unchanged on exit.   

    B      - DOUBLE PRECISION array of DIMENSION ( LDB, n ).   
             Before entry,  the leading  m by n part of the array  B must 
  
             contain  the  right-hand  side  matrix  B,  and  on exit  is 
  
             overwritten by the solution matrix  X.   

    LDB    - INTEGER.   
             On entry, LDB specifies the first dimension of B as declared 
  
             in  the  calling  (sub)  program.   LDB  must  be  at  least 
  
             max( 1, m ).   
             Unchanged on exit.   


    Level 3 Blas routine.   


    -- Written on 8-February-1989.   
       Jack Dongarra, Argonne National Laboratory.   
       Iain Duff, AERE Harwell.   
       Jeremy Du Croz, Numerical Algorithms Group Ltd.   
       Sven Hammarling, Numerical Algorithms Group Ltd.   



       Test the input parameters.   

    
   Parameter adjustments   
       Function Body */

#define A(I,J) a[(I)-1 + ((J)-1)* ( *lda)]
#define B(I,J) b[(I)-1 + ((J)-1)* ( *ldb)]

    lside = lsame_(side, "L");
    if (lside) {
	nrowa = *m;
    } else {
	nrowa = *n;
    }
    nounit = lsame_(diag, "N");
    upper = lsame_(uplo, "U");

    info = 0;
    if (! lside && ! lsame_(side, "R")) {
	info = 1;
    } else if (! upper && ! lsame_(uplo, "L")) {
	info = 2;
    } else if (! lsame_(transa, "N") && ! lsame_(transa, "T") 
	    && ! lsame_(transa, "C")) {
	info = 3;
    } else if (! lsame_(diag, "U") && ! lsame_(diag, "N")) {
	info = 4;
    } else if (*m < 0) {
	info = 5;
    } else if (*n < 0) {
	info = 6;
    } else if (*lda < max(1,nrowa)) {
	info = 9;
    } else if (*ldb < max(1,*m)) {
	info = 11;
    }
    if (info != 0) {
	xerbla_("DTRSM ", &info);
	return 0;
    }

/*     Quick return if possible. */

    if (*n == 0) {
	return 0;
    }

/*     And when  alpha.eq.zero. */

    if (*alpha == 0.) {
	//i__1 = *n;
	for (j = 1; j <= *n; ++j) {
	    //i__2 = *m;
	    for (i = 1; i <= *m; ++i) {
		B(i,j) = 0.;
/* L10: */
	    }
/* L20: */
	}
	return 0;
    }

/*     Start the operations. */

    if (lside) {
	if (lsame_(transa, "N")) {

/*           Form  B := alpha*inv( A )*B. */

	    if (upper) {
		//i__1 = *n;
		for (j = 1; j <= *n; ++j) {
		    if (*alpha != 1.) {
			//i__2 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,j) = *alpha * B(i,j);
/* L30: */
			}
		    }
		    for (k = *m; k >= 1; --k) {
			if (B(k,j) != 0.) {
			    if (nounit) {
				B(k,j) /= A(k,k);
			    }
			    //i__2 = k - 1;
			    for (i = 1; i <= k-1; ++i) {
				B(i,j) -= B(k,j) * A(i,k);
/* L40: */
			    }
			}
/* L50: */
		    }
/* L60: */
		}
	    } else {
		//i__1 = *n;
		for (j = 1; j <= *n; ++j) {
		    if (*alpha != 1.) {
			//i__2 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,j) = *alpha * B(i,j);
/* L70: */
			}
		    }
		    //i__2 = *m;
		    for (k = 1; k <= *m; ++k) {
			if (B(k,j) != 0.) {
			    if (nounit) {
				B(k,j) /= A(k,k);
			    }
			    //i__3 = *m;
			    for (i = k + 1; i <= *m; ++i) {
				B(i,j) -= B(k,j) * A(i,k);
/* L80: */
			    }
			}
/* L90: */
		    }
/* L100: */
		}
	    }
	} else {

/*           Form  B := alpha*inv( A' )*B. */

	    if (upper) {
		//i__1 = *n;
		for (j = 1; j <= *n; ++j) {
		    //i__2 = *m;
		    for (i = 1; i <= *m; ++i) {
			temp = *alpha * B(i,j);
			//i__3 = i - 1;
			for (k = 1; k <= i-1; ++k) {
			    temp -= A(k,i) * B(k,j);
/* L110: */
			}
			if (nounit) {
			    temp /= A(i,i);
			}
			B(i,j) = temp;
/* L120: */
		    }
/* L130: */
		}
	    } else {
		//i__1 = *n;
		for (j = 1; j <= *n; ++j) {
		    for (i = *m; i >= 1; --i) {
			temp = *alpha * B(i,j);
			//i__2 = *m;
			for (k = i + 1; k <= *m; ++k) {
			    temp -= A(k,i) * B(k,j);
/* L140: */
			}
			if (nounit) {
			    temp /= A(i,i);
			}
			B(i,j) = temp;
/* L150: */
		    }
/* L160: */
		}
	    }
	}
    } else {
	if (lsame_(transa, "N")) {

/*           Form  B := alpha*B*inv( A ). */

	    if (upper) {
		//i__1 = *n;
		for (j = 1; j <= *n; ++j) {
		    if (*alpha != 1.) {
			//i__2 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,j) = *alpha * B(i,j);
/* L170: */
			}
		    }
		    //i__2 = j - 1;
		    for (k = 1; k <= j-1; ++k) {
			if (A(k,j) != 0.) {
			    //i__3 = *m;
			    for (i = 1; i <= *m; ++i) {
				B(i,j) -= A(k,j) * B(i,k);
/* L180: */
			    }
			}
/* L190: */
		    }
		    if (nounit) {
			temp = 1. / A(j,j);
			//i__2 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,j) = temp * B(i,j);
/* L200: */
			}
		    }
/* L210: */
		}
	    } else {
		for (j = *n; j >= 1; --j) {
		    if (*alpha != 1.) {
			//i__1 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,j) = *alpha * B(i,j);
/* L220: */
			}
		    }
		    //i__1 = *n;
		    for (k = j + 1; k <= *n; ++k) {
			if (A(k,j) != 0.) {
			    //i__2 = *m;
			    for (i = 1; i <= *m; ++i) {
				B(i,j) -= A(k,j) * B(i,k);
/* L230: */
			    }
			}
/* L240: */
		    }
		    if (nounit) {
			temp = 1. / A(j,j);
			//i__1 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,j) = temp * B(i,j);
/* L250: */
			}
		    }
/* L260: */
		}
	    }
	} else {

/*           Form  B := alpha*B*inv( A' ). */

	    if (upper) {
		for (k = *n; k >= 1; --k) {
		    if (nounit) {
			temp = 1. / A(k,k);
			//i__1 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,k) = temp * B(i,k);
/* L270: */
			}
		    }
		    //i__1 = k - 1;
		    for (j = 1; j <= k-1; ++j) {
			if (A(j,k) != 0.) {
			    temp = A(j,k);
			    //i__2 = *m;
			    for (i = 1; i <= *m; ++i) {
				B(i,j) -= temp * B(i,k);
/* L280: */
			    }
			}
/* L290: */
		    }
		    if (*alpha != 1.) {
			//i__1 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,k) = *alpha * B(i,k);
/* L300: */
			}
		    }
/* L310: */
		}
	    } else {
		//i__1 = *n;
		for (k = 1; k <= *n; ++k) {
		    if (nounit) {
			temp = 1. / A(k,k);
			//i__2 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,k) = temp * B(i,k);
/* L320: */
			}
		    }
		    //i__2 = *n;
		    for (j = k + 1; j <= *n; ++j) {
			if (A(j,k) != 0.) {
			    temp = A(j,k);
			    //i__3 = *m;
			    for (i = 1; i <= *m; ++i) {
				B(i,j) -= temp * B(i,k);
/* L330: */
			    }
			}
/* L340: */
		    }
		    if (*alpha != 1.) {
			//i__2 = *m;
			for (i = 1; i <= *m; ++i) {
			    B(i,k) = *alpha * B(i,k);
/* L350: */
			}
		    }
/* L360: */
		}
	    }
	}
    }

    return 0;

/*     End of DTRSM . */

} /* dtrsm_ */


