
if( g_DRAWING_MODE == g_DRAWING_ON )
% Below this point the code is just plotting data
% -----------------------------------------------
    hold on;
    set( gcf, 'Color', 'White' );
    plot( t, a, 'Color', 'Blue' );
    linewidth = 6;
    if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
        for k = 1 : 1 : the_imCalcP1_t.numUploads
            sz = the_imCalcP1_t.all_cycle_sizes( 1, k );
            n = sz;
            current_cycle = the_imCalcP1_t.all_cycles( k, 1 : 1 : sz );
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
                x = the_imCalcP1_t.upload_triggering_samples( i );
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

