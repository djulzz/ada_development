//
//  p1.cpp
//
//  Created by Julien Esposito on 12/17/13.
//  Copyright (c) 2013 Blast Motion. All rights reserved.
//


/******************************************************************************/
/******************************************************************************/
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "ada.h"


/******************************************************************************/
/******************************************************************************/
#define g_ON                              1
#define g_OFF                             0

//% Define Drawing Modes
#define g_DRAWING_OFF                     g_OFF
#define g_DRAWING_ON                      g_ON
#define g_DRAWING_MODE                    g_DRAWING_OFF

//% Define for the Algo mode (one shot VS. continuous)
#define g_ALGO_MODE_ONE_SHOT              1
#define g_ALGO_MODE_CONTINUOUS_STREAMING  2
#define g_ALGO_MODE                       g_ALGO_MODE_CONTINUOUS_STREAMING
#define g_ALGO_UPLOAD_MODE_FULL_CAPACITY  1
#define g_ALGO_UPLOAD_MODE_RELEVANT_ONLY  2
#define g_ALGO_UPLOAD_MODE_WAIT_PUSH      3
#define g_ALGO_UPLOAD_MODE                g_ALGO_UPLOAD_MODE_WAIT_PUSH

//% Define Activity-specific Constants
#define g_SPRINTING_MAG_THRESHOLD         1005
#define g_SPRINTING_DISC_THRESHOLD        1200
#define g_RUNNING_DISC_THRESHOLD          1000
#define g_JUMPING_DISC_THRESHOLD          1700
#define g_JUMPING_MAGN_THRESHOLD          2250

#define g_MIN_NUM_SAMPLES_BETWEEN_CYCLES  30
#define g_MAX_NUM_SAMPLES_BETWEEN_CYCLES  400
#define g_MAG_THRESHOLD                   g_SPRINTING_MAG_THRESHOLD
#define g_DISC_THRESHOLD                  g_SPRINTING_DISC_THRESHOLD

#define g_MAG_THRESHOLD_SQUARED           ( g_SPRINTING_MAG_THRESHOLD ) * ( g_SPRINTING_MAG_THRESHOLD )
#define g_DISC_THRESHOLD_SQUARED          ( g_SPRINTING_DISC_THRESHOLD ) * ( g_SPRINTING_DISC_THRESHOLD )

//% Define Simulation Constants
#define g_SENSOR_HARDWARE_EMULATION_ON    g_ON
#define g_SENSOR_HARDWARE_EMULATION_OFF   g_OFF
#define g_SENSOR_HARDWARE_EMULATION_MODE  g_SENSOR_HARDWARE_EMULATION_OFF
#define g_KEEP_TRACK_OFF_ALL_CYCLES       g_OFF

//% Computer memory specific Constants
#define g_NUMBER_SAMPLE_CURRENT_BUFFER	  1600
#define g_MAX_NUM_CYCLE_LOCATIONS         54

//% Buffer Relevant activity fullness
#define g_CRITICAL_PERCENT                50.0
#define g_MAX_NUM_ELEMENTS                16000
#define g_MAX_NUMBER_BUFFERS_TO_UPLOAD    10

#define INDEX_T                           0
#define INDEX_A                           1

#define g_NUMBER_SAMPLES_BEFORE_FIRST_INTERESTING_SAMPLE    4
#define g_MEANINGLESS_DATA_REQUIRED                         g_ON
#define g_WAIT_FOR_FULL_BUFFER                              g_ON


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
typedef struct _perf_info_t
{
    _int32_t in_buffer_cycle_locations[ g_MAX_NUM_CYCLE_LOCATIONS ];
    _uint32_t cycle[ g_MAX_NUM_CYCLE_LOCATIONS ];

    _uint32_t a_prev;
    _uint32_t a_curr;
    _uint32_t nCycle;

    _int32_t idx_cur_sample;
    _uint32_t numCycle_Locations;

    _int32_t in_buffer1;
    _int32_t in_buffer2;
    _uint32_t numBuffersProcessed;
    _uint32_t numUploads;

    _uint32_t verbose_level;
    _uint32_t sample_count;

    _bool_t firstSampleOfCapture;
    _bool_t manual_reset_requested;
    _bool_t warning_issued;
} perf_info_t;

/******************************************************************************/
/******************************************************************************/
static perf_info_t _p1;
static perf_info_t *perf_info = &_p1;


