#ifndef LPK_H
#define LPK_H

#include "f2c.h"

int dgetrf_(integer *m, integer *n, doublereal *a, integer *
        lda, integer *ipiv, integer *info);

int dgetri_(integer *n, doublereal *a, integer *lda, integer
        *ipiv, doublereal *work, integer *lwork, integer *info);

int dgees_(char *jobvs, char *sort, L_fp select, integer *n,
        doublereal *a, integer *lda, integer *sdim, doublereal *wr,
        doublereal *wi, doublereal *vs, integer *ldvs, doublereal *work,
        integer *lwork, logical *bwork, integer *info);

int dtrsyl_(char *trana, char *tranb, integer *isgn, integer
        *m, integer *n, doublereal *a, integer *lda, doublereal *b, integer *
        ldb, doublereal *c__, integer *ldc, doublereal *scale, integer *info);

int dsyevr_(char *jobz, char *range, char *uplo, integer *n,
        doublereal *a, integer *lda, doublereal *vl, doublereal *vu, integer *
        il, integer *iu, doublereal *abstol, integer *m, doublereal *w,
        doublereal *z__, integer *ldz, integer *isuppz, doublereal *work,
        integer *lwork, integer *iwork, integer *liwork, integer *info);

#endif // INVERSE_H

