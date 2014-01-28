/**
 * @file ada_externals.h
 * @author Julien Esposito
 * @brief A Description of the types and non - static functions used by the
 * ADA.
 */

#ifndef ADA_EXTERNALS_H
#define ADA_EXTERNALS_H

/******************************************************************************/
/******************************************************************************/
//#define DEBUG
//#define NO_CONSOLE

/******************************************************************************/
/******************************************************************************/
/**
 * @def X
 * @brief Variable used for indexing in arrays dealing with Cartesian
 * coordinates, and access the X coordinate.
 */
#define X   0

/**
 * @def Y
 * @brief Variable used for indexing in arrays dealing with Cartesian
 * coordinates, and access the Y coordinate.
 */
#define Y   1

/**
 * @def Z
 * @brief Variable used for indexing in arrays dealing with Cartesian
 * coordinates, and access the Z coordinate.
 */
#define Z   2

#define ADA_STATE_MEMORY_SIZE          256

/**
 * @typedef _int8_t
 * @brief Signed 8 bit integer
 */
typedef signed   char   int8;

/**
 * @brief Unsigned 8 bit integer
 */
typedef unsigned char   uint8;

/**
 * @brief Signed 16 bit integer
 */
typedef signed   short  int16;

/**
 * @brief Unsigned 16 bit integer
 */
typedef unsigned short  uint16;

/**
 * @brief Signed 32 bit integer
 */
typedef signed   long   int32;

/**
 * @brief Unsigned 32 bit integer
 */
typedef unsigned long   uint32;

/**
 * @brief Boolean
 */
typedef unsigned char   bool_t;

/*
 * I test my code in a C++ environment, where true and false are defined, but
 * in C, they are not, hence the __cplusplus thingy.
 */

#ifndef __cplusplus
    typedef int bool;
    #define false 0
    #define true !false
#endif


/**
 * @brief the "im_axes_t" is just a typedef to represent a triplet of coordinates,
 * like accelerations.
 */
typedef int16 im_axes_t[ 3 ];


/**
 * @brief This is where the struct used to pass all the necessary data to the
 * performance ADA.
 * @sa im_axes_t
 */
typedef struct _ada_sample_t
{
    im_axes_t gyro;
    im_axes_t accel;
    bool forceReset;
} ada_sample_t;


/******************************************************************************/
/******************************************************************************/
typedef struct _ada_capture_t
{
    int16 begin_capture_offset;
    int16 end_capture_offset;
} ada_capture_t;

/******************************************************************************/
/******************************************************************************/
extern uint8 ada_state_memory[ ADA_STATE_MEMORY_SIZE ];

/******************************************************************************/
/******************************************************************************/
void CustomPrintf( char *fmt, ... );

/******************************************************************************/
/******************************************************************************/
uint32 ada_sqrt( uint32 accSquared );


/*
 * I'm bound to be using the _cplusplus stuff because I want my code to be
 * compiled in C, and yet be able to use it in a C++ environment.
 */
#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus defined */
    
/**
 * @fn call_p1Reset
 *
 * @brief "call_p1Reset" calls the static function "p1_Reset".
 *
 * @details Apparently, any "Reset" function of any im_calc algorithm needs to
 * be static. This function should only be used in a MATLAB environment.
 */
//void call_p1Reset( void );
    
/**
 * @fn call_p1Exec
 *
 * @brief "This function call_p1Exec" calls the static function "p1_Exec".
 *
 * @details Apparently, any "Exec" function of any im_calc algorithm needs to
 * be static. This function should only be used in a MATLAB environment.
 *
 * @param pData, a pointer to an ada_data_t structure.
 *
 * @return _uint16_t - A boolean reflecting whether anything relevant has been
 *  detected (1) or not (0).
 *
 * @sa ada_data_t
 */
//uint16 call_p1Exec( ada_sample_t *pData );
    
/**
 * @fn RecordIndices
 *
 * @param absolute_sample_index - A pointer to the sample number which triggered the upload.
 *
 * @param relO - A pointer to the lower bound index (relative to the sample number) for the part of the buffer which is "of interest".
 *
 * @param relP - A pointer to the upper bound index (relative to the sample number) for the part of the buffer which is "of interest".
 *
 * @param idx1 - A pointer to the lower bound index, for the part of the buffer which is "of interest".
 *
 * @param idx2 - A pointer to the absolute upper bound index, for the part of the buffer which is "of interest"
 */
void RecordIndices(
                   int32* absolute_sample_index,
                   int16* relO,
                   int16* relP, uint16* idx1, uint16* idx2 );


#ifdef __cplusplus
}
#endif /* __cplusplus defined */
        
#endif /* ADA_EXTERNALS_H defined */
