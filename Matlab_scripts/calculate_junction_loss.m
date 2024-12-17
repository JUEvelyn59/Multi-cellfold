function junction_loss = calculate_junction_loss(E)
    % This function calculates the loss of cell-cell junctions at each time point t,
    % based on the difference between the cell-cell edges at time t and time t+1.
    %
    % Input:
    % E - cell array containing edge data structure across time points
    %
    % Output:
    % junction_loss - matrix containing [time, edge index, loss or not]

    num_timepoints = numel(E);
    temp_junction_loss = cell(num_timepoints - 1, 1); % Temporary storage for losses at each time point

    % Parallel loop over time points up to the second-to-last time point
    parfor t = 1:(num_timepoints - 1)
        current_edges = [];
        next_edges = [];

        % Collect cell pairs (edges) for the current time point t
        for edge_idx = 1:numel(E{t})
            cells = E{t}(edge_idx).cells;
            if numel(cells) == 2 && all(cells > 0) % Ensure valid cell connection
                current_edges = [current_edges; cells(1), cells(2)];
            end
        end

        % Collect cell pairs (edges) for the next time point t+1
        for edge_idx = 1:numel(E{t+1})
            cells = E{t+1}(edge_idx).cells;
            if numel(cells) == 2 && all(cells > 0) % Ensure valid cell connection
                next_edges = [next_edges; cells(1), cells(2)];
            end
        end

        % Find lost edges (present in current_edges but not in next_edges)
        lost_edges = setdiff(current_edges, next_edges, 'rows');

        % Record loss for each edge in the current time point
        time_loss_data = zeros(size(current_edges, 1), 3);
        for i = 1:size(current_edges, 1)
            % Check if the current cell pair in current_edges was lost
            loss = ismember(current_edges(i, :), lost_edges, 'rows');
            time_loss_data(i, :) = [t, i, loss];
        end

        temp_junction_loss{t} = time_loss_data;
    end

    % Concatenate results from all time points (except the last time point)
    junction_loss = vertcat(temp_junction_loss{:});
end
