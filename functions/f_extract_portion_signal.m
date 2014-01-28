function idx = f_extract_portion_signal( acc_waveform,...
    percentage_removed_left,...
    percentage_removed_right )

    n = length( acc_waveform );

    
    sz_activity         = n;
    LEFT                = 1;
    RIGHT               = 2;
    half                = 0.5;
    portion( LEFT )     = percentage_removed_left / 100;
    portion( RIGHT )    = percentage_removed_right / 100;

    percent( LEFT )    = portion( LEFT );
    percent( RIGHT )   = portion( RIGHT );

    activity( LEFT )   = floor( sz_activity * half );
    activity( RIGHT )  = sz_activity - activity( LEFT );

    index( LEFT )      = activity( LEFT ) * ( percent( LEFT ) );
    index( RIGHT )     = activity( LEFT ) + activity( RIGHT ) * ( 1 - percent( RIGHT ) );

    idx                = [ index( LEFT ) : 1 : index( RIGHT ) ];
    return;
end
