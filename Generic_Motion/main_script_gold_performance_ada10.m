clear all;
close all;
clc;
format bank;


load( 'the_generated_buffers.mat' );

a = b;
% a = a( 1601 : 3200 );
nElements = length( a );
t = 1 : 1 : nElements;


% Define ON and OFF keywords
ON                              = 1;
OFF                             = 0;

% Define Drawing Modes
DRAWING_OFF                     = OFF;
DRAWING_ON                      = ON;
DRAWING_MODE                    = DRAWING_ON;

% Define for the Algo mode (one shot VS. continuous)
ALGO_MODE_ONE_SHOT              = 1;
ALGO_MODE_CONTINUOUS_STREAMING  = 2;
ALGO_MODE                       = ALGO_MODE_CONTINUOUS_STREAMING;

% Activity-specific Constants
SPRINTING_MAG_THRESHOLD         = 1005;
SPRINTING_DISC_THRESHOLD        = 1200;
RUNNING_DISC_THRESHOLD          = 1000;
JUMPING_DISC_THRESHOLD          = 1700;
JUMPING_MAGN_THRESHOLD          = 2250;
MIN_NUM_SAMPLES_BETWEEN_CYCLES  = 30;
MAX_NUM_SAMPLES_BETWEEN_CYCLES  = 500;
MAG_THRESHOLD                   = SPRINTING_MAG_THRESHOLD;
DISC_THRESHOLD                  = SPRINTING_DISC_THRESHOLD;
 
% Computer memory specific Constants
NUMBER_SAMPLE_CURRENT_BUFFER	= 1600;
MAX_NUM_CYCLE_LOCATIONS         = ceil( NUMBER_SAMPLE_CURRENT_BUFFER / MIN_NUM_SAMPLES_BETWEEN_CYCLES );

% Buffer Relevant activity fullness
CRITICAL_PERCENT                = 50;

% Simulation variables
% --------------------
buffer                          = zeros( 2, NUMBER_SAMPLE_CURRENT_BUFFER );
in_buffer_cycle_locations       = zeros( 1, MAX_NUM_CYCLE_LOCATIONS );
cycle                           = zeros( 1, MAX_NUM_CYCLE_LOCATIONS );
MAX_NUMBER_BUFFERS_TO_UPLOAD    = ( nElements / NUMBER_SAMPLE_CURRENT_BUFFER );
numUploads                      = 0;
all_cycles                      = cell( 1, MAX_NUMBER_BUFFERS_TO_UPLOAD );
buffers                         = cell( 1, MAX_NUMBER_BUFFERS_TO_UPLOAD );
upload_triggering_samples       = zeros( 1, MAX_NUMBER_BUFFERS_TO_UPLOAD );

% Needs to be moved to a "imCalcP1_t" struct
a_prev                          = 0;
a_curr                          = 0;
nCycle                          = 0;
LimitElementsToProcess          = nElements;
idx_cur_sample                  = 1;

warning_issued                  = false;
numCycle_Locations              = 0;
verbose_level                   = 1;
numBuffersProcessed             = 0;
numCycle_current_buffer         = 0; % number of activity spikes detected
                                     % in current buffer

