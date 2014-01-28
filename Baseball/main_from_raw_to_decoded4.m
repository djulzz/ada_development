clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );
addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );

delete('log.txt' );
fprintf( 'Now processing the missfire\n' );

filename = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Invalid swings/Hitting shoe/HitShoe_2013-06-20.17_50_28.csv';
filename = '/Users/jesposito/Desktop/julian/20 post impacts/victor/BlastBaseball_2013-09-13.11_18_42.csv'
RawSensorData = BLRawSensorData( filename );


% res = f_scripted_mexRunADA( RawSensorData );
% res
% [res, values] = f_detect_swing( RawSensorData );


% hold on;
% plot( RawSensorData.TimeLine, sig );

w_misfire = 1;
w_swing   = 1;
all_records = [  ];

threshold_interval = 9;
gy_impact_threshold = 5000;
res = mexRunADA( RawSensorData.Accelerations, RawSensorData.Gyroscopes, true, threshold_interval, gy_impact_threshold, 1 );
res