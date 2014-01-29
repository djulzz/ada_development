/**
 * @file ada_p0.c
 *
 * @author Julien Esposito
 *
 * @brief A Description of Performance-Specific functions used by the
 * "Performances/Generic Motion" ADA.
 */

/******************************************************************************/
/******************************************************************************/
#include <math.h>
#include <assert.h>
#include <limits.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

#include "ada_externals.h"
#include "ada_p0.h"

/******************************************************************************/
/******************************************************************************/
/**
 * @addtogroup Constants
 */
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
#define g_JUMPING_MAGN_THRESHOLD          2250

#define g_RUNNING_DISC_THRESHOLD          1000
#define g_SPRINTING_DISC_THRESHOLD        1200
#define g_JUMPING_DISC_THRESHOLD          1700


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


/* Computer memory specific Constants */
/* Note: Although this constant implies that the Algorithm deals with a fixed
   ----- buffer size, that is not the case. This constant is actually used to
   perform event duration calculation. At 250 Hz, 1600 samples are equivalent
   to 6.4 seconds.*/
#define g_NUMBER_SAMPLE_CURRENT_BUFFER	  1600
#define g_MAX_NUM_CYCLE_LOCATIONS         54

//% Buffer Relevant activity fullness
#define g_CRITICAL_PERCENT                50.0f
#define g_MAX_NUM_ELEMENTS                16000
#define g_MAX_NUMBER_BUFFERS_TO_UPLOAD    10

#define INDEX_T                           0
#define INDEX_A                           1

#define g_NUMBER_SAMPLES_BEFORE_FIRST_INTERESTING_SAMPLE    4
#define g_MEANINGLESS_DATA_REQUIRED                         g_ON
#define g_WAIT_FOR_FULL_BUFFER                              g_ON


