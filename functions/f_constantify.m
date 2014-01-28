function [ out_vec ] = f_constantify( in_vec, low, high )
    n = length( in_vec );
    avg = ( low + high ) / 2;
    for i = 1 : 1 : n
        val_in = in_vec( i );
        if( ( val_in >= low ) && ( val_in <= high ) )
            out_vec( i ) = avg;
        else
            out_vec( i ) = val_in;
        end
    end
    return;
end

