/*  Copyright 1990-2004 The MathWorks, Inc. */
/*  $Revision: 1.5.4.2 $ */
/* 
 *   File : sfun_frmunbuff_wrapper.h
 *   Abstract:
 *      External definition of routine that implement the unbuffer
 *
 */

#ifdef __cplusplus
extern "C" {
#endif

extern void sfun_frm_unbuff_wrapper(int count, int nChans, int frmSize,
                                    real_T *y, real_T *u);

#ifdef __cplusplus
}
#endif

/* [eof] sfun_frmunbuff_wrapper.h */
