function f_handle_Piyush_report( algo_str, buf, nSamples )

    if( 1 == strcmp( algo_str, 'B1' ) )
        index = buf( 1 );
        aDelta = buf( 2 : 4 );
        gPrev = buf( 5 : 7 );
        
        consecutiveGAboveThreshold = buf( 8 : end );
        fprintf( 'B1 - A_delta(X,Y,Z) = (%i,%i,%i) - @(%i/%i) - #consecutiveGyAboveThreshod(X,Y,Z) = (%i,%i,%i) - gPrev(X,Y,Z) = (%i,%i,%i)\n',...
            aDelta( 1 ), aDelta( 2 ), aDelta( 3 ), ...
            index + 1, nSamples,...
            consecutiveGAboveThreshold( 1 ), consecutiveGAboveThreshold( 2 ), consecutiveGAboveThreshold( 3 ), ...
            gPrev( 1 ), gPrev( 2 ), gPrev( 3 ) );
    elseif( 1 == strcmp( algo_str, 'B2' ) )
        deltaX = buf( 1 );
        deltaY = buf( 2 );
        deltaZ = buf( 3 );
        sampleIndex = buf( 4 );
        consecutiveGyAboveThreshold = buf( 5 );
        gxPrev = buf( 6 );
        gyPrev = buf( 7 );
        fprintf( 'B2 - A_delta(X,Y,Z) = (%i,%i,%i) - @(%i/%i) - #consecutiveGyAboveThreshold = %i - gPrev(x,y) = (%i,%i)\n', deltaX, deltaY, deltaZ,...
            sampleIndex + 1, nSamples,...
            consecutiveGyAboveThreshold, gxPrev, gyPrev );
    else
        fprintf( 'Using an unsuported BB Algorithm...\n' );
    end
    return;
end
