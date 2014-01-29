function im_calc_p1( new_a, new_t, the_imCalcP1_t )
    instanciate_globals;
    
    the_imCalcP1_t.idx_cur_sample = the_imCalcP1_t.idx_cur_sample + 1;
    % Simple check to see if a full buffer of samples has been
    % accumulated.
    % Note: for C conversion, AND IF the ALGO is in 
    % ALGO_MODE_CONTINUOUS_STREAMING mode, the next variable can be
    % made a local boolean
    anotherBufferCompletelyFull = ...
        ( mod( the_imCalcP1_t.idx_cur_sample, g_NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 );
    
    % Test Environment Only: keeps track of the number of full buffers
    % ----------------------
    % received so far.
    if( true == anotherBufferCompletelyFull )
        the_imCalcP1_t.numBuffersProcessed = the_imCalcP1_t.numBuffersProcessed + 1;
        if( the_imCalcP1_t.the_Verbose.verbose_level >= 1 )
            fprintf( 'Buffer %i processed\n', the_imCalcP1_t.numBuffersProcessed );
        end
    end
    

    
    % Algorithm Side (next two variables)
    % --------------
    the_imCalcP1_t.in_buffer1 = 0; % dynamic relevant activity sample start (in buffer)
    the_imCalcP1_t.in_buffer2 = 0; % dynamic relevant activity sample stop (in buffer)
    
        
    % Portion of the code in charge of keeping track of where the relevant
    % activity is, relative to the circular buffer.
    %              --------------------------------
    if( the_imCalcP1_t.numCycle_Locations > 0 )
        for k = 1 : 1 : the_imCalcP1_t.numCycle_Locations
            the_imCalcP1_t.in_buffer_cycle_locations( k ) =...
                the_imCalcP1_t.in_buffer_cycle_locations( k ) - 1;
        end
        
        for k = 1 : 1 : the_imCalcP1_t.numCycle_Locations
            if( the_imCalcP1_t.in_buffer_cycle_locations( k ) >= 1 )
                the_imCalcP1_t.in_buffer1 = the_imCalcP1_t.in_buffer_cycle_locations( k );
                break;
            end
        end
        the_imCalcP1_t.in_buffer2 = the_imCalcP1_t.in_buffer_cycle_locations( the_imCalcP1_t.numCycle_Locations );
    end
    % END of book-keeping for the dynamic indices in charge of locating
    % relevant data within the buffer
    
    % Debug Only:
    % -----------
    % The next block contained within the next if statement takes care of
    % printing activity indices relative to the receiving buffer
    if( ( the_imCalcP1_t.in_buffer1 >= 1 ) &&...
            ( the_imCalcP1_t.in_buffer2 <= g_NUMBER_SAMPLE_CURRENT_BUFFER ) &&...
            ( the_imCalcP1_t.in_buffer1 < the_imCalcP1_t.in_buffer2 ) )
        if( the_imCalcP1_t.the_Verbose.verbose_level > 1 )
            fprintf( ...
                'buffer of interest - info: I = [%.0f %.0f] - n = %.0f\n',...
                the_imCalcP1_t.in_buffer1, the_imCalcP1_t.in_buffer2, ( the_imCalcP1_t.in_buffer2 - the_imCalcP1_t.in_buffer1 + 1 ) );
        end
    end

    % Test Environment Only:
    % ----------------------
    % In the next two lines of code, data erasure is simulated, and this is
    % done by shifting the "sensor buffer" by one element to the left, and
    % appending the new data at the very end of it (to its last element,
    % or to the right).
    
    ScrollHardwareBuffer( the_imCalcP1_t, new_t, new_a );
    
    % Algorithm Side (next two variables)
    % --------------
    %
    % Updating accelerations
    the_imCalcP1_t.a_prev = the_imCalcP1_t.a_curr;
    the_imCalcP1_t.a_curr = new_a;
    
    % Calculate the discontinuity between previous and current activity
    % 01 - Calculate the discontinuity
    discontinuity = abs( the_imCalcP1_t.a_curr - the_imCalcP1_t.a_prev );
    b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );
    
    % 02 - Is it the first activity detection for the current buffer
    b_FirstActivityDetectionCurrentBuffer = ( the_imCalcP1_t.nCycle >= 1 );
    
    b_MeaningfulActivityDetected = false;
    b_dTBetweenCycleOK = false;
    

    
    if( true == b_FirstActivityDetectionCurrentBuffer )
        delta_t = new_t - the_imCalcP1_t.cycle( the_imCalcP1_t.nCycle );
        b_dTBetweenCycleOK = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK = b_dTBetweenCycleOK && ...
            ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    else
        b_FirstActivityDetectionCurrentBuffer = true;
        b_dTBetweenCycleOK = true;
    end
    
    b_MeaningfulAccelerationDetected = ...
        ( the_imCalcP1_t.a_prev >= g_MAG_THRESHOLD ) || ( the_imCalcP1_t.a_curr >= g_MAG_THRESHOLD );
    
    b_allConditionsMet = b_AccDiscontinuityBigEnough;
    b_allConditionsMet = b_allConditionsMet && b_FirstActivityDetectionCurrentBuffer;
    b_allConditionsMet = b_allConditionsMet && b_dTBetweenCycleOK;
    b_allConditionsMet = b_allConditionsMet && b_MeaningfulAccelerationDetected;
    
    if( true == b_allConditionsMet )
        the_imCalcP1_t.nCycle = the_imCalcP1_t.nCycle + 1;
        the_imCalcP1_t.cycle( the_imCalcP1_t.nCycle ) = new_t;
        b_MeaningfulActivityDetected = true;
    end

    
    % if a detection happens, it's always upstream, which means from a
    % circular buffer perspective, it always happens at the end of the
    % buffer, which is location NUMBER_SAMPLE_CURRENT_BUFFER in MATLAB.
    if( b_MeaningfulActivityDetected == true )
        the_imCalcP1_t.numCycle_Locations = the_imCalcP1_t.numCycle_Locations + 1;
        the_imCalcP1_t.in_buffer_cycle_locations( the_imCalcP1_t.numCycle_Locations ) = g_NUMBER_SAMPLE_CURRENT_BUFFER;
        if( the_imCalcP1_t.the_Verbose.verbose_level > 1 )
            fprintf( 'cycle detected @ sample #%i\n', new_t );
        end
    end
    
    if( the_imCalcP1_t.nCycle > 0 )
        percentageRelevantActivity = CalculatePercentageRelevantActivity( the_imCalcP1_t );
        
        
        % Two conditions need to be met in order for the buffer to be
        % uploaded:
        % - The percentage of relevant activity needs to be >= 50
        % - The first sign of the relevant data must be about to dissapear
        b_bufferContainsEnoughData = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );
        b_bufferIsAboutToSelfErase = ( the_imCalcP1_t.in_buffer1 == 1 );
        b_uploadCondition = false;
        if( g_ALGO_MODE == g_ALGO_MODE_CONTINUOUS_STREAMING )
            b_uploadCondition = b_bufferContainsEnoughData && b_bufferIsAboutToSelfErase;
        else
            b_uploadCondition = b_bufferContainsEnoughData;
        end
        if( true == b_uploadCondition )
            fprintf( 'Uploading buffer - I = [%.0f %.0f] - Triggered by sample number %.0f\n',...
                the_imCalcP1_t.in_buffer1, the_imCalcP1_t.in_buffer2, the_imCalcP1_t.idx_cur_sample );
            % Example:
            the_imCalcP1_t.numUploads = the_imCalcP1_t.numUploads + 1;
            the_imCalcP1_t.the_Sim.upload_triggering_samples( 1, the_imCalcP1_t.numUploads ) = the_imCalcP1_t.idx_cur_sample;
            
            
            MaybeKeepTrackOfAllCycles( the_imCalcP1_t );

            
            %--------------------------------------------------------------
            % HARDWARE EMULATION ON?
            if( g_SENSOR_HARDWARE_EMULATION_MODE  == g_SENSOR_HARDWARE_EMULATION_ON )
                MaybeKeepTrackOfCycles( the_imCalcP1_t );
            end % End if( SENSOR_HARDWARE_EMULATION_MODE  == SENSOR_HARDWARE_EMULATION_ON )
            %--------------------------------------------------------------
            
            ResetBufferIndices( the_imCalcP1_t );

        end
        if( b_bufferIsAboutToSelfErase &&  ~b_bufferContainsEnoughData )
            ResetBufferIndices( the_imCalcP1_t );
        end
    end
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function ScrollHardwareBuffer( the_imCalcP1_t, new_t, new_a )
    instanciate_globals;
    if( g_SENSOR_HARDWARE_EMULATION_MODE  == g_SENSOR_HARDWARE_EMULATION_ON )
        the_imCalcP1_t.the_Sim.buffer( :, 1 : end - 1 ) = the_imCalcP1_t.the_Sim.buffer( :, 2 : end );
        the_imCalcP1_t.the_Sim.buffer( :, end ) = [new_t; new_a];
    end
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function MaybeKeepTrackOfAllCycles( the_imCalcP1_t )
    instanciate_globals;
    if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
        sz = the_imCalcP1_t.nCycle;
        the_imCalcP1_t.the_Sim.all_cycle_sizes( 1, the_imCalcP1_t.numUploads ) = sz;
        the_imCalcP1_t.the_Sim.all_cycles( the_imCalcP1_t.numUploads, 1 : 1 : the_imCalcP1_t.nCycle ) = the_imCalcP1_t.cycle( 1 : 1 : the_imCalcP1_t.nCycle );
    end % End if( KEEP_TRACK_OFF_ALL_CYCLES == ON )
    return;
