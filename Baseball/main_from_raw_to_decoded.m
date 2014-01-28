clear all;
close all;
clc;

addpath( './functions' );
addpath( './classes' );
addpath( '/Users/jesposito/RepoTop/julien_tests/mex' );

MSG_SHOCK_ANY_ACCE_LAXIS  = 0;
MSG_GYROS_MATCH_DOWNSWING = 1;
MSG_IMPACT_SIGNATURE      = 2;
MSG_NOTHING               = 3;
threshold = 1500;

k1 = { '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Invalid swings/',
    '/Users/jesposito/blast data/John_Goree/Baseball filter tests/Valid swings/',
    '/Users/jesposito/Desktop/Data/Baseball CSVs/Blast Data/2013_06_27 Easton/',
    '/Users/jesposito/blast data/Granger Good Baseball Swings/',
    '/Users/jesposito/blast data/postimpact/',
    '/Users/jesposito/Google Drive/Blast Motion Sensor-Recorder Data/BB/'};

titles = { 'NO  - John Goree''s Misfires',
           'YES - John Goree''s Swings',
           'YES - Easton 06/27/2013 Swings',
           'YES - Granger''s Good Swings',
           'YES - Victor''s Good Swings',
           'NO  - Jira''s Misfires' };
       
       
v1 = { false, true, true, true, true, false };

test_prediction_Map = containers.Map( k1, v1 );

number_of_tests = test_prediction_Map.Count(  );
fprintf( 'Number of tests = %i\n', number_of_tests );
for index_test = 6 : 1 : number_of_tests
    base = char( cell2mat( k1( index_test ) ) );
    expected_result = test_prediction_Map( base );
    expected_result_str = [];
    if( true == expected_result )
        expected_result_str = 'true';
    else
        expected_result_str = 'false';
    end
    fprintf( '\n\nEntering directory \"%s\". Expected result = %s...\n', base, expected_result_str );
    folder = base;
    files = dirrec( folder, '.csv' );
    [nRows, nCols] = size( files );


    current_test_min_max_table = [  ];
    max_digit = 3;
    str = f_generate_png_filename_from_number( index_test, max_digit );
    str = [pwd, '/pix/', 'cloud_', str];
    
	close all;
    hFig = figure( 1 );
    set( hFig, 'Color', 'White' );
    hold on;
    axis on;
    grid on;
    values = [  ];
    values_current_test = [  ];
    %criteria = 6.466e7
%         val_sum = sum( ( values_current_test( :, 1 ) <= 6.466e7 ) );
%     val_sum
    for Index_Current_File = 1 : 1 : nCols
        cur_cell = files( 1, Index_Current_File );
        fullFileName = cell2mat( cur_cell );
        [pathstr, name, ext] = fileparts( fullFileName );
        RawSensorData = BLRawSensorData( fullFileName );
        

        [ index ] = f_detect_acc_discontinuity( RawSensorData, threshold );

        [ vMin, vMax, values_curent ] = f_MinMaxB1Algo( RawSensorData );
%         sz = length( values_curent( :, 1 ) );
%         if( false == isempty( values_curent ) )
%             
%             su = sum( ( values_curent( :, 1 ) <= 0.5e8 ) && ( values_curent( :, 1 ) <= 0.5e8 ) );
%             perc = ( su / sz ) * 100;
%             sz, perc
%         end
        values_current_test = [values_curent;  values_curent];
        values = [values; values_curent];
        
        current_test_min_max_table = [current_test_min_max_table; [ vMin, vMax ]];
%         [t, v] = f_generate_velocity_profile_mph( RawSensorData );
%         [C, index_max]  = max( v );
%         if( index_max < index )
%             index = index_max;
%         end
%         index2 = index - 50;
%         if( index2 < 1 )
%             index2 = 1;
%         end

    %     [ ad ] = f_generate_raw_acceleration_delta_vector( RawSensorData );

