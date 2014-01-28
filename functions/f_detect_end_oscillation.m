function tf = f_detect_end_oscillation( buffer_time, buffer_signal, index, threshold, totalSampleNumber )
    tf = false;
    if( index > ( totalSampleNumber  - 1 ) )
        return;
    end
    y1 = buffer_signal( index + 0 );
    y2 = buffer_signal( index + 1 );
    x1 = buffer_time( index + 0 );
    x2 = buffer_time( index + 1 );
    dy = ( y2 - y1 );
    dx = ( x2 - x1 );
    a = dy / dx;
    tf = abs( a ) >= threshold;
    return;
end