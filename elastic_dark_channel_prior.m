function [D, U] = elastic_dark_channel_prior(I, thresh, optim)
    % Assume that the dark channel isn't explicitly needed
    if ~exist('optim','var')
        optim = true;
    end

    % Determine the size of the input image
    [M, N, P] = size(I);

    % If the image has multiple channels, find the minimum across all the
    % channels
    Id = min(I, [], 3);

    % Calculate the window size so that we end up with between 25 to 100
    % dark pixel references
    window_size = 2 ^ floor(log2(numel(Id)/100)/2);
    window_elem = window_size ^ 2;
    M_padded = ceil(M / window_size) * window_size;
    N_padded = ceil(N / window_size) * window_size;

    % Pad the image
    pad_size = [M_padded N_padded] - [M N];
    I_padded = padarray(Id,pad_size,Inf,'post');

    % Find the minimum of each window
    [W_min,W_ind] = min(im2col(I_padded,[window_size window_size],'distinct'),[],1);

    % Locate the darkest quartile of pixels
    mask = W_min <= prctile(W_min,25);

    % Locate the corresponding dark pixels in the full-sized image
    dark_mask = false(window_elem,M_padded*N_padded/window_elem);
    ind = sub2ind([window_elem nnz(mask)],W_ind(mask),1:nnz(mask));
    T = false(window_elem,nnz(mask));
    T(ind) = true;
    dark_mask(:,mask) = T;
    dark_mask = col2im(dark_mask,[window_size window_size],size(I),'distinct');

    % In practise, it isn't necessary to explicitly compute the dark channel
    if optim
        % For optimisation, we can directly threshold the darkest pixels
        D = [];
        Dt = I .* (I .^ 2 >= thresh);
        U = I .* ~dark_mask + Dt .* dark_mask;
    else
        % Translate the mask to coordinates
        [x,y] = meshgrid(1:N,1:M);
        dark_x = x(dark_mask);
        dark_y = y(dark_mask);
    
        % Find the nearest dark pixel for each pixel
        [~,ind] = min((x(:) - dark_x') .^ 2 + (y(:) - dark_y') .^ 2,[],2);
    
        % Calculate the dark channel
        dark = W_min(mask);
        D = reshape(dark(ind),size(Id));

        % Map the dark channels back to the latent image
        Dt = I .* (I .^ 2 >= thresh);
        U = I .* ~dark_mask + Dt .* dark_mask;
    end
end