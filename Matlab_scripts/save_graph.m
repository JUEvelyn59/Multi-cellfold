function save_graph(node_features, edge_features, junction_loss, type)
    % Combine node features, edge features, and junction loss into a graph data structure
    num_timepoints = numel(node_features);
    graph_data = cell(num_timepoints - 1, 1);  % Only save up to second-to-last time point

    % Combine features for each time point up to the second-to-last
    for t = 1:(num_timepoints - 1)
        graph_data{t}.time = t;
        graph_data{t}.node_features = node_features{t};
        graph_data{t}.edge_features = edge_features{t};
        
        % Extract the rows from junction_loss that correspond to the current time point
        time_point_rows = junction_loss(junction_loss(:, 1) == t, :);
        
        % Add junction loss data for the current time point
        if ~isempty(time_point_rows)
            graph_data{t}.junction_loss = time_point_rows(:, 2:end);  % Exclude the time column
        else
            graph_data{t}.junction_loss = []; % Handle missing or insufficient data
        end
    end

    % Save the graph data
    filename = sprintf('%s_graph_data.mat', type);
    save(filename, 'graph_data', '-v7.3');
end