clear all;
close all;
clc;


load( 'collectedVars.mat' );

gy_impact_threshold = 2000 : 500 : 10000;
threshold_interval = 2 : 1 : 40;
w_num_files = nFiles_vec / max( nFiles_vec );
test_weights = [ false , true, true, true, true, false, true, true, false ];
weight_swing = 10;
weight_misfire = 1;
%     'JG 7- Misf.
%     'JG 3- Swin.
%     'Easton 94- Swin.
%     'Granger 143- Swin.
%     'Victor 5- Swin.
%     'Jira - 162 Misf.
%     'Granger 9- Swin.
%     'Victor 10- Swin.
%     'Julien 8- Misf.'
nIs = length( gy_impact_threshold );
nJs = length( threshold_interval );
Zs = zeros( nIs, nJs );
all_scores = zeros( 1, nIs * nJs );

for i = 1 : 1 : nIs
    for j = 1 : 1 : nJs
        Idx = ( i - 1 ) * nJs + j;
        percentage_tests = all_records( Idx, : );
        nPercentages = length( percentage_tests );
        score = 0;
        for k = 1 : 1 : nPercentages
            current_test_weight = test_weights( k );
            w_tf = 0;
            if( current_test_weight == false )
                w_tf = weight_misfire;
            else
                w_tf = weight_swing;
            end
                
            score = score + w_tf * w_num_files( k ) * percentage_tests( k );
        end
        all_scores( Idx ) = score;
        %Zs( i, j ) = all_scores( Idx );
        Zs( i, j ) = score;
    end
end

[c, index_Best_Result] = max( all_scores );

% index_i = floor( index_Best_Result / nIs );
% index_j = index_Best_Result - index_i * nIs;
% c
% Zs( index_i, index_j )
index_gy_impact_threshold = 0;
index_threshold_interval = 0;
inner_loop_2_broken = false;
found = false;
for i = 1 : 1 : nIs
    for j = 1 : 1 : nJs
        Idx = ( i - 1 ) * nJs + j;
        if( Idx == index_Best_Result )
            index_gy_impact_threshold = i;
            index_threshold_interval = j;
            fprintf( 'Found it!\n' );
            inner_loop_2_broken = true;
            break;
        end
    end
    if( true == inner_loop_2_broken )
        found = true;
        break;
    end
end

Linear_Index_Best_Result = ( index_gy_impact_threshold - 1 ) * nJs + index_threshold_interval;
Corresponding_Percentage = all_records( Linear_Index_Best_Result, : );

GY_IMPACT_THRESHOLD = 5000;
EXCEED_THRESHOLD_INTERVAL = 3;

index_gy_john = find( gy_impact_threshold == GY_IMPACT_THRESHOLD );
index_impact_john = find( threshold_interval == EXCEED_THRESHOLD_INTERVAL );
Linear_Index_John = ( index_gy_john - 1 ) * nJs + index_impact_john;
Corresponding_Percentage_john = all_records( Linear_Index_John, : );

fprintf( 'Score Julien = %.2f - Score John = %.2f\n',...
    all_scores( Linear_Index_Best_Result ),...
    all_scores( Linear_Index_John ) );

str_title = 'Empty';
if( true == found )
    str_title = sprintf( 'GY IMPACT THRESHOLD = %i - EXCEED THRESHOLD INTERVAL = %i',...
        gy_impact_threshold( index_gy_impact_threshold ), threshold_interval( index_threshold_interval ) );
end

X = gy_impact_threshold; % n = 17
Y = threshold_interval; % m = 39
Z = Zs';

hFig = figure( 1 );
set( hFig, 'Color', 'White' );
hold on;
surf(X,Y,Z);
grid on;

xlabel( 'GY IMPACT THRESHOLD' );
ylabel( 'EXCEED THRESHOLD INTERVAL' );
zlabel( 'Weigthed Discrimination Score' );
title( str_title );