end

%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function ResetBufferIndices( the_imCalcP1_t )
    the_imCalcP1_t.nCycle = 0;
    the_imCalcP1_t.the_Verbose.warning_issued = false;
    the_imCalcP1_t.numCycle_Locations = 0;
    the_imCalcP1_t.in_buffer1 = 0;
    the_imCalcP1_t.in_buffer2 = 0;
    return;
end


%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function MaybeKeepTrackOfCycles( the_imCalcP1_t )
    instanciate_globals;
    if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
        i1 = the_imCalcP1_t.in_buffer1;
        i2 = the_imCalcP1_t.in_buffer2;
        sz = the_imCalcP1_t.in_buffer2 - the_imCalcP1_t.in_buffer1 + 1;
        the_imCalcP1_t.the_Sim.buffer_sizes( 1, the_imCalcP1_t.numUploads ) = sz;
        a1 = 2 * ( the_imCalcP1_t.numUploads - 1 ) + 1;
        a2 = a1 + 1;
        the_imCalcP1_t.the_Sim.buffers(  a1 : 1 : a2, i1 : 1 : i2 ) = the_imCalcP1_t.the_Sim.buffer( 1 : 2, i1 : 1 : i2 );
    end % End if( KEEP_TRACK_OFF_ALL_CYCLES == ON )
    return;