#ifdef __cplusplus
extern "C"
{
#endif
    
/******************************************************************************/
/******************************************************************************/
typedef struct _adaP0_t
{
    uint32 a_prev;
    uint32 a_curr;
    uint32 nCycle;
    int32 idx_cur_sample;
    uint32 cycle[ g_MAX_NUM_CYCLE_LOCATIONS ];
    uint16 idx1;
    uint16 idx2;
    bool manual_reset_requested;
    int16 relative_O;
    int16 relative_P;
} adaP0_t;


/* assert((sizeof(adaP0_t) < sizeof(ada_state_memory)), "adaP0_t is too big"); */

#define state  ((adaP0_t *)ada_state_memory)

/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
/******************************************************************************/
bool im_calc_p1_rev03( uint32 new_a );
void DetectMeaningfulActivity( void );
bool CheckIfCurrentBufferNeedsToBeUploaded_rev03( void );
void ResetBufferIndices_rev03( void );
void CalculatePercentageRelevantActivity_rev03( float* percentageRelevantActivity );
void DetectMeaningfulActivity( void );
void f_relativize_indices( int16* relO, int16* relP, int16 N, int16 O, int16 P );

/******************************************************************************/
/******************************************************************************/
/**
 * @fn void f_relativize_indices( int16* relO, int16* relP, int16 N, int16 O, int16 P )
 *
 * @brief This function's only purpose is to compute indexing relative to absolute sample number.
 *
 * @details
 * Example:
 * --------
 * - N = 7 (ABSOLUTE sample number)
 * - O = 1 (ABSOLUTE lower bound for the buffer of interest)
 * - P = 8 (ABSOLUTE upper bound for the buffer of interest)
 *
 * Which yield:
 * - relO = O - N = 1 - 7 = -6
 * - relP = P - N = 8 - 7 = +1
 *
 * @param[out] relO The lower bound index relative to the absolute sample number.
 * @param[out] relP The higher bound index relative to the absolute sample number.
 * @param[in] N The absolute sample number (can be greater than the internal buffer length).
 * @param[in] O The absolute lower bound for the data series of interest.
 * @param[in] P The absolute higher bound for the data series of interest.
 * @return Nothing.
 */
void f_relativize_indices( int16* relO, int16* relP, int16 N, int16 O, int16 P )
{
    *relO = 0;
    *relP = 0;
    
    *relO = O - N;
    *relP = P - N;
    
    return;
}

/**
 * @fn bool im_calc_p1_rev03( uint32 new_a )
 *
 * @brief This function contains all the high level logic ran by the algorithm.
 *
 * @details The function performs the following (high level) operations:
 * -# The acceleration magnitude is updated
 * -# Then a routine checks if the new acceleration leads to a meaningful activity detection
 * -# Then a check is performed to decide if the buffer must be uploaded
 *
 * @param[in] new_a The acceleration magnitude.
 * @return A boolean (0 or 1) depending on whether the observed activity was
 * judged worth recording to flash or not.
 */
/******************************************************************************/
/******************************************************************************/
bool im_calc_p1_rev03( uint32 new_a )
{
    
    state->a_prev         = state->a_curr;
    state->a_curr         = new_a;
    
    DetectMeaningfulActivity(  );
    bool res = CheckIfCurrentBufferNeedsToBeUploaded_rev03( );
    state->idx_cur_sample = state->idx_cur_sample + 1;
    return res;
}

/******************************************************************************/
/******************************************************************************/
void ResetBufferIndices_rev03( void )
{
    memset( state->cycle, 0, sizeof( uint32 ) *  g_MAX_NUM_CYCLE_LOCATIONS );
    state->nCycle = 0;
    return;
}

/******************************************************************************/
/******************************************************************************/
void CalculatePercentageRelevantActivity_rev03( float* percentageRelevantActivity )
{
    uint32 numberSamplesInRelevantActivity = ( uint32 )( 0 );
    if( state->nCycle >= 2 )
    {
        uint16 k;
        for( k = 1; k < state->nCycle; k++ )
        {
            uint16 len = ( uint16 )( state->cycle[ k ] - state->cycle[ k - 1 ] + 1 );
            numberSamplesInRelevantActivity = numberSamplesInRelevantActivity + len;
        }
    }
    *percentageRelevantActivity = ( ( float )numberSamplesInRelevantActivity / ( float )g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100.0f;
    return;
}


/******************************************************************************/
/******************************************************************************/
void DetectMeaningfulActivity( void )
{
    uint32 discontinuity                           = ( uint32 )( 0 );
    int32 new_t                                    = state->idx_cur_sample;
    
    bool b_AccDiscontinuityBigEnough             = false;
    bool b_MeaningfulActivityDetected            = false;
    bool b_dTBetweenCycleOK                      = false;
    
    
    if( state->a_curr > state->a_prev )
        discontinuity = state->a_curr - state->a_prev;
    else
        discontinuity = state->a_prev - state->a_curr;
    
    b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );
    bool b_MeaningfulAccelerationDetected = ( state->a_prev >= g_MAG_THRESHOLD ) || ( state->a_curr >= g_MAG_THRESHOLD );
    
    uint32 delta_t = 0;
    if( state->nCycle >= 1 )
    {
        delta_t             = new_t - state->cycle[ state->nCycle - 1 ];
        if( delta_t >= 2 * g_MAX_NUM_SAMPLES_BETWEEN_CYCLES ) {
            ResetBufferIndices_rev03(  );
        }
        b_dTBetweenCycleOK  = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK  = b_dTBetweenCycleOK && ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    }
    else
    if( state->nCycle == 0 )
    {
        b_dTBetweenCycleOK = true;
    }
    
//    b_dTBetweenCycleOK = true;
    b_MeaningfulActivityDetected = b_AccDiscontinuityBigEnough && b_MeaningfulAccelerationDetected && b_dTBetweenCycleOK;
    
    if( true == b_MeaningfulActivityDetected )
    {
        state->nCycle = state->nCycle + 1;
        state->cycle[ state->nCycle - 1 ] = state->idx_cur_sample;
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
bool CheckIfCurrentBufferNeedsToBeUploaded_rev03( void )
{
    state->idx1 = 0;
    state->idx2 = 0;
    if( state->nCycle >= 2 )
    {
        float percentageRelevantActivity = 0;
        CalculatePercentageRelevantActivity_rev03( &percentageRelevantActivity );
        
        int32 n2 = state->cycle[ state->nCycle - 1 ];
        int32 n1 = state->cycle[ 0 ];
        
        int32 size_in_buffer = ( n2 - n1 ) + 1;

        bool b_uploadCondition               = false;
        
        b_uploadCondition = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );
        
        int32 nDataPoints = size_in_buffer;
        if( true == b_uploadCondition )
        {
            CustomPrintf( "Uploading buffer - I = [%li %li] - Triggered by sample number %li - NPoints = %li\n", n1, n2, state->idx_cur_sample, nDataPoints );
            state->idx1 = (uint16 )( n1 );
            state->idx2 = (uint16 )( n2 );
            int16 relO = 0;
            int16 relP = 0;
            int16 N = ( int16 )( state->idx_cur_sample );
            int16 O = ( int16 )( n1 );
            int16 P = ( int16 )( n2 );
            //void RecordIndices( _int32_t* absolute_sample_index, _int16_t* relO, _int16_t* relP, _uint16_t* idx1, _uint16_t* idx2 )
            f_relativize_indices( &relO, &relP, N, O, P );
            state->relative_O = relO;
            state->relative_P = relP;
            CustomPrintf( "[i1, i2] = [%i %i] - [O, P] = [%i, %i] - N = %i\n", n1, n2, relO, relP, N );
            
//            perf_info->relative_O = O;
//            perf_info->relative_P = P;
            ResetBufferIndices_rev03(  );
            return true;
        }
        else
        {
            if( ( state->nCycle >= g_MAX_NUM_CYCLE_LOCATIONS ) && ( percentageRelevantActivity < g_CRITICAL_PERCENT ) )
            {
                ResetBufferIndices_rev03(  );
                return false;
            }
        }
    }
    
    return false;
}





/******************************************************************************/
/******************************************************************************/
bool im_calc_p1_rev03( uint32 new_a );
void DetectActivityDiscontinuity_rev03( void );
bool CheckIfCurrentBufferNeedsToBeUploaded_rev03( void );
void ResetBufferIndices_rev03( void );
void CalculatePercentageRelevantActivity_rev03( float* percentageRelevantActivity );
void DetectActivityDiscontinuity_rev03( void );

/******************************************************************************/
/******************************************************************************/
void adaInitP0( void )
{
    if( true == state->manual_reset_requested )
    {
        state->idx_cur_sample = 0;
        state->manual_reset_requested = false;
    }
    
    state->a_prev = 0;
    state->a_curr = 0;
    state->nCycle = 0;
    
    memset( state->cycle, 0, sizeof( uint32 ) * g_MAX_NUM_CYCLE_LOCATIONS );
    
    ResetBufferIndices_rev03( );
    
    //    perf_info->idx1 = 0;
    //    perf_info->idx2 = 0;
    return;
}


/******************************************************************************/
/******************************************************************************/
bool adaExecP0( ada_sample_t *pData, ada_capture_t* pCapture )
{
    bool worthRecordingMotion = false;
    
    
    if( true == pData->forceReset ) {
        state->manual_reset_requested = true;
        adaInitP0(  );
        state->idx_cur_sample = 0;
        return false;
    }
    
    
    int16 ax = pData->accel[ X ];
    int16 ay = pData->accel[ Y ];
    int16 az = pData->accel[ Z ];
    
    
    
    uint32 accSquared = ( uint32 )( ( ( int32 )ax * ax ) +
                                   ( ( int32 )ay * ay ) +
                                   ( ( int32 )az * az ) );
    
    uint32 acc = ( uint32 )sqrt( accSquared );
    worthRecordingMotion = im_calc_p1_rev03( acc );
    
    
    if( true == worthRecordingMotion ) {
        pCapture->begin_capture_offset = state->relative_O;
        pCapture->end_capture_offset   = state->relative_P;
        adaInitP0(  );
        return true;
    }
    return false;
}

/******************************************************************************/
/******************************************************************************/
void RecordIndices(
                   int32* absolute_sample_index,
                   int16* relO,
                   int16* relP,
                   uint16* idx1, uint16* idx2 )
{
    *absolute_sample_index = state->idx_cur_sample;
    
    *relO = state->relative_O;
    *relP = state->relative_P;
    
    *idx1 = state->idx1;
    *idx2 = state->idx2;
    return;
}

#ifdef __cplusplus
}
#endif /* __cplusplus defined */
