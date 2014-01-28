clear all;
close all;
clc;

load( 'reference_scores.mat' );

global g_verbose;

g_verbose = false;
google_drive = '/Users/jesposito/Google Drive/';
str_username = 'jesposito';

% addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/functions'] );
% addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/classes'] );
%addpath( ['/Users/', str_username, '/Google Drive/Julien_Code/matlab_code/mex_files'] );
addpath( 'mex' );
addpath( ['functions'] );
addpath( ['classes'] );

folder_list_01 =    {
    [google_drive, 'John_Goree/Baseball filter tests/Valid swings/'],   % 01
    [google_drive, '2013_06_27 Easton/'],                               % 02
    [google_drive, 'Granger Good Baseball Swings/'],                    % 03
    [google_drive, 'postimpact/'],                                      % 04
    [google_drive, '20 post impacts/granger/'],                         % 05
    [google_drive, '20 post impacts/victor/'],                          % 06
    [google_drive, 'John_Goree/Baseball filter tests/Invalid swings/'], % 07
    [google_drive, '20 post impacts/misfires/'],                        % 08
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1146/'],    % 09
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1148/'],    % 10
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1236/'],    % 11
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1237/'],    % 12
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1238/'],    % 13
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1239/'],    % 14
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1240/'],    % 15
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1298/'],    % 16
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1299/'],    % 17
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-2931/'],    % 18
    [google_drive, 'data/Scotts_Swings/']                               % 19
};

folder_list_01_nickname = {

    '"1 - Goree Valid"',
    '"1 - Easton"',
    '"1 - Granger Many Swings"',
    '"1 - Victor First Batch"',
    '"1 - Granger 2nd Batch"',
    '"1 - Victor 2nd Batch"',
    '"0 - Goree Invalid"',
    '"0 - Julien Missfires"',
    '"0 - Knocking ball back to pitcher"',
    '"0 - Hold bat against body, hit ground"',
    '"0 - Backhand ball towards batter"',
    '"0 - Hit plate then waggle"',
    '"0 - Waggle, hit plate, then waggle"',
    '"0 - Dropping the bat"',
    '"0 - Swing, no impact, then drop the bat"',
    '"0 - Throw and catch sensor/isolator"',
    '"0 - Banging/Tapping sensor/isolator on table"',
    '"0 - Practice swing (no impact), dropping bat, knocking ball back to pitcher, bat fell from leaning on a net"',
    '"1 - Scott Swings"'};


folder_list_01_expected_result = [true( 1, 6 ), false( 1, 12 ), true( 1, 1 ) ];



% gy_impact_threshold = 12000;
% threshold_interval = 3;
% parameters = [threshold_interval, gy_impact_threshold];

indices = [1 : 1 : 19];

fprintf( 'START\n' );

MinimumPostShockNumberRequired = 30;
nBBEntries = length( indices );
folder_used = folder_list_01;

processedFileNumber = zeros( 1, 4 );
scores = zeros( 1, 4 );

possible_NumberOfSamples = [2000, 1020, 1200, 2000];

nSwings = 0;
nMissfires = 0;
MinimumPostShockNumberRequired = 50;

needed = 600;

