#include "blaswrap.h"
#include "f2c.h"

/* Subroutine */ int dlascl_(char *type__, integer *kl, integer *ku, 
	doublereal *cfrom, doublereal *cto, integer *m, integer *n, 
	doublereal *a, integer *lda, integer *info)
{
/*  -- LAPACK auxiliary routine (version 3.1) --   
       Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..   
       November 2006   


    Purpose   
    =======   

    DLASCL multiplies the M by N real matrix A by the real scalar   
    CTO/CFROM.  This is done without over/underflow as long as the final   
    result CTO*A(I,J)/CFROM does not over/underflow. TYPE specifies that   
    A may be full, upper triangular, lower triangular, upper Hessenberg,   
    or banded.   

    Arguments   
    =========   

    TYPE    (input) CHARACTER*1   
            TYPE indices the storage type of the input matrix.   
            = 'G':  A is a full matrix.   
            = 'L':  A is a lower triangular matrix.   
            = 'U':  A is an upper triangular matrix.   
            = 'H':  A is an upper Hessenberg matrix.   
            = 'B':  A is a symmetric band matrix with lower bandwidth KL   
                    and upper bandwidth KU and with the only the lower   
                    half stored.   
            = 'Q':  A is a symmetric band matrix with lower bandwidth KL   
                    and upper bandwidth KU and with the only the upper   
                    half stored.   
            = 'Z':  A is a band matrix with lower bandwidth KL and upper   
                    bandwidth KU.   

    KL      (input) INTEGER   
            The lower bandwidth of A.  Referenced only if TYPE = 'B',   
            'Q' or 'Z'.   

    KU      (input) INTEGER   
            The upper bandwidth of A.  Referenced only if TYPE = 'B',   
            'Q' or 'Z'.   

    CFROM   (input) DOUBLE PRECISION   
    CTO     (input) DOUBLE PRECISION   
            The matrix A is multiplied by CTO/CFROM. A(I,J) is computed   
            without over/underflow if the final result CTO*A(I,J)/CFROM   
            can be represented without over/underflow.  CFROM must be   
            nonzero.   

    M       (input) INTEGER   
            The number of rows of the matrix A.  M >= 0.   

    N       (input) INTEGER   
            The number of columns of the matrix A.  N >= 0.   

    A       (input/output) DOUBLE PRECISION array, dimension (LDA,N)   
            The matrix to be multiplied by CTO/CFROM.  See TYPE for the   
            storage type.   

    LDA     (input) INTEGER   
            The leading dimension of the array A.  LDA >= max(1,M).   

    INFO    (output) INTEGER   
            0  - successful exit   
            <0 - if INFO = -i, the i-th argument had an illegal value.   

    =====================================================================   


       Test the input arguments   

       Parameter adjustments */
    /* System generated locals */
    integer a_dim1, a_offset, i__1, i__2, i__3, i__4, i__5;
    /* Local variables */
    static integer i__, j, k1, k2, k3, k4;
    static doublereal mul, cto1;
    static logical done;
    static doublereal ctoc;
    extern logical lsame_(char *, char *);
    static integer itype;
    static doublereal cfrom1;
    extern doublereal dlamch_(char *);
    static doublereal cfromc;
    extern /* Subroutine */ int xerbla_(char *, integer *);
    static doublereal bignum, smlnum;

    a_dim1 = *lda;
    a_offset = 1 + a_dim1;
    a -= a_offset;

    /* Function Body */
    *info = 0;

    if (lsame_(type__, "G")) {
	itype = 0;
    } else if (lsame_(type__, "L")) {
	itype = 1;
    } else if (lsame_(type__, "U")) {
	itype = 2;
    } else if (lsame_(type__, "H")) {
	itype = 3;
    } else if (lsame_(type__, "B")) {
	itype = 4;
    } else if (lsame_(type__, "Q")) {
	itype = 5;
    } else if (lsame_(type__, "Z")) {
	itype = 6;
    } else {
	itype = -1;
    }

    if (itype == -1) {
	*info = -1;
    } else if (*cfrom == 0.) {
	*info = -4;
    } else if (*m < 0) {
	*info = -6;
    } else if (*n < 0 || (itype == 4 && *n != *m) || (itype == 5 && *n != *m)) {
	*info = -7;
    } else if (itype <= 3 && *lda < max(1,*m)) {
	*info = -9;
    } else if (itype >= 4) {
/* Computing MAX */
	i__1 = *m - 1;
	if (*kl < 0 || *kl > max(i__1,0)) {
	    *info = -2;
	} else /* if(complicated condition) */ {
/* Computing MAX */
	    i__1 = *n - 1;
	    if (*ku < 0 || *ku > max(i__1,0) || ((itype == 4 || itype == 5) && 
		    *kl != *ku)) {
		*info = -3;
	    } else if ((itype == 4 && *lda < *kl + 1) || (itype == 5 && *lda < *
		    ku + 1) || (itype == 6 && *lda < (*kl << 1) + *ku + 1)) {
		*info = -9;
	    }
	}
    }

    if (*info != 0) {
	i__1 = -(*info);
	xerbla_("DLASCL", &i__1);
	return 0;
    }

/*     Quick return if possible */

    if (*n == 0 || *m == 0) {
	return 0;
    }

/*     Get machine parameters */

    smlnum = dlamch_("S");
    bignum = 1. / smlnum;

    cfromc = *cfrom;
    ctoc = *cto;

L10:
    cfrom1 = cfromc * smlnum;
    cto1 = ctoc / bignum;
    if (abs(cfrom1) > abs(ctoc) && ctoc != 0.) {
	mul = smlnum;
	done = FALSE_;
	cfromc = cfrom1;
    } else if (abs(cto1) > abs(cfromc)) {
	mul = bignum;
	done = FALSE_;
	ctoc = cto1;
    } else {
	mul = ctoc / cfromc;
	done = TRUE_;
    }

    if (itype == 0) {

/*        Full matrix */

	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
	    i__2 = *m;
	    for (i__ = 1; i__ <= i__2; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L20: */
	    }
/* L30: */
	}

    } else if (itype == 1) {

/*        Lower triangular matrix */

	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
	    i__2 = *m;
	    for (i__ = j; i__ <= i__2; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L40: */
	    }
/* L50: */
	}

    } else if (itype == 2) {

/*        Upper triangular matrix */

	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
	    i__2 = min(j,*m);
	    for (i__ = 1; i__ <= i__2; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L60: */
	    }
/* L70: */
	}

    } else if (itype == 3) {

/*        Upper Hessenberg matrix */

	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
/* Computing MIN */
	    i__3 = j + 1;
	    i__2 = min(i__3,*m);
	    for (i__ = 1; i__ <= i__2; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L80: */
	    }
/* L90: */
	}

    } else if (itype == 4) {

/*        Lower half of a symmetric band matrix */

	k3 = *kl + 1;
	k4 = *n + 1;
	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
/* Computing MIN */
	    i__3 = k3, i__4 = k4 - j;
	    i__2 = min(i__3,i__4);
	    for (i__ = 1; i__ <= i__2; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L100: */
	    }
/* L110: */
	}

    } else if (itype == 5) {

/*        Upper half of a symmetric band matrix */

	k1 = *ku + 2;
	k3 = *ku + 1;
	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
/* Computing MAX */
	    i__2 = k1 - j;
	    i__3 = k3;
	    for (i__ = max(i__2,1); i__ <= i__3; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L120: */
	    }
/* L130: */
	}

    } else if (itype == 6) {

/*        Band matrix */

	k1 = *kl + *ku + 2;
	k2 = *kl + 1;
	k3 = (*kl << 1) + *ku + 1;
	k4 = *kl + *ku + 1 + *m;
	i__1 = *n;
	for (j = 1; j <= i__1; ++j) {
/* Computing MAX */
	    i__3 = k1 - j;
/* Computing MIN */
	    i__4 = k3, i__5 = k4 - j;
	    i__2 = min(i__4,i__5);
	    for (i__ = max(i__3,k2); i__ <= i__2; ++i__) {
		a[i__ + j * a_dim1] *= mul;
/* L140: */
	    }
/* L150: */
	}

    }

    if (! done) {
	goto L10;
    }

    return 0;

/*     End of DLASCL */

} /* dlascl_ */

