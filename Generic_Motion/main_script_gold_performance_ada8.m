clear all;
close all;
clc;
format bank;

global g_verbose;
g_verbose = false;

google_drive = '/Users/jesposito/Google Drive/';
str_username = 'jesposito';


addpath( 'mex' );
addpath( ['functions'] );
addpath( ['classes'] );

X = 1;
Y = 2;
Z = 3;

base_dir = '/Users/jesposito/Desktop/fieldwork.11.14.2013/';

% base_dir = '/Users/jesposito/Desktop/test2/';

activities = {  'Auto-10s Gap-Walking',
                'Mini Suicide',
                'Running',
                'Scissor Mild Left to Right',
                'Semi - Static Jumps',
                'Sprint',
                'Walking Fast' };

% jump, var = 158 377
% sprint, var = 203 000

AUTO_10S_GAP_WALKING        =   1;
MINI_SUICIDE                =   2;
RUNNING                     =   3;
SCISSOR_MILD_LEFT_TO_RIGHT  =   4;
SEMI_STATIC_JUMPS           =   5;
SPRINT                      =   6;
WALKING_FAST                =   7;

BELT = 1;
SHOE = 2;
use_cpp = false;


sensor_placement = { 'BELT', 'SHOE' };

SELECTED_CONTRAST = SPRINT;
PLACEMENT_SELECTED = SHOE;


placement_str = char( cell2mat( sensor_placement( PLACEMENT_SELECTED ) ) );
activity_str_1 = char( cell2mat( activities( AUTO_10S_GAP_WALKING ) ) );
activity_str_2 = char( cell2mat( activities( SELECTED_CONTRAST ) ) );

title_str = activity_str_2;

validPutsBaseDir_1 = [base_dir,  placement_str, '/', activity_str_1, '/'];
validPutsBaseDir_2 = [base_dir,  placement_str, '/', activity_str_2, '/'];

the_CSV_Directory_1 = CSV_Directory( validPutsBaseDir_1 );
the_CSV_Directory_2 = CSV_Directory( validPutsBaseDir_2 );

pathToCurrentFile_1 = the_CSV_Directory_1.getFileAt( 1 );
the_BLRawSensorData_1 = BLRawSensorData( pathToCurrentFile_1 );

pathToCurrentFile_2 = the_CSV_Directory_2.getFileAt( 1 );
the_BLRawSensorData_2 = BLRawSensorData( pathToCurrentFile_2 );

sz_1 = the_BLRawSensorData_1.NumberOfSamples(  );
sz_2 = the_BLRawSensorData_2.NumberOfSamples(  );

a1 = the_BLRawSensorData_1.MergeAccelerations(  );  % walk
a2 = the_BLRawSensorData_2.MergeAccelerations(  );  % sprint
sz_a3 = ceil( length( a2 ) * ( 80 / 100 ) );
a3 = a2( 1 : sz_a3 );                               % sprint50
%             walk  sprint  walk   sprint50 walk
% nElements = ( sz_1 + sz_2 + sz_1 + sz_a3 + sz_1 );
% v = [1 : 1 : nElements];
load( 'the_generated_buffers.mat' );

% fprintf( 'variance for %s = %.2f\n', title_str, var( a2 ) );
% a = [a1, a2, a1, a3, a1];
a = [b];
nElements = length( a );
v = [1 : 1 : nElements];
% 
% plot( v, a );
SPRINTING_MAG_THRESHOLD         = 1005;
%SPRINTING_MAG_THRESHOLD         = 2200;
% SPRINTING_DISC_THRESHOLD        = 1700;
SPRINTING_DISC_THRESHOLD        = 1200;
RUNNING_DISC_THRESHOLD          = 1000;
JUMPING_DISC_THRESHOLD          = 1700;
JUMPING_MAGN_THRESHOLD          = 2250;
MIN_NUM_SAMPLES_BETWEEN_CYCLES  = 30;
MAX_NUM_SAMPLES_BETWEEN_CYCLES  = 500;
MAG_THRESHOLD                   = SPRINTING_MAG_THRESHOLD;
DISC_THRESHOLD                  = SPRINTING_DISC_THRESHOLD;

LIMIT_BETWEEN_EDGES             = 75;
NUMBER_SAMPLE_CURRENT_BUFFER	= 1600;
SAMPLING_FREQUENCY_HZ           = 250;
DT                              = 1 / SAMPLING_FREQUENCY_HZ;
sensor_buffer                   = zeros( 2, NUMBER_SAMPLE_CURRENT_BUFFER );
t                               = v;

a_prev                          = 0;
a_curr                          = 0;

