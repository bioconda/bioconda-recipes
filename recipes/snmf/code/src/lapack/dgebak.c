#include "blaswrap.h"
#include "f2c.h"

/* Subroutine */ int dgebak_(char *job, char *side, integer *n, integer *ilo, 
	integer *ihi, doublereal *scale, integer *m, doublereal *v, integer *
	ldv, integer *info)
{
/*  -- LAPACK routine (version 3.1) --   
       Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..   
       November 2006   


    Purpose   
    =======   

    DGEBAK forms the right or left eigenvectors of a real general matrix   
    by backward transformation on the computed eigenvectors of the   
    balanced matrix output by DGEBAL.   

    Arguments   
    =========   

    JOB     (input) CHARACTER*1   
            Specifies the type of backward transformation required:   
            = 'N', do nothing, return immediately;   
            = 'P', do backward transformation for permutation only;   
            = 'S', do backward transformation for scaling only;   
            = 'B', do backward transformations for both permutation and   
                   scaling.   
            JOB must be the same as the argument JOB supplied to DGEBAL.   

    SIDE    (input) CHARACTER*1   
            = 'R':  V contains right eigenvectors;   
            = 'L':  V contains left eigenvectors.   

    N       (input) INTEGER   
            The number of rows of the matrix V.  N >= 0.   

    ILO     (input) INTEGER   
    IHI     (input) INTEGER   
            The integers ILO and IHI determined by DGEBAL.   
            1 <= ILO <= IHI <= N, if N > 0; ILO=1 and IHI=0, if N=0.   

    SCALE   (input) DOUBLE PRECISION array, dimension (N)   
            Details of the permutation and scaling factors, as returned   
            by DGEBAL.   

    M       (input) INTEGER   
            The number of columns of the matrix V.  M >= 0.   

    V       (input/output) DOUBLE PRECISION array, dimension (LDV,M)   
            On entry, the matrix of right or left eigenvectors to be   
            transformed, as returned by DHSEIN or DTREVC.   
            On exit, V is overwritten by the transformed eigenvectors.   

    LDV     (input) INTEGER   
            The leading dimension of the array V. LDV >= max(1,N).   

    INFO    (output) INTEGER   
            = 0:  successful exit   
            < 0:  if INFO = -i, the i-th argument had an illegal value.   

    =====================================================================   


       Decode and Test the input parameters   

       Parameter adjustments */
    /* System generated locals */
    integer v_dim1, v_offset, i__1;
    /* Local variables */
    static integer i__, k;
    static doublereal s;
    static integer ii;
    extern /* Subroutine */ int dscal_(integer *, doublereal *, doublereal *, 
	    integer *);
    extern logical lsame_(char *, char *);
    extern /* Subroutine */ int dswap_(integer *, doublereal *, integer *, 
	    doublereal *, integer *);
    static logical leftv;
    extern /* Subroutine */ int xerbla_(char *, integer *);
    static logical rightv;

    --scale;
    v_dim1 = *ldv;
    v_offset = 1 + v_dim1;
    v -= v_offset;

    /* Function Body */
    rightv = lsame_(side, "R");
    leftv = lsame_(side, "L");

    *info = 0;
    if (! lsame_(job, "N") && ! lsame_(job, "P") && ! lsame_(job, "S") 
	    && ! lsame_(job, "B")) {
	*info = -1;
    } else if (! rightv && ! leftv) {
	*info = -2;
    } else if (*n < 0) {
	*info = -3;
    } else if (*ilo < 1 || *ilo > max(1,*n)) {
	*info = -4;
    } else if (*ihi < min(*ilo,*n) || *ihi > *n) {
	*info = -5;
    } else if (*m < 0) {
	*info = -7;
    } else if (*ldv < max(1,*n)) {
	*info = -9;
    }
    if (*info != 0) {
	i__1 = -(*info);
	xerbla_("DGEBAK", &i__1);
	return 0;
    }

/*     Quick return if possible */

    if (*n == 0) {
	return 0;
    }
    if (*m == 0) {
	return 0;
    }
    if (lsame_(job, "N")) {
	return 0;
    }

    if (*ilo == *ihi) {
	goto L30;
    }

/*     Backward balance */

    if (lsame_(job, "S") || lsame_(job, "B")) {

	if (rightv) {
	    i__1 = *ihi;
	    for (i__ = *ilo; i__ <= i__1; ++i__) {
		s = scale[i__];
		dscal_(m, &s, &v[i__ + v_dim1], ldv);
/* L10: */
	    }
	}

	if (leftv) {
	    i__1 = *ihi;
	    for (i__ = *ilo; i__ <= i__1; ++i__) {
		s = 1. / scale[i__];
		dscal_(m, &s, &v[i__ + v_dim1], ldv);
/* L20: */
	    }
	}

    }

/*     Backward permutation   

       For  I = ILO-1 step -1 until 1,   
                IHI+1 step 1 until N do -- */

L30:
    if (lsame_(job, "P") || lsame_(job, "B")) {
	if (rightv) {
	    i__1 = *n;
	    for (ii = 1; ii <= i__1; ++ii) {
		i__ = ii;
		if (i__ >= *ilo && i__ <= *ihi) {
		    goto L40;
		}
		if (i__ < *ilo) {
		    i__ = *ilo - ii;
		}
		k = (integer) scale[i__];
		if (k == i__) {
		    goto L40;
		}
		dswap_(m, &v[i__ + v_dim1], ldv, &v[k + v_dim1], ldv);
L40:
		;
	    }
	}

	if (leftv) {
	    i__1 = *n;
	    for (ii = 1; ii <= i__1; ++ii) {
		i__ = ii;
		if (i__ >= *ilo && i__ <= *ihi) {
		    goto L50;
		}
		if (i__ < *ilo) {
		    i__ = *ilo - ii;
		}
		k = (integer) scale[i__];
		if (k == i__) {
		    goto L50;
		}
		dswap_(m, &v[i__ + v_dim1], ldv, &v[k + v_dim1], ldv);
L50:
		;
	    }
	}
    }

    return 0;

/*     End of DGEBAK */

} /* dgebak_ */

