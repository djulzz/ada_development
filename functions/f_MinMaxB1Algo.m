function [ vMin, vMax, values ] = f_MinMaxB1Algo( RawSensorData )

    MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
    MSG_GYROS_MATCH_DOWNSWING = 1;
    MSG_IMPACT_SIGNATURE      = 2;
    MSG_NOTHING               = 3;
    threshold = 1500;

    vMin = -1;
    vMax = -1;
    
    pRec = im_rec_t(  );
    b1 = imCalcB1_t(  );
    
    res = 0;
    first_sample_info = false;
    values = [  ];
    bPotentialSignature = false;
    nSamples = length( RawSensorData.TimeLine );
    
    for i = 1 : 1 : nSamples

        in_accel = RawSensorData.Accelerations( i, : );
        in_gyros = RawSensorData.Gyroscopes( i, : );
        if( i == 1 )
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

        [res, ret_val] = detect_swing( b1, pRec );

        if( MSG_IMPACT_SIGNATURE == res )
            values = [values; [ret_val, i]];
            bPotentialSignature = true;
        end
    end
    if( true == bPotentialSignature )
        vMin = min( values( :, 1 ) );
        vMax = max( values( :, 1 ) );
        %fprintf( 'Y - [%.1E\t%.1E]\n', vMin, vMax );
        ;
    end
    return;
end

