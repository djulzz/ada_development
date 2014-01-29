function o = im_calc_p1_4( new_a, new_t, the_imCalcP1_t )
    instanciate_globals;
    initialize_globals;

    o = the_imCalcP1_t;
    
    o.idx_cur_sample = o.idx_cur_sample + 1;
    
    anotherBufferCompletelyFull = ...
        ( mod( o.idx_cur_sample, g_NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 );

    
    if( true == anotherBufferCompletelyFull )
        o.numBuffersProcessed = o.numBuffersProcessed + 1;
        if( o.verbose_level >= 1 )
            fprintf( 'Buffer %i processed\n', o.numBuffersProcessed );
        end
    end
    
    o = UpdateBufferRelativeCycleIndices( o );

    o.a_prev = o.a_curr;
    o.a_curr = new_a;

	o = DetectActivityDiscontinuity( o, new_t );

    o = CheckIfCurrentBufferNeedsToBeUploaded( o );
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = ResetBufferIndices( the_imCalcP1_t )
    o = the_imCalcP1_t;
    o.nCycle = uint32( 0 );
    o.warning_issued = false;
    o.numCycle_Locations = uint32( 0 );
    o.in_buffer1 = int32( 0 );
    o.in_buffer2 = int32( 0 );
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function [percentageRelevantActivity, o] = CalculatePercentageRelevantActivity( the_imCalcP1_t )
    instanciate_globals;
    o = the_imCalcP1_t;
    numberSamplesInRelevantActivity = uint32( 0 );
    if( o.nCycle >= 2 )
        for k = 1 : 1 : ( o.nCycle - 1 )
            len = uint32( o.cycle( k + 1 ) - o.cycle( k ) + 1 );
            if( len > 0 )
                numberSamplesInRelevantActivity =...
                    numberSamplesInRelevantActivity + len;
            end
        end
    end
    percentageRelevantActivity = ...
        ( numberSamplesInRelevantActivity / g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100;
    

    if( ( percentageRelevantActivity >= g_CRITICAL_PERCENT ) && ( the_imCalcP1_t.warning_issued == false ) )
        o.warning_issued = true;
        if( o.verbose_level > 1 )
            fprintf( 'Warning: data is worth being recorded!\n' );
        end
        nLeft = g_NUMBER_SAMPLE_CURRENT_BUFFER - numberSamplesInRelevantActivity;
        if( o.verbose_level > 1 )
            fprintf( 'samples left to accumulate before meaningful data starts being erased = %.0f\n', nLeft );
        end
    end
    return;
end


%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = UpdateBufferRelativeCycleIndices( the_imCalcP1_t )
    o = the_imCalcP1_t;
    o.in_buffer1 = int32( 0 );
    o.in_buffer2 = int32( 0 );

    if( o.numCycle_Locations > 0 )
        for k = 1 : 1 : o.numCycle_Locations
            o.in_buffer_cycle_locations( k ) =...
                o.in_buffer_cycle_locations( k ) - 1;
        end

        for k = 1 : 1 : o.numCycle_Locations
            if( o.in_buffer_cycle_locations( k ) >= 1 )
                o.in_buffer1 = o.in_buffer_cycle_locations( k );
                break;
            end
        end
        o.in_buffer2 = o.in_buffer_cycle_locations( o.numCycle_Locations );
    end
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = DetectActivityDiscontinuity( the_imCalcP1_t, new_t )
    instanciate_globals;
    o = the_imCalcP1_t;
    discontinuity = uint32( 0 );
    
    b_AccDiscontinuityBigEnough = false;
    b_FirstActivityDetectionCurrentBuffer = false;
    b_MeaningfulActivityDetected = false;
    b_dTBetweenCycleOK = false;
    b_allConditionsMet = false;
    
    if( o.a_curr > o.a_prev )
        discontinuity = o.a_curr - o.a_prev;
    else
        discontinuity = o.a_prev - o.a_curr;
    end
    
    b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );
    b_FirstActivityDetectionCurrentBuffer = ( o.nCycle >= 1 );

    

    
    if( true == b_FirstActivityDetectionCurrentBuffer )
        delta_t = new_t - o.cycle( o.nCycle );
        b_dTBetweenCycleOK = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK = b_dTBetweenCycleOK && ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    else
        b_FirstActivityDetectionCurrentBuffer = true;
        b_dTBetweenCycleOK = true;
    end
    
    
    b_MeaningfulAccelerationDetected = ( o.a_prev >= g_MAG_THRESHOLD ) || ( o.a_curr >= g_MAG_THRESHOLD );
    
    b_allConditionsMet = b_AccDiscontinuityBigEnough;
    b_allConditionsMet = b_allConditionsMet && b_FirstActivityDetectionCurrentBuffer;
    b_allConditionsMet = b_allConditionsMet && b_dTBetweenCycleOK;
    b_allConditionsMet = b_allConditionsMet && b_MeaningfulAccelerationDetected;
    
    if( true == b_allConditionsMet )
        b_MeaningfulActivityDetected = true;
    end
    
    
    if( true == b_MeaningfulActivityDetected )
        o.nCycle = o.nCycle + 1;
        o.cycle( o.nCycle ) = new_t;
    end
    

    if( b_MeaningfulActivityDetected == true )
        o.numCycle_Locations = o.numCycle_Locations + 1;
        o.in_buffer_cycle_locations( o.numCycle_Locations ) = g_NUMBER_SAMPLE_CURRENT_BUFFER;
        if( o.verbose_level > 1 )
            fprintf( 'cycle detected @ sample #%i\n', new_t );
        end
    end
    
    
    return;
end

    
%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function o = CheckIfCurrentBufferNeedsToBeUploaded( the_imCalcP1_t )
    instanciate_globals;
    o = the_imCalcP1_t;
    if( o.nCycle > 0 )
        [percentageRelevantActivity, o] = CalculatePercentageRelevantActivity( o );
        
        size_in_buffer = ( o.in_buffer2 - o.in_buffer1 ) + 1;
        
        b_bufferContainsEnoughData = false;
        b_bufferIsAboutToSelfErase = false;
        b_uploadCondition = false;
        b_bufferFull = false;
        
        b_bufferContainsEnoughData = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );
        if( g_MEANINGLESS_DATA_REQUIRED == g_OFF )
            b_bufferIsAboutToSelfErase = ( o.in_buffer1 == 1 );
        else
            b_bufferIsAboutToSelfErase = ( o.in_buffer1 == ( g_NUMBER_SAMPLES_BEFORE_FIRST_INTERESTING_SAMPLE + 1 ) );
        end
        b_bufferFull = ( mod( o.idx_cur_sample, g_NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 );
        

        if( g_WAIT_FOR_FULL_BUFFER == g_OFF )
            if( b_bufferContainsEnoughData && b_bufferIsAboutToSelfErase )
                b_uploadCondition = true;
            end
        else
            if( b_bufferContainsEnoughData && b_bufferFull )
                b_uploadCondition = true;
                o.in_buffer1 = 1;
                o.in_buffer2 = g_NUMBER_SAMPLE_CURRENT_BUFFER;
            end
        end

        
        if( true == b_uploadCondition )
            nDataPoints = ( o.in_buffer2 - o.in_buffer1 ) + 1;
            fprintf( 'Uploading buffer - I = [%.0f %.0f] - Triggered by sample number %.0f - NPoints = %.0f\n',...
                o.in_buffer1, o.in_buffer2, o.idx_cur_sample, nDataPoints );
            

            o = ResetBufferIndices( o );
            return;

        else
            if( g_WAIT_FOR_FULL_BUFFER == g_OFF )
                if( b_bufferIsAboutToSelfErase &&  ~b_bufferContainsEnoughData )
                    o = ResetBufferIndices( o );
                    return;
                end
            else
                if( b_bufferFull )
                    o = ResetBufferIndices( o );
                    return;
                end
            end
        end
    end
    return;
end
