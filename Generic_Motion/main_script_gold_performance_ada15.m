clear all;
close all;
clc;
format bank;


load( 'the_generated_buffers.mat' );

a = b;
a = a( 1601 : 3201 );
fprintf( 'Numbers of samples in buffer = %i\n', length( a ) );

nElements = length( a );
t = [ 1 : 1 : nElements ];

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
global g_ON                              ;
global g_OFF                             ;
global g_DRAWING_OFF                     ;
global g_DRAWING_ON                      ;
global g_DRAWING_MODE                    ;

global g_ALGO_MODE_ONE_SHOT              ;
global g_ALGO_MODE_CONTINUOUS_STREAMING  ;
global g_ALGO_MODE                       ;

global g_ALGO_UPLOAD_MODE_FULL_CAPACITY  ;
global g_ALGO_UPLOAD_MODE_RELEVANT_ONLY  ;
global g_ALGO_UPLOAD_MODE_WAIT_PUSH      ;
global g_ALGO_UPLOAD_MODE                ;
global g_SPRINTING_MAG_THRESHOLD         ;
global g_SPRINTING_DISC_THRESHOLD        ;
global g_RUNNING_DISC_THRESHOLD          ;
global g_JUMPING_DISC_THRESHOLD          ;
global g_JUMPING_MAGN_THRESHOLD          ;
global g_MIN_NUM_SAMPLES_BETWEEN_CYCLES  ;
global g_MAX_NUM_SAMPLES_BETWEEN_CYCLES  ;
global g_MAG_THRESHOLD                   ;
global g_DISC_THRESHOLD                  ;
global g_SENSOR_HARDWARE_EMULATION_ON    ;
global g_SENSOR_HARDWARE_EMULATION_OFF   ;
global g_SENSOR_HARDWARE_EMULATION_MODE  ;
global g_KEEP_TRACK_OFF_ALL_CYCLES       ;
global g_NUMBER_SAMPLE_CURRENT_BUFFER	 ;
global g_MAX_NUM_CYCLE_LOCATIONS         ;
global g_CRITICAL_PERCENT                ;
global g_MAX_NUMBER_BUFFERS_TO_UPLOAD    ;

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
% Define ON and OFF keywords
g_ON                              = 1;
g_OFF                             = 0;

% Define Drawing Modes
g_DRAWING_OFF                     = g_OFF;
g_DRAWING_ON                      = g_ON;
g_DRAWING_MODE                    = g_DRAWING_ON;

% Define for the Algo mode (one shot VS. continuous)
g_ALGO_MODE_ONE_SHOT              = 1;
g_ALGO_MODE_CONTINUOUS_STREAMING  = 2;
g_ALGO_MODE                       = g_ALGO_MODE_ONE_SHOT;
g_ALGO_UPLOAD_MODE_FULL_CAPACITY  = 1;
g_ALGO_UPLOAD_MODE_RELEVANT_ONLY  = 2;
g_ALGO_UPLOAD_MODE_WAIT_PUSH      = 3;
g_ALGO_UPLOAD_MODE                = g_ALGO_UPLOAD_MODE_WAIT_PUSH;

% Define Activity-specific Constants
g_SPRINTING_MAG_THRESHOLD         = 1005;
g_SPRINTING_DISC_THRESHOLD        = 1200;
g_RUNNING_DISC_THRESHOLD          = 1000;
g_JUMPING_DISC_THRESHOLD          = 1700;
g_JUMPING_MAGN_THRESHOLD          = 2250;
g_MIN_NUM_SAMPLES_BETWEEN_CYCLES  = 30;
g_MAX_NUM_SAMPLES_BETWEEN_CYCLES  = 500;
g_MAG_THRESHOLD                   = g_SPRINTING_MAG_THRESHOLD;
g_DISC_THRESHOLD                  = g_SPRINTING_DISC_THRESHOLD;
 
