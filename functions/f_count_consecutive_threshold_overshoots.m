function arr = f_count_consecutive_threshold_overshoots( indices )

    arr = [  ];
    if( isempty( indices ) == true )
        return;
    end
    
    o = f_take_out_first_sequence_consecutive_indices( indices );
    if( true == isempty( o ) )
        return;
    end
    
    n = length( o );
    for i = 1 : 1 : n
        if( o( i ) == true )
            str( i ) = '1';
        else
            str( i ) = '0';
        end
    end
    
    C = strsplit( str, '0' );
    nPatterns = length( C );
    for i = 1 : 1 : nPatterns
        current_str = num2str( cell2mat( C( i ) ) );
        sz = length( current_str );
        arr = [arr, sz];
    end
end
