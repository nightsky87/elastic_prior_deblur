function [P,U] = intensity_prior(I,patch_size,thresh,thresh_type,method)
    if ~exist('method','var')
        method = 'eecp';
    end

    if strcmpi(method,'dcp')
        [P,U] = dark_channel_prior(I,patch_size,thresh,thresh_type);
    elseif strcmpi(method,'ecp')
        [P,U] = extreme_channel_prior(I,patch_size,thresh,thresh_type);
    elseif strcmpi(method,'pmp')
        [P,U] = patch_min_prior(I,patch_size,thresh,thresh_type);
    elseif strcmpi(method,'pep')
        [P,U] = patch_extreme_prior(I,patch_size,thresh,thresh_type);
    elseif strcmpi(method,'edcp')
        [P,U] = elastic_dark_channel_prior(I,thresh,thresh_type);
    elseif strcmpi(method,'eecp')
        [P,U] = elastic_extreme_channel_prior(I,thresh,thresh_type);
    end
end