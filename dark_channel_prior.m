function [D,U] = dark_channel_prior(I,patch_size,thresh,optim)
    % Assume that the dark channel isn't explicitly needed
    if ~exist('optim','var')
        optim = true;
    end

    % Determine the original image dimensions
    h = size(I,1);
    w = size(I,2);

    % Find the darkest pixel across all image channels
    I1 = min(I,[],3);

    % Pad the image 
    if mod(patch_size,2) == 0
        pad = repmat(patch_size / 2,[1 2]) - 1;
        I_padded = padarray(padarray(I1,pad,nan,'pre'),pad+1,nan,'post');
    else
        pad = repmat((patch_size - 1) / 2,[1 2]);
        I_padded = padarray(I1,pad,nan);
    end

    % Find the darkest pixel in each sliding patch
    if optim
        [~,ind] = min(im2col(I_padded,[patch_size patch_size],'sliding'));
        D = [];
    else
        [D,ind] = min(im2col(I_padded,[patch_size patch_size],'sliding'));
        D = reshape(D,size(I1));
    end

    % Locate the dark pixel in the image
    [dr,dc] = ind2sub([patch_size patch_size],ind);
    [r,c] = ind2sub(size(I1),1:numel(ind));
    r = r + dr - pad(1) - 1;
    c = c + dc - pad(1) - 1;
    
    % Generate a mask for the dark pixels
    dark_mask = false(h,w);
    dark_mask(sub2ind([h w],r,c)) = true;

    % Apply the threshold to the dark pixels
    T = I .* (I .^ 2 >= thresh);
    U = I .* ~dark_mask + T .* dark_mask;
end