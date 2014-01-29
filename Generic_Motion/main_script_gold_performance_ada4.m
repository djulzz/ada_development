clear all;
close all;
clc;

load( 'reference_scores.mat' );

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


validPutsBaseDir = '/Users/jesposito/Google Drive/data/Valid/peformances/sprints/JE - Sat. Nov. 09 - 2013';
validPutsBaseDir = '/Users/jesposito/Google Drive/data/Valid/peformances/sprints/JE - Sunday Nov. 11th 2013';
base_dir = '/Users/jesposito/Desktop/fieldwork.11.14.2013/';
save_dir            = '/Users/jesposito/Desktop/screen_captures/';

activities = {'Auto-10s Gap-Walking',
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

sensor_placement = { 'BELT', 'SHOE' };

nActivities  = length( activities );

fprintf( 'Number of activities = %i\n', nActivities );

ACTIVITY_SELECTED = WALKING_FAST;
PLACEMENT_SELECTED = SHOE;

str1 = char( cell2mat( sensor_placement( PLACEMENT_SELECTED ) ) );
activity_str = char( cell2mat( activities( ACTIVITY_SELECTED ) ) );


save_dir = [save_dir, str1, '_GYRX_', activity_str];
mkdir( save_dir );

str2 = activity_str;
validPutsBaseDir = [base_dir,  str1, '/', str2, '/'];
% validPutsBaseDir	= '/Users/jesposito/Desktop/lab.11.21.2013/walking';
% save_dir            = '/Users/jesposito/Desktop/lab.11.21.2013';

% validPutsBaseDir	= '/Users/jesposito/Desktop/fieldwork.11.14.2013/SHOE/Running';

the_CSV_Directory = CSV_Directory( validPutsBaseDir );



numberOfFiles = the_CSV_Directory.GetNumberOfFiles(  );
numberOfFiles = 1;
for i = 1 : 1 : numberOfFiles
    pathToCurrentFile = the_CSV_Directory.getFileAt( i );
    the_BLRawSensorData = BLRawSensorData( pathToCurrentFile );
    [Time, aX, aY, aZ, gX, gY, gZ] = CSV_Parser.ExtractCalibratedSensorDataOnly( pathToCurrentFile );


    numSamplesCurrentFile = the_BLRawSensorData.NumberOfSamples(  );
    if( numSamplesCurrentFile < 200 )
        continue;
    end
    [pathstr,name,ext] = fileparts( pathToCurrentFile );

    accX = the_BLRawSensorData.Accelerations( :, X );
    accY = the_BLRawSensorData.Accelerations( :, Y );
    accZ = the_BLRawSensorData.Accelerations( :, Z );
    
    gyrX = the_BLRawSensorData.Gyroscopes( :, X );
    gyrY = the_BLRawSensorData.Gyroscopes( :, Y );
    gyrZ = the_BLRawSensorData.Gyroscopes( :, Z );
    
    t = the_BLRawSensorData.TimeLine;
    
    vel0 = [0, 0, 0];
    pos0 = [0, 0, 0];
    c = ( 24 / 2048 ) * 9.81;
%     velX = vel0( 1 ) + cumtrapz( t, accX * c );
%     velY = vel0( 2 ) + cumtrapz( t, accY * c );
%     velZ = vel0( 3 ) + cumtrapz( t, accZ * c );
    
%     accX = accX * c;
%     accY = accY * c;
%     accZ = accZ * c;
%     
%     velX = vel0( 1 ) + cumtrapz( t, accX );
%     velY = vel0( 2 ) + cumtrapz( t, accY );
%     velZ = vel0( 3 ) + cumtrapz( t, accZ );
%     
%     posX = pos0( 1 ) + cumtrapz( t, velX );
%     posY = pos0( 2 ) + cumtrapz( t, velY );
%     posZ = pos0( 3 ) + cumtrapz( t, velZ );
%     f = fopen( './mex/input', 'w' );
%     fprintf( f, '%s', pathToCurrentFile );
%     fclose( f );
%     
%     cur_dir = pwd;
%     cd( './mex' );
%     pwd
%     !./exe_performances
%     cd( cur_dir );
%     %mexPerformances( pathToCurrentFile );
%     M = csvread('pos.csv');
%     posX = M( :, 1 );
%     posY = M( :, 2 );
%     posZ = M( :, 3 );

    color = 'Black';
    linestyle = '-';
% 
%     pA = [posX( 1 ), posY( 1 ), posZ( 1 )];
%     pB = [posX( end ), posY( end ), posZ( end )];
%     len = norm( pB - pA );
%     fprintf( 'run %i - length (m) = %f\n', i, len );
%     hold on;
    lineWidth = 1;
    nSamples = length( t );
    
    vec = [  ];
%     for j = 1 : 1 : ( nSamples - 1 )
%         lineWidth = 1;
%         t1 = t( j );
%         t2 = t( j + 1 );
%         y1 = gyrX( j );
%         y2 = gyrX( j + 1 );
%         color = 'Blue';
%         Ampl = 15000;
%         Ampl = 1200;
%         dy = ( y2 - y1 );
%         dx = ( t2 - t1 );
%         vec_t = [t1, t2];
%         vec_y = [y1, y2];
%         b1 = abs( dy >= Ampl );
%         b2 = true;
%         if( length( vec ) > 1 )
%             b2 = ( ( j - vec( end ) ) > 100 );
%         end
%         if( b1 && b2 )
%             color = 'Red';
%             lineWidth = 3;
%             vec = [vec, j];
%         end
%         
%         plot( vec_t,vec_y, 'Color', color, 'LineWidth', lineWidth );
%     end
%     plot( t, gyrX );
%     title( activity_str );
    
%     vec = diff( vec );
%     a = mean( vec );
%     a
    
%     [Oindex ,Ovalues] = Algorithm_Functor.CollectDiscontinuities( gyrX );
%     plot( TS.Time, TS.Data, 'b' );
%     hold on;
%     plot( TS1.Time, TS1.Data, 'r' );
    hFig = figure( i );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time' );
    ylabel( 'Acceleration Raw Magnitude' );
%     plot( t, gyrX );
    set( hFig, 'Color', 'White' );
%     grid on;
%     plot3( posX, posY, posZ );
%     xlabel( 'Left' );
%     ylabel( 'Up' );
%     zlabel( 'Forward' );
%     grid on;
%     axis on;

    [Aindex ,Avalues] = Algorithm_Functor.CollectDiscontinuities( gyrX );
    
    A = [accX, accY, accZ];
    accMerged = Math.Magnitude( A );
    the_FFT = fft( A );
    %plot( t, accMerged );
    plot( t, gyrX );
    title( activity_str );
    %BlastPlotter.Plot( the_BLRawSensorData, color, linestyle );
    [prefix, year, month, day, hour, min, sec] = Filename_Functor.SplitElements( name );
    str = sprintf( 'prefix = %s - year = %s - month = %s - day = %s - hour = %s - min = %s - sec = %s', prefix, year, month, day, hour, min, sec );
    fprintf( '%s\n', str );
%     hFig = gcf;
%     saveas( hFig, [pathstr,'/', name, '.png'], 'png' );
    saveas( hFig, [save_dir, '/', name, '.png'], 'png' );
%     close( hFig );
    
end
