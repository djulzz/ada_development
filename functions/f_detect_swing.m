function [res, values] = f_detect_swing( RawSensorData, consecutive_limit, gy_impact_threshold )

    res = false;
    values = [  ];
    MSG_IMPACT_SIGNATURE      = 2;
    
    nSamples = length( RawSensorData.TimeLine );
    pRec = im_rec_t(  );
    b1 = imCalcB1_t(  );
    

    for k = 1 : 1 : nSamples
        in_accel = RawSensorData.Accelerations( k, : );
        in_gyros = RawSensorData.Gyroscopes( k, : );
        if( k == 1 )
            b1.firstSampleOfCapture = true;
        else
            b1.firstSampleOfCapture = false;
        end

        pRec.accel.x = in_accel( 1 );
        pRec.accel.y = in_accel( 2 );
        pRec.accel.z = in_accel( 3 );

        pRec.gyro.x = in_gyros( 1 );
        pRec.gyro.y = in_gyros( 2 );
        pRec.gyro.z = in_gyros( 3 );

        [result, ret_val] = detect_swing( b1, pRec, consecutive_limit, gy_impact_threshold );
        if( result == MSG_IMPACT_SIGNATURE )
            values = [values; [k, ret_val]];
            res = true;
            break;
        end
    end

%     if( true == isempty( values ) )
%         res = false;
%     else
%         res = true;
%     end
    
    return;
end
