function [ acc_delta ] = f_generate_raw_acceleration_delta_vector( RawSensorData )

    index = -1;
    n = length( RawSensorData.TimeLine );
    if( n < 50 )
        return;
    end
    
    for i = 1 : 1 : ( n - 1 )
        abs_delta_ax = abs( RawSensorData.Accelerations( i + 1, 1 ) - RawSensorData.Accelerations( i + 0, 1 ) );
        abs_delta_ay = abs( RawSensorData.Accelerations( i + 1, 2 ) - RawSensorData.Accelerations( i + 0, 2 ) );
        abs_delta_az = abs( RawSensorData.Accelerations( i + 1, 3 ) - RawSensorData.Accelerations( i + 0, 3 ) );
        acc_delta( i ) = norm( [abs_delta_ax, abs_delta_ay, abs_delta_az] );
    end

    return;
end

