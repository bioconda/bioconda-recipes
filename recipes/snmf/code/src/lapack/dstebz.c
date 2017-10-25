#include "blaswrap.h"
/*  -- translated by f2c (version 19990503).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Common Block Declarations */

struct {
    doublereal ops, itcnt;
} latime_;

#define latime_1 latime_

/* Table of constant values */

static integer c__1 = 1;
static integer c_n1 = -1;
static integer c__3 = 3;
static integer c__2 = 2;
static integer c__0 = 0;

/* Subroutine */ int dstebz_(char *range, char *order, integer *n, doublereal 
	*vl, doublereal *vu, integer *il, integer *iu, doublereal *abstol, 
	doublereal *d__, doublereal *e, integer *m, integer *nsplit, 
	doublereal *w, integer *iblock, integer *isplit, doublereal *work, 
	integer *iwork, integer *info)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1, d__2, d__3, d__4, d__5;

    /* Builtin functions */
    double sqrt(doublereal), log(doublereal);

    /* Local variables */
    static integer iend, ioff, iout, itmp1, j, jdisc;
    extern logical lsame_(char *, char *);
    static integer iinfo;
    static doublereal atoli;
    static integer iwoff;
    static doublereal bnorm;
    static integer itmax;
    static doublereal wkill, rtoli, tnorm;
    static integer ib, jb, ie, je, nb;
    static doublereal gl;
    static integer im, in;
    extern doublereal dlamch_(char *);
    static integer ibegin;
    static doublereal gu;
    static integer iw;
    extern /* Subroutine */ int dlaebz_(integer *, integer *, integer *, 
	    integer *, integer *, integer *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, integer *,
	     doublereal *, doublereal *, integer *, integer *, doublereal *, 
	    integer *, integer *);
    static doublereal wl;
    static integer irange, idiscl;
    static doublereal safemn, wu;
    static integer idumma[1];
    extern integer ilaenv_(integer *, char *, char *, integer *, integer *, 
	    integer *, integer *, ftnlen, ftnlen);
    extern /* Subroutine */ int xerbla_(char *, integer *);
    static integer idiscu, iorder;
    static logical ncnvrg;
    static doublereal pivmin;
    static logical toofew;
    static integer nwl;
    static doublereal ulp, wlu, wul;
    static integer nwu;
    static doublereal tmp1, tmp2;


