function cellEdgeDistances = calculate_edge_lengths(C, E, V)
    % This function calculates the distances between cells based on the edges
    % that connect them at each time point, and includes the edge index.
    %
    % Input:
    % C - cell array containing cell data structure across time points
    % E - cell array containing edge data structure across time points
    % V - cell array containing vertex data structure across time points
    %
    % Output:
    % cellEdgeDistances - matrix containing time, cell1, cell2, edge index, and distance information

    % Initialize an array to store the distance information
    num_time_points = length(C);

    % Initialize a cell array to temporarily store distances for each time point
    tempDistances = cell(num_time_points, 1);

    % Use a parallel loop to process each time point independently
    parfor t = 1:num_time_points
        % Get the number of edges at this time point
        num_edges = length(E{t});
        time_distances = zeros(num_edges, 5);  % Preallocate for each time point
        idx = 1; % Local index for filling in time_distances

        % Loop through each edge to calculate distances between connected cells
        for e = 1:num_edges
            % Get the indices of the two cells connected by this edge
            cells = E{t}(e).cells;

            % If both cells are valid (connected by this edge)
            if length(cells) == 2 && all(cells > 0)
                cell1 = cells(1);
                cell2 = cells(2);

                % Get the vertices for this edge
                vertices = E{t}(e).vertices;

                % Ensure the edge has exactly two vertices
                if length(vertices) == 2
                    vertex1 = vertices(1);
                    vertex2 = vertices(2);

                    % Retrieve the coordinates of the two vertices from V
                    coords1 = V{t}(vertex1).coords;
                    coords2 = V{t}(vertex2).coords;

                    % Calculate the Euclidean distance between the vertices
                    distance = sqrt(sum((coords1 - coords2) .^ 2));

                    % Store the information in the local array for this time point
                    time_distances(idx, :) = [t, cell1, cell2, e, distance]; % Include edge index (e)
                    idx = idx + 1;
                end
            end
        end

        % Trim unused rows and assign to temporary storage
        tempDistances{t} = time_distances(1:idx-1, :);
    end

    % Concatenate results from all time points into the main array
    cellEdgeDistances = vertcat(tempDistances{:});
end
