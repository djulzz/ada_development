function [ tf ] = f_scripted_mexRunADA( RawSensorData )
    tf = false;
    nSamples = length( RawSensorData.TimeLine );
    if( nSamples < 1000 )
        return;
    end
    first_sample_info = false;
    for i = 1 : 1 : nSamples
        in_accel = RawSensorData.Accelerations( i, : );
        in_gyros = RawSensorData.Gyroscopes( i, : );
        if( 1 == i )
            first_sample_info = true;
        end
        res = mexRunADA( in_accel, in_gyros, first_sample_info );
        if( 1 == res )
            tf = true;
            break;
        end
    end
    return;
end
