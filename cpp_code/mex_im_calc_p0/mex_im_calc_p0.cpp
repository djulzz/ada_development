//
//  main.cpp
//  mex_ADA_Performances
//
//  Created by Julien Esposito on 11/22/13.
//
//

#include "mex.h"
#include "ada_externals.h"
#include "ada_p0.h"
#include <string.h>
#ifdef __cplusplus
#undef false
#undef true
#endif

//#define DEBUG_ON
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
bool CheckInputDimensions( const mxArray* arr )
{
    size_t nRows = mxGetM( arr );
    size_t nCols = mxGetN( arr );
    //    mexPrintf( "#Rows = %i - #Columns = %i\n", nRows, nCols );
    bool res = false;
    res = ( nRows == 1 ) && ( nCols == 3 );
    return res;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void mexFunction( int nlhs, mxArray* plhs[  ], int nrhs, const mxArray* prhs[  ] )
{
    static const size_t numberInputRequired = 3;
    static const char appName[  ] = "mex_ADA_Performances";
    
#ifdef DEBUG_ON
    mexPrintf( "%s - Function Entered\n", appName );
#endif
    
    im_axes_t record;
    size_t nInputs = nrhs;
    size_t nOutputs = nlhs;
    
    if( nInputs != numberInputRequired )
    {
        mexPrintf( "Error - %s - needs %i inputs\n", appName, numberInputRequired );
        return;
    }
    //    mexPrintf( "# inputs = %i\n", nInputs );
    //    mexPrintf( "# output = %i\n", nOutputs );
    size_t nInputsRequired = 3;
    for( size_t i = 0; i < nInputsRequired - 1; i++ ) {
        const mxArray* ar = prhs[ i ];
        bool res = CheckInputDimensions( ar );
        if( false == res )
        {
            mexPrintf( "Error - mex_ADA_Performances - Dimension for inputs must be [M, N] = [1, 3] - Aborting\n" );
            return;
        }
    }
    
    
    
    double* accel_buf = ( double* )( mxGetPr( prhs[ 0 ] ) ); // triplet ACC input 1
    double* gyro__buf = ( double* )( mxGetPr( prhs[ 1 ] ) ); // triplet GYR input 2
    const mxArray* ar = prhs[ 2 ];
    double firstSample = *( double* )mxGetPr( ar );          // first sample input 3
    
    //    mexPrintf( "[%.2f,%.2f,%.2f] - [%.2f,%.2f,%.2f]\n", accel_buf[ 0 ], accel_buf[ 1 ], accel_buf[ 2 ],
    //              gyro__buf[ 0 ], gyro__buf[ 1 ], gyro__buf[ 2 ] );
    
    ada_sample_t ada_data;
    ( void )memset( &ada_data, 0, sizeof( ada_sample_t ) );
//    ada_axes_t current_sample;
    
    if( firstSample == 1 ) {
#ifdef DEBUG_ON
        mexPrintf( "%s - Reset called\n", appName );
#endif
        ada_data.forceReset = true;
    }
    
    ada_data.accel[ X ] = ( int16 )( accel_buf[ X ] );
    ada_data.accel[ Y ] = ( int16 )( accel_buf[ Y ] );
    ada_data.accel[ Z ] = ( int16 )( accel_buf[ Z ] );
    
//    ada_data.gyro[ X ] = ( _int16_t )( gyro__buf[ X ] );
//    ada_data.gyro[ Y ] = ( _int16_t )( gyro__buf[ Y ] );
//    ada_data.gyro[ Z ] = ( _int16_t )( gyro__buf[ Z ] );
    
    //PrintSample( current_sample );
    ada_capture_t Capture;
    bool testResult = adaExecP0( &ada_data, &Capture );
//    uint16 testResult = call_p1Exec( &ada_data );
    
    uint16 idx1, idx2;
    int32 absolute_sample_index;
    int16 relO;
    int16 relP;
    int16 reconstO = 0;
    int16 reconstP = 0;
    if( 1 == testResult )
    {
        //void RecordIndices( _int32_t* absolute_sample_index, _int16_t* relO, _int16_t* relP, _uint16_t* idx1, _uint16_t* idx2 )
        RecordIndices( &absolute_sample_index, &relO, &relP, &idx1, &idx2 );
        reconstO = absolute_sample_index + relO;
        reconstP = absolute_sample_index + relP;
        mexPrintf( "[i1, i2] = [%hu %hu] - [O, P]_rel = [%hd, %hd] - N = %d\n", idx1, idx2, relO, relP, absolute_sample_index );
//        mexPrintf( "[O, P]_rel = [%i, %i]\n", relO, relP );
    }
//    RecordIndices( &idx1, &idx2 );
    plhs[ 0 ] = mxCreateDoubleScalar( ( double )( testResult ) );
    plhs[ 1 ] = mxCreateDoubleScalar( ( double )( reconstO + 1 ) );
    plhs[ 2 ] = mxCreateDoubleScalar( ( double )( reconstP + 1 ) );
    return;
}
