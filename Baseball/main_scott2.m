clear all;
close all;
clc;


folder = '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Valid swings/';

files = dirrec( folder, '.csv' );
[nRows, nCols] = size( files );


Index_Current_File = 1;
cur_cell = files( 1, Index_Current_File );
fullFileName = cell2mat( cur_cell );
RawSensorData = BLRawSensorData( fullFileName );



hold on;



X = 1;
Y = 2;
Z = 3;

[ delta_t, range ] = f_analyze_discontinuity( RawSensorData );
fprintf( 'Discontinuity info - Time span = %.3f ms - Nb. points %i\n', delta_t, length( range ) );
hold on;
plot( RawSensorData.TimeLine, RawSensorData.Accelerations( :, X ), 'Color', 'Blue' );
plot( RawSensorData.TimeLine( range ), RawSensorData.Accelerations( range, X ), 'Color', 'Red', 'LineWidth', 2 );
