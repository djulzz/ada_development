function str = f_generate_str_from_number( in_number, max_digit )

    str = sprintf( '%i', in_number );
    sz = length( str );
    num_leading_zeros = max_digit - sz;
    temp = [  ];
    if( num_leading_zeros > 0 )
        for i = 1 : 1 : num_leading_zeros
            temp = [temp, '0'];
        end
        str = [temp, str];
    end
    str = [str, '.fig'];
    return;
end
