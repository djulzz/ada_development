function [ index ] = f_detect_acc_discontinuity( RawSensorData, thresold )

    index = -1;
    n = length( RawSensorData.TimeLine );
    if( n < 50 )
        return;
    end
    
    for i = 1 : 1 : ( n - 1 )
        abs_delta_ax = abs( RawSensorData.Accelerations( i + 1, 1 ) - RawSensorData.Accelerations( i + 0, 1 ) );
        abs_delta_ay = abs( RawSensorData.Accelerations( i + 1, 2 ) - RawSensorData.Accelerations( i + 0, 2 ) );
        abs_delta_az = abs( RawSensorData.Accelerations( i + 1, 3 ) - RawSensorData.Accelerations( i + 0, 3 ) );
        if( ( abs_delta_ax >= thresold ) || ( abs_delta_ay >= thresold ) || ( abs_delta_az >= thresold ) )
            index = i;
            break;
            return;
        end
    end

    return;
end

