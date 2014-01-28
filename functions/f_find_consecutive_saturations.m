function max_consecutive_saturations = f_find_consecutive_saturations( RawSensorData )

    n = length( RawSensorData.TimeLine );
    sig = zeros( 1, n );

    disc = [  ];
    for i = 1 : 1 : n
        sig( i ) = norm( RawSensorData.Accelerations( i, : ) );
        if( i > 1 )
            deltaX = abs( RawSensorData.Accelerations( i, 1 ) - RawSensorData.Accelerations( i - 1, 1 ) );
            deltaY = abs( RawSensorData.Accelerations( i, 2 ) - RawSensorData.Accelerations( i - 1, 2 ) );
            deltaZ = abs( RawSensorData.Accelerations( i, 3 ) - RawSensorData.Accelerations( i - 1, 3 ) );
            DiscFound = ( deltaX > 1500 ) ||( deltaY > 1500 ) || ( deltaZ > 1500 );
            if( true == DiscFound )
                disc = [disc, i];
            end
        end
    end

    %res = ( diff( disc ) == 1 );
     p = find([true,diff(disc)==1,true]); % Find beginnings of sequences.

     [ignore,q] = max(diff(p)); % Determine which sequence is longest
     y = disc(p(q):p(q+1)-1); % Reduce x to just that sequence

     max_consecutive_saturations = length( y );
 
 end
 