/*  -- LAPACK routine (instrumented to count operations, version 3.0) --   
       Univ. of Tennessee, Univ. of California Berkeley, NAG Ltd.,   
       Courant Institute, Argonne National Lab, and Rice University   
       June 30, 1999   

       Common block to return operation count and iteration count   
       ITCNT is initialized to 0, OPS is only incremented   

    Purpose   
    =======   

    DSTEBZ computes the eigenvalues of a symmetric tridiagonal   
    matrix T.  The user may ask for all eigenvalues, all eigenvalues   
    in the half-open interval (VL, VU], or the IL-th through IU-th   
    eigenvalues.   

    To avoid overflow, the matrix must be scaled so that its   
    largest element is no greater than overflow**(1/2) *   
    underflow**(1/4) in absolute value, and for greatest   
    accuracy, it should not be much smaller than that.   

    See W. Kahan "Accurate Eigenvalues of a Symmetric Tridiagonal   
    Matrix", Report CS41, Computer Science Dept., Stanford   
    University, July 21, 1966.   

    Arguments   
    =========   

    RANGE   (input) CHARACTER   
            = 'A': ("All")   all eigenvalues will be found.   
            = 'V': ("Value") all eigenvalues in the half-open interval   
                             (VL, VU] will be found.   
            = 'I': ("Index") the IL-th through IU-th eigenvalues (of the   
                             entire matrix) will be found.   

    ORDER   (input) CHARACTER   
            = 'B': ("By Block") the eigenvalues will be grouped by   
                                split-off block (see IBLOCK, ISPLIT) and   
                                ordered from smallest to largest within   
                                the block.   
            = 'E': ("Entire matrix")   
                                the eigenvalues for the entire matrix   
                                will be ordered from smallest to   
                                largest.   

    N       (input) INTEGER   
            The order of the tridiagonal matrix T.  N >= 0.   

    VL      (input) DOUBLE PRECISION   
    VU      (input) DOUBLE PRECISION   
            If RANGE='V', the lower and upper bounds of the interval to   
            be searched for eigenvalues.  Eigenvalues less than or equal   
            to VL, or greater than VU, will not be returned.  VL < VU.   
            Not referenced if RANGE = 'A' or 'I'.   

    IL      (input) INTEGER   
    IU      (input) INTEGER   
            If RANGE='I', the indices (in ascending order) of the   
            smallest and largest eigenvalues to be returned.   
            1 <= IL <= IU <= N, if N > 0; IL = 1 and IU = 0 if N = 0.   
            Not referenced if RANGE = 'A' or 'V'.   

    ABSTOL  (input) DOUBLE PRECISION   
            The absolute tolerance for the eigenvalues.  An eigenvalue   
            (or cluster) is considered to be located if it has been   
            determined to lie in an interval whose width is ABSTOL or   
            less.  If ABSTOL is less than or equal to zero, then ULP*|T|   
            will be used, where |T| means the 1-norm of T.   

            Eigenvalues will be computed most accurately when ABSTOL is   
            set to twice the underflow threshold 2*DLAMCH('S'), not zero.   

    D       (input) DOUBLE PRECISION array, dimension (N)   
            The n diagonal elements of the tridiagonal matrix T.   

    E       (input) DOUBLE PRECISION array, dimension (N-1)   
            The (n-1) off-diagonal elements of the tridiagonal matrix T.   

    M       (output) INTEGER   
            The actual number of eigenvalues found. 0 <= M <= N.   
            (See also the description of INFO=2,3.)   

    NSPLIT  (output) INTEGER   
            The number of diagonal blocks in the matrix T.   
            1 <= NSPLIT <= N.   

    W       (output) DOUBLE PRECISION array, dimension (N)   
            On exit, the first M elements of W will contain the   
            eigenvalues.  (DSTEBZ may use the remaining N-M elements as   
            workspace.)   

    IBLOCK  (output) INTEGER array, dimension (N)   
            At each row/column j where E(j) is zero or small, the   
            matrix T is considered to split into a block diagonal   
            matrix.  On exit, if INFO = 0, IBLOCK(i) specifies to which   
            block (from 1 to the number of blocks) the eigenvalue W(i)   
            belongs.  (DSTEBZ may use the remaining N-M elements as   
            workspace.)   

    ISPLIT  (output) INTEGER array, dimension (N)   
            The splitting points, at which T breaks up into submatrices.   
            The first submatrix consists of rows/columns 1 to ISPLIT(1),   
            the second of rows/columns ISPLIT(1)+1 through ISPLIT(2),   
            etc., and the NSPLIT-th consists of rows/columns   
            ISPLIT(NSPLIT-1)+1 through ISPLIT(NSPLIT)=N.   
            (Only the first NSPLIT elements will actually be used, but   
            since the user cannot know a priori what value NSPLIT will   
            have, N words must be reserved for ISPLIT.)   

    WORK    (workspace) DOUBLE PRECISION array, dimension (4*N)   

    IWORK   (workspace) INTEGER array, dimension (3*N)   

    INFO    (output) INTEGER   
            = 0:  successful exit   
            < 0:  if INFO = -i, the i-th argument had an illegal value   
            > 0:  some or all of the eigenvalues failed to converge or   
                  were not computed:   
                  =1 or 3: Bisection failed to converge for some   
                          eigenvalues; these eigenvalues are flagged by a   
                          negative block number.  The effect is that the   
                          eigenvalues may not be as accurate as the   
                          absolute and relative tolerances.  This is   
                          generally caused by unexpectedly inaccurate   
                          arithmetic.   
                  =2 or 3: RANGE='I' only: Not all of the eigenvalues   
                          IL:IU were found.   
                          Effect: M < IU+1-IL   
                          Cause:  non-monotonic arithmetic, causing the   
                                  Sturm sequence to be non-monotonic.   
                          Cure:   recalculate, using RANGE='A', and pick   
                                  out eigenvalues IL:IU.  In some cases,   
                                  increasing the PARAMETER "FUDGE" may   
                                  make things work.   
                  = 4:    RANGE='I', and the Gershgorin interval   
                          initially used was too small.  No eigenvalues   
                          were computed.   
                          Probable cause: your machine has sloppy   
                                          floating-point arithmetic.   
                          Cure: Increase the PARAMETER "FUDGE",   
                                recompile, and try again.   

    Internal Parameters   
    ===================   

    RELFAC  DOUBLE PRECISION, default = 2.0e0   
            The relative tolerance.  An interval (a,b] lies within   
            "relative tolerance" if  b-a < RELFAC*ulp*max(|a|,|b|),   
            where "ulp" is the machine precision (distance from 1 to   
            the next larger floating point number.)   

    FUDGE   DOUBLE PRECISION, default = 2   
            A "fudge factor" to widen the Gershgorin intervals.  Ideally,   
            a value of 1 should work, but on machines with sloppy   
            arithmetic, this needs to be larger.  The default for   
            publicly released versions should be large enough to handle   
            the worst machine around.  Note that this has no effect   
            on accuracy of the solution.   

    =====================================================================   


       Parameter adjustments */
    --iwork;
    --work;
    --isplit;
    --iblock;
    --w;
    --e;
    --d__;

    /* Function Body */
    *info = 0;

