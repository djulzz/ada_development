function [relO, relP] = f_relativize_indices( N, O, P )
    relO = 0;
    relP = 0;

    relO = O - N;
    relP = P - N;

    return;
end
