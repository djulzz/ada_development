function f_draw_raw_sensor_data( the_BLRawSensorData, title_str )

    ax = the_BLRawSensorData.Accelerations( :, 1 );
    ay = the_BLRawSensorData.Accelerations( :, 2 );
    az = the_BLRawSensorData.Accelerations( :, 3 );
    
    gx = the_BLRawSensorData.Gyroscopes( :, 1 );
    gy = the_BLRawSensorData.Gyroscopes( :, 2 );
    gz = the_BLRawSensorData.Gyroscopes( :, 3 );
    
    t = the_BLRawSensorData.TimeLine(  );
    
    color_x = 'Red';
    color_y = 'Green';
    color_z = 'Blue';
    
%     fig = figure;
%     set( fig, 'Color', 'White' );
    
    subplot( 2, 1, 1 ); hold on; axis on; grid on;
    plot( t, ax, 'Color', color_x );
    plot( t, ay, 'Color', color_y );
    plot( t, az, 'Color', color_z );
    
    subplot( 2, 1, 2 ); hold on; axis on; grid on;
    plot( t, gx, 'Color', color_x );
    plot( t, gy, 'Color', color_y );
    plot( t, gz, 'Color', color_z );

    return;
end