% Define Simulation Constants
g_SENSOR_HARDWARE_EMULATION_ON    = g_ON;
g_SENSOR_HARDWARE_EMULATION_OFF   = g_OFF;
g_SENSOR_HARDWARE_EMULATION_MODE  = g_SENSOR_HARDWARE_EMULATION_ON;
g_KEEP_TRACK_OFF_ALL_CYCLES       = g_ON;

% Computer memory specific Constants
g_NUMBER_SAMPLE_CURRENT_BUFFER	= 1600;
g_MAX_NUM_CYCLE_LOCATIONS         = ceil( g_NUMBER_SAMPLE_CURRENT_BUFFER / g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );

% Buffer Relevant activity fullness
g_CRITICAL_PERCENT                = 50;
g_MAX_NUMBER_BUFFERS_TO_UPLOAD    = ( nElements / g_NUMBER_SAMPLE_CURRENT_BUFFER );

% Algo variables
%--------------------------------------------------------------------------
imCalcP1_t.a_prev                          = 0;
imCalcP1_t.a_curr                          = 0;
imCalcP1_t.nCycle                          = 0;
imCalcP1_t.LimitElementsToProcess          = nElements;
imCalcP1_t.idx_cur_sample                  = 0;
imCalcP1_t.numCycle_Locations              = 0;
imCalcP1_t.in_buffer_cycle_locations       = zeros( 1, g_MAX_NUM_CYCLE_LOCATIONS );
imCalcP1_t.cycle                           = zeros( 1, g_MAX_NUM_CYCLE_LOCATIONS );
imCalcP1_t.in_buffer1                      = 0;
imCalcP1_t.in_buffer2                      = 0;
imCalcP1_t.numBuffersProcessed             = 0;
imCalcP1_t.numUploads                      = 0;

% Simulation variables
%--------------------------------------------------------------------------
imCalcP1_t.Sim.buffer                      = zeros( 2, g_NUMBER_SAMPLE_CURRENT_BUFFER );
imCalcP1_t.Sim.all_cycles                  = cell( 1, g_MAX_NUMBER_BUFFERS_TO_UPLOAD );
imCalcP1_t.Sim.buffers                     = cell( 1, g_MAX_NUMBER_BUFFERS_TO_UPLOAD );
imCalcP1_t.Sim.upload_triggering_samples   = zeros( 1, g_MAX_NUMBER_BUFFERS_TO_UPLOAD );

% Verbose variables
%--------------------------------------------------------------------------
imCalcP1_t.Verbose.warning_issued          = false;
imCalcP1_t.verbose_level                   = 1;