%         vec = v( index2 : index );
%         l = length( vec );
%         movavgFilt( vec, l, 'Left' );
%         dx = length( vec );
%         dy = vec( l ) - vec( 1 );
%         a = dy / dx;
%         avg = ( vec( l ) + vec( 1 ) ) / 2;
%         v_max = vec( l );
        %fprintf( 'slope = %.1E - dx = %.1E (sec) - y_max = %.2f (mph) - y_avg = %.2f (mph)\n', a, dx * 0.002, vec( l ), avg );
    %     fprintf( 'y_max = %.2f (mph) - test = %i\n', v_max, res );
    %     [C, index_max]  = max( v );
    %     [C, index]  = min( v( 1 : index_max ) );
    %     close all;
    %     h = figure( Index_Current_File );



    
    % %     subplot( 2, 1, 1 );
    %     hold on;
    %     grid on;
    %     plot( v );
        if( -1 ~= index )
            ;
    %         fprintf( 'Discontinuity detected\n' );
            %plot( RawSensorData.TimeLine( index ), v( index ), 'Marker', 'Square', 'MarkerFaceColor', 'Red' );
    %         plot( index, v( index ), 'Marker', 'Square', 'MarkerFaceColor', 'Red' );
        else
            ;
    %         fprintf( 'NO Discontinuity detected\n' );
        end
    %     xlabel( 'Time (sec)' );
    %     ylabel( 'Velocity (mph)' );

    %     subplot( 2, 1, 2 );
    %     hold on;
    %     grid on;
    %     plot( ad );
    %     ind = find(ad >= threshold );
%         plot( ind, ad( ind ), 'Color', 'Red' );

    %     str = sprintf( '%i', Index_Current_File );
    %     sz = length( str );
    %     num_leading_zeros = max_digit - sz;
    %     temp = [  ];
    %     if( num_leading_zeros > 0 )
    %         for i = 1 : 1 : num_leading_zeros
    %             temp = [temp, '0'];
    %         end
    %         str = [temp, str];
    %     end
    %     str = [base, 'pix/', str, '.png'];
    %     saveas( h, str );
    end % (END) - for Index_Current_File = 1 : 1 : nCols

    min_ampli = [mean( current_test_min_max_table( :, 1 ) ) ];
    max_ampli = [mean( current_test_min_max_table( :, 2 ) ) ];
    c = 1e8;
    %fprintf( 'Expected passing = %s\tSCORES - mins = [%.1E, %.1E] - maxs = [%.1E, %.1E]\n', expected_result_str, min_ampli( 1 )/c, min_ampli( 2 )/c, max_ampli( 1 )/c, max_ampli( 2 )/c );
    fprintf( 'Expected passing = %s\tSCORES - vals = [%.2f, %.2f] - #files = %i\n', expected_result_str, min_ampli /c, max_ampli /c, nCols );
    nPts = size( values, 1 );
    
    idx_sorted = sort( values( :, 2 ) );
    val_mean = mean( values( :, 1 ) );
%     values( :, 1 ) = values( idx_sorted, 1 );
    
    %cdfplot( values( :, 1 ) );
%     [h,stats] = cdfplot( values( :, 1 ) );
%     stats.min
   %pareto( values( :, 1 ) ); 
%     hist( values( :, 1 ),3 );
    color = 'Blue';
    for k = 1 : 1 : nPts
        idx = values( k, 2 );
        val = values( k, 1 );
        plot( idx, val, 'Marker', 'Square', 'MarkerFaceColor', 'Blue', 'MarkerEdgeColor', 'Black' );
    end
    

    
    x1 = idx_sorted( 1 );
    x2 = idx_sorted( end );
    y1 = val_mean;
    y2 = y1;
%     plot( [x1, x2], [y1, y2], 'Color', 'Green', 'LineStyle', '--', 'LineWidth', 3 );
    
    val_mode = mode( values( :, 1 ) );
    idx_mode = find( values( :, 1 ) == val_mode );
    x1 = values( idx_mode( 1 ), 2 );
    y1 = val_mode;
%     plot( [x1], [y1], 'Marker', 'Square', 'MarkerFaceColor', 'Red', 'MarkerEdgeColor', 'Black' );
%     text( x1, y1, 'Mode' );
%     
    
    current_title = char( cell2mat( titles( index_test ) ) );
    current_title = [current_title, ' - (', num2str( nCols ), ' files)'];
    title( current_title );
%     ylabel( 'Potential Swing Signature - G_{x}^{2}+G_{y}^{2} (Raw)' );
%     xlabel( 'Sample Index' );
    saveas( hFig, str );
    close all;
end
