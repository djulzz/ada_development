function [ relative_variation_vector ] = f_analyze_relative_sign( vec_in )

    relative_variation_vector = [  ];
    n = length( vec_in );
    relative_variation_vector( 1 ) = 0;
    for i =  2 : 1 : ( n )
        val_cur = vec_in( i + 0 );
        val_prev = vec_in( i - 1 );
        delta = ( val_cur - val_prev );
        relative_variation_vector( i ) = 0;
        if( delta < 0 )
            relative_variation_vector( i ) = -1;
        elseif( delta > 0 )
            relative_variation_vector( i ) = +1;
        else
            relative_variation_vector( i ) = +0;
        end
    end
    relative_variation_vector( 1 ) = relative_variation_vector( 2 );
end

