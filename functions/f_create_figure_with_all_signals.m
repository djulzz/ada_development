function f_create_figure_with_all_signals( filename )

    RawSensorData = BLRawSensorData( filename );
    ax = RawSensorData.Accelerations( :, 1 );
    ay = RawSensorData.Accelerations( :, 2 );
    az = RawSensorData.Accelerations( :, 3 );
    
    gx = RawSensorData.Gyroscopes( :, 1 );
    gy = RawSensorData.Gyroscopes( :, 2 );
    gz = RawSensorData.Gyroscopes( :, 3 );
    
    t = RawSensorData.TimeLine;
    
    figure( 1 );
    set( gcf, 'Color', 'White' );
    
    subplot( 2, 3, 1 );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time (sec)' );
    ylabel( 'Accel. X' );
    plot( t, ax );
    
    subplot( 2, 3, 2 );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time (sec)' );
    ylabel( 'Accel. Y' );
    plot( t, ay );
    
    subplot( 2, 3, 3 );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time (sec)' );
    ylabel( 'Accel. Z' );
    plot( t, az );
    
    
    subplot( 2, 3, 4 );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time (sec)' );
    ylabel( 'Gyro. X' );
    plot( t, gx );
    
    subplot( 2, 3, 5 );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time (sec)' );
    ylabel( 'Gyro. Y' );
    plot( t, gy );
    
    subplot( 2, 3, 6 );
    hold on;
    grid on;
    axis on;
    xlabel( 'Time (sec)' );
    ylabel( 'Gyro. Z' );
    plot( t, gz );
    
    return;
end
