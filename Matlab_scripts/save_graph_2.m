function save_graph_2(node_features, edge_features, junction_loss, type)
    % Combine node features, edge features, and junction loss into a graph data structure
    num_timepoints = numel(node_features);
    graph_data = cell(num_timepoints - 1, 1);  % Only save up to second-to-last time point

    % Combine features for each time point up to the second-to-last
    for t = 1:(num_timepoints - 1)
        graph_data{t}.time = t;
        graph_data{t}.node_features = node_features{t};
        graph_data{t}.edge_features = edge_features{t};
        graph_data{t}.junction_loss = junction_loss{t};

    % Save the graph data
    filename = sprintf('%s_graph_data.mat', type);
    save(filename, 'graph_data', '-v7.3');
end