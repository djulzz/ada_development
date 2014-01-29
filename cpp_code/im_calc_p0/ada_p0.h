/**
 * @file  ada_p0.h
 *
 * @brief Generic Motion ADA declaration file.
 *
 * @author Julien Esposito on 1/10/14.
 *
 * @Copyright (c) 2014 Blast Motion, Inc. All rights reserved.
 */

#ifndef ADA_P0_H
#define ADA_P0_H

/******************************************************************************/
/******************************************************************************/
#include "ada_externals.h"


/******************************************************************************/
/******************************************************************************/
#ifdef __cplusplus
extern "C"
{
#endif
    

/******************************************************************************/
/******************************************************************************/
bool adaExecP0( ada_sample_t* pSample, ada_capture_t* pCapture );
void RecordIndices(
                   int32* absolute_sample_index,
                   int16* relO,
                   int16* relP,
                   uint16* idx1, uint16* idx2 );
void adaInitP0( void );
    
    
#ifdef __cplusplus
}
#endif

#endif /* ADA_P0_H defined */
