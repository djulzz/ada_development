function o = f_combine_gxgy( gx, gy )
    o = [  ];
    n = length( gx );
    for i = 1 : 1 : n
        gxi = gx( i );
        gyi = gy( i );
        
        mag_gxi = abs( gxi );
        mag_gyi = abs( gyi );
        mag_total = sqrt( mag_gxi * mag_gxi + mag_gyi * mag_gyi );
        c1 = mag_gxi / mag_total;
        c2 = mag_gyi / mag_total;
        o( i ) = ( c1 * gxi + c2 * gyi );
    end
    return;
end
        