function edge_features = save_edge_features(E, edge_lengths)
    % Initialize edge features as a cell array
    num_timepoints = numel(E);
    edge_features = cell(num_timepoints, 1);

    % Preprocess edge_lengths into a structure for faster lookups
    edge_length_map = containers.Map;
    for i = 1:size(edge_lengths, 1)
        key = sprintf('%d_%d_%d_%d', edge_lengths(i,1), edge_lengths(i,2), edge_lengths(i,3), edge_lengths(i,4));
        edge_length_map(key) = edge_lengths(i, 5);
    end

    % Loop over time points
    parfor t = 1:num_timepoints
        num_edges = numel(E{t});
        local_edge_features = zeros(num_edges, 5);  % Preallocate for efficiency
        edge_count = 0;

        for edge_idx = 1:num_edges
            cells = E{t}(edge_idx).cells;
            if numel(cells) == 2
                cell1 = cells(1);
                cell2 = cells(2);

                % Create a key for the current edge
                key = sprintf('%d_%d_%d_%d', t, cell1, cell2, edge_idx);

                % Retrieve edge length if available
                if isKey(edge_length_map, key)
                    length = edge_length_map(key);
                else
                    length = 0;
                end

                % Compute weighted length and delta
                if t == 1
                    weighted_length = exp(-length);
                    weighted_delta_length = 0;
                else
                    % Create key for the previous time point
                    prev_key = sprintf('%d_%d_%d_%d', t-1, cell1, cell2, edge_idx);
                    if isKey(edge_length_map, prev_key)
                        prev_length = edge_length_map(prev_key);
                    else
                        prev_length = 0;
                    end
                    weighted_length = exp(-length);
                    weighted_delta_length = weighted_length - exp(-prev_length);
                end

                % Store edge data
                edge_count = edge_count + 1;
                local_edge_features(edge_count, :) = [cell1, cell2, edge_idx, weighted_length, weighted_delta_length];
            end
        end

        % Trim unused rows
        edge_features{t} = local_edge_features(1:edge_count, :);
    end
end
