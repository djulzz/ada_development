

clear all;
close all;
clc;

N  = 5;

O = 1;
P = 2;


[relO, relP] = f_relativize_indices( N, O, P );

% reconstruct
reconstO = N + relO;
reconstP = N + relP;

% [O, P]
% [reconstO, reconstP]
diffO = O - reconstO;
diffP = P - reconstP;

[diffO, diffP]