clear all;
close all;
clc;
format bank;

addpath( 'mex' );
addpath( ['functions'] );
addpath( ['classes'] );

load( 'the_generated_buffers.mat' );

a = b;
% a = a( 1601 : 3200 );
fprintf( 'Numbers of samples in buffer = %i\n', length( a ) );


nElements = length( a );
t = 1 : 1 : nElements;

instanciate_globals;
initialize_globals;


the_imCalcP1_t = imCalcP1_t(  );


% The top for-loop simulates oncoming data that would be sensed by the
% sensor
for index_samples = 1 : 1 : nElements % iterate through all
                                                   % the simulated oncoming
                                                   % sensed data

    % Test Environment Only:
    % ----------------------
    % short hand variables keeping track of oncoming sample
    
    new_t = t( index_samples ); % new oncoming sample number
    new_a = a( index_samples ); % new oncoming acceleration magnitude
    im_calc_p1( new_a, new_t, the_imCalcP1_t );
end


if( g_DRAWING_MODE == g_DRAWING_ON )
% Below this point the code is just plotting data
% -----------------------------------------------
    hold on;
    set( gcf, 'Color', 'White' );
    plot( t, a, 'Color', 'Blue' );
    linewidth = 6;
    if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
        for k = 1 : 1 : the_imCalcP1_t.numUploads
            sz = the_imCalcP1_t.the_Sim.all_cycle_sizes( 1, k );
            n = sz;
            current_cycle = the_imCalcP1_t.the_Sim.all_cycles( k, 1 : 1 : sz );
            for i = 1 : 1 : ( n - 1 )
                v = 1000 * ones( 1, 2 );
                x = [ current_cycle( i ), current_cycle( i + 1 ) ];
                color = 'Black';
                if( 0 == mod( i, 2 ) );
                    color = 'Red';
                end
                plot( x, v, 'Color', color, 'LineWidth', linewidth );
            end
        end
    end % End if( KEEP_TRACK_OFF_ALL_CYCLES == ON )

    for i = 1 : 1 : 10
        i1 = ( i - 1 ) * g_NUMBER_SAMPLE_CURRENT_BUFFER + 1;
        i2 = i1 + ( g_NUMBER_SAMPLE_CURRENT_BUFFER - 1 );
        x = [i1 , i1];
        y = [0, 3000];
        plot( x, y, 'Color', 'Green', 'LineWidth', 2 );
        x = [i2, i2];
        plot( x, y, 'Color', 'Green', 'LineWidth', 2 );
    end



% plot the buffer upload triggering samples
% -----------------------------------------
    doPlotTriggeringSamples = true;
    if( true == doPlotTriggeringSamples )
        n = the_imCalcP1_t.numUploads;
        if( n > 0 )
            for i = 1 : 1 : n
                x = the_imCalcP1_t.the_Sim.upload_triggering_samples( i );
                y = 3000;
                marker = 'Square';
                markerFaceColor = 'Red';
                markerEdgeColor = 'Black';
                plot( x, y, 'Marker', marker,...
                    'MarkerFaceColor', markerFaceColor,...
                    'MarkerEdgeColor', markerEdgeColor );
            end
        end
    end
end % End if( DRAWING_MODE == DRAWING_ON )

