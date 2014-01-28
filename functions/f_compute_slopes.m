function [ out ] = f_compute_slopes( t, in )
    n = length( in );
    out = zeros( 1, ( n - 0 ) );
    for i = 1 : 1 : ( n - 1 )
        y2 = in( i + 1 );
        y1 = in( i + 0 );
        x2 = t( i + 1 );
        x1 = t( i + 0 );
        %a = ( y2 - y1 ) / ( x2 - x1 );
        a = abs( y2 - y1 );
        out( i ) = abs( a );
    end
    out( end ) = out( end - 1 );
    return;
end