end


%//////////////////////////////////////////////////////////////////////////
%//////////////////////////////////////////////////////////////////////////
function percentageRelevantActivity = CalculatePercentageRelevantActivity( the_imCalcP1_t )
    instanciate_globals;
    numberSamplesInRelevantActivity = 0;
    if( the_imCalcP1_t.nCycle >= 2 )
        for k = 1 : 1 : ( the_imCalcP1_t.nCycle - 1 )
            len = the_imCalcP1_t.cycle( k + 1 ) - the_imCalcP1_t.cycle( k ) + 1;
            if( len > 0 )
                numberSamplesInRelevantActivity =...
                    numberSamplesInRelevantActivity + len;
            end
        end
    end
    percentageRelevantActivity = ...
        ( numberSamplesInRelevantActivity / g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100;
    if( ( percentageRelevantActivity >= g_CRITICAL_PERCENT ) && ( the_imCalcP1_t.the_Verbose.warning_issued == false ) )
        the_imCalcP1_t.the_Verbose.warning_issued = true;
        if( the_imCalcP1_t.the_Verbose.verbose_level > 1 )
            fprintf( 'Warning: data is worth being recorded!\n' );
        end
        nLeft = g_NUMBER_SAMPLE_CURRENT_BUFFER - numberSamplesInRelevantActivity;
        if( the_imCalcP1_t.the_Verbose.verbose_level > 1 )
            fprintf( 'samples left to accumulate before meaningful data starts being erased = %.0f\n', nLeft );
        end
    end
    return;
end
