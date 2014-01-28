function [tf, mini, maxi] = f_check_vector_within_range( v, lowerBound, upperBound )
    n = length( v );
    count = 0;
    for i = 1 : 1 : n
        if( ( v( i ) >= lowerBound ) && ( v( i ) <= upperBound ) )
            count = count + 1;
        end
    end
    tf = ( count > 0 );
    mini = min( v );
    maxi = max( v );
    return;
end
