function cell_perimeter = calc_cell_perimeters(C, V)
%{
This function calculates the perimeter (in microns) of each cell at each time point.

Input:
C - a cell array containing information about cells at each time point. 
V - a cell array containing information about the vertices at each time point.

Output:
cell_perimeter - a numeric matrix with the perimeters of the cells.
    The size is [n_time_points, n_cells], where cell_perimeter(t, c) stores 
    the perimeter of cell "c" at time point "t".

This function uses 'parfor' for parallel computation. Replace 'parfor' 
with 'for' if parallelization is not needed.
%}

    % Initialization
    n_cells = max(cellfun(@length, C));  % Max number of cells in any frame
    n_time_points = length(C);           % Total number of time points

    % Preallocate the output matrix
    cell_perimeter = nan(n_time_points, n_cells, 'single'); 

    % Pad C with empty structures for consistency
    for t = 1:n_time_points
        C{t}(end+1:n_cells) = struct('vertices', [], 'edges', [], 'cells', [], 'centroid', []);
    end

    % Parallel loop over time points
    parfor t = 1:n_time_points
        for i = 1:n_cells
            if i > length(C{t}) || isempty(C{t}(i).vertices)
                continue;  % Skip if there are no vertices
            end

            % Get the vertices of the current cell
            curr_cell_vertices = C{t}(i).vertices;
            curr_coords = cell2mat({V{t}(curr_cell_vertices).coords}');

            % Calculate perimeter by summing distances between consecutive vertices
            curr_coords(end+1, :) = curr_coords(1, :);  % Close the polygon
            diffs = diff(curr_coords);  % Differences between consecutive points
            perimeter = sum(sqrt(sum(diffs.^2, 2)));  % Euclidean distance

            % Store the calculated perimeter
            cell_perimeter(t, i) = perimeter;
        end
    end
end