% The top for-loop simulates oncoming data that would be sensed by the
% sensor
for index_samples = 1 : 1 : imCalcP1_t.LimitElementsToProcess % iterate through all
                                                   % the simulated oncoming
                                                   % sensed data

    imCalcP1_t.idx_cur_sample = imCalcP1_t.idx_cur_sample + 1;
    % Simple check to see if a full buffer of samples has been
    % accumulated.
    % Note: for C conversion, AND IF the ALGO is in 
    % ALGO_MODE_CONTINUOUS_STREAMING mode, the next variable can be
    % made a local boolean
    anotherBufferCompletelyFull = ...
        ( mod( imCalcP1_t.idx_cur_sample, g_NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 );
    
    % Test Environment Only: keeps track of the number of full buffers
    % ----------------------
    % received so far.
    if( true == anotherBufferCompletelyFull )
        imCalcP1_t.numBuffersProcessed = imCalcP1_t.numBuffersProcessed + 1;
        if( imCalcP1_t.verbose_level >= 1 )
            fprintf( 'Buffer %i processed\n', imCalcP1_t.numBuffersProcessed );
        end
    end
    
    % Test Environment Only:
    % ----------------------
    % short hand variables keeping track of oncoming sample
    
    new_t = t( imCalcP1_t.idx_cur_sample ); % new oncoming sample number
    new_a = a( imCalcP1_t.idx_cur_sample ); % new oncoming acceleration magnitude
    
    % Algorithm Side (next two variables)
    % --------------
    imCalcP1_t.in_buffer1 = 0; % dynamic relevant activity sample start (in buffer)
    imCalcP1_t.in_buffer2 = 0; % dynamic relevant activity sample stop (in buffer)
    
        
    % Portion of the code in charge of keeping track of where the relevant
    % activity is, relative to the circular buffer.
    %              --------------------------------
    if( imCalcP1_t.numCycle_Locations > 0 )
        for k = 1 : 1 : imCalcP1_t.numCycle_Locations
            imCalcP1_t.in_buffer_cycle_locations( k ) =...
                imCalcP1_t.in_buffer_cycle_locations( k ) - 1;
        end
        
        for k = 1 : 1 : imCalcP1_t.numCycle_Locations
            if( imCalcP1_t.in_buffer_cycle_locations( k ) >= 1 )
                imCalcP1_t.in_buffer1 = imCalcP1_t.in_buffer_cycle_locations( k );
                break;
            end
        end
        imCalcP1_t.in_buffer2 = imCalcP1_t.in_buffer_cycle_locations( imCalcP1_t.numCycle_Locations );
    end
    % END of book-keeping for the dynamic indices in charge of locating
    % relevant data within the buffer
    
    % Debug Only:
    % -----------
    % The next block contained within the next if statement takes care of
    % printing activity indices relative to the receiving buffer
    if( ( imCalcP1_t.in_buffer1 >= 1 ) &&...
            ( imCalcP1_t.in_buffer2 <= g_NUMBER_SAMPLE_CURRENT_BUFFER ) &&...
            ( imCalcP1_t.in_buffer1 < imCalcP1_t.in_buffer2 ) )
        if( imCalcP1_t.verbose_level > 1 )
            fprintf( ...
                'buffer of interest - info: I = [%.0f %.0f] - n = %.0f\n',...
                imCalcP1_t.in_buffer1, imCalcP1_t.in_buffer2, ( imCalcP1_t.in_buffer2 - imCalcP1_t.in_buffer1 + 1 ) );
        end
    end

    % Test Environment Only:
    % ----------------------
    % In the next two lines of code, data erasure is simulated, and this is
    % done by shifting the "sensor buffer" by one element to the left, and
    % appending the new data at the very end of it (to its last element,
    % or to the right).
    
    if( g_SENSOR_HARDWARE_EMULATION_MODE  == g_SENSOR_HARDWARE_EMULATION_ON )
        imCalcP1_t.Sim.buffer( :, 1 : end - 1 ) = imCalcP1_t.Sim.buffer( :, 2 : end );
        imCalcP1_t.Sim.buffer( :, end ) = [new_t; new_a];
    end
    
    % Algorithm Side (next two variables)
    % --------------
    %
    % Updating accelerations
    imCalcP1_t.a_prev = imCalcP1_t.a_curr;
    imCalcP1_t.a_curr = new_a;
    
    % Calculate the discontinuity between previous and current activity
    discontinuity = abs( imCalcP1_t.a_curr - imCalcP1_t.a_prev );
    
    b_MeaningfulActivityDetected = false;
    b_AccDiscontinuityBigEnough = ( discontinuity >= g_DISC_THRESHOLD );
    b_FirstActivityDetectionCurrentBuffer = ( imCalcP1_t.nCycle >= 1 );
    b_dTBetweenCycleOK = false;
    

    
    if( true == b_FirstActivityDetectionCurrentBuffer )
        delta_t = new_t - imCalcP1_t.cycle( imCalcP1_t.nCycle );
        b_dTBetweenCycleOK = ( delta_t >= g_MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK = b_dTBetweenCycleOK && ...
            ( delta_t <=  g_MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    else
        b_FirstActivityDetectionCurrentBuffer = true;
        b_dTBetweenCycleOK = true;
    end
    
    b_MeaningfulAccelerationDetected = ...
        ( imCalcP1_t.a_prev >= g_MAG_THRESHOLD ) || ( imCalcP1_t.a_curr >= g_MAG_THRESHOLD );
    
    b_allConditionsMet = b_AccDiscontinuityBigEnough;
    b_allConditionsMet = b_allConditionsMet && b_FirstActivityDetectionCurrentBuffer;
    b_allConditionsMet = b_allConditionsMet && b_dTBetweenCycleOK;
    b_allConditionsMet = b_allConditionsMet && b_MeaningfulAccelerationDetected;
    
    if( true == b_allConditionsMet )
        imCalcP1_t.nCycle = imCalcP1_t.nCycle + 1;
        imCalcP1_t.cycle( imCalcP1_t.nCycle ) = new_t;
        b_MeaningfulActivityDetected = true;
    end

    
    % if a detection happens, it's always upstream, which means from a
    % circular buffer perspective, it always happens at the end of the
    % buffer, which is location NUMBER_SAMPLE_CURRENT_BUFFER in MATLAB.
    if( b_MeaningfulActivityDetected == true )
        imCalcP1_t.numCycle_Locations = imCalcP1_t.numCycle_Locations + 1;
        imCalcP1_t.in_buffer_cycle_locations( imCalcP1_t.numCycle_Locations ) = g_NUMBER_SAMPLE_CURRENT_BUFFER;
        if( imCalcP1_t.verbose_level > 1 )
            fprintf( 'cycle detected @ sample #%i\n', new_t );
        end
    end
    
    if( imCalcP1_t.nCycle > 0 )
        numberSamplesInRelevantActivity = 0;
        if( imCalcP1_t.nCycle >= 2 )
            for k = 1 : 1 : ( imCalcP1_t.nCycle - 1 )
                len = imCalcP1_t.cycle( k + 1 ) - imCalcP1_t.cycle( k ) + 1;
                if( len > 0 )
                    numberSamplesInRelevantActivity =...
                        numberSamplesInRelevantActivity + len;
                end
            end
        end
        percentageRelevantActivity = ...
            ( numberSamplesInRelevantActivity / g_NUMBER_SAMPLE_CURRENT_BUFFER ) * 100;
        if( ( percentageRelevantActivity >= g_CRITICAL_PERCENT ) && ( imCalcP1_t.Verbose.warning_issued == false ) )
            imCalcP1_t.Verbose.warning_issued = true;
            if( imCalcP1_t.verbose_level > 1 )
                fprintf( 'Warning: data is worth being recorded!\n' );
            end
            nLeft = g_NUMBER_SAMPLE_CURRENT_BUFFER - numberSamplesInRelevantActivity;
            if( imCalcP1_t.verbose_level > 1 )
                fprintf( 'samples left to accumulate before meaningful data starts being erased = %.0f\n', nLeft );
            end
        end
        
        
        % Two conditions need to be met in order for the buffer to be
        % uploaded:
        % - The percentage of relevant activity needs to be >= 50
        % - The first sign of the relevant data must be about to dissapear
        b_bufferContainsEnoughData = ( percentageRelevantActivity >= g_CRITICAL_PERCENT );
        b_bufferIsAboutToSelfErase = ( imCalcP1_t.in_buffer1 == 1 );
        b_uploadCondition = false;
        if( g_ALGO_MODE == g_ALGO_MODE_CONTINUOUS_STREAMING )
            b_uploadCondition = b_bufferContainsEnoughData && b_bufferIsAboutToSelfErase;
        else
            b_uploadCondition = b_bufferContainsEnoughData;
        end
        if( true == b_uploadCondition )
            fprintf( 'Uploading buffer - I = [%.0f %.0f] - Triggered by sample number %.0f\n',...
                imCalcP1_t.in_buffer1, imCalcP1_t.in_buffer2, imCalcP1_t.idx_cur_sample );
            
            imCalcP1_t.numUploads = imCalcP1_t.numUploads + 1;
            imCalcP1_t.Sim.upload_triggering_samples( 1, imCalcP1_t.numUploads ) = imCalcP1_t.idx_cur_sample;
            
            
            %--------------------------------------------------------------
            if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
                imCalcP1_t.Sim.all_cycles( 1, imCalcP1_t.numUploads ) = { imCalcP1_t.cycle( 1 : imCalcP1_t.nCycle ) };
            end % End if( KEEP_TRACK_OFF_ALL_CYCLES == ON )
            %--------------------------------------------------------------
            
            %--------------------------------------------------------------
            % HARDWARE EMULATION ON?
            if( g_SENSOR_HARDWARE_EMULATION_MODE  == g_SENSOR_HARDWARE_EMULATION_ON )
                if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
                    imCalcP1_t.Sim.buffers( 1, imCalcP1_t.numUploads ) =...
                        { imCalcP1_t.Sim.buffer( :, imCalcP1_t.in_buffer1 : 1 : imCalcP1_t.in_buffer2 ) };
                end % End if( KEEP_TRACK_OFF_ALL_CYCLES == ON )
            end % End if( SENSOR_HARDWARE_EMULATION_MODE  == SENSOR_HARDWARE_EMULATION_ON )
            %--------------------------------------------------------------
            
            
            imCalcP1_t.nCycle = 0;
            imCalcP1_t.Verbose.warning_issued = false;
            imCalcP1_t.numCycle_Locations = 0;
            imCalcP1_t.in_buffer1 = 0;
            imCalcP1_t.in_buffer2 = 0;
            nLost = 0;
        end
        if( b_bufferIsAboutToSelfErase &&  ~b_bufferContainsEnoughData )
            imCalcP1_t.nCycle = 0;
            imCalcP1_t.Verbose.warning_issued = false;
            imCalcP1_t.in_buffer1 = 0;
            imCalcP1_t.in_buffer2 = 0;
        end
    end
end


if( g_DRAWING_MODE == g_DRAWING_ON )
% Below this point the code is just plotting data
% -----------------------------------------------
    hold on;
    set( gcf, 'Color', 'White' );
    plot( t, a, 'Color', 'Blue' );
    linewidth = 6;
    if( g_KEEP_TRACK_OFF_ALL_CYCLES == g_ON )
        for k = 1 : 1 : imCalcP1_t.numUploads
            current_cycle = cell2mat( imCalcP1_t.Sim.all_cycles( k ) );
            n = length( current_cycle );
            for i = 1 : 1 : ( n - 1 )
                v = 1000 * ones( 1, 2 );
                x = [ current_cycle( i ), current_cycle( i + 1 ) ];
                color = 'Black';
                if( 0 == mod( i, 2 ) );
                    color = 'Red';
                end
                plot( x, v, 'Color', color, 'LineWidth', linewidth );
            end
        end
    end % End if( KEEP_TRACK_OFF_ALL_CYCLES == ON )

    for i = 1 : 1 : 10
        i1 = ( i - 1 ) * g_NUMBER_SAMPLE_CURRENT_BUFFER + 1;
        i2 = i1 + ( g_NUMBER_SAMPLE_CURRENT_BUFFER - 1 );
        x = [i1, i1];
        y = [0, 3000];
        plot( x, y, 'Color', 'Green', 'LineWidth', 2 );
        x = [i2, i2];
        plot( x, y, 'Color', 'Green', 'LineWidth', 2 );
    end



% plot the buffer upload triggering samples
% -----------------------------------------
    doPlotTriggeringSamples = true;
    if( true == doPlotTriggeringSamples )
        n = imCalcP1_t.numUploads;
        if( n > 0 )
            for i = 1 : 1 : n
                x = imCalcP1_t.Sim.upload_triggering_samples( i );
                y = 3000;
                marker = 'Square';
                markerFaceColor = 'Red';
                markerEdgeColor = 'Black';
                plot( x, y, 'Marker', marker,...
                    'MarkerFaceColor', markerFaceColor,...
                    'MarkerEdgeColor', markerEdgeColor );
            end
        end
    end
end % End if( DRAWING_MODE == DRAWING_ON )