cycle                           = [  ];
all_cycles                      = [  ];
% disc_indices                    = [  ];
warning_issued                  = false;
nSamples_Erased                 = 0;
in_buffer_cycle_locations       = [  ];
verbose_level                   = 1;
buffer                          = zeros( 2, NUMBER_SAMPLE_CURRENT_BUFFER );
buffers                         = [  ];

numBuffersProcessed             = 0;
upload_triggering_samples       = [  ];

for index_samples = 1 : 1 : nElements   % iterate through all the simulated oncoming
                            % sensed data
    anotherBufferCompletellyFull = ( mod( index_samples, NUMBER_SAMPLE_CURRENT_BUFFER ) == 0 );
    if( true == anotherBufferCompletellyFull )
        numBuffersProcessed = numBuffersProcessed + 1;
        fprintf( 'Buffer %i processed\n', numBuffersProcessed );
    end
    
    new_t = t( index_samples ); % new oncoming sample number
    new_a = a( index_samples ); % new oncoming acceleration magnitude
    
    in_buffer1 = 0; % dynamic relevant activity sample start (in buffer)
    in_buffer2 = 0; % dynamic relevant activity sample stop (in buffer)
    
%     nLost = 0;      % keeps track of the number of samples lost by the
%                     % circular buffer
        
    % Portion of the code in charge of keeping track of where the relevant
    % activity is, relative to the circular buffer.
    %              --------------------------------
    % This is where the buffer-relative indices for all the 
    if( false == isempty( in_buffer_cycle_locations ) )
        nElemsInBuffer = length( in_buffer_cycle_locations );
        for k = 1 : 1 : nElemsInBuffer
            in_buffer_cycle_locations( k ) = in_buffer_cycle_locations( k ) - 1;
%             if( in_buffer_cycle_locations( k ) <= 0 )
%                 nLost = nLost + 1;
%             end
        end
        in_buffer1 = 0;
        in_buffer2 = 0;
        
        for k = 1 : 1 : nElemsInBuffer
            if( in_buffer_cycle_locations( k ) >= 1 )
                in_buffer1 = in_buffer_cycle_locations( k );
                break;
            end
        end
        in_buffer2 = in_buffer_cycle_locations( end );
    end
    % END of book-keeping for the dynamic indices in charge of locating
    % relevant data within the buffer
    
    % The next 
    if( ( in_buffer1 >= 1 ) &&...
            ( in_buffer2 <= NUMBER_SAMPLE_CURRENT_BUFFER ) &&...
            ( in_buffer1 < in_buffer2 ) )
        if( verbose_level > 1 )
            fprintf( 'buffer of interest - info: I = [%.0f %.0f] - n = %.0f\n',...
                in_buffer1, in_buffer2, ( in_buffer2 - in_buffer1 + 1 ) );
        end
    end
%     if( nLost > 0 ) % Don't know if this is really necessary
%         if( verbose_level > 1 )
%             fprintf( 'N. lost = %.0f\n', nLost );
%         end
%     end

%     nSamples_Erased = nSamples_Erased + 1;
    buffer( :, 1 : end - 1 ) = buffer( :, 2 : end );
    buffer( :, end ) = [new_t; new_a];
    
    a_prev = a_curr;
    a_curr = new_a;
    
    discontinuity = abs( a_curr - a_prev );
    %fprintf( '%.2f\n', discontinuity );
    cycle_detected = false;
    cond1 = ( discontinuity >= DISC_THRESHOLD );
    cond2 = ( length( cycle ) >= 1 );
    cond3 = false;
    if( true == cond1 )
%         disc_indices = [disc_indices, index_samples];
    end
    
    if( true == cond2 )
        cond3 = ( new_t - cycle( end ) >= MIN_NUM_SAMPLES_BETWEEN_CYCLES );
        cond3 = cond3 && ( new_t - cycle( end ) <=  MAX_NUM_SAMPLES_BETWEEN_CYCLES );
    else
        cond2 = true;
        cond3 = true;
    end
    
    cond = cond1 && cond2 && cond3;
