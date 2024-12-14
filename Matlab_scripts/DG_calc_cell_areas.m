function cell_area = DG_calc_cell_areas(C, V)

%{
This function calculates the area (in microns^2) of each cell at each time point.

Input:
C - a cell array that contains all the info about the cells. The centroid of cell "c" at time point "t" will be written in: "C{t}(c).centroid".
V - a cell array that contains all the info about the vertices.

Output:
cell_area - a numeric matrix with the areas of the cells. size(cell_area) is equal to: [total time points in movie, total cells in mesh].
    The area of cell "c" at time point "t" is stored in cell_area(t,c).

Note that this function uses "parfor" to parallelize the calculation of areas. If you prefer the (much slower...) option of only a single worker,
    simply replace the word "parfor" with "for", and press "Ctrl + S" to save the updated script.
%}

% calculating cell areas:
n_cells = max(cellfun(@length, C));
n_time_points = length(C);

cell_area = nan(n_time_points, n_cells, 'single');

for t = 1 : n_time_points
    C{t}(end+1:n_cells) = struct('vertices', [], 'edges', [], 'cells', [], 'centroid', []);
end

parfor t = 1 : n_time_points
    
    for i = 1 : n_cells
        if i > length(C{t})
            break;
        end
        curr_cell_vertices = C{t}(i).vertices;
        if isempty(curr_cell_vertices)
            continue;
        end
        curr_coords = cell2mat({V{t}(C{t}(i).vertices).coords}');
        [~, score] = pca(curr_coords);
        if size(score,2) < 2
            continue;
        end
        score(end+1,:) = score(1,:); %#ok<AGROW>
        cell_area(t,i) = polyarea(score(:,1), score(:,2));
    end
    
end
