function [E, U] = elastic_extreme_channel_prior(I, thresh, thresh_type, optim)
    % Assume that the extreme channel isn't explicitly needed
    if ~exist('optim','var')
        optim = true;
    end

    % Determine the size of the input image
    [M, N, P] = size(I);

    % If the image has multiple channels, find the minimum/maximum across 
    % all the channels
    Id = min(I, [], 3);
    Ib = min(I, [], 3);

    % Calculate the window size so that we end up with between 25 to 100
    % dark pixel references
    window_size = 2 ^ floor(log2(numel(I)/100)/2);
    window_elem = window_size ^ 2;
    M_padded = ceil(M / window_size) * window_size;
    N_padded = ceil(N / window_size) * window_size;

    % Pad the image
    pad_size = [M_padded N_padded] - [M N];
    I_padded_dark = padarray(Id,pad_size,nan,'post');
    I_padded_bright = padarray(Ib,pad_size,nan,'post');

    % Find the extreme of each window
    [W_min,d_ind] = min(im2col(I_padded_dark,[window_size window_size],'distinct'),[],1);
    [W_max,b_ind] = max(im2col(I_padded_bright,[window_size window_size],'distinct'),[],1);

    % Locate the extreme quartiles
    d_mask = W_min <= prctile(W_min,25);
    b_mask = W_max >= prctile(W_max,75);

    % Locate the corresponding dark pixels in the full-sized image
    dark_mask = false(window_elem,M_padded*N_padded/window_elem);
    d_ind = sub2ind([window_elem nnz(d_mask)],d_ind(d_mask),1:nnz(d_mask));
    T = false(window_elem,nnz(d_mask));
    T(d_ind) = true;
    dark_mask(:,d_mask) = T;
    dark_mask = col2im(dark_mask,[window_size window_size],size(I),'distinct');

    % Locate the corresponding dark pixels in the full-sized image
    bright_mask = false(window_elem,M_padded*N_padded/window_elem);
    b_ind = sub2ind([window_elem nnz(b_mask)],b_ind(b_mask),1:nnz(b_mask));
    T = false(window_elem,nnz(b_mask));
    T(b_ind) = true;
    bright_mask(:,b_mask) = T;
    bright_mask = col2im(bright_mask,[window_size window_size],size(I),'distinct');

    % Ensure that the two masks don't overlap. This is extremely unlikely
    % to happen unless there are a lot of flat areas in the image.
    bright_mask = bright_mask & ~dark_mask;

    % In practise, it isn't necessary to explicitly compute the dark channel
    if optim
        % For optimisation, we can directly threshold the darkest pixels
        E = [];
        Dt = threshold(I, thresh, thresh_type);
        Bt = 1-threshold(1-I, thresh, thresh_type);
        U = I .* (~dark_mask & ~bright_mask) + Dt .* dark_mask + Bt .* bright_mask;
    else
        % Translate the mask to coordinates
        [x,y] = meshgrid(1:N,1:M);
        dark_x = x(dark_mask);
        dark_y = y(dark_mask);
        bright_x = x(bright_mask);
        bright_y = y(bright_mask);
    
        % Find the nearest extreme pixel for each pixel
        [~,d_ind] = min((x(:) - dark_x') .^ 2 + (y(:) - dark_y') .^ 2,[],2);
        [~,b_ind] = min((x(:) - bright_x') .^ 2 + (y(:) - bright_y') .^ 2,[],2);
    
        % Calculate the extreme channels
        dark = W_min(d_mask);
        D = reshape(dark(d_ind),size(Id));
        bright = W_max(b_mask);
        B = reshape(bright(b_ind),size(Ib));
        E = cat(3,D,B);

        % Map the dark channels back to the latent image
        Dt = threshold(I, thresh, thresh_type);
        Bt = 1-threshold(1-I, thresh, thresh_type);
        U = I .* (~dark_mask & ~bright_mask) + Dt .* dark_mask + Bt .* bright_mask;
    end
end

function X = threshold(X, thresh, thresh_type)
    mask = abs(X) <= thresh;
    if thresh_type == 's'
        X = X - sign(X) .* thresh;
    end
    X(mask) = 0;
end