/*     Decode RANGE */

    if (lsame_(range, "A")) {
	irange = 1;
    } else if (lsame_(range, "V")) {
	irange = 2;
    } else if (lsame_(range, "I")) {
	irange = 3;
    } else {
	irange = 0;
    }

/*     Decode ORDER */

    if (lsame_(order, "B")) {
	iorder = 2;
    } else if (lsame_(order, "E")) {
	iorder = 1;
    } else {
	iorder = 0;
    }

/*     Check for Errors */

    if (irange <= 0) {
	*info = -1;
    } else if (iorder <= 0) {
	*info = -2;
    } else if (*n < 0) {
	*info = -3;
    } else if (irange == 2) {
	if (*vl >= *vu) {
	    *info = -5;
	}
    } else if (irange == 3 && (*il < 1 || *il > max(1,*n))) {
	*info = -6;
    } else if (irange == 3 && (*iu < min(*n,*il) || *iu > *n)) {
	*info = -7;
    }

    if (*info != 0) {
	i__1 = -(*info);
	xerbla_("DSTEBZ", &i__1);
	return 0;
    }

/*     Initialize error flags */

    *info = 0;
    ncnvrg = FALSE_;
    toofew = FALSE_;

/*     Quick return if possible */

    *m = 0;
    if (*n == 0) {
	return 0;
    }

/*     Simplifications: */

    if (irange == 3 && *il == 1 && *iu == *n) {
	irange = 1;
    }

/*     Get machine constants   
       NB is the minimum vector length for vector bisection, or 0   
       if only scalar is to be done. */

    safemn = dlamch_("S");
    ulp = dlamch_("P");
    latime_1.ops += 1;
    rtoli = ulp * 2.;
    nb = ilaenv_(&c__1, "DSTEBZ", " ", n, &c_n1, &c_n1, &c_n1, (ftnlen)6, (
	    ftnlen)1);
    if (nb <= 1) {
	nb = 0;
    }

/*     Special Case when N=1 */

    if (*n == 1) {
	*nsplit = 1;
	isplit[1] = 1;
	if (irange == 2 && (*vl >= d__[1] || *vu < d__[1])) {
	    *m = 0;
	} else {
	    w[1] = d__[1];
	    iblock[1] = 1;
	    *m = 1;
	}
	return 0;
    }

/*     Compute Splitting Points */

    *nsplit = 1;
    work[*n] = 0.;
    pivmin = 1.;

    latime_1.ops = latime_1.ops + (*n - 1) * 5 + 1;
/* DIR$ NOVECTOR */
    i__1 = *n;
    for (j = 2; j <= i__1; ++j) {
/* Computing 2nd power */
	d__1 = e[j - 1];
	tmp1 = d__1 * d__1;
/* Computing 2nd power */
	d__2 = ulp;
	if ((d__1 = d__[j] * d__[j - 1], abs(d__1)) * (d__2 * d__2) + safemn 
		> tmp1) {
	    isplit[*nsplit] = j - 1;
	    ++(*nsplit);
	    work[j - 1] = 0.;
	} else {
	    work[j - 1] = tmp1;
	    pivmin = max(pivmin,tmp1);
	}
/* L10: */
    }
    isplit[*nsplit] = *n;
    pivmin *= safemn;

