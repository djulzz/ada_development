function [ o ] = f_compute_rate_magnitude2( vec_gx, vec_gy, vec_gz )
    n = length( vec_gx );
    for i = 1 : 1 : n
        gx = 0;
        gy = 0;
        gz = 0;
        gx = vec_gx( i );
        gy = vec_gy( i );
        gz = vec_gz( i );
        comb = ( gx + gy );
        mag = sqrt( comb * comb + gz * gz );
        if( mag == 0 )
            mag = 1;
        end
        relxy = comb / mag;
        relz = gz / mag;
        o( i, 1 : 2 ) = [relxy, relz];
    end
    return;
end

