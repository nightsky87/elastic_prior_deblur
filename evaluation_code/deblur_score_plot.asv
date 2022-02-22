clear; close all; clc;

load('deblur_score_eecp.mat');
load('deblur_score_dcp.mat');
load('deblur_score_pmp.mat');

figure; bar(cat(2, min(DeblurScoreDCP.PSNR, [], 2), min(DeblurScorePMP.PSNR, [], 2), min(DeblurScoreEECP.PSNR, [], 2))); title('MIN PSNR'); legend({'DCP','PMP', 'EECP'},'Location','southwest');
figure; bar(cat(2, max(DeblurScoreDCP.PSNR, [], 2), max(DeblurScorePMP.PSNR, [], 2), max(DeblurScoreEECP.PSNR, [], 2))); title('MAX PSNR'); legend({'DCP','PMP', 'EECP'},'Location','southwest');
figure; bar(cat(2, mean(DeblurScoreDCP.PSNR, 2), mean(DeblurScorePMP.PSNR, 2), mean(DeblurScoreEECP.PSNR, 2))); title('MEAN PSNR'); legend({'DCP','PMP', 'EECP'},'Location','southwest');