/*     Compute Interval and ATOLI */

    if (irange == 3) {

/*        RANGE='I': Compute the interval containing eigenvalues   
                     IL through IU.   

          Compute Gershgorin interval for entire (split) matrix   
          and use it as the initial interval */

	gu = d__[1];
	gl = d__[1];
	tmp1 = 0.;

	latime_1.ops = latime_1.ops + (*n - 1) * 5 + 23;
	i__1 = *n - 1;
	for (j = 1; j <= i__1; ++j) {
	    tmp2 = sqrt(work[j]);
/* Computing MAX */
	    d__1 = gu, d__2 = d__[j] + tmp1 + tmp2;
	    gu = max(d__1,d__2);
/* Computing MIN */
	    d__1 = gl, d__2 = d__[j] - tmp1 - tmp2;
	    gl = min(d__1,d__2);
	    tmp1 = tmp2;
/* L20: */
	}

/* Computing MAX */
	d__1 = gu, d__2 = d__[*n] + tmp1;
	gu = max(d__1,d__2);
/* Computing MIN */
	d__1 = gl, d__2 = d__[*n] - tmp1;
	gl = min(d__1,d__2);
/* Computing MAX */
	d__1 = abs(gl), d__2 = abs(gu);
	tnorm = max(d__1,d__2);
	gl = gl - tnorm * 2. * ulp * *n - pivmin * 4.;
	gu = gu + tnorm * 2. * ulp * *n + pivmin * 2.;

/*        Compute Iteration parameters */

	itmax = (integer) ((log(tnorm + pivmin) - log(pivmin)) / log(2.)) + 2;
	if (*abstol <= 0.) {
	    atoli = ulp * tnorm;
	} else {
	    atoli = *abstol;
	}

	work[*n + 1] = gl;
	work[*n + 2] = gl;
	work[*n + 3] = gu;
	work[*n + 4] = gu;
	work[*n + 5] = gl;
	work[*n + 6] = gu;
	iwork[1] = -1;
	iwork[2] = -1;
	iwork[3] = *n + 1;
	iwork[4] = *n + 1;
	iwork[5] = *il - 1;
	iwork[6] = *iu;

	dlaebz_(&c__3, &itmax, n, &c__2, &c__2, &nb, &atoli, &rtoli, &pivmin, 
		&d__[1], &e[1], &work[1], &iwork[5], &work[*n + 1], &work[*n 
		+ 5], &iout, &iwork[1], &w[1], &iblock[1], &iinfo);

	if (iwork[6] == *iu) {
	    wl = work[*n + 1];
	    wlu = work[*n + 3];
	    nwl = iwork[1];
	    wu = work[*n + 4];
	    wul = work[*n + 2];
	    nwu = iwork[4];
	} else {
	    wl = work[*n + 2];
	    wlu = work[*n + 4];
	    nwl = iwork[2];
	    wu = work[*n + 3];
	    wul = work[*n + 1];
	    nwu = iwork[3];
	}

	if (nwl < 0 || nwl >= *n || nwu < 1 || nwu > *n) {
	    *info = 4;
	    return 0;
	}
    } else {

/*        RANGE='A' or 'V' -- Set ATOLI */

	latime_1.ops = latime_1.ops + 3 + ((*n - 2) << 1);
/* Computing MAX */
	d__3 = abs(d__[1]) + abs(e[1]), d__4 = (d__1 = d__[*n], abs(d__1)) + (
		d__2 = e[*n - 1], abs(d__2));
	tnorm = max(d__3,d__4);

	i__1 = *n - 1;
	for (j = 2; j <= i__1; ++j) {
/* Computing MAX */
	    d__4 = tnorm, d__5 = (d__1 = d__[j], abs(d__1)) + (d__2 = e[j - 1]
		    , abs(d__2)) + (d__3 = e[j], abs(d__3));
	    tnorm = max(d__4,d__5);
/* L30: */
	}

	if (*abstol <= 0.) {
	    atoli = ulp * tnorm;
	} else {
	    atoli = *abstol;
	}

	if (irange == 2) {
	    wl = *vl;
	    wu = *vu;
	} else {
	    wl = 0.;
	    wu = 0.;
	}
    }

/*     Find Eigenvalues -- Loop Over Blocks and recompute NWL and NWU.   
       NWL accumulates the number of eigenvalues .le. WL,   
       NWU accumulates the number of eigenvalues .le. WU */

    *m = 0;
    iend = 0;
    *info = 0;
    nwl = 0;
    nwu = 0;

    i__1 = *nsplit;
    for (jb = 1; jb <= i__1; ++jb) {
	ioff = iend;
	ibegin = ioff + 1;
	iend = isplit[jb];
	in = iend - ioff;

	if (in == 1) {

/*           Special Case -- IN=1 */

	    latime_1.ops += 4;
	    if (irange == 1 || wl >= d__[ibegin] - pivmin) {
		++nwl;
	    }
	    if (irange == 1 || wu >= d__[ibegin] - pivmin) {
		++nwu;
	    }
	    if (irange == 1 || (wl < d__[ibegin] - pivmin && wu >= d__[ibegin] 
		    - pivmin)) {
		++(*m);
		w[*m] = d__[ibegin];
		iblock[*m] = jb;
	    }
	} else {

/*           General Case -- IN > 1   

             Compute Gershgorin Interval   
             and use it as the initial interval */

	    gu = d__[ibegin];
	    gl = d__[ibegin];
	    tmp1 = 0.;

	    latime_1.ops = latime_1.ops + ((iend - ibegin) << 2) + 13;
	    i__2 = iend - 1;
	    for (j = ibegin; j <= i__2; ++j) {
		tmp2 = (d__1 = e[j], abs(d__1));
/* Computing MAX */
		d__1 = gu, d__2 = d__[j] + tmp1 + tmp2;
		gu = max(d__1,d__2);
/* Computing MIN */
		d__1 = gl, d__2 = d__[j] - tmp1 - tmp2;
		gl = min(d__1,d__2);
		tmp1 = tmp2;
/* L40: */
	    }

/* Computing MAX */
	    d__1 = gu, d__2 = d__[iend] + tmp1;
	    gu = max(d__1,d__2);
/* Computing MIN */
	    d__1 = gl, d__2 = d__[iend] - tmp1;
	    gl = min(d__1,d__2);
/* Computing MAX */
	    d__1 = abs(gl), d__2 = abs(gu);
	    bnorm = max(d__1,d__2);
	    gl = gl - bnorm * 2. * ulp * in - pivmin * 2.;
	    gu = gu + bnorm * 2. * ulp * in + pivmin * 2.;

/*           Compute ATOLI for the current submatrix */

	    if (*abstol <= 0.) {
/* Computing MAX */
		d__1 = abs(gl), d__2 = abs(gu);
		atoli = ulp * max(d__1,d__2);
	    } else {
		atoli = *abstol;
	    }

	    if (irange > 1) {
		if (gu < wl) {
		    nwl += in;
		    nwu += in;
		    goto L70;
		}
		gl = max(gl,wl);
		gu = min(gu,wu);
		if (gl >= gu) {
		    goto L70;
		}
	    }

/*           Set Up Initial Interval */

	    work[*n + 1] = gl;
	    work[*n + in + 1] = gu;
	    dlaebz_(&c__1, &c__0, &in, &in, &c__1, &nb, &atoli, &rtoli, &
		    pivmin, &d__[ibegin], &e[ibegin], &work[ibegin], idumma, &
		    work[*n + 1], &work[*n + (in << 1) + 1], &im, &iwork[1], &
		    w[*m + 1], &iblock[*m + 1], &iinfo);

	    nwl += iwork[1];
	    nwu += iwork[in + 1];
	    iwoff = *m - iwork[1];

/*           Compute Eigenvalues */

	    latime_1.ops += 8;
	    itmax = (integer) ((log(gu - gl + pivmin) - log(pivmin)) / log(2.)
		    ) + 2;
	    dlaebz_(&c__2, &itmax, &in, &in, &c__1, &nb, &atoli, &rtoli, &
		    pivmin, &d__[ibegin], &e[ibegin], &work[ibegin], idumma, &
		    work[*n + 1], &work[*n + (in << 1) + 1], &iout, &iwork[1],
		     &w[*m + 1], &iblock[*m + 1], &iinfo);

/*           Copy Eigenvalues Into W and IBLOCK   
             Use -JB for block number for unconverged eigenvalues. */

	    latime_1.ops += iout << 1;
	    i__2 = iout;
	    for (j = 1; j <= i__2; ++j) {
		tmp1 = (work[j + *n] + work[j + in + *n]) * .5;

/*              Flag non-convergence. */

		if (j > iout - iinfo) {
		    ncnvrg = TRUE_;
		    ib = -jb;
		} else {
		    ib = jb;
		}
		i__3 = iwork[j + in] + iwoff;
		for (je = iwork[j] + 1 + iwoff; je <= i__3; ++je) {
		    w[je] = tmp1;
		    iblock[je] = ib;
/* L50: */
		}
/* L60: */
	    }

	    *m += im;
	}
L70:
	;
    }