figure( 1 );
hold on;
y_start = 0;
y_inc = 50;
for i = 1 : 1 : nBBEntries
    idx = indices( i );
    folder_selected = char( cell2mat( folder_used( idx ) ) );
    nickname_used = char( cell2mat( folder_list_01_nickname( idx ) ) );
    TestBaseDirectoryPath = folder_selected;
    the_BL_ADA_Test = BL_ADA_Test( TestBaseDirectoryPath );
    expected_result_tf = folder_list_01_expected_result( idx );
    shockInfoMatrix = the_BL_ADA_Test.GetShockInfo( MinimumPostShockNumberRequired );
    if( ~isempty( shockInfoMatrix ) )
        nCSV_files = size( shockInfoMatrix, 1 );
        str = 'SWING';
        if( false == expected_result_tf )
            str = 'MISSFIRE';
        end
        fprintf( 'test type = %s\n', str );
        for j = 1 : 1 : nCSV_files
            index_csv_file  = shockInfoMatrix( j, 1 );
            nPreShock       = shockInfoMatrix( j, 2 );
            index_shock     = shockInfoMatrix( j, 3 );
            nPostShock      = shockInfoMatrix( j, 4 );
            total = nPreShock + nPostShock;
            found = false;
            for k = 1 : 1 : 4
                if( possible_NumberOfSamples( k ) == total )
                    found = true;
                    break;
                end
            end
            color_test = 'Black';
            nLeft = ( nPreShock - needed );
            bEnoughData = ( nLeft >= 0 );
            quantity_preshock_available = nPreShock - needed;
            %fprintf( 'index = %i - N_pre = %i - N_post = %i - index = %i\n', index_csv_file, nPreShock, nPostShock, index_shock );
            if( found && bEnoughData )
                if( false == expected_result_tf )
                    nMissfires = nMissfires + 1;
                    color_test = 'Red';
                else
                    nSwings = nSwings + 1;
                    color_test = 'Green';
                end
                
                base_path_str = the_BL_ADA_Test.getBaseDirectoryPath(  );
                the_CSV_Directory = CSV_Directory( base_path_str );
                file_str = the_CSV_Directory.getFileAt( index_csv_file );
                %fprintf( '%s\n', file_str );
                rawSensorData = BLRawSensorData( file_str );
                nAvailableSamples = rawSensorData.NumberOfSamples(  );
                
                %[nAvailableSamples, index_shock]
                
                range1 = index_shock - needed : index_shock - 1;
                Accelerations_pre   = rawSensorData.Accelerations( range1 , : );
                Gyroscopes_pre      = rawSensorData.Gyroscopes( range1, : );
                
                range2 = [ index_shock + 1 : index_shock + 50 ];
%                 Accelerations_post   = rawSensorData.Accelerations( range2, : );
%                 Gyroscopes_post      = rawSensorData.Gyroscopes( range2, : );
                
                i1 = nPreShock - needed;
                iS = index_shock;
                i2 = ( iS ) + 50;
                

                
                ax_pre = Accelerations_pre( :, 1 )';
                ay_pre = Accelerations_pre( :, 2 )';
                az_pre = Accelerations_pre( :, 3 )';
                
                gx_pre = Gyroscopes_pre( :, 1 )';
                gy_pre = Gyroscopes_pre( :, 2 )';
                gz_pre = Gyroscopes_pre( :, 3 )';
                
                numberAvg = 50;
%                 ax_pre = movavgFilt (ax_pre, numberAvg, 'Left' );
%                 ay_pre = movavgFilt (ay_pre, numberAvg, 'Left' );
%                 az_pre = movavgFilt (az_pre, numberAvg, 'Left' );
%                 
%                 gx_pre = movavgFilt (gx_pre, numberAvg, 'Left' );
%                 gy_pre = movavgFilt (gy_pre, numberAvg, 'Left' );
%                 gz_pre = movavgFilt (gz_pre, numberAvg, 'Left' );
                
%                 ax_post = Accelerations_post( :, 1 )';
%                 ay_post = Accelerations_post( :, 2 )';
%                 az_post = Accelerations_post( :, 3 )';
%                 
%                 gx_post = Gyroscopes_post( :, 1 )';
%                 gy_post = Gyroscopes_post( :, 2 )';
%                 gz_post = Gyroscopes_post( :, 3 )';
                
                R_ax_pre = f_calc_r_sqr( range1, ax_pre );
                R_ay_pre = f_calc_r_sqr( range1, ay_pre );
                R_az_pre = f_calc_r_sqr( range1, az_pre );
                
                R_gx_pre = f_calc_r_sqr( range1, gx_pre );
                R_gy_pre = f_calc_r_sqr( range1, gy_pre );
                R_gz_pre = f_calc_r_sqr( range1, gz_pre );
                
