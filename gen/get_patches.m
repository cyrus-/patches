%
% Generates patches from a directory of images
% and calculates saliency of each patch.
%
% Author: Cyrus Omar (cyrus.omar@gmail.com)
% Date: June 6, 2011
%

% directories
base_path = '../';
data_path = [base_path 'data/'];
stim_path = [data_path 'ALLSTIMULI/'];
extension = '.jpeg'; 
extension_length = length(extension);
saliency_map_path = [base_path 'data/ALLFIXATIONMAPS/'];

% patches are drawn uniformly from this range
min_patchSize = 25;
max_patchSize = 125;
span_patchSize = max_patchSize - min_patchSize;

% 
num_patches_per_file = 2;

% initialize empty metadata array
patchData = struct(... 
    ... %'img', {}, ...
    'img_name', {}, ...
    'img_path', {}, ...
    'img_index', {}, ...
    'base_name', {}, ...
    ... %'saliency_map', {}, ...
    'mean_saliency', [], ...
    'sum_saliency', [], ...
    'median_saliency', [], ...
    'std_saliency', [], ...
    'patches', {} ...
);
outfile = [data_path 'patchData.mat'];

files = dir([stim_path '*' extension]);
for i=1:length(files)
    % load image
    file = files(i);
    img_name = file.name;
    img_path = [stim_path img_name];
    img = imread(img_path);
    
    % load saliency map into global 'saliencyMapBlur'
    base_name = img_name(1:length(img_name) - extension_length);
    load([saliency_map_path base_name '.mat']);
    saliency_map = saliencyMapBlur;
    img_mean_saliency = mean(saliency_map(:));
    img_sum_saliency = sum(saliency_map(:));
    img_median_saliency = median(saliency_map(:));
    img_std_saliency = std(double(saliency_map(:)));
     
    % initialize empty struct array for patches
    patches = struct(...
        'patch_size', [], ...
        'start_x', [], ...
        'end_x', [], ...
        'x_range', {}, ...
        'start_y', [], ...
        'end_y', [], ...
        'y_range', {}, ...
        'patch', {}, ...
        'img_index', [], ...
        'patch_index', [], ...
        'mean_saliency', [], ...
        'sum_saliency', [] ...
    );

    % generate patches
    for j=1:num_patches_per_file
        % generate a random patch size in [min_patchSize, max_patchSize]
        patch_size = min_patchSize + unidrnd(span_patchSize + 1) - 1;

        % generate patch
        [patch, patch_info] = gen_patch(img, patch_size);
        
        % figure out saliency information
        patch_saliency = saliency_map(patch_info.y_range, ...
            patch_info.x_range);
        mean_saliency = mean(patch_saliency(:));
        sum_saliency = sum(patch_saliency(:));
        
        % add additional metadata to patch_info
        patch_info.patch = patch;
        patch_info.img_index = i;
        patch_info.patch_index = j;
        patch_info.mean_saliency = mean_saliency;
        patch_info.sum_saliency = sum_saliency;
        patches(j) = patch_info;
    end
    
    % create entry in metadata struct array
    patchData(i) = struct(...
        ... %'img', img, ...
        'img_name', img_name, ...
        'img_path', img_path, ...
        'img_index', i, ...
        'base_name', base_name, ...
        ... %'saliency_map', saliency_map, ...,
        'mean_saliency', img_mean_saliency, ...
        'sum_saliency', img_sum_saliency, ...
        'median_saliency', img_median_saliency, ...
        'std_saliency', img_std_saliency, ...
        'patches', patches ...
    );
    
    % display index in loop
    i
end

% save metadata to outfile
save(outfile, 'patchData');
