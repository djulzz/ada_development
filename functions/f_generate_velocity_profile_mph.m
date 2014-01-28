function [t, v] = f_generate_velocity_profile_mph( RawSensorData )

    t = [  ];
    v = [  ];
    nSamples = length( RawSensorData.TimeLine );

    conv = 2.236936;
    g2mss = 9.8065;
    rawToGs = ( 1 / 2048 );

    mps_to_mph = 178.954903;

    %dt_array = [  ];
    for i = 1 : 1 : ( nSamples - 1 )

        idx = i;
        rawToGs = RawSensorData.ScaleRrawVector( idx ) / 2048;
        ax = RawSensorData.Accelerations( idx, 1 ) * rawToGs;
        ay = RawSensorData.Accelerations( idx, 2 ) * rawToGs;
        az = RawSensorData.Accelerations( idx, 3 ) * rawToGs;

    %     a_vec = [ax, ay, az];
    %     a( i ) = norm( a_vec );

        t1 = RawSensorData.TimeLine( idx );

        idx = i + 1;


        t2 = RawSensorData.TimeLine( idx );

        dt = ( t2 - t1 );
        %dt = 0.002;
        %dt_array = [dt_array, dt];
        vx = ax * g2mss * dt * mps_to_mph;
        vy = ay * g2mss * dt * mps_to_mph;
        vz = az * g2mss * dt * mps_to_mph;

        t( i ) = t1;
        v( i ) = norm( [vx, vy, vz] );


    end
end
