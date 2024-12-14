function node_features = save_node_features(C, cell_areas, perimeters)
    % Initialize node features as a cell array
    num_timepoints = numel(C);
    node_features = cell(num_timepoints, 1);

    % Loop over time points
    parfor t = 1:num_timepoints
        local_node_features = [];
        for cell_idx = 1:numel(C{t})
            % Handle NaN values
            area = cell_areas(t, cell_idx);
            perimeter = perimeters(t, cell_idx);

            if isnan(area)
                area = 0;
            end

            if isnan(perimeter)
                perimeter = 0;
            end

            if t == 1
                delta_area = 0;
                delta_perimeter = 0;
            else
                prev_area = cell_areas(t-1, cell_idx);
                if isnan(prev_area)
                    prev_area = 0;
                end
                delta_area = area - prev_area;

                prev_perimeter = perimeters(t-1, cell_idx);
                if isnan(prev_perimeter)
                    prev_perimeter = 0;
                end
                delta_perimeter = perimeter - prev_perimeter;
            end

            % Store node features
            node_data = [cell_idx, area, delta_area, perimeter, delta_perimeter];
            local_node_features = [local_node_features; node_data];
        end
        % Assign the collected features for the current time point
        node_features{t} = local_node_features;
    end
end
