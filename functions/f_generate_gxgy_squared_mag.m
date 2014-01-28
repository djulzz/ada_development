function o = f_generate_gxgy_squared_mag( gx, gy )
    n = length( gx );
    for i = 1 : 1 : n
        gxi = gx( i );
        gyi = gy( i );
        o( i ) = ( gxi * gxi + gyi * gyi );
    end
end
