clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );
addpath( './functions/geom2d_2012.02.29/geom2d/geom2d' );

addpath( '/Users/jesposito/RepoTop/julien_tests/mex/' );
%addpath( 'C:\Users\djulzz\Desktop\blast-api_win\mex_files\' );
MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;
threshold = 1500;

google_drive = '/Users/jesposito/Google Drive/';
%google_drive = 'C:/Users/djulzz/Google Drive/';

delete( 'log.txt' );
% k1 = {
%     %[google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1146/'],
%     [google_drive, 'Blast Motion Sensor-Recorder Data/BB/'],
%     [google_drive, '20 post impacts/victor/']
%     };
% 
% v1 = { 
%     false,
%     true
%     };

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

shorts = {'John''s FALSE', 'John''s TRUE', 'Easton TRUE', 'Granger''s TRUE', 'Victor''s TRUE', 'Jira''s FALSE', 'Granger''s 10 TRUE', 'Victor''s 9 TRUE', 'Julien''s FALSE' };
Interval = 3;
gyThreshold = 5000;
AccelDiscontinuityThreshold = 1500;
GxySquaredImpactThreshold = 8000^2;
   
param( 1 ) = Interval;
param( 2 ) = gyThreshold;
param( 3 ) = AccelDiscontinuityThreshold;
param( 4 ) = GxySquaredImpactThreshold;


pix_folder = 'pix_all';
mkdir( pwd, pix_folder );
save_folder = [pwd, '/', pix_folder];
delete( [save_folder, '/*.*'] );
nFiles_vec = [];
div = max(nFiles_vec);
nFiles_vec = nFiles_vec / div;
test_prediction_Map = containers.Map( k1, v1 );
number_of_tests = test_prediction_Map.Count(  );
for index_test = 1 : 1 : number_of_tests
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
    for Index_Current_File = 1 : 1 : nFiles
        cur_cell = files( 1, Index_Current_File );
%         fullFileName = '/Users/jesposito/Google Drive/Blast Motion Sensor-Recorder Data/BB/BB-1146/BlastBaseball_2013-07-31.11_59_31.csv';
        
        fullFileName = cell2mat( cur_cell );
        [pathstr, name, ext] = fileparts( fullFileName );
        if( strncmp( name, '._', 2 ) == true )
            name = char( name( 3 : end ) );
            fullFileName = [pathstr, '/', name, ext];
        end
        RawSensorData = BLRawSensorData( fullFileName );
        
        acceleration_threshold = 1500;
        almost_continuous_threshold = 10;
        
        the_IMU_Analyzer = IMU_Analyzer( ...
            RawSensorData,...
            acceleration_threshold,...
            almost_continuous_threshold );
        
        save_png = false;
        bb = ( the_IMU_Analyzer.nElements_post >= 20 );
        bbb = ( the_IMU_Analyzer.nElements_post > 10 );
        if( ( true == the_IMU_Analyzer.b_hasPreImpact ) && ...
                ( true == the_IMU_Analyzer.b_hasPostImpact ) &&...
                ( the_IMU_Analyzer.nShockPoints > 1 ) )
            res1 = the_IMU_Analyzer.CheckMag( RawSensorData );

            Cmp = [Cmp, expected_result];
            res = [res, res1];
            if( expected_result ~= res1 )
                fprintf( '#samp. = %i - #post impact = %i - post impact range = [%i, %i] - R = %.2f\n',...
                    the_IMU_Analyzer.nSamples,...
                    the_IMU_Analyzer.nElements_post,...
                    the_IMU_Analyzer.Interval_PostImpact( 1 ),...
                    the_IMU_Analyzer.Interval_PostImpact( end ),...
                    the_IMU_Analyzer.r );
            end
%             res2 = mexRunADA( RawSensorData.Accelerations, RawSensorData.Gyroscopes, true,...
%                     param, 1 );
            %fprintf( '%i %i\n', res1, res2 );
%             fprintf( '%i\n', res1 );
            if( true == save_png )
                close all;
                hFig = figure( 1 );
                set( hFig, 'Color', color_fig );
                set( hFig, 'InvertHardCopy', 'off');
                base = char( cell2mat( k1( index_test ) ) );

                str = f_generate_str_from_number( Index_Current_File, 3 );

                x = 1;
                y = 2;
                z = 3;

                opt = 'pre_impact';
                
                subplot( 3, 2, 1 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Accelerations( :, x ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Blue' );

                subplot( 3, 2, 2 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Gyroscopes( :, x ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Blue' );

                subplot( 3, 2, 3 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Accelerations( :, y ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Red' );

                subplot( 3, 2, 4 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Gyroscopes( :, y ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Red' );
 
                subplot( 3, 2, 5 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Accelerations( :, z ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Green' );
 
                subplot( 3, 2, 6 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Gyroscopes( :, z ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Green' );
 
                opt = 'post_impact';
                
                subplot( 3, 2, 1 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Accelerations( :, x ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Black' );

                subplot( 3, 2, 2 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Gyroscopes( :, x ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Black' );

                subplot( 3, 2, 3 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Accelerations( :, y ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Black' );

                subplot( 3, 2, 4 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Gyroscopes( :, y ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Black' );

                subplot( 3, 2, 5 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Accelerations( :, z ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Black' );

                subplot( 3, 2, 6 );
                hold on; grid on; axis on;
                bb = the_IMU_Analyzer.CreateBoundingBox( RawSensorData.Gyroscopes( :, z ), RawSensorData.TimeLine, opt );
                patch( bb( :, x ), bb( :, y ), 'Black' );

                saved_filename = [save_folder, '/', prefix1, name, num2str( Index_Current_File ), '.png'];
                saveas( hFig, saved_filename );
            end
        end
    end
    nMatches = sum( res == Cmp );
    nMax = length( Cmp );
    percentage = ( nMatches / nMax ) * 100;
    if( nMax > 0 )
        fprintf( 'percent detection = %.2f %% based on %i files\n\n', percentage, nMax );
    else
        fprintf( 'percent detection IMPOSSIBLE because not enough files with enough samples\n\n' );
    end
end
