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


/******************************************************************************/
/******************************************************************************/
typedef struct
{
    _uint32_t a_prev;
    _uint32_t a_curr;
    _uint32_t nCycle;
    _int32_t idx_cur_sample;
    _uint32_t cycle[ g_MAX_NUM_CYCLE_LOCATIONS ];
    _bool_t manual_reset_requested;
} perf_info_t;

/******************************************************************************/
/******************************************************************************/
static perf_info_t _p1;
static perf_info_t *perf_info = &_p1;

/******************************************************************************/
/******************************************************************************/
_bool_t im_calc_p1_rev02( _uint32_t new_a );
void DetectActivityDiscontinuity_rev02( void );
_bool_t CheckIfCurrentBufferNeedsToBeUploaded_rev02( void );
void ResetBufferIndices_rev02( void );
void CalculatePercentageRelevantActivity_rev02( float* percentageRelevantActivity );
void DetectActivityDiscontinuity_rev02( void );

/******************************************************************************/
/******************************************************************************/
_bool_t im_calc_p1_rev02( _uint32_t new_a )
{
    
    perf_info->a_prev         = perf_info->a_curr;
    perf_info->a_curr         = new_a;
    
    DetectActivityDiscontinuity_rev02(  );
    _bool_t res = CheckIfCurrentBufferNeedsToBeUploaded_rev02( );
    perf_info->idx_cur_sample = perf_info->idx_cur_sample + 1;
    return res;
}

/******************************************************************************/
/******************************************************************************/
void ResetBufferIndices_rev02( void )
{
    memset( perf_info->cycle, 0, sizeof( _uint32_t ) *  g_MAX_NUM_CYCLE_LOCATIONS );
    perf_info->nCycle = 0;
    return;
}

/******************************************************************************/
/******************************************************************************/
void CalculatePercentageRelevantActivity_rev02( float* percentageRelevantActivity )
{
    _uint32_t numberSamplesInRelevantActivity = ( _uint32_t )( 0 );
    if( perf_info->nCycle >= 2 )
    {
        for( _uint16_t k = 1; k < perf_info->nCycle; k++ )
        {
            _uint16_t len = ( _uint16_t )( perf_info->cycle[ k ] - perf_info->cycle[ k - 1 ] + 1 );
            numberSamplesInRelevantActivity = numberSamplesInRelevantActivity + len;
        }
    }
    *percentageRelevantActivity = ( ( float )numberSamplesInRelevantActivity / ( float )g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100.0f;
    return;
}


/******************************************************************************/
/******************************************************************************/
void DetectActivityDiscontinuity_rev02( void )
{
    _uint32_t discontinuity                           = ( _uint32_t )( 0 );
    _int32_t new_t                                    = perf_info->idx_cur_sample;
    
    _bool_t b_AccDiscontinuityBigEnough             = false;
    _bool_t b_MeaningfulActivityDetected            = false;
    _bool_t b_dTBetweenCycleOK                      = false;
    
    
    if( perf_info->a_curr > perf_info->a_prev )
        discontinuity = perf_info->a_curr - perf_info->a_prev;
    else
        discontinuity = perf_info->a_prev - perf_info->a_curr;
    
    b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );
    _bool_t b_MeaningfulAccelerationDetected = ( perf_info->a_prev >= g_MAG_THRESHOLD ) || ( perf_info->a_curr >= g_MAG_THRESHOLD );
    
    _uint32_t delta_t = 0;
    if( perf_info->nCycle >= 1 )
    {
        delta_t             = new_t - perf_info->cycle[ perf_info->nCycle - 1 ];
        b_dTBetweenCycleOK  = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK  = b_dTBetweenCycleOK && ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    }
    
    b_dTBetweenCycleOK = true;
    b_MeaningfulActivityDetected = b_AccDiscontinuityBigEnough && b_MeaningfulAccelerationDetected && b_dTBetweenCycleOK;
    
    if( true == b_MeaningfulActivityDetected )
    {
        perf_info->nCycle = perf_info->nCycle + 1;
        perf_info->cycle[ perf_info->nCycle - 1 ] = perf_info->idx_cur_sample;
    }
    if( false == b_dTBetweenCycleOK )
    {
        if( b_MeaningfulAccelerationDetected && b_AccDiscontinuityBigEnough )
        {
            ;
        }
    }
    
    return;
}

/******************************************************************************/
/******************************************************************************/
_bool_t CheckIfCurrentBufferNeedsToBeUploaded_rev02( void )
{
    if( perf_info->nCycle >= 2 )
    {
        float percentageRelevantActivity = 0;
        CalculatePercentageRelevantActivity_rev02( &percentageRelevantActivity );
        
        _int32_t n2 = perf_info->cycle[ perf_info->nCycle - 1 ];
        _int32_t n1 = perf_info->cycle[ 0 ];
        
        _int32_t size_in_buffer = ( n2 - n1 ) + 1;
        
        _bool_t b_uploadCondition               = false;

        
        b_uploadCondition = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );
        
        _int32_t nDataPoints = size_in_buffer;
        if( true == b_uploadCondition )
        {
            CustomPrintf( "Uploading buffer - I = [%li %li] - Triggered by sample number %li - NPoints = %li\n", n1, n2, perf_info->idx_cur_sample, nDataPoints );
            ResetBufferIndices_rev02(  );
            return true;
        }
        else
        {
            if( ( perf_info->nCycle >= g_MAX_NUM_CYCLE_LOCATIONS ) && ( percentageRelevantActivity < g_CRITICAL_PERCENT ) )
            {
                ResetBufferIndices_rev02(  );
                return false;
            }
        }
    }
    
    return false;
}
