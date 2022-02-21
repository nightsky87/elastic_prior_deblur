function [D,U] = patch_min_prior(I,patch_size,thresh,optim)
    % Assume that the dark channel isn't explicitly needed
    if ~exist('optim','var')
        optim = true;
    end

    % Determine the original image dimensions
    h = size(I,1);
    w = size(I,2);

    % Find the darkest pixel across all image channels
    Id = min(I,[],3);

    % Pad the image
    padded_dim = ceil([h w] / patch_size) * patch_size;
    pad = padded_dim - [h w];
    I_padded_dark = padarray(Id,pad,nan,'post');

    % Find the darkest pixel in each sliding patch
    if optim
        [~,d_ind] = min(im2col(I_padded_dark,[patch_size patch_size],'distinct'));
        D = [];
    else
        [D,d_ind] = min(im2col(I_padded_dark,[patch_size patch_size],'distinct'));
        D = reshape(D,padded_dim/patch_size);
    end

    % Locate the dark pixels in the image
    dark_mask = false(patch_size^2,length(d_ind));
    dark_mask(sub2ind(size(dark_mask),d_ind,1:length(d_ind))) = true;
    dark_mask = col2im(dark_mask,[patch_size patch_size],size(Id),'distinct');

    % Apply the threshold to the dark pixels
    Dt = I .* (I .^ 2 >= thresh);
    U = I .* ~dark_mask + Dt .* dark_mask;
end