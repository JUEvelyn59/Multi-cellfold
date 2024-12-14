%% Set Paths to Data Directories
baseDir_1620 = 'C:/Users/JU/Downloads/Multi-fold/Data/Deconstructing Gastrulation - Data/Img_1620 (intercalations)/';
baseDir_1830 = 'C:/Users/JU/Downloads/Multi-fold/Data/Deconstructing Gastrulation - Data/Img_1830 (divisions)/';
embryo1 = fullfile(baseDir_1620, 'Mesh');
embryo2 = fullfile(baseDir_1830, 'Mesh');

%% Load Cell and Vertex Data
disp('Loading cell and vertex data...');
[C_1, E_1, V_1] = DG_load_segmented_embryo(embryo1);  % Load mesh data from embryo1
[C_2, E_2, V_2] = DG_load_segmented_embryo(embryo2);  % Load mesh data from embryo2
%% Calculate Cell Areas
disp('Calculating cell areas...');
areas_1 = DG_calc_cell_areas(C_1, V_1);
areas_2 = DG_calc_cell_areas(C_2, V_2);
%% Calculate Cell Perimeters 
disp('Calculating cell perimeters...')
perimeters_1 = calc_cell_perimeters(C_1, V_1);
perimeters_2 = calc_cell_perimeters(C_2, V_2);
%% Edge Attribute
disp('Calculating edge attribute...')
% Calculate edge lengths at each time point
edge_lengths_1 = calculate_edge_lengths(C_1, E_1, V_1);
edge_lengths_2 = calculate_edge_lengths(C_2, E_2, V_2);

%% Loss of cell-cell junction
disp('Calculating loss of cell-cell junction...')
junction_loss_1 = calculate_junction_loss_2(C_1, 198);
junction_loss_2 = calculate_junction_loss_2(C_2, 60);

%junction_loss_22 = calculate_junction_loss_2(C_2, 60);
%% Node features
disp('Save node features')
node_features_1 = save_node_features(C_1, areas_1, perimeters_1);
node_features_2 = save_node_features(C_2, areas_2, perimeters_2);

%% Edge features
disp('Save edge features')
edge_features_1 = save_edge_features(E_1, edge_lengths_1);
edge_features_2 = save_edge_features(E_2, edge_lengths_2);

%% Construct Graph 
disp('Constructing Graph...')
% Construct the graph representation
save_graph_2(node_features_1, edge_features_1, junction_loss_1, 'train');
save_graph_2(node_features_2, edge_features_2, junction_loss_2, 'test');
