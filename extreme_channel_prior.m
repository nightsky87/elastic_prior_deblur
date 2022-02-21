function [E,U] = extreme_channel_prior(I,patch_size,thresh,optim)
    % Assume that the dark channel isn't explicitly needed
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
    if mod(patch_size,2) == 0
        pad = repmat(patch_size / 2,[1 2]) - 1;
        I_padded_dark = padarray(padarray(Id,pad,nan,'pre'),pad+1,nan,'post');
        I_padded_bright = padarray(padarray(Ib,pad,nan,'pre'),pad+1,nan,'post');
    else
        pad = repmat((patch_size - 1) / 2,[1 2]);
        I_padded_dark = padarray(Id,pad,nan);
        I_padded_bright = padarray(Ib,pad,nan);
    end

    % Find the darkest pixel in each sliding patch
    if optim
        [~,d_ind] = min(im2col(I_padded_dark,[patch_size patch_size],'sliding'));
        [~,b_ind] = max(im2col(I_padded_bright,[patch_size patch_size],'sliding'));
        E = [];
    else
        [D,d_ind] = min(im2col(I_padded_dark,[patch_size patch_size],'sliding'));
        [B,b_ind] = max(im2col(I_padded_bright,[patch_size patch_size],'sliding'));
        D = reshape(D,size(Id));
        B = reshape(B,size(Ib));
        E = cat(3,D,B);
    end

    % Locate the dark pixels in the image
    [dr,dc] = ind2sub([patch_size patch_size],d_ind);
    [r,c] = ind2sub(size(Id),1:numel(d_ind));
    r = r + dr - pad(1) - 1;
    c = c + dc - pad(1) - 1;
    
    % Generate a mask for the dark pixels
    dark_mask = false(h,w);
    dark_mask(sub2ind([h w],r,c)) = true;

    % Locate the bright pixels in the image
    [dr,dc] = ind2sub([patch_size patch_size],b_ind);
    [r,c] = ind2sub(size(Ib),1:numel(b_ind));
    r = r + dr - pad(1) - 1;
    c = c + dc - pad(1) - 1;
    
    % Generate a mask for the dark pixels
    bright_mask = false(h,w);
    bright_mask(sub2ind([h w],r,c)) = true;

    % Ensure that the masks don't overlap. The dark channel takes priority
    % in the event that this does happen.
    bright_mask = bright_mask & ~dark_mask;

    % Apply the threshold to the dark pixels
    Dt = I .* (I .^ 2 >= thresh);
    Bt = 1 - (1 - I) .* ((1 - I) .^ 2 >= thresh);
    U = I .* (~dark_mask & ~bright_mask) + Dt .* dark_mask + Bt .* bright_mask;
end