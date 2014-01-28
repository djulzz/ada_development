clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );

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
k1 = {
    %[google_drive, 'Blast Motion Sensor-Recorder Data/BB/BB-1146/'],
    [google_drive, 'Blast Motion Sensor-Recorder Data/BB/'],
    [google_drive, '20 post impacts/victor/']
    };

v1 = { 
    false,
    true
    };

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
    folder = base;
    files = dirrec( folder, '.csv' );
    [nRows, nFiles] = size( files );
    fprintf( '# files detected = %i\n', nFiles );
    %nFiles = 2;
    nActualGoodFiles = 0;
    nFiles_vec = [nFiles_vec, nFiles];
    expected_result = test_prediction_Map( base );
    color_fig = [  ];
    if( true == expected_result )
        prefix1 = '1_';
        color_fig = 'Green';
    else
        prefix1 = '0_';
        color_fig = 'Red';
    end
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
        
        nSamples = length( RawSensorData.TimeLine );
        idx = [  ];
        for i = 1 : 1 : ( nSamples - 1 )
            delta = abs( RawSensorData.Accelerations( i + 1, : ) - RawSensorData.Accelerations( i, : ) );
            if( ( delta( 1 ) > 1500 ) || ( delta( 2 ) > 1500 ) || ( delta( 3 ) > 1500 ) )
                idx = [idx, i];
            end
        end
        i1 = idx( 1 );
        i2 = idx( end );
        hasPreImpact = false;
        hasPostImpact = false;
        fprintf( 'Shock range = [%i %i]\n', i1, i2 );
        isInLinearRange = false;
        i = i1;
        l = 10;
        iPreImpact = 1;
        while( false == isInLinearRange )
            i = i - 1;
            delta = abs( RawSensorData.Accelerations( i + 1, : ) - RawSensorData.Accelerations( i, : ) );
            if( ( delta( 1 ) < l ) && ( delta( 2 ) < l ) && ( delta( 3 ) < l ) )
                isInLinearRange = true;
                hasPreImpact = true;
                fprintf( 'Pre - impact linear range found @ i = %i\n', i );
                iPreImpact = i;
            end
        end
        i = i2;
        iPostImpact = 1;
        isInLinearRange = false;
        while( ( false == isInLinearRange ) && ( i <= nSamples - 2 ) )
            i = i + 1;
            delta = abs( RawSensorData.Accelerations( i + 1, : ) - RawSensorData.Accelerations( i, : ) );
            if( ( delta( 1 ) < l ) || ( delta( 2 ) < l ) || ( delta( 3 ) < l ) )
                isInLinearRange = true;
                fprintf( 'Post - impact linear range found @ i = %i\n', i );
                hasPostImpact = true;
                iPostImpact = i;
            end
        end
        if( ( true == hasPreImpact ) && ( true == hasPostImpact ) )
            %fprintf( '
            close all;
            hFig = figure( 1 );
            set( hFig, 'Color', color_fig );
            set( hFig, 'InvertHardCopy', 'off');
            base = char( cell2mat( k1( index_test ) ) );
            
            str = f_generate_str_from_number( Index_Current_File, 3 );
            

            if( true == hasPreImpact )
                linearRangeAccel = [iPreImpact : i1];
                subplot( 3, 2, 1 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Accelerations( linearRangeAccel, 1 ),...
                    'Color', 'Blue', 'LineWidth', 2 );

                subplot( 3, 2, 2 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Gyroscopes( linearRangeAccel, 1 ),...
                    'Color', 'Blue', 'LineWidth', 2 );


                subplot( 3, 2, 3 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Accelerations( linearRangeAccel, 2 ),...
                    'Color', 'Red', 'LineWidth', 2 );

                subplot( 3, 2, 4 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Gyroscopes( linearRangeAccel, 2 ),...
                    'Color', 'Red', 'LineWidth', 2 );

                subplot( 3, 2, 5 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Accelerations( linearRangeAccel, 1 ),...
                    'Color', 'Green', 'LineWidth', 2 );

                subplot( 3, 2, 6 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Gyroscopes( linearRangeAccel, 1 ),...
                    'Color', 'Green', 'LineWidth', 2 );


            end
            if( true == hasPostImpact )
                linearRangeAccel = [i2 : iPostImpact];

                subplot( 3, 2, 1 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Accelerations( linearRangeAccel, 1 ),...
                    'Color', 'Black', 'LineWidth', 2 );

                subplot( 3, 2, 2 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Gyroscopes( linearRangeAccel, 1 ),...
                    'Color', 'Black', 'LineWidth', 2 );


                subplot( 3, 2, 3 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Accelerations( linearRangeAccel, 2 ),...
                    'Color', 'Black', 'LineWidth', 2 );

                subplot( 3, 2, 4 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Gyroscopes( linearRangeAccel, 2 ),...
                    'Color', 'Black', 'LineWidth', 2 );

                subplot( 3, 2, 5 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Accelerations( linearRangeAccel, 1 ),...
                'Color', 'Black', 'LineWidth', 2 );

                subplot( 3, 2, 6 );
                hold on;
                grid on;
                axis on;
                plot( RawSensorData.TimeLine( linearRangeAccel ),...
                    RawSensorData.Gyroscopes( linearRangeAccel, 1 ),...
                    'Color', 'Black', 'LineWidth', 2 );
            end
            saved_filename = [save_folder, '/', prefix1, name, num2str( Index_Current_File ), '.png'];
            saveas( hFig, saved_filename );
        end
    end
end
