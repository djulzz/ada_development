clear all;
close all;
clc;
format bank;


load( 'the_generated_buffers.mat' );

a = uint32( b );
fprintf( 'Numbers of samples in buffer = %i\n', length( a ) );


nElements = uint32( length( a ) );
t = uint32( 1 : 1 : nElements );

% f = fopen( 'nums.txt', 'w' );
% for i = 1 : 1 : nElements
%     fprintf( f, '%.0f\t%.0f\n', t( i ), a( i ) );
% end
% fclose( f );


instanciate_globals;
initialize_globals;


the_imCalcP1_t.a_prev                          = uint32( 0 );
the_imCalcP1_t.a_curr                          = uint32( 0 );
the_imCalcP1_t.nCycle                          = uint32( 0 );


% the_imCalcP1_t.LimitElementsToProcess          = uint32( g_MAX_NUM_ELEMENTS );
the_imCalcP1_t.idx_cur_sample                  = uint32( 0 );
the_imCalcP1_t.numCycle_Locations              = uint32( 0 );
the_imCalcP1_t.in_buffer_cycle_locations       = int32( repmat( -1, 1, g_MAX_NUM_CYCLE_LOCATIONS ) );
the_imCalcP1_t.cycle                           = uint32( zeros( 1, g_MAX_NUM_CYCLE_LOCATIONS ) );
the_imCalcP1_t.in_buffer1                      = int32( 0 );
the_imCalcP1_t.in_buffer2                      = int32( 0 );
the_imCalcP1_t.numBuffersProcessed             = uint32( 0 );
the_imCalcP1_t.numUploads                      = uint32( 0 );


the_imCalcP1_t.warning_issued                  = false;
the_imCalcP1_t.verbose_level                   = uint32( 1 );

the_imCalcP1_t.buffer                      = uint32( zeros( 2, g_NUMBER_SAMPLE_CURRENT_BUFFER ) );
the_imCalcP1_t.all_cycles                  = uint32( zeros( g_MAX_NUMBER_BUFFERS_TO_UPLOAD, g_MAX_NUM_CYCLE_LOCATIONS ) );
the_imCalcP1_t.all_cycle_sizes             = uint32( zeros( 1, g_MAX_NUMBER_BUFFERS_TO_UPLOAD ) );
the_imCalcP1_t.buffers                     = uint32( zeros( 2 * g_MAX_NUMBER_BUFFERS_TO_UPLOAD, g_NUMBER_SAMPLE_CURRENT_BUFFER ) );
the_imCalcP1_t.buffer_sizes                = uint32( zeros( 1, g_MAX_NUMBER_BUFFERS_TO_UPLOAD ) );
the_imCalcP1_t.upload_triggering_samples   = uint32( zeros( 1, g_MAX_NUMBER_BUFFERS_TO_UPLOAD ) );


for index_samples = 1 : 1 : nElements % iterate through all

    new_t = t( index_samples ); % new oncoming sample number
    new_a = a( index_samples ); % new oncoming acceleration magnitude
    the_imCalcP1_t = im_calc_p1_2( new_a, new_t, the_imCalcP1_t );
end

DrawResults;
