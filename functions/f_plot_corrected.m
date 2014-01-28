function [ o ] = f_plot_corrected( t, in )
    [ delta ] = f_compute_slopes( t, in );
    n = length( t );
    ACCEL_DISCONTINUITY_THRESHOLD  = 1500;
    %hold on;
    for i = 1 : 1 : ( n - 1 )
        x1 = t( i + 0 );
        x2 = t( i + 1 );

        y1 = in( i + 0 );
        y2 = in( i + 1 );
        %if( delta( i ) >= 100000 )
        if( delta( i ) >= ACCEL_DISCONTINUITY_THRESHOLD )

            plot( [x1, x2], [y1, y2], 'r' );
        else
            plot( [x1, x2], [y1, y2], 'b' );
        end
    end
%    plot( t, o );
end