%     if( ( isempty( cycle ) ) && ( true == cond1 ) )
%         if( verbose_level > 1 )
%             fprintf( 'First Detection\n' );
%         end
%         cond = true;
%     end
    
    cond4 = ( a_prev >= MAG_THRESHOLD ) || ( a_curr >= MAG_THRESHOLD );
    cond = cond && cond4;
    if( true == cond )
        cycle = [cycle, new_t];
        cycle_detected = true;
    end

    
    if( cycle_detected == true )
        in_buffer_cycle_locations = [in_buffer_cycle_locations,  NUMBER_SAMPLE_CURRENT_BUFFER];
        if( verbose_level > 1 )
            fprintf( 'cycle detected @ sample #%i\n', new_t );
        end
    end
    
    if( false == isempty( cycle ) )
        number_cycles = length( cycle );
        numberSamplesInRelevantActivity = 0;
        %length( cycle );
        if( number_cycles >= 2 )
            for k = 1 : 1 : ( number_cycles - 1 )
                len = cycle( k + 1 ) - cycle( k ) + 1;
                if( len > 0 )
                    numberSamplesInRelevantActivity = numberSamplesInRelevantActivity + len;
                end
            end
        end
        percentageRelevantActivity = ( numberSamplesInRelevantActivity / NUMBER_SAMPLE_CURRENT_BUFFER ) * 100;
        if( ( percentageRelevantActivity >= 50 ) && ( warning_issued == false ) )
            warning_issued = true;
            if( verbose_level > 1 )
                fprintf( 'Warning: data is worth being recorded!\n' );
            end
            nLeft = NUMBER_SAMPLE_CURRENT_BUFFER - numberSamplesInRelevantActivity;
            if( verbose_level > 1 )
                fprintf( 'samples left to accumulate before meaningful data starts being erased = %.0f\n', nLeft );
            end
            if( number_cycles > 1 )
                
            end
        end
        
        % Two conditions need to be met in order for the buffer to be
        % uploaded:
        % - The percentage of relevant activity needs to be >= 50
        % - The first sign of the relevant data must be about to dissapear
        if( ( percentageRelevantActivity >= 50 ) && ( in_buffer1 == 1 ) )
            fprintf( 'Uploading buffer - I = [%.0f %.0f] - Triggered by sample number %.0f\n', in_buffer1, in_buffer2, index_samples );
            upload_triggering_samples = [upload_triggering_samples, index_samples];
%             index = [  ];
            all_cycles = [all_cycles, {cycle}];
            buffers = [buffers, {buffer}];
            cycle = [  ];
%             disc_indices = [  ];
            warning_issued = false;
            nSamples_Erased = 0;
            in_buffer_cycle_locations = [  ];
            in_buffer1 = 0;
            in_buffer2 = 0;
            nLost = 0;
        end
        if( ( in_buffer1 == 1 ) &&  ( percentageRelevantActivity < 50 ) )
            cycle = [  ];
            warning_issued = false;
%             nSamples_Erased = 0;
%             in_buffer_cycle_locations = [  ];
%             in_buffer1 = 0;
%             in_buffer2 = 0;
%             nLost = 0;
        end
    end
end
if( false == isempty( cycle ) )
    
    numberSamplesInRelevantActivity = cycle( end ) - cycle( 1 );
    numberCyclesForRelevantActivity = length( cycle );
    fprintf( 'Number of samples in relevant activity = %i\n', numberSamplesInRelevantActivity );
    fprintf( 'Number of cycles for relevant activity = %i\n', numberCyclesForRelevantActivity );
    fprintf( 'Number of samples per cycle = %.2f\n', numberSamplesInRelevantActivity / numberCyclesForRelevantActivity );
end

hold on;
set( gcf, 'Color', 'White' );

% m = length( buffers );
% i1 = 1;
% for k = 1 : 1 : m
%     buf = cell2mat( buffers( k ) );
%     sz = length( buf );
%     i2 = i1 + sz - 1;
%     plot( [i1:1:i2], buf, 'Color', 'Red' );
%     i1 = i2 + 1;
% end
title( title_str );
t2 = the_BLRawSensorData_1.TimeLine;
plot( v, a, 'Color', 'Blue' );
linewidth = 6;
numCycles = length( all_cycles );
for k = 1 : 1 : numCycles
    cycle = cell2mat( all_cycles( k ) );
    n = length( cycle );
    for i = 1 : 1 : ( n - 1 )
        v = 1000 * ones( 1, 2 );
        x = [cycle( i ), cycle( i + 1 )];
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
% plot( t2( 1 : 2 : end ), a2( 1 : 2 : end ), 'Color', 'Red' ); % 125
% plot( t2( 1 : 4 : end ), a2( 1 : 4 : end ), 'Color', 'Green' ); % 72.5
% plot( t2( 1 : 8 : end ), a2( 1 : 8 : end ), 'Color', 'Black' ); % 36.25






% plot the buffer upload triggering samples
% -----------------------------------------
doPlotTriggeringSamples = true;
if( true == doPlotTriggeringSamples )
    n = length( upload_triggering_samples );
    if( n > 0 )
        for i = 1 : 1 : n
            x = upload_triggering_samples( i );
            y = 3000;
            marker = 'Square';
            markerFaceColor = 'Red';
            markerEdgeColor = 'Black';
            plot( x, y, 'Marker', marker, 'MarkerFaceColor', markerFaceColor, 'MarkerEdgeColor', markerEdgeColor );
        end
    end
end


% m = cell2mat( all_cycles( 1 ) ); m
