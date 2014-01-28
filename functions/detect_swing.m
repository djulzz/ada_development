function [res, ret_val] = detect_swing( b1, pRec, consecutive_limit, gy_impact_threshold )

    ret_val = 0;
%     b1.indexTime = b1.indexTime + 1;
%     b1.consecutiveGyAboveThreshold = b1.consecutiveGyAboveThreshold + 1;
    % imCalcB1_t* b1, im_rec_t *pRec
	MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
	MSG_GYROS_MATCH_DOWNSWING = 1;
	MSG_IMPACT_SIGNATURE      = 2;
	MSG_NOTHING               = 3;
    
    ACCEL_DISCONTINUITY_THRESHOLD  = 1500;  % = 18g @ 24g range
    
    %changed for CES Mini Club Demo 10000  // = 12.2 rad/s; note should be POSITIVE
	GY_IMPACT_THRESHOLD = gy_impact_threshold;
    EXCEED_THRESHOLD_INTERVAL = consecutive_limit;
    GXY_SQUARED_IMPACT_THRESHOLD = 64000000;  % = 8000^2
    
    res = MSG_NOTHING;

    
    gx = pRec.gyro.x;
    gy = pRec.gyro.y;
    gz = pRec.gyro.z;
    
    ax = pRec.accel.x;
    ay = pRec.accel.y;
    az = pRec.accel.z;
    
    if( true == b1.firstSampleOfCapture )
        %fprintf( 1, 'detect_swing (MATLAB): 1st sample\n' );
        b1.firstSampleOfCapture = false;
        
        b1.axPrev = ax;
        b1.ayPrev = ay;
        b1.azPrev = az;
        
        b1.gxPrev = gx;
        b1.gyPrev = gy;
        b1.gzPrev = gz;
    end
    
    axDelta = abs( ax - b1.axPrev );
    ayDelta = abs( ay - b1.ayPrev );
    azDelta = abs( az - b1.azPrev );
    
    shockAx = axDelta > ACCEL_DISCONTINUITY_THRESHOLD;
    shockAy = ayDelta > ACCEL_DISCONTINUITY_THRESHOLD;
    shockAz = azDelta > ACCEL_DISCONTINUITY_THRESHOLD;
    shockAnyAccelAxis = shockAx || shockAy || shockAz;
%   
    magAxAyDelta = norm( [axDelta, ayDelta] );
    bZDominantAccel = azDelta > magAxAyDelta;

    
    if( abs( b1.gyPrev) > gy_impact_threshold )
        b1.consecutiveGyAboveThreshold = b1.consecutiveGyAboveThreshold + 1;
    else
        b1.consecutiveGyAboveThreshold = 0;
    end
    if( abs( b1.gxPrev ) > gy_impact_threshold )
        b1.consecutiveGxAboveThreshold = b1.consecutiveGxAboveThreshold + 1;
    else
        b1.consecutiveGxAboveThreshold = 0;
    end
%     if( abs( b1.gzPrev ) > GY_IMPACT_THRESHOLD)
%         fprintf( '- Z - \n' );
%     end
%         b1.consecutiveGzAboveThreshold = b1.consecutiveGzAboveThreshold + 1;
%     else
%         b1.consecutiveGzAboveThreshold = 0;
%     end
    
    b1.axPrev = ax;
    b1.ayPrev = ay;
    b1.azPrev = az;
    
    b1.gxPrev = gx;
    b1.gyPrev = gy;
    b1.gzPrev = gz;
    
    gxySquaredPrev = ( b1.gxPrev ) * ( b1.gxPrev ) + ( b1.gyPrev ) * ( b1.gyPrev );
    ret_val = gxySquaredPrev;
    impactSignature = false;
    
    if( ( true == shockAnyAccelAxis ) && ( false == bZDominantAccel ) )
        res = MSG_SHOCK_ANY_ACCE_LAXIS;
%         res = MSG_IMPACT_SIGNATURE;

        gyMatchesDownswing = b1.consecutiveGyAboveThreshold >= EXCEED_THRESHOLD_INTERVAL;
        gxMatchesDownswing = b1.consecutiveGxAboveThreshold >= EXCEED_THRESHOLD_INTERVAL;
%         gzMatchesDownswing = b1.consecutiveGzAboveThreshold >= EXCEED_THRESHOLD_INTERVAL;

%         if( gyMatchesDownswing || gxMatchesDownswing || gzMatchesDownswing )
        if( gyMatchesDownswing || gxMatchesDownswing )
            res = MSG_GYROS_MATCH_DOWNSWING;
            
            if( gxySquaredPrev >= GXY_SQUARED_IMPACT_THRESHOLD )
                res = MSG_IMPACT_SIGNATURE;
                impactSignature = true;
            end
        end
    end
    return;
end
