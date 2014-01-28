/**
 * @file ada.c
 * @author Julien Esposito
 * @brief A Description of the most generic functions used by the
 * ADA.
 */

/******************************************************************************/
/******************************************************************************/
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "ada_externals.h"




/******************************************************************************/
/******************************************************************************/



//
//#define DEBUG
//#define NO_CONSOLE

/**
 * @fn CustomPrintf
 *
 * @brief I use the performance ADA as a static lib with my MATLAB environment.
 *
 * @details In MATLAB any message printed on the standard output is not re-directed to
 * the MATLAB console. Hence, I print all my debug messages to a file opened in
 * "append" mode, in order to see what I'm doing, and that is done via the
 * this CustomPrintf.
 *
 * @param fmt - the format string, like for "printf".
 *
 * @return Nothing.
 */
#ifdef DEBUG
void CustomPrintf( char *fmt, ... )
{
    va_list argptr;
    char msg[ 2048 ];
            
    va_start( argptr, fmt );
    vsprintf( msg, fmt, argptr );
    va_end( argptr );
            
#ifdef NO_CONSOLE
    FILE* f = fopen( "im_calc_p1.txt", "a" );
    fprintf( f, "%s", msg );
    fclose( f );
#else
    printf( "%s", msg );
#endif
    return;
}
#else
void CustomPrintf( char *fmt, ... )
{
    ( void )fmt;
}
#endif

/**
 * @fn ada_sqrt
 *
 * @brief This function is used to compute the square root of a _uint32_t.
 *
 * @param accSquared - a _uint32_t value to take the square root form.
 *
 * @return The square root as a _uint32_t value.
 */
uint32 ada_sqrt( uint32 accSquared )
{
    return ( uint32 )sqrtf( ( float )accSquared );
}



