% =================================================================
% DEFINE IMGPATH, DEBLNAME, IMGTEXT AND metric
% -----------------------------------------------------------------
MYPATH = ['/Users/migellejosebarlis/Documents/MATLAB/elastic_prior_deblur/evaluation_code'];
DEBLPATH = '/Users/migellejosebarlis/Documents/MATLAB/elastic_prior_deblur/results_eccv12';
DEBLNAME = 'eecp_';
IMGEXT = 'png';

% -----------------------------------------------------------------
% DEFINE METRIC: available metrics: 'MSE','MSSIM','VIF','IFC','PSNR','MAD'
% -----------------------------------------------------------------
metric = {'PSNR'};

% =================================================================
% DEFINE image Number (1 to 4) and Kernel Number (1 to 12) of
% deblurred images, which shall be assigned a score
% -----------------------------------------------------------------
imgNo = 1:4;
kernNo = 1:12;

% do not calculate the score for following images [img, kernel; img
% kernel]
% exclude = [1 1; 1 2; 1 3; 1 4; 1 5; 1 6];
exclude = [0 0];
% exclude = [1 2; 1 3; 1 4; 1 5; 1 6; 1 7; 1 8; 1 9; 1 10; 1 11; 1 12; ...
%     2 2; 2 3; 2 4; 2 5; 2 6; 2 7; 2 8; 2 9; 2 10; 2 11; 2 12; ...
%     3 2; 3 3; 3 4; 3 5; 3 6; 3 7; 3 8; 3 9; 3 10; 3 11; 3 12; ...
%     4 1; 4 2; 4 3; 4 4; 4 5; 4 6; 4 7; 4 8; 4 9; 4 10; 4 11; 4 12;];
% =================================================================
% run the evaluation script with all ground truth images
% -----------------------------------------------------------------
cd(MYPATH)

for iM = 1 : length(metric)
  for iImg = imgNo
    for iKern = kernNo
      if ~isempty(intersect([iImg iKern],exclude,'rows'))
        continue
      end
      
      metricNow = metric{iM};
      deblurred = imread(sprintf('%s/%s%d_%d.%s',DEBLPATH,DEBLNAME,iImg,iKern,IMGEXT));
      scores = eval_image(deblurred,iImg,iKern,metricNow);
     
      switch metricNow
        case 'MSE'
          DeblurScore.MSE(iImg,iKern) = ...
              get_best_metric_value2(scores.MSE,'MSE',iImg,iKern);
        case 'MSSIM'
           DeblurScore.MSSIM(iImg,iKern) = ...
              get_best_metric_value2(scores.MSSIM,'MSSIM',iImg,iKern);
        case 'VIF'
          DeblurScore.VIF(iImg,iKern) = ...
              get_best_metric_value2(scores.VIF,'VIF',iImg,iKern);
        case 'IFC'
           DeblurScore.IFC(iImg,iKern) = ...
              get_best_metric_value2(scores.IFC,'IFC',iImg,iKern);
        case 'PSNR'
          DeblurScore.PSNR(iImg,iKern) = ...
              get_best_metric_value2(scores.PSNR,'PSNR',iImg,iKern);
        case 'MAD'
           DeblurScore.MAD(iImg,iKern) = ...
              get_best_metric_value2(scores.MAD,'MAD',iImg,iKern);
      end
               
    end
  end
end



% =================================================================
% function dependencies
% -----------------------------------------------------------------
% start_eval_image.m
%   *eval_image.m
%     -dftregistration.m
%     -imshift.m
%     -metrix_mux
%     -MAD_index
%       + myrgb2gray
%   *get_best_metric_value2
