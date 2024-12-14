function [C, E, V] = DG_load_segmented_embryo(dirname, time_points)

%{
This script loads the mesh representing the embryo after cell segmentation and tracking.

Input:
dirname - path to the directory with all the files of the mesh.
time_points - an array of integers indicating what frames in the movie to load. The value should be between 1 and the total number of frames.
    If the length of the movie is unknown, use [] to load the entire movie.

Output:
C - a cell array that contains all the info about the cells.
E - a cell array that contains all the info about the edges (i.e. cell-cell interfaces).
V - a cell array that contains all the info about the vertices.

For detailed information about the structure of C, E, and V, see documentation at the bottom of the function "DG_main_script".
%}

loaded_fields = { ...
    'C_cells', 'C_edges', 'C_vertices', ...
    'E_cells', 'E_edges', 'E_vertices', ...
    'V_cells', 'V_coords', 'V_edges', 'V_vertices'};

if ~exist('time_points', 'var')
    time_points = [];
end

if isempty(time_points)
    n_time_points = inf;
else
    n_time_points = max(time_points);
end

% calculating how many cells, edges and vertices we have in total so we could allocate the required memory:
curr_filename = fullfile(dirname, 'C_edges.mat');
I = getfield(load(curr_filename), 'C_edges');
if isinf(n_time_points)
    n_time_points = double(max(I(:,1)));
end
to_take = ismember(I(:,1), time_points);
I = I(to_take,:);
rp = regionprops(I(:,1), 'PixelIdxList');
rp = {rp.PixelIdxList}';
is_used_idx = ~cellfun(@isempty, rp);
n_cells = zeros(n_time_points,1);
n_cells(is_used_idx) = cellfun(@(x) I(x(end),2), rp(is_used_idx));
C = arrayfun(@(x) repmat(struct('vertices', [], 'edges', [], 'cells', [], 'centroid', []), x, 1), n_cells, 'UniformOutput', false);

curr_filename = fullfile(dirname, 'E_vertices.mat');
I = getfield(load(curr_filename), 'E_vertices');
to_take = ismember(I(:,1), time_points);
I = I(to_take,:);
rp = regionprops(I(:,1), 'PixelIdxList');
rp = {rp.PixelIdxList}';
is_used_idx = ~cellfun(@isempty, rp);
n_edges = zeros(n_time_points,1);
n_edges(is_used_idx) = cellfun(@(x) I(x(end),2), rp(is_used_idx));
E = arrayfun(@(x) repmat(struct('pixels', [], 'vertices', [], 'edges', [], 'cells', []), x, 1), n_edges, 'UniformOutput', false);

curr_filename = fullfile(dirname, 'V_coords.mat');
I = getfield(load(curr_filename), 'V_coords');
to_take = ismember(I(:,1), time_points);
I = I(to_take,:);
rp = regionprops(I(:,1), 'PixelIdxList');
rp = {rp.PixelIdxList}';
is_used_idx = ~cellfun(@isempty, rp);
n_vertices = zeros(n_time_points,1);
n_vertices(is_used_idx) = cellfun(@(x) I(x(end),2), rp(is_used_idx));
V = arrayfun(@(x) repmat(struct('coords', [], 'vertices', [], 'edges', [], 'cells', []), x, 1), n_vertices, 'UniformOutput', false);

disp('Loading mesh fields...');
for i = 1 : length(loaded_fields)
    
    disp(['    ', num2str(i), '/', num2str(length(loaded_fields)), ' ', loaded_fields{i}])
    
    curr_filename = fullfile(dirname, [loaded_fields{i}, '.mat']);
    I = getfield(load(curr_filename), loaded_fields{i});
    
    if ~isempty(time_points)
        to_take = ismember(I(:,1), time_points);
        I = I(to_take,:);
    end
    
    % extracting the ranges of the time points:
    time_ranges = regionprops(I(:,1), 'PixelIdxList');
    time_ranges = {time_ranges.PixelIdxList}';
    is_used_time_range = ~cellfun(@isempty, time_ranges);
    time_ranges(~is_used_time_range) = {[nan; nan]};
    time_ranges = cell2mat(cellfun(@(x) x([1,end])', time_ranges, 'UniformOutput', false));
    
    % extracting the ranges of the objects:
    object_ranges = cell(size(time_ranges,1),1);
    for j = 1 : size(time_ranges,1)
        if isnan(time_ranges(j,1)), continue; end
        obj_idx = I(time_ranges(j,1):time_ranges(j,2),2);
        last_idx = [find(diff(obj_idx)); length(obj_idx)];
        first_idx = [1; last_idx(1:end-1)+1];
        object_ranges{j} = nan(obj_idx(end),2);
        obj_idx = obj_idx(first_idx);
        object_ranges{j}(obj_idx,:) = [first_idx, last_idx] + time_ranges(j,1) - 1;
    end
    
    switch loaded_fields{i}
        
        case 'C_cells'
            for t = 1 : length(C)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        C{t}(o).cells = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'C_edges'
            for t = 1 : length(C)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        C{t}(o).edges = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'C_vertices'
            for t = 1 : length(C)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        C{t}(o).vertices = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'E_cells'
            for t = 1 : length(E)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        E{t}(o).cells = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3:4);
                    end
                end
            end
            
        case 'E_edges'
            for t = 1 : length(E)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        E{t}(o).edges = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'E_pixels'
            keyboard;
            for t = 1 : length(E)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        E{t}(o).pixels = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3:4);
                    end
                end
            end
            
        case 'E_vertices'
            for t = 1 : length(E)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        E{t}(o).vertices = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'V_cells'
            for t = 1 : length(V)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        V{t}(o).cells = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'V_coords'
            for t = 1 : length(V)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        V{t}(o).coords = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3:5);
                    end
                end
            end
            
        case 'V_edges'
            for t = 1 : length(V)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        V{t}(o).edges = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
        case 'V_vertices'
            for t = 1 : length(V)
                if isnan(time_ranges(t,1)), continue; end
                for o = 1 : size(object_ranges{t},1)
                    if ~isnan(object_ranges{t}(o,1))
                        V{t}(o).vertices = I(object_ranges{t}(o,1) : object_ranges{t}(o,2),3)';
                    end
                end
            end
            
    end
    
end
fprintf(newline);

if ~exist('C', 'var')
    C = [];
else
    C = cellfun(@(x) x(:), C, 'UniformOutput', false);
end
if ~exist('E', 'var')
    E = [];
else
    E = cellfun(@(x) x(:), E, 'UniformOutput', false);
end
if ~exist('V', 'var')
    V = [];
else
    V = cellfun(@(x) x(:), V, 'UniformOutput', false);
end


