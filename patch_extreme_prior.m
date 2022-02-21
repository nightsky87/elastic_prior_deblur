function [E,U] = patch_extreme_prior(I,patch_size,thresh,optim)
    % Assume that the extreme channel isn't explicitly needed
    if ~exist('optim','var')
        optim = true;
    end

    % Determine the original image dimensions
    h = size(I,1);
    w = size(I,2);

    % Find the darkest pixel across all image channels
    Id = min(I,[],3);
    Ib = max(I,[],3);

    % Pad the image
    padded_dim = ceil([h w] / patch_size) * patch_size;
    pad = padded_dim - [h w];
    I_padded_dark = padarray(Id,pad,nan,'post');
    I_padded_bright = padarray(Ib,pad,nan,'post');

    % Find the darkest pixel in each sliding patch
    if optim
        [~,d_ind] = min(im2col(I_padded_dark,[patch_size patch_size],'distinct'));
        [~,b_ind] = max(im2col(I_padded_bright,[patch_size patch_size],'distinct'));
        E = [];
    else
        [D,d_ind] = min(im2col(I_padded_dark,[patch_size patch_size],'distinct'));
        [B,b_ind] = max(im2col(I_padded_bright,[patch_size patch_size],'distinct'));
        D = reshape(D,padded_dim/patch_size);
        B = reshape(B,padded_dim/patch_size);
        E = cat(3,D,B);
    end

    % Locate the dark pixels in the image
    dark_mask = false(patch_size^2,length(d_ind));
    dark_mask(sub2ind(size(dark_mask),d_ind,1:length(d_ind))) = true;
    dark_mask = col2im(dark_mask,[patch_size patch_size],size(Id),'distinct');

    % Locate the bright pixels in the image
    bright_mask = false(patch_size^2,length(b_ind));
    bright_mask(sub2ind(size(bright_mask),b_ind,1:length(b_ind))) = true;
    bright_mask = col2im(bright_mask,[patch_size patch_size],size(Ib),'distinct');

    % Ensure that the masks don't overlap. The dark channel takes priority
    % in the event that this does happen.
    bright_mask = bright_mask & ~dark_mask;

    % Apply the threshold to the dark pixels
    Dt = I .* (I .^ 2 >= thresh);
    Bt = 1 - (1 - I) .* ((1 - I) .^ 2 >= thresh);
    U = I .* (~dark_mask & ~bright_mask) + Dt .* dark_mask + Bt .* bright_mask;
end