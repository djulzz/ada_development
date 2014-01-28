function o = f_take_out_first_sequence_consecutive_indices( indices )
    o = [  ];
    if( ( true == isempty( indices ) ) || ( length( indices ) < 2 ) )
        return;
    end

    a = ( diff( indices ) == 1 );
    a = [a; a( end )];
    n = length( a );
    o = a;
end
