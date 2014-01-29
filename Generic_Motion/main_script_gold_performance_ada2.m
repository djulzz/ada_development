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
validPutsBaseDir = '/Users/jesposito/Desktop/fieldwork.11.14.2013/SHOE/Walking Fast';


the_CSV_Directory = CSV_Directory( validPutsBaseDir );



numberOfFiles = the_CSV_Directory.GetNumberOfFiles(  );
numberOfFiles = 1;
for i = 1 : 1 : numberOfFiles
    pathToCurrentFile = the_CSV_Directory.getFileAt( i );
    the_BLRawSensorData = BLRawSensorData( pathToCurrentFile );
    [Time, aX, aY, aZ, gX, gY, gZ] = CSV_Parser.ExtractCalibratedSensorDataOnly( pathToCurrentFile );
    
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
%     M = csvread('./mex/pos.csv');
%     pX = M( :, 1 );
%     pY = M( :, 2 );
%     pZ = M( :, 3 );
    

    numSamplesCurrentFile = the_BLRawSensorData.NumberOfSamples(  );
    if( numSamplesCurrentFile < 200 )
        continue;
    end
    [pathstr,name,ext] = fileparts( pathToCurrentFile );
%     fprintf( 'file analyzed = %s - number of samples = %i\n', [name, ext], numSamplesCurrentFile );
    accX = the_BLRawSensorData.Accelerations( :, X );
    accY = the_BLRawSensorData.Accelerations( :, Y );
    accZ = the_BLRawSensorData.Accelerations( :, Z );
    
    gyrX = the_BLRawSensorData.Gyroscopes( :, X );
    gyrY = the_BLRawSensorData.Gyroscopes( :, Y );
    gyrZ = the_BLRawSensorData.Gyroscopes( :, Z );

    
    color = 'Black';
    linestyle = '-';

    hFig = figure( i );
    hold on;
    set( hFig, 'Color', 'White' );
    grid on;
    axis on;
%     plot3( pX, pY, pZ );
%     xlabel( 'Left pos. (m)' );
%     ylabel( 'Up pos. (m)' );
%     zlabel( 'Forward pos. (m)' );
%     
%     dist_Left = pX( end ) - pX( 1 );
%     dist_Up = pY( end ) - pY( 1 );
%     dist_Forward = pZ( end ) - pZ( 1 );
%     
%     fprintf( 'dist_Left = %.2f m - dist_Up = %.2f m - dist_Forward = %.2f m\n', dist_Left, dist_Up, dist_Forward );
    
    BlastPlotter.Plot( the_BLRawSensorData, color, linestyle );
    [prefix, year, month, day, hour, min, sec] = Filename_Functor.SplitElements( name );
    str = sprintf( 'prefix = %s - year = %s - month = %s - day = %s - hour = %s - min = %s - sec = %s', prefix, year, month, day, hour, min, sec );
    fprintf( '%s\n', str );
    saveas( hFig, [pathstr,'/', name, '.png'], 'png' );
    
    close( hFig );
%     f = fopen( [pathstr,'/', name, '.txt'], 'w' );
%     fprintf( f, '%s\n', comment );
%     fclose( f );
    
end
