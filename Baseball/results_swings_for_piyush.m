clear all;
close all;
clc;

addpath( 'mex' );
addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );
addpath( 'functions' );
addpath( 'classes' );

acc = [  ];
gyro = [  ];
firstSample = true;
params = [8, 9000];
oneShot = 1;

filename = '/Users/jesposito/Desktop/BlastBaseball_2014-01-09.15_35_21.csv';

the_BLRawSensorData = BLRawSensorData( filename );
nSamples = the_BLRawSensorData.NumberOfSamples(  );
acc = the_BLRawSensorData.Accelerations;
gyro = the_BLRawSensorData.Gyroscopes;
[ada_res, piyush_res] = mexRunADA( 'B2T', acc, gyro, firstSample, params, oneShot );
if( ada_res == 1 )
    fprintf( 'Success\n' );
else
    fprintf( 'Failure\n' );
end