% The top for-loop simulates oncoming data that would be sensed by the
% sensor
for index_samples = 1 : 1 : LimitElementsToProcess % iterate through all
                                                   % the simulated oncoming
                                                   % sensed data
                        
    idx_cur_sample = index_samples;
    % Simple check to see if a full buffer of samples has been
    % accumulated.
    % Note: for C conversion, AND IF the ALGO is in 
    % ALGO_MODE_CONTINUOUS_STREAMING mode, the next variable can be
    % made a local boolean
    anotherBufferCompletelyFull = ...
        ( mod( idx_cur_sample, NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 );
    
    % Test Environment Only: keeps track of the number of full buffers
    % ----------------------
    % received so far.
    if( true == anotherBufferCompletelyFull )
        numBuffersProcessed = numBuffersProcessed + 1;
        if( verbose_level >= 1 )
            fprintf( 'Buffer %i processed\n', numBuffersProcessed );
        end
    end
    
    % Test Environment Only:
    % ----------------------
    % short hand variables keeping track of oncoming sample
    
    new_t = t( idx_cur_sample ); % new oncoming sample number
    new_a = a( idx_cur_sample ); % new oncoming acceleration magnitude
    
    % Algorithm Side (next two variables)
    % --------------
    in_buffer1 = 0; % dynamic relevant activity sample start (in buffer)
    in_buffer2 = 0; % dynamic relevant activity sample stop (in buffer)
    
        
    % Portion of the code in charge of keeping track of where the relevant
    % activity is, relative to the circular buffer.
    %              --------------------------------
    if( numCycle_Locations > 0 )
        for k = 1 : 1 : numCycle_Locations
            in_buffer_cycle_locations( k ) =...
                in_buffer_cycle_locations( k ) - 1;
        end
        
        for k = 1 : 1 : numCycle_Locations
            if( in_buffer_cycle_locations( k ) >= 1 )
                in_buffer1 = in_buffer_cycle_locations( k );
                break;
            end
        end
        in_buffer2 = in_buffer_cycle_locations( numCycle_Locations );
    end
    % END of book-keeping for the dynamic indices in charge of locating
    % relevant data within the buffer
    
    % Debug Only:
    % -----------
    % The next block contained within the next if statement takes care of
    % printing activity indices relative to the receiving buffer
    if( ( in_buffer1 >= 1 ) &&...
            ( in_buffer2 <= NUMBER_SAMPLE_CURRENT_BUFFER ) &&...
            ( in_buffer1 < in_buffer2 ) )
        if( verbose_level > 1 )
            fprintf( ...
                'buffer of interest - info: I = [%.0f %.0f] - n = %.0f\n',...
                in_buffer1, in_buffer2, ( in_buffer2 - in_buffer1 + 1 ) );
        end
    end

    % Test Environment Only:
    % ----------------------
    % In the next two lines of code, data erasure is simulated, and this is
    % done by shifting the "sensor buffer" by one element to the left, and
    % appending the new data at the very end of it (to its last element,
    % or to the right).
    buffer( :, 1 : end - 1 ) = buffer( :, 2 : end );
    buffer( :, end ) = [new_t; new_a];
    
    % Algorithm Side (next two variables)
    % --------------
    %
    % Updating accelerations
    a_prev = a_curr;
    a_curr = new_a;
    
    % Calculate the discontinuity between previous and current activity
    discontinuity = abs( a_curr - a_prev );
    
    b_MeaningfulActivityDetected = false;
    b_AccDiscontinuityBigEnough = ( discontinuity >= DISC_THRESHOLD );
    b_FirstActivityDetectionCurrentBuffer = ( nCycle >= 1 );
    b_dTBetweenCycleOK = false;
    

    
    if( true == b_FirstActivityDetectionCurrentBuffer )
        delta_t = new_t - cycle( nCycle );
        b_dTBetweenCycleOK = ( delta_t >= MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        b_dTBetweenCycleOK = b_dTBetweenCycleOK && ...
            ( delta_t <=  MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    else
        b_FirstActivityDetectionCurrentBuffer = true;
        b_dTBetweenCycleOK = true;
    end
    
    b_MeaningfulAccelerationDetected = ...
        ( a_prev >= MAG_THRESHOLD ) || ( a_curr >= MAG_THRESHOLD );
    
    b_allConditionsMet = b_AccDiscontinuityBigEnough;
    b_allConditionsMet = b_allConditionsMet && b_FirstActivityDetectionCurrentBuffer;
    b_allConditionsMet = b_allConditionsMet && b_dTBetweenCycleOK;
    b_allConditionsMet = b_allConditionsMet && b_MeaningfulAccelerationDetected;
    
    if( true == b_allConditionsMet )
        nCycle = nCycle + 1;
        cycle( nCycle ) = new_t;
        b_MeaningfulActivityDetected = true;
    end

    
    % if a detection happens, it's always upstream, which means from a
    % circular buffer perspective, it always happens at the end of the
    % bufer, which is location NUMBER_SAMPLE_CURRENT_BUFFER in MATLAB.
    if( b_MeaningfulActivityDetected == true )
        numCycle_Locations = numCycle_Locations + 1;
        in_buffer_cycle_locations( numCycle_Locations ) = NUMBER_SAMPLE_CURRENT_BUFFER;
        if( verbose_level > 1 )
            fprintf( 'cycle detected @ sample #%i\n', new_t );
        end
    end
    
    if( nCycle > 0 )
        number_cycles = nCycle;
        numberSamplesInRelevantActivity = 0;
        if( number_cycles >= 2 )
            for k = 1 : 1 : ( number_cycles - 1 )
                len = cycle( k + 1 ) - cycle( k ) + 1;
                if( len > 0 )
                    numberSamplesInRelevantActivity =...
                        numberSamplesInRelevantActivity + len;
                end
            end
        end
        percentageRelevantActivity = ...
            ( numberSamplesInRelevantActivity / NUMBER_SAMPLE_CURRENT_BUFFER ) * 100;
        if( ( percentageRelevantActivity >= CRITICAL_PERCENT ) && ( warning_issued == false ) )
            warning_issued = true;
            if( verbose_level > 1 )
                fprintf( 'Warning: data is worth being recorded!\n' );
            end
            nLeft = NUMBER_SAMPLE_CURRENT_BUFFER - numberSamplesInRelevantActivity;
            if( verbose_level > 1 )
                fprintf( 'samples left to accumulate before meaningful data starts being erased = %.0f\n', nLeft );
            end
        end
        
        
        % Two conditions need to be met in order for the buffer to be
        % uploaded:
        % - The percentage of relevant activity needs to be >= 50
        % - The first sign of the relevant data must be about to dissapear
        b_bufferContainsEnoughData = ( percentageRelevantActivity >= CRITICAL_PERCENT );
        b_bufferIsAboutToSelfErase = ( in_buffer1 == 1 );
        b_uploadCondition = false;
        if( ALGO_MODE == ALGO_MODE_CONTINUOUS_STREAMING )
            b_uploadCondition = b_bufferContainsEnoughData && b_bufferIsAboutToSelfErase;
        else
            b_uploadCondition = b_bufferContainsEnoughData;
        end
        if( true == b_uploadCondition )
            fprintf( 'Uploading buffer - I = [%.0f %.0f] - Triggered by sample number %.0f\n',...
                in_buffer1, in_buffer2, idx_cur_sample );
            
            numUploads = numUploads + 1;
            upload_triggering_samples( 1, numUploads ) = idx_cur_sample;
            all_cycles( 1, numUploads ) = { cycle( 1 : nCycle ) };
            buffers( 1, numUploads ) = { buffer( :, in_buffer1 : 1 : in_buffer2 ) };
            nCycle = 0;
            warning_issued = false;
            numCycle_Locations = 0;
            in_buffer1 = 0;
            in_buffer2 = 0;
            nLost = 0;
        end
        if( b_bufferIsAboutToSelfErase &&  ~b_bufferContainsEnoughData )
            nCycle = 0;
            warning_issued = false;
            in_buffer1 = 0;
            in_buffer2 = 0;
        end
    end
end

% Below this point it's just printing of statistics
% -------------------------------------------------
if( nCycle > 0 )
    
    numberSamplesInRelevantActivity = cycle( nCycle ) - cycle( 1 ) + 1;
    numberCyclesForRelevantActivity = nCycle;
    
    fprintf( 'Number of samples in relevant activity = %i\n',...
        numberSamplesInRelevantActivity );
    
    fprintf( 'Number of cycles for relevant activity = %i\n',...
        numberCyclesForRelevantActivity );
    
    fprintf( 'Number of samples per cycle = %.2f\n',...
        numberSamplesInRelevantActivity / numberCyclesForRelevantActivity );
end


if( DRAWING_MODE == DRAWING_ON )
% Below this point the code is just plotting data
% -----------------------------------------------
    hold on;
    set( gcf, 'Color', 'White' );
    plot( t, a, 'Color', 'Blue' );
    linewidth = 6;
    for k = 1 : 1 : numUploads
        current_cycle = cell2mat( all_cycles( k ) );
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

    for i = 1 : 1 : 10
        i1 = ( i - 1 ) * NUMBER_SAMPLE_CURRENT_BUFFER + 1;
        i2 = i1 + ( NUMBER_SAMPLE_CURRENT_BUFFER - 1 );
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
        n = numUploads;
        if( n > 0 )
            for i = 1 : 1 : n
                x = upload_triggering_samples( i );
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

