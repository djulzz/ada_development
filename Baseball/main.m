clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );
addpath( './functions/geom2d_2012.02.29/geom2d/geom2d' );

addpath( '/Users/jesposito/RepoTop/julien_tests/mex/' );



google_drive = '/Users/jesposito/Google Drive/';

k1 = {
    [google_drive, 'John_Goree/Baseball filter tests/Invalid swings/'],
    [google_drive, 'John_Goree/Baseball filter tests/Valid swings/'],
    [google_drive, '2013_06_27 Easton/'],
    [google_drive, 'Granger Good Baseball Swings/'],
    [google_drive, 'postimpact/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/'],
    [google_drive, '20 post impacts/granger/'],
    [google_drive, '20 post impacts/victor/'],
    [google_drive, '20 post impacts/misfires/']
    };


v1 = { 
    false...
    , true, ...
    true,...
    true, true, ...
    false,...
    true, true, false
    };

shorts = {'John''s FALSE',...
    'John''s TRUE',...
    'Easton TRUE',...
    'Granger''s TRUE',...
    'Victor''s TRUE',...
    'Jira''s FALSE',...
    'Granger''s 10 TRUE',...
    'Victor''s 9 TRUE',...
    'Julien''s FALSE' };

test_prediction_Map = containers.Map( k1, v1 );
number_of_tests = test_prediction_Map.Count(  );
index_test = 3;
base = char( cell2mat( k1( index_test ) ) );
expected_result = test_prediction_Map( base );
res_str = 'FALSE';
if( true == expected_result )
    res_str = 'TRUE';
end
folder = base;
files = dirrec( folder, '.csv' );
[nRows, nFiles] = size( files );
fprintf( '# files detected = %i - name = %s\n', nFiles, char( cell2mat( shorts( index_test ) ) ) );
%nFiles = 2;
nActualGoodFiles = 0;
nFiles_vec = [nFiles_vec, nFiles];

color_fig = [  ];
if( true == expected_result )
    prefix1 = '1_';
    color_fig = 'Green';
else
    prefix1 = '0_';
    color_fig = 'Red';
end
res = [  ];
Cmp = [  ];
Index_Current_File = 1;
cur_cell = files( 1, Index_Current_File );

fullFileName = cell2mat( cur_cell );
[pathstr, name, ext] = fileparts( fullFileName );
if( strncmp( name, '._', 2 ) == true )
    name = char( name( 3 : end ) );
    fullFileName = [pathstr, '/', name, ext];
end

