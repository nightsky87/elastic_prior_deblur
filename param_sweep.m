clear; close all; clc;

addpath(genpath('cho_code'));

kernel_sizes=[41    41    41    41    41    41    41   121   125   151    75    41;
              41    41    41    41    41    41    41   121   125   151    75    41;
              41    41    31    21    41    41    41   121   101   151    75    41;
              41    41    31    21    41    41    41   121   101   151    75    41];
          


lambda_list = [0.01 0.02 0.05 0.1 0.2 0.5];
lambda_grad_list = [1e-3 5e-3];

parfor img=1:4
    opts = [];
    opts.prescale = 1; % downsampling
    opts.xk_iter = 5;  % the iterations
    opts.k_thresh = 20;
    opts.gamma_correct = 1.0;
    for blur=1:12
        % Define the parameters that aren't relevant to kernel estimation
        lambda_tv = 1e-3;
        lambda_l0 = 1e-3;
        weight_ring = 0;

        if (blur==8) || (img==2 && blur==10) || (blur==11)
            lambda_l0 = 2e-4; weight_ring = 1;
        end

        % Test out different values of lambda and lamdba_grad for kernel
        % estimation
        for thresh = lambda_list
            for grad = lambda_grad_list
                imgName = sprintf('Blurry%d_%d',img,blur);
                fprintf('========================== %s, lambda=%.2f, lambda_grad=%.3f ==========================\n',imgName,thresh,grad);
        
                filename = sprintf('BlurryImages/%s.png',imgName);
                opts.kernel_size = kernel_sizes(img,blur);
        
                y = imread(filename);
                yg = im2double(rgb2gray(y));
        
                tic;
                [kernel, interim_latent] = blind_deconv(yg, thresh, grad, opts);
                toc
        
                % Final Deblur: 1. TV-L2 denoising method
                y = im2double(y);
                Latent = ringing_artifacts_removal(y, kernel, lambda_tv, lambda_l0, weight_ring);
        
                k = kernel - min(kernel(:));
                k = k./max(k(:));
        
                imwrite(k,sprintf('results_icip22/eecp_%s_%.2f_%.3f_kernel.png',imgName,thresh,grad));
                imwrite(Latent,sprintf('results_icip22/eecp_%s_%.2f_%.3f.png',imgName,thresh,grad));
            end
        end
    end
end