%                 R_ax_post = f_calc_r_sqr( range2, ax_post );
%                 R_ay_post = f_calc_r_sqr( range2, ay_post );
%                 R_az_post = f_calc_r_sqr( range2, az_post );
%                 
%                 R_gx_post = f_calc_r_sqr( range2, gx_post );
%                 R_gy_post = f_calc_r_sqr( range2, gy_post );
%                 R_gz_post = f_calc_r_sqr( range2, gz_post );
                
                R_a_pre = [R_ax_pre, R_ay_pre, R_az_pre];
                R_g_pre = [R_gx_pre, R_gy_pre, R_gz_pre];
                

%                 R_a_post = [R_ax_post, R_ay_post, R_az_post];
%                 R_g_post = [R_gx_post, R_gy_post, R_gz_post];
                
%                 v = [R_a_pre; R_g_pre; R_a_post; R_g_post];
                v = [R_a_pre; R_g_pre];

               
               apre = ( v( 1, : ) );
%                apost = ( v( 3, : ) );
               
               gpre = ( v( 2, : ) );
%                gpost = ( v( 4, : ) );
               
               apre = sort( apre( 1 : 2 ) );
%                apost = sort( apost( 1 : 2 ) );
               
               gpre = sort( gpre( 1 : 2 ) );
%                gpost = sort( gpost( 1 : 2 ) );
               
               coef_accel = 0.7;
               coef_gyro  = 0.3;
               mag_max = norm( [coef_accel, coef_gyro] );
               
               cmPl = 1;
               a_pre = [apre, cmPl];
               g_pre = [gpre, cmPl];
               col = [coef_accel * a_pre + coef_gyro * g_pre] / mag_max;
               if( col( 1 ) > 1 )
                   col( 1 ) = 1;
               end
               if( col( 2 ) > 1 )
                   col( 2 ) = 1;
               end 
               if( col( 3 ) > 1 )
                   col( 3 ) = 1;
               end
               %col = [gpre, 1];
               col = [gpre, 1];
%                col = [apre, 1];
%                v_color_pre = sort( color_pre( 1 : 2 ) );
%                v_color_pre = sort( color_pre( 1 : 2 ) );
%                color_pre = gpre_sum;
%                color_pre = [sort( color_pre( 1 : 2 ) ), 0];
% %                color_pre = [sort(
%                
%                color_post = gpost_sum;
%                color_post = [sort( color_post( 1 : 2 ) ), 0];
               x1 = 0;
               x2 = x1 + 100;
               x3 = x2;
               x4 = x1;
               
               y1 = y_start + y_inc;
               y2 = y1;
               y3 = y2 + y_inc;
               y4 = y3;
               
               x = [x1, x2, x3, x4];
               y = [y1, y2, y3, y4];
               
               y_start = y_start + y_inc;
               
               patch( x, y, color_test );
               
               x1 = x2;
               x2 = x1 + 300;
               x3 = x2;
               x4 = x1;
               
               x = [x1, x2, x3, x4];
               %patch( x, y, color_pre );
               patch( x, y, col );
               
               x1 = x2;
               x2 = x1 + 300;
               x3 = x2;
               x4 = x1;
               
               x = [x1, x2, x3, x4];
%                patch( x, y, color_post );
               %fprintf( '%.1f %.1f\n\n\n', apre_sum, apost_sum );
            end
        end
        %shockIndex = 
        % [index_csv_file, ( l1 - 1 ), l1, nPostShocks]];
    end
    % test B2 tightened
%     idx = 3;
%     the_BL_ADA_Test.Initialize( TestBaseDirectoryPath );
%     testName = 'B2T';
%     TestParameters = [8, 9000];
%     [nDiscarded, nCSV_Records] = the_BL_ADA_Test.Run( testName, expected_result_tf, TestParameters, MinimumPostShockNumberRequired );
%     nProcess = nCSV_Records - nDiscarded;
%     processedFileNumber( idx ) = processedFileNumber( idx ) + nProcess;
%     percentageB2_tightened = the_BL_ADA_Test.GetTestPassingPercentage(  );


    
%     fprintf( 'tightened = %.2f\n', percentageB2_tightened );
end

[nMissfires, nSwings]
fprintf( 'STOP\n' );

