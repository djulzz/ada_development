clear all;
close all;
clc;
format bank;

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

motion = Enum_GenericMotion.AUTO_10S_GAP_WALKING;

base_dir = '/Users/jesposito/Desktop/fieldwork.11.14.2013/';

% base_dir = '/Users/jesposito/Desktop/test2/';

activities = {  'Auto-10s Gap-Walking',
                'Mini Suicide',
                'Running',
                'Scissor Mild Left to Right',
                'Semi - Static Jumps',
                'Sprint',
                'Walking Fast' };

% jump, var = 158 377
% sprint, var = 203 000

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

SELECTED_CONTRAST = SPRINT;
PLACEMENT_SELECTED = SHOE;


placement_str = char( cell2mat( sensor_placement( PLACEMENT_SELECTED ) ) );




activity_str_walk       = char( cell2mat( activities( AUTO_10S_GAP_WALKING ) ) );
activity_str_run        = char( cell2mat( activities( RUNNING ) ) );
activity_str_jump       = char( cell2mat( activities( SEMI_STATIC_JUMPS ) ) );
activity_str_sprint     = char( cell2mat( activities( SPRINT ) ) );
activity_str_fast_walk	= char( cell2mat( activities( WALKING_FAST ) ) );


path_walk          = [base_dir,  placement_str, '/', activity_str_walk, '/'];
path_run           = [base_dir,  placement_str, '/', activity_str_run, '/'];
path_jump          = [base_dir,  placement_str, '/', activity_str_jump, '/'];
path_sprint        = [base_dir,  placement_str, '/', activity_str_sprint, '/'];
path_fast_walk     = [base_dir,  placement_str, '/', activity_str_fast_walk, '/'];

the_CSV_walk        = CSV_Directory( path_walk );
the_CSV_run         = CSV_Directory( path_run );
the_CSV_jump        = CSV_Directory( path_jump );
the_CSV_sprint      = CSV_Directory( path_sprint );
the_CSV_fast_walk   = CSV_Directory( path_fast_walk );

path_walk       =   the_CSV_walk.getFileAt( 1 );
path_run        =   the_CSV_run.getFileAt( 1 );
path_jump       =   the_CSV_jump.getFileAt( 1 );
path_sprint     =   the_CSV_sprint.getFileAt( 1 );
path_fast_walk  =   the_CSV_fast_walk.getFileAt( 1 );




the_BLRawSensorData_walk                = BLRawSensorData( path_walk );
the_BLRawSensorData_run                 = BLRawSensorData( path_run );
the_BLRawSensorData_jump                = BLRawSensorData( path_jump );
the_BLRawSensorData_sprint              = BLRawSensorData( path_sprint );
the_BLRawSensorData_fast_walk           = BLRawSensorData( path_fast_walk );

% UNTIL HERE

sz_walk         = the_BLRawSensorData_walk.NumberOfSamples(  );
sz_run          = the_BLRawSensorData_run.NumberOfSamples(  );
sz_jump         = the_BLRawSensorData_jump.NumberOfSamples(  );
sz_sprint       = the_BLRawSensorData_sprint.NumberOfSamples(  );
sz_fast_walk    = the_BLRawSensorData_fast_walk.NumberOfSamples(  );

acc_walk = the_BLRawSensorData_walk.MergeAccelerations(  );
acc_run = the_BLRawSensorData_run.MergeAccelerations(  );
acc_jump = the_BLRawSensorData_jump.MergeAccelerations(  );
acc_sprint = the_BLRawSensorData_sprint.MergeAccelerations(  );
acc_fast_walk = the_BLRawSensorData_fast_walk.MergeAccelerations(  );

idx_walk        = [ 60 : 1 : 1570];
idx_run         = [244 : 1 : 1410];
idx_jump        = [283 : 1 : 1558];
idx_sprint      = [190 : 1 : 1550];
idx_fast_walk   = [180 : 1 : 1390];

v_sprint = acc_sprint( idx_sprint );
% v_sprint = [v_sprint, v_sprint, v_sprint];
v_sprint_10 = v_sprint( 1 : 1 : 160 );
v_sprint_5 = v_sprint( 1 : 1 : 80 );
v_sprint_49 = v_sprint( 1 : 1 : 784 );
v_walk = acc_walk( idx_walk );
v_walk_10 = v_walk( 1 : 1 : 160 );
v_walk_5 = v_walk( 1 : 1 : 80 );
v_walk_51 = v_walk( 1 : 1 : 816 );
v_walk_49 = v_walk( 1 : 1 : 784 );

