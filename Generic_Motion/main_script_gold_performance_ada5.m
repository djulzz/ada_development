clear all;
close all;
clc;
%**************************************************************************
% Warning: Although old, this script should be used for testing the
% modifications brought to the Performance ADA.
% Last update to this script was today (12/18/2013)
% file: main_script_gold_performance_ada5.m
%**************************************************************************

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

base_dir = '/Users/jesposito/Google Drive/data/Valid/performances/fieldwork.11.14.2013/';

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

% expectation_table = [false, true, true, true, true, true, false];

sensor_placement = { 'BELT', 'SHOE' };

nActivities  = length( activities );

% fprintf( 'Number of activities = %i\n', nActivities );

ACTIVITY_SELECTED = RUNNING;
PLACEMENT_SELECTED = SHOE;


placement_str = char( cell2mat( sensor_placement( PLACEMENT_SELECTED ) ) );
activity_str = char( cell2mat( activities( ACTIVITY_SELECTED ) ) );

activity_start = 1;
% activity_stop = 1;
activity_stop = nActivities;
nFig = 0;
for k = activity_start : 1 : activity_stop
    
    ACTIVITY_SELECTED = k;
    activity_str = char( cell2mat( activities( ACTIVITY_SELECTED ) ) );
    fprintf( 'Activity selected is: %s\n', activity_str );
    str2 = activity_str;
    validPutsBaseDir = [base_dir,  placement_str, '/', activity_str, '/'];
% 800 275 8777
% 760 729 2144 1800 742 5877 - 800 782 7892
    the_CSV_Directory = CSV_Directory( validPutsBaseDir );

    numberOfFiles = the_CSV_Directory.GetNumberOfFiles(  );
    fprintf( 'number of files for current activity = %i\n', numberOfFiles );
    
    file_index_start = 1;
    vec_var = [  ];
	for i = file_index_start : 1 : numberOfFiles
        pathToCurrentFile = the_CSV_Directory.getFileAt( i );
        the_BLRawSensorData = BLRawSensorData( pathToCurrentFile );
        nSamples = the_BLRawSensorData.NumberOfSamples(  );
        accels = the_BLRawSensorData.MergeAccelerations(  );
        v = var( accels );

        vec_var = [vec_var, v];
        %fprintf( 'Number of samples for current file = %i - test result = ', nSamples );
        first_sample = 0;
        valid = false;
        for j = 1 : 1 : nSamples
            if( 1 == j )
                first_sample = 1;
            else
                first_sample = 0;
            end
            acc = the_BLRawSensorData.Accelerations( j, : );
            gyr = the_BLRawSensorData.Gyroscopes( j, : );
            [res, idx1, idx2] = mex_im_calc_p11( acc, gyr, first_sample );
%             res = mex_ADA_Performances( acc, gyr, first_sample );
            if( 1 == res )
                valid = true;
                break;
            end
        end
        title_str = activity_str;
        if( true == valid )
            fprintf( 'success!\n' );
            fprintf( 'nSamples = %i - idx1 = %i - idx2 = %i\n', nSamples, idx1, idx2 );
            if( ( k == SPRINT ) && ( i == 1 ) )
                title_str = [title_str, ' - Success!'];
                nFig = nFig + 1;
                hFig = figure( nFig );
                set( hFig, 'Color', 'White' );
                hold on;
                title( activity_str );
                t = the_BLRawSensorData.TimeLine(  );
                plot( t, accels, 'Color', 'Blue' );
                plot( t( idx1 : 1 : idx2 ), accels( idx1 : 1 : idx2 ), 'Color', 'Red' );
                plot( t( idx1 ), accels( idx1 ), 'Marker', 'Square', 'MarkerFaceColor', 'Black' );
                plot( t( idx2 ), accels( idx2 ), 'Marker', 'Square', 'MarkerFaceColor', 'Black' );
            end
%             [idx1, idx2]
        else
            ;
%             fprintf( 'Failure\n' );
%             title_str = [title_str, ' - Failure!'];
%             nFig = nFig + 1;
%             hFig = figure( nFig );
%             set( hFig, 'Color', 'White' );
%             hold on;
%             title( activity_str );
%             t = the_BLRawSensorData.TimeLine(  );
%             plot( t, accels, 'Color', 'Blue' );
        end
%         nFig = nFig + 1;
%         hFig = figure( nFig );
%         set( hFig, 'Color', 'White' );
%         f_draw_raw_sensor_data( the_BLRawSensorData, title_str );
%         title( title_str );
    end

    fprintf( 'Variance = %.0f\n', mean( vec_var ) );
%     numberOfFiles = 1;

%     spikeDetected = false;
%     timeSpike = 0;
%     timeUnspike = 0;
%     eventCount = 0;
%     file_index_start = 1;
%     file_index_stop = numberOfFiles;
% %     file_index_stop = 1;
%     useCppTF = true;
%     for i = file_index_start : 1 : file_index_stop
%         pathToCurrentFile = the_CSV_Directory.getFileAt( i );
%         the_BLRawSensorData = BLRawSensorData( pathToCurrentFile );
%         %tf = GM_Framework.TestRawData( the_BLRawSensorData, useCppTF );
%     end
end
