clear all;
close all;
clc;
format bank;


load( 'the_generated_buffers.mat' );

a = uint32( b );
% a = a( 1601 : 1 : 3200 );

fprintf( 'Numbers of samples in buffer = %i\n', length( a ) );


nElements = uint32( length( a ) );
t = uint32( 1 : 1 : nElements );


instanciate_globals;
initialize_globals;
g_cycles                          = [  ];


the_imCalcP1_t.a_prev                          = uint32( 0 );
the_imCalcP1_t.a_curr                          = uint32( 0 );
the_imCalcP1_t.nCycle                          = uint32( 0 );
the_imCalcP1_t.idx_cur_sample                  = uint32( 0 );
the_imCalcP1_t.cycle                           = zeros( 1, g_MAX_NUM_CYCLE_LOCATIONS );

for index_samples = 1 : 1 : nElements % iterate through all
    new_t = t( index_samples );
    new_a = a( index_samples );
    the_imCalcP1_t = im_calc_p1_5( new_a, new_t, the_imCalcP1_t );
end

nRow = size( g_cycles, 1 );

hold on;
plot( a );
for i = 1 : 1 : nRow
    i1 = g_cycles( i, 1 );
    i2 = g_cycles( i, 2 );
    x = [i1 : 1 : i2];
    y = a( i1 : 1 : i2 );
    plot( x, y, 'r' );
end
    