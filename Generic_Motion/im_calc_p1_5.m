function o = im_calc_p1_5( new_a, new_t, the_imCalcP1_t )
    instanciate_globals;
    initialize_globals;

    o                   = the_imCalcP1_t;
    o.idx_cur_sample    = new_t;
    o.a_prev            = o.a_curr;
    o.a_curr            = new_a;

	o = DetectActivityDiscontinuity( o );
    o = CheckIfCurrentBufferNeedsToBeUploaded( o );
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = ResetBufferIndices( the_imCalcP1_t )
    instanciate_globals;
    fn_name = 'ResetBufferIndices';
%     fprintf( '%s\n', fn_name );
    o = the_imCalcP1_t;
    o.cycle = zeros( 1, g_MAX_NUM_CYCLE_LOCATIONS );
    o.nCycle = 0;
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function [percentageRelevantActivity, o] = CalculatePercentageRelevantActivity( the_imCalcP1_t )
    instanciate_globals;
    o = the_imCalcP1_t;
    numberSamplesInRelevantActivity = 0;
    if( o.nCycle >= 2 )
%         fn_name = 'CalculatePercentageRelevantActivity';
%         fprintf( '%s\n', fn_name );
        for k = 2 : 1 : o.nCycle
            len = ( o.cycle( k ) - o.cycle( k - 1 ) + 1 );
            numberSamplesInRelevantActivity = numberSamplesInRelevantActivity + len;
        end
    end
    percentageRelevantActivity = ( numberSamplesInRelevantActivity / g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100;
%     if( ( percentageRelevantActivity > 0 ) && ( percentageRelevantActivity < 100 ) )
%         fprintf( 'Percentage = %.2f\n', percentageRelevantActivity );
%     end
    return;
end


%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = DetectActivityDiscontinuity( the_imCalcP1_t )
    instanciate_globals;
    o                                       = the_imCalcP1_t;
    discontinuity                           = uint32( 0 );
    new_t                                   = o.idx_cur_sample;
    
    b_AccDiscontinuityBigEnough             = false;
    b_MeaningfulActivityDetected            = false;
    b_dTBetweenCycleOK                      = false;
    
    
    if( o.a_curr > o.a_prev )
        discontinuity = o.a_curr - o.a_prev;
    else
        discontinuity = o.a_prev - o.a_curr;
    end
    
    b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );
    b_MeaningfulAccelerationDetected = ( o.a_prev >= g_MAG_THRESHOLD ) || ( o.a_curr >= g_MAG_THRESHOLD );
    
    delta_t = 0;
    if( o.nCycle >= 1 )
        delta_t             = new_t - o.cycle( o.nCycle );
        if( delta_t >= 2 * g_MAX_NUM_SAMPLES_BETWEEN_CYCLES )
            o = ResetBufferIndices( o );
        end
        b_dTBetweenCycleOK  = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK  = b_dTBetweenCycleOK && ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
%         b_dTBetweenCycleOK  = ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
%     elseif( o.nCycle == 1 )
%         delta_t             = new_t - o.cycle( o.nCycle );
%         b_dTBetweenCycleOK = true;
    elseif( o.nCycle == 0 )
        b_dTBetweenCycleOK = true;
    end
    
%     b_dTBetweenCycleOK = true;
    b_MeaningfulActivityDetected = b_AccDiscontinuityBigEnough && b_MeaningfulAccelerationDetected && b_dTBetweenCycleOK;

    if( true == b_MeaningfulActivityDetected )
        o.nCycle = o.nCycle + 1;
        o.cycle( o.nCycle ) = o.idx_cur_sample;
%         fn_name = 'DetectActivityDiscontinuity';
%         fprintf( '%s - #cycle = %i\n', fn_name, o.nCycle );
    else
        if( ~b_dTBetweenCycleOK )
            if( b_MeaningfulAccelerationDetected && b_AccDiscontinuityBigEnough )
%                 fn_name = 'DetectActivityDiscontinuity';
%                 fprintf( '%s - time problem - dt = %i\n', fn_name, delta_t );
%                 o = ResetBufferIndices( o );
%                 o.nCycle = o.nCycle + 1;
%                 o.cycle( o.nCycle ) = o.idx_cur_sample;
            end
        end
    end

    return;
end

    
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = CheckIfCurrentBufferNeedsToBeUploaded( the_imCalcP1_t )
    instanciate_globals;
    o = the_imCalcP1_t;
    if( o.nCycle >= 2 )
%         fn_name = 'CheckIfCurrentBufferNeedsToBeUploaded';
%         fprintf( '%s\n', fn_name );
        [percentageRelevantActivity, o] = CalculatePercentageRelevantActivity( o );
        
        n2 = o.cycle( o.nCycle );
        n1 = o.cycle( 1 );
        
        size_in_buffer = ( n2 - n1 ) + 1;
        
        b_bufferContainsEnoughData      = false;
        b_bufferIsAboutToSelfErase      = false;
        b_uploadCondition               = false;
        b_bufferFull                    = false;
        
        b_uploadCondition = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );

        nDataPoints = size_in_buffer;
        if( true == b_uploadCondition )
            fprintf( 'Uploading I = [%.0f %.0f] - Triggered by sample %.0f - NPoints = %.0f - Percentage = %.2f\n',...
                n1, n2, o.idx_cur_sample, nDataPoints, percentageRelevantActivity );
            g_cycles = [g_cycles; [n1, n2]];
            o = ResetBufferIndices( o );
            return;

        else
            if( ( o.nCycle >= g_MAX_NUM_CYCLE_LOCATIONS ) && ( percentageRelevantActivity < g_CRITICAL_PERCENT ) )
                o = ResetBufferIndices( o );
                return;
            end

        end
    end
    return;
end