/******************************************************************************/
/******************************************************************************/
_bool_t im_calc_p1_rev01( _uint32_t new_a );
void ResetBufferIndices_rev01( void );
void CalculatePercentageRelevantActivity_rev01( float* percentageRelevantActivity );
void UpdateBufferRelativeCycleIndices_rev01( void );
void DetectActivityDiscontinuity_rev01( void );
_bool_t CheckIfCurrentBufferNeedsToBeUploaded_rev01( void );


/******************************************************************************/
/******************************************************************************/
_bool_t im_calc_p1_rev01( _uint32_t new_a )
{
    perf_info->idx_cur_sample = perf_info->idx_cur_sample + 1;

    _bool_t anotherBufferCompletelyFull = ( ( perf_info->idx_cur_sample + 1 )  % g_NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 ;
    //    anotherBufferCompletelyFull = anotherBufferCompletelyFull && ( perf_info->idx_cur_sample != 0 );

    if( true == anotherBufferCompletelyFull )   {
        perf_info->numBuffersProcessed = perf_info->numBuffersProcessed + 1;
        if( perf_info->verbose_level >= 1 )
            CustomPrintf( "Buffer %li processed\n", perf_info->numBuffersProcessed );
    }

    UpdateBufferRelativeCycleIndices_rev01( );

    perf_info->a_prev = perf_info->a_curr;
    perf_info->a_curr = new_a;

    DetectActivityDiscontinuity_rev01( );

    _bool_t res = CheckIfCurrentBufferNeedsToBeUploaded_rev01( );
    return res;
}


/******************************************************************************/
/******************************************************************************/
void ResetBufferIndices_rev01( void )
{
    perf_info->nCycle = 0;
    perf_info->warning_issued = false;
    perf_info->numCycle_Locations = 0;
    perf_info->in_buffer1 = -1;
    perf_info->in_buffer2 = -1;
    return;
}


/******************************************************************************/
/******************************************************************************/
void CalculatePercentageRelevantActivity_rev01( float* percentageRelevantActivity )
{
    _uint32_t numberSamplesInRelevantActivity = 0;
    _uint32_t nCycle = perf_info->nCycle;

    if( nCycle >= 2 )   {
        for( size_t k = 0; k < ( nCycle - 1 ); k++ ) {
            _int32_t len = ( _uint32_t )( perf_info->cycle[ k + 1 ] - perf_info->cycle[ k ] + 1 );
            if( len > 0 )
                numberSamplesInRelevantActivity = numberSamplesInRelevantActivity + len;
        }
    }
    *percentageRelevantActivity = ( ( float )numberSamplesInRelevantActivity / ( float )g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100.0f;

    if( ( *percentageRelevantActivity >= g_CRITICAL_PERCENT ) && ( perf_info->warning_issued == false ) ) {
        perf_info->warning_issued = true;
        if( perf_info->verbose_level > 1 )
            CustomPrintf( "Warning: data is worth being recorded!\n" );

        _uint32_t nLeft = g_NUMBER_SAMPLE_CURRENT_BUFFER - numberSamplesInRelevantActivity;
        if( perf_info->verbose_level > 1 )
            CustomPrintf( "samples left to accumulate before meaningful data starts being erased = %lif\n", nLeft );
    }
    return;
}


/******************************************************************************/
/******************************************************************************/
void UpdateBufferRelativeCycleIndices_rev01( void )
{
    perf_info->in_buffer1 = ( _int32_t )( -1 );
    perf_info->in_buffer2 = ( _int32_t )( -1 );

    size_t numCycle_Locations = perf_info->numCycle_Locations;
    if( numCycle_Locations > 0 ) {
        for( size_t k = 0; k < numCycle_Locations; k++ ) {
            perf_info->in_buffer_cycle_locations[ k ] = perf_info->in_buffer_cycle_locations[ k ] - 1;
        }

        for( size_t k = 0; k < numCycle_Locations; k++ ) {
            if( perf_info->in_buffer_cycle_locations[ k ] >= 0 ) {
                perf_info->in_buffer1 = perf_info->in_buffer_cycle_locations[ k ];
                break;
            }
        }

        size_t index_second_index = perf_info->numCycle_Locations - 1;
        perf_info->in_buffer2 = perf_info->in_buffer_cycle_locations[ index_second_index ];
    }
    return;
}


/******************************************************************************/
/******************************************************************************/
void DetectActivityDiscontinuity_rev01( void )
{
    _uint32_t discontinuity = ( _uint32_t )( 0 );
    if( perf_info->a_curr > perf_info->a_prev )
        discontinuity = perf_info->a_curr - perf_info->a_prev;
    else
        discontinuity = perf_info->a_prev - perf_info->a_curr;


    _bool_t b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );

    _bool_t b_FirstActivityDetectionCurrentBuffer = ( perf_info->nCycle >= 1 );

    _bool_t b_MeaningfulActivityDetected = false;
    _bool_t b_dTBetweenCycleOK = false;

    if( true == b_FirstActivityDetectionCurrentBuffer ) {
        _uint32_t delta_t = perf_info->sample_count - perf_info->cycle[ perf_info->nCycle - 1 ];
        b_dTBetweenCycleOK = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK = b_dTBetweenCycleOK && ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    } else {
        b_FirstActivityDetectionCurrentBuffer = true;
        b_dTBetweenCycleOK = true;
    }

    _bool_t b_allConditionsMet = false;
    _bool_t b_MeaningfulAccelerationDetected = ( perf_info->a_prev >= g_MAG_THRESHOLD ) || ( perf_info->a_curr >= g_MAG_THRESHOLD );

    b_allConditionsMet = b_AccDiscontinuityBigEnough;
    b_allConditionsMet = b_allConditionsMet && b_FirstActivityDetectionCurrentBuffer;
    b_allConditionsMet = b_allConditionsMet && b_dTBetweenCycleOK;
    b_allConditionsMet = b_allConditionsMet && b_MeaningfulAccelerationDetected;

    if( true == b_allConditionsMet )
        b_MeaningfulActivityDetected = true;


    if( true == b_MeaningfulActivityDetected ) {
        perf_info->nCycle = perf_info->nCycle + 1;
        perf_info->cycle[ perf_info->nCycle - 1 ] = perf_info->sample_count;
    }


    if( b_MeaningfulActivityDetected == true ) {
        perf_info->numCycle_Locations = perf_info->numCycle_Locations + 1;
        perf_info->in_buffer_cycle_locations[ perf_info->numCycle_Locations - 1 ] = g_NUMBER_SAMPLE_CURRENT_BUFFER - 1;

        if( perf_info->verbose_level > 1 )
            CustomPrintf( "cycle detected @ sample #%li\n", perf_info->sample_count );

    }


    return;
}


/******************************************************************************/
/******************************************************************************/
_bool_t CheckIfCurrentBufferNeedsToBeUploaded_rev01( void )
{
    _bool_t res = false;
    if( perf_info->nCycle > 0 )
    {
        float percentageRelevantActivity = 0;

        CalculatePercentageRelevantActivity_rev01( &percentageRelevantActivity );

        _bool_t b_bufferContainsEnoughData = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );
        _bool_t b_bufferIsAboutToSelfErase = false;
        _bool_t b_uploadCondition = false;
        _bool_t b_bufferFull = false;


        if( g_MEANINGLESS_DATA_REQUIRED == g_OFF )
            b_bufferIsAboutToSelfErase = ( perf_info->in_buffer1 == 0 );

        else
            b_bufferIsAboutToSelfErase = ( perf_info->in_buffer1 == ( g_NUMBER_SAMPLES_BEFORE_FIRST_INTERESTING_SAMPLE + 0 ) );


        b_bufferFull = ( ( perf_info->idx_cur_sample + 1 ) % g_NUMBER_SAMPLE_CURRENT_BUFFER ) == 0;

        if( g_WAIT_FOR_FULL_BUFFER == g_OFF ) {
            if( b_bufferContainsEnoughData && b_bufferIsAboutToSelfErase ) {
                b_uploadCondition = true;
                res = true;
            }
        } else {
            if( b_bufferContainsEnoughData && b_bufferFull ) {
                b_uploadCondition = true;
                perf_info->in_buffer1 = 0;
                perf_info->in_buffer2 = g_NUMBER_SAMPLE_CURRENT_BUFFER - 1;
                res = true;
            }
        }
        if( true == b_uploadCondition )
        {
            _int32_t nDataPoints = ( perf_info->in_buffer2 - perf_info->in_buffer1 ) + 1;
            CustomPrintf( "Uploading buffer - I = [%li %li] - Triggered by sample number %li - NPoints = %li\n",
                   perf_info->in_buffer1, perf_info->in_buffer2, perf_info->idx_cur_sample, nDataPoints );

            ResetBufferIndices_rev01( );
            return res;
        } else {
            if( g_WAIT_FOR_FULL_BUFFER == g_OFF ) {
                if( b_bufferIsAboutToSelfErase &&  ( false == b_bufferContainsEnoughData ) ) {
                    ResetBufferIndices_rev01( );
                    return res;
                }
            } else {
                if( b_bufferFull ) {
                    ResetBufferIndices_rev01( );
                    return res;
                }
            }
        }

    }
    return res;
}