b01 = repmat( v_walk_10, 1, 10 );

b02 = [v_walk_10, repmat( v_sprint_10, 1, 8 ), v_walk_10];

b03 = [repmat( v_walk_10, 1, 3 ), v_walk_5, repmat( v_sprint_10, 1, 3 ), v_walk_5, repmat( v_walk_10, 1, 3 )];

b04 = [repmat( v_walk_10, 1, 2 ), v_walk_5, v_sprint_5, repmat( v_walk_10, 1, 7 )];

b05 = [repmat( v_sprint_10, 1, 10 )];

b06 = [v_walk_10, repmat( v_sprint_10, 1, 3 ), repmat( v_walk_10, 1, 2 ), repmat( v_sprint_10, 1, 3 ), v_walk_10];

b07 = [v_sprint_49, v_walk_51];

b08 = [v_walk_51, v_sprint_49];

b09 = [v_walk_10, v_sprint_10, v_walk_10, v_sprint_10, v_walk_10, v_sprint_10, v_walk_10, v_sprint_10, v_walk_10, v_sprint_10];

b10 = repmat( v_walk_10, 1, 10 );

b = [b01, b02, b03, b04, b05, b06, b07, b08, b09, b10];
plot( b );
hold on;
for i = 1 : 1 : 10
    i1 = ( i - 1 ) * 1600 + 1;
    i2 = i1 + 1599;
    x = [i1, i1];
    y = [0, 3000];
    plot( x, y, 'Color', 'Red', 'LineWidth', 2 );
    x = [i2, i2];
    plot( x, y, 'Color', 'Red', 'LineWidth', 2 );
end

% hFig = figure( 1 );
% set( hFig, 'Color', 'White' );
% idx = idx_walk;
% subplot( 2, 3, 1 ); hold on; grid on; axis on; color = 'Blue'; str = 'Walk'; plot( acc_walk( idx ), 'Color', color ); ylabel( str );
% 
% idx = idx_run;
% subplot( 2, 3, 2 ); hold on; grid on; axis on; color = 'Blue'; str = 'Run '; plot( acc_run( idx ), 'Color', color ); ylabel( str );
% 
% idx = idx_jump;
% subplot( 2, 3, 3 ); hold on; grid on; axis on; color = 'Blue'; str = 'Jump'; plot( acc_jump( idx ), 'Color', color ); ylabel( str );
% 
% idx = idx_sprint;
% subplot( 2, 3, 4 ); hold on; grid on; axis on; color = 'Blue'; str = 'Sprint'; plot( acc_sprint( idx ), 'Color', color ); ylabel( str );
% 
% idx = idx_fast_walk;
% subplot( 2, 3, 5 ); hold on; grid on; axis on; color = 'Blue'; str = 'Fast Walk'; plot( acc_fast_walk( idx ), 'Color', color ); ylabel( str );

sz_activity         = sz_run;
LEFT                = 1;
RIGHT               = 2;
half                = 0.5;
portion( LEFT )     = 0.3;
portion( RIGHT )    = 0.7;
% 
% percent( LEFT )    = portion( LEFT );
% percent( RIGHT )   = portion( RIGHT );
% 
% activity( LEFT )   = floor( sz_activity * half );
% activity( RIGHT )  = sz_activity - activity( LEFT );
% 
% index( LEFT )      = activity( LEFT ) * ( percent( LEFT ) );
% index( RIGHT )     = activity( LEFT ) + activity( RIGHT ) * ( 1 - percent( RIGHT ) );
% 
% idx                = [ index( LEFT ) : 1 : index( RIGHT ) ];

% acc_sprint = the_BLRawSensorData_sprint.MergeAccelerations(  );
% idx = f_extract_portion_signal( acc_sprint, 30, 70 );

% hFig = figure( 1 );
% hold on;
% set( hFig, 'Color', 'White' );
% idx_vector = [1 : 1 : sz_run];
% 
% plot( idx_vector, acc_sprint, 'Color', 'Green' );
% plot( idx_vector( idx ), acc_sprint( idx ), 'Color', 'Blue' );
% 
% x11 = activity( LEFT );
% x12 = x11;
% 
% x21 = x11 + 1;
% x22 = x21;
% 
% y11 = 0;
% y12 = 3500;
% 
% y21 = 0;
% y22 = 3500;
% 
% xLeft = [x11, x12];
% yLeft = [y11, y12];
% 
% xRight = [x21, x22];
% yRight = [y21, y22];
% 
% plot( xLeft, yLeft, 'Color', 'Red' );
% plot( xRight, yRight, 'Color', 'Red' );