/*     If RANGE='I', then (WL,WU) contains eigenvalues NWL+1,...,NWU   
       If NWL+1 < IL or NWU > IU, discard extra eigenvalues. */

    if (irange == 3) {
	im = 0;
	idiscl = *il - 1 - nwl;
	idiscu = nwu - *iu;

	if (idiscl > 0 || idiscu > 0) {
	    i__1 = *m;
	    for (je = 1; je <= i__1; ++je) {
		if (w[je] <= wlu && idiscl > 0) {
		    --idiscl;
		} else if (w[je] >= wul && idiscu > 0) {
		    --idiscu;
		} else {
		    ++im;
		    w[im] = w[je];
		    iblock[im] = iblock[je];
		}
/* L80: */
	    }
	    *m = im;
	}
	if (idiscl > 0 || idiscu > 0) {

/*           Code to deal with effects of bad arithmetic:   
             Some low eigenvalues to be discarded are not in (WL,WLU],   
             or high eigenvalues to be discarded are not in (WUL,WU]   
             so just kill off the smallest IDISCL/largest IDISCU   
             eigenvalues, by simply finding the smallest/largest   
             eigenvalue(s).   

             (If N(w) is monotone non-decreasing, this should never   
                 happen.) */

	    if (idiscl > 0) {
		wkill = wu;
		i__1 = idiscl;
		for (jdisc = 1; jdisc <= i__1; ++jdisc) {
		    iw = 0;
		    i__2 = *m;
		    for (je = 1; je <= i__2; ++je) {
			if (iblock[je] != 0 && (w[je] < wkill || iw == 0)) {
			    iw = je;
			    wkill = w[je];
			}
/* L90: */
		    }
		    iblock[iw] = 0;
/* L100: */
		}
	    }
	    if (idiscu > 0) {

		wkill = wl;
		i__1 = idiscu;
		for (jdisc = 1; jdisc <= i__1; ++jdisc) {
		    iw = 0;
		    i__2 = *m;
		    for (je = 1; je <= i__2; ++je) {
			if (iblock[je] != 0 && (w[je] > wkill || iw == 0)) {
			    iw = je;
			    wkill = w[je];
			}
/* L110: */
		    }
		    iblock[iw] = 0;
/* L120: */
		}
	    }
	    im = 0;
	    i__1 = *m;
	    for (je = 1; je <= i__1; ++je) {
		if (iblock[je] != 0) {
		    ++im;
		    w[im] = w[je];
		    iblock[im] = iblock[je];
		}
/* L130: */
	    }
	    *m = im;
	}
	if (idiscl < 0 || idiscu < 0) {
	    toofew = TRUE_;
	}
    }

/*     If ORDER='B', do nothing -- the eigenvalues are already sorted   
          by block.   
       If ORDER='E', sort the eigenvalues from smallest to largest */

    if (iorder == 1 && *nsplit > 1) {
	i__1 = *m - 1;
	for (je = 1; je <= i__1; ++je) {
	    ie = 0;
	    tmp1 = w[je];
	    i__2 = *m;
	    for (j = je + 1; j <= i__2; ++j) {
		if (w[j] < tmp1) {
		    ie = j;
		    tmp1 = w[j];
		}
/* L140: */
	    }

	    if (ie != 0) {
		itmp1 = iblock[ie];
		w[ie] = w[je];
		iblock[ie] = iblock[je];
		w[je] = tmp1;
		iblock[je] = itmp1;
	    }
/* L150: */
	}
    }

    *info = 0;
    if (ncnvrg) {
	++(*info);
    }
    if (toofew) {
	*info += 2;
    }
    return 0;

/*     End of DSTEBZ */

} /* dstebz_ */

