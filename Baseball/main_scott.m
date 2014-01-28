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

nSamples = length( RawSensorData.TimeLine );

conv = 2.236936;
g2mss = 9.8065;
rawToGs = ( 1 / 2048 );

mps_to_mph = 178.954903;
deg2rad = pi / 180;
%dt_array = [  ];
Rest = [0, 0, 0];

Ayz0 = 0;
Axz0 = 0;
Axy0 = 0;

hold on;

Rest = [  ];

shock_induced_discontinuity = 1500;

shock_window = [  ];

X = 1;
Y = 2;
Z = 3;

for i = 2 : 1 : ( nSamples )
    idx = i;

    
    Ax_Cur = RawSensorData.Accelerations( idx, X );
    Ay_Cur = RawSensorData.Accelerations( idx, Y );
    Az_Cur = RawSensorData.Accelerations( idx, Z );
    
    Gx_Cur = RawSensorData.Gyroscopes( idx, X );
    Gy_Cur = RawSensorData.Gyroscopes( idx, Y );
    Gz_Cur = RawSensorData.Gyroscopes( idx, Z );

    Ax_Prev = RawSensorData.Accelerations( idx - 1, X );
    Ay_Prev = RawSensorData.Accelerations( idx - 1, Y );
    Az_Prev = RawSensorData.Accelerations( idx - 1, Z );
    
    Gx_Prev = RawSensorData.Gyroscopes( idx - 1, X );
    Gy_Prev = RawSensorData.Gyroscopes( idx - 1, Y );
    Gz_Prev = RawSensorData.Gyroscopes( idx - 1, Z );
    
    delta_Ax = abs( Ax_Cur - Ax_Prev );
    delta_Ay = abs( Ay_Cur - Ay_Prev );
    
    if( ( delta_Ax >= shock_induced_discontinuity ) || ( delta_Ay >= shock_induced_discontinuity ) )
        shock_window = [shock_window, i];
    end
end


i_min = min( shock_window );
i_max = max( shock_window );
range = i_min : 1 : i_max;

delta_t = RawSensorData.TimeLine( i_max ) - RawSensorData.TimeLine( i_min );
fprintf( 'Discontinuity info - Time span = %.3f ms - Nb. points %i\n', delta_t, length( range ) );
hold on;
plot( RawSensorData.TimeLine, RawSensorData.Accelerations( :, X ), 'Color', 'Blue' );
plot( RawSensorData.TimeLine( range ), RawSensorData.Accelerations( range, X ), 'Color', 'Red', 'LineWidth', 2 );
