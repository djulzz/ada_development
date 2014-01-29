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

activities = {'Auto-10s Gap-Walking',
'Mini Suicide',
'Running',
'Scissor Mild Left to Right',
'Semi - Static Jumps',
'Sprint',
'Walking Fast' };

sensor_placement = { 'BELT', 'SHOE' };

nActivities  = length( activities );

fprintf( 'Number of activities = %i\n', nActivities );

% INSIDE SHOE
% -----------
% Auto-10s Gap-Walking
% Mini Suicide
% Running
% Scissor Mild Left to Right
% Semi - Static Jumps
% Sprint
% Walking Fast


% INSIDE BELT
% -----------
% Auto-10s Gap-Walking
% Mini Suicide
% Running
% Scissor Mild Left to Right
% Semi - Static Jumps
% Sprint
% Walking Fast

str1 = char( cell2mat( sensor_placement( 2 ) ) );

activity_str = char( cell2mat( activities( 1 ) ) );
str2 = activity_str;
validPutsBaseDir = [base_dir,  str1, '/', str2, '/'];
validPutsBaseDir	= '/Users/jesposito/Desktop/lab.11.21.2013/static stepping';
save_dir            = '/Users/jesposito/Desktop/lab.11.21.2013';
the_CSV_Directory = CSV_Directory( validPutsBaseDir );



numberOfFiles = the_CSV_Directory.GetNumberOfFiles(  );
% numberOfFiles = 1;
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
    
%     TS = timeseries( gyrX, t );
%     newVec = [t( 1 ) : 0.01 : t( end )];
%     TS1 = TS.resample( newVec );
    color = 'Black';
    linestyle = '-';
% 

    hold on;
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
%     plot( t, gyrX );
    set( hFig, 'Color', 'White' );
%     grid on;
%     axis on;

%     [Aindex ,Avalues] = Algorithm_Functor.CollectDiscontinuities( gyrX );
    
    
    BlastPlotter.Plot( the_BLRawSensorData, color, linestyle );
    [prefix, year, month, day, hour, min, sec] = Filename_Functor.SplitElements( name );
    str = sprintf( 'prefix = %s - year = %s - month = %s - day = %s - hour = %s - min = %s - sec = %s', prefix, year, month, day, hour, min, sec );
    fprintf( '%s\n', str );
%     hFig = gcf;
%     saveas( hFig, [pathstr,'/', name, '.png'], 'png' );
    saveas( hFig, [save_dir, '/', name, '.png'], 'png' );
    close( hFig );
    
end
