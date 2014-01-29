clear all;
close all;
clc;


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

nActivities  = length( activities );

fprintf( 'Number of activities = %i\n', nActivities );

ACTIVITY_SELECTED = RUNNING;
PLACEMENT_SELECTED = SHOE;


placement_str = char( cell2mat( sensor_placement( PLACEMENT_SELECTED ) ) );
activity_str = char( cell2mat( activities( ACTIVITY_SELECTED ) ) );

activity_start = 3;
activity_stop = 3;
% activity_stop = nActivities;
collected = [];
for k = activity_start : 1 : activity_stop
    
    ACTIVITY_SELECTED = k;
    activity_str = char( cell2mat( activities( ACTIVITY_SELECTED ) ) );
    fprintf( 'Activity selected is: %s\n', activity_str );
    validPutsBaseDir = [base_dir,  placement_str, '/', activity_str, '/'];
%     validPutsBaseDir = '/Users/jesposito/Desktop/after_fw_update/';
%     validPutsBaseDir = '/Users/jesposito/Desktop/test1/';
%     validPutsBaseDir = '/Users/jesposito/Desktop/back_to_old/';
%     validPutsBaseDir = '/Users/jesposito/Desktop/0.0.18_mikes_attachment/';
%     validPutsBaseDir = '/Users/jesposito/Desktop/Steve_help/';
%     validPutsBaseDir = '//Users/jesposito/Desktop/lab.11.21.2013/walking/';
    the_CSV_Directory = CSV_Directory( validPutsBaseDir );

    numberOfFiles = the_CSV_Directory.GetNumberOfFiles(  );
    fprintf( 'number of files for current activity = %i\n', numberOfFiles );
    numberOfFiles = 1;

    spikeDetected = false;
    timeSpike = 0;
    timeUnspike = 0;
    eventCount = 0;
    file_index_start = 1;
    file_index_stop = numberOfFiles;
%     file_index_stop = 1;
    useCppTF = true;
    for i = file_index_start : 1 : file_index_stop
        pathToCurrentFile = the_CSV_Directory.getFileAt( i );
        the_BLRawSensorData = BLRawSensorData( pathToCurrentFile );
        n = the_BLRawSensorData.NumberOfSamples(  );
        a = the_BLRawSensorData.MergeAccelerations(  );
        a_min = min( a );
        a_max = max( a );
%         fprintf( 'for current file, number of records = %i - a_min = %.2f, a_max = %.2f\n', n, a_min, a_max );
        [pathstr,name,ext] = fileparts( pathToCurrentFile );
        [prefix, year, month, day, hour, minu, sec] = Filename_Functor.SplitElements( name );
%         if( a_max > 1000 )
%         if( 1 )
%             f = figure( i );
%             hold on;
%             set( f, 'Color', 'White' );
%             str_title = sprintf( 'time = %i:%i:%i - a.max = %.2f - num. samples = %i', hour, minu, sec, a_max, n );
%             title( str_title );
%             plot( the_BLRawSensorData.TimeLine, a );
%             saveas( f, [pathstr, '/', num2str( i ), '.png'] );
%             close( f );
%             fprintf( 'month = %i - day = %i - time = %i:%i:%i - a_max = %.2f - num. samples = %i\n', month, day, hour, minu, sec, a_max, n );
%         end
%         worth_testing = false;
%         if( hour >= 17 )
%             collected = [collected; [i, a_min, a_max, n]];
%             worth_testing = true;
%             tf = GM_Framework.TestRawData( the_BLRawSensorData, useCppTF );
%         end
        tf = GM_Framework.TestRawData( the_BLRawSensorData, useCppTF );
        t = the_BLRawSensorData.TimeLine(  );
        as = movavgFilt ( a, 16, 'Left' );
        v = [1:1:1600];
        plot( v, a, 'Color', 'Blue' );
        hold on;
        plot( v, as, 'Color', 'Red' );
    end
end

% format bank;
% [B, index] = sortrows( collected, 3 );
% B