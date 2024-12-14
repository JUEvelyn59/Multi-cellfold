function R_t = calculate_junction_loss_2(C, n_time_points)
%{
This function calculates the loss of cell-cell junctions at each time point using parallel processing.

Input:
C - Cell array where C{t}(c) contains the neighbors of cell "c" at time "t".
n_time_points - Number of time points.

Output:
R_t - A cell array where R_t{t} contains the lost cell-cell junctions at time "t".
%}

    % Initialize output
    R_t = cell(n_time_points - 1, 1);

    % Parallel loop through each time point
    parfor t = 1:n_time_points - 1
        % Get neighboring pairs at time t
        E_cc_t = get_cell_neighbors(C{t});
        
        % Get neighboring pairs at time t+1
        E_cc_t1 = get_cell_neighbors(C{t + 1});
        
        % Compute the lost junctions
        R_t{t} = setdiff(E_cc_t, E_cc_t1, 'rows');
    end
end

function E_cc = get_cell_neighbors(C_t)
%{
This helper function computes the set of cell-cell neighboring pairs for a given time point.

Input:
C_t - Struct array containing cell data at a single time point.

Output:
E_cc - A matrix where each row is a pair of neighboring cell indices.
%}

    E_cc = []; % Initialize list of cell-cell pairs
    
    % Loop through each cell
    for c = 1:length(C_t)
        neighbors = C_t(c).cells;
        
        % Create pairs (sorted order to avoid duplicates)
        if ~isempty(neighbors)
            pairs = sortrows([repmat(c, length(neighbors), 1), neighbors(:)], 2);
            E_cc = [E_cc; pairs];
        end
    end
    
    % Remove duplicate pairs
    E_cc = unique(sort(E_cc, 2), 'rows');
end
