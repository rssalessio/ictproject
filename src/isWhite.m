function [result,ratio] = isWhite(process, alpha, samples, opt)
% isWhite(process, alpha, opt) performs the Anderson Whiteness Test for the
% given process.
%   process: process to run the test on
%   alpha: margin of tolerance (default alpha=0.1), the lower the better
%   samples: percentage of samples to consider (default 0.1)
%   opt: 'plot' (show plot) shows the interval of confidence
%        '' nothing
   
    switch nargin
        case 1 
            alpha = 0.1;
            samples = 0.1;
            opt = '';
        case 2
            samples = 0.1;
            opt = '';
        case 3
            opt = '';
    end
    
    if size(process,2) ~= 1
        error('process must be a column vector');
    end
    
    if (alpha <= 0 || alpha >= 1)
        alpha = 0.1;
    end
    
    if (samples <= 0 || samples > 1)
        samples = 0.1;
    end
    
    process = detrend(process,'constant');
    process = detrend(process,'linear');
    
    N=length(process); % number of samples

    process_cov=covf(process, floor(N*samples)); %compute the covariances up to N/10
    rho=process_cov(2:end)/process_cov(1); %compute the normalized correlations (for tau>0)
    beta=norminv(1-alpha/2); %probability to land outside (-beta;+beta) is alpha
    cov_beta = (beta*process_cov(1))/sqrt(N); %tolerances for covariance
    
    nalpha=length(find(sqrt(N)*rho>beta))+length(find(sqrt(N)*rho<-beta)); %number of points outside interval
    ratio=nalpha/length(rho);
    
    
    result = (ratio <= alpha);
    disp(['Ratio of violation: ',num2str(ratio*100),'%, alpha=',num2str(alpha), ', covariance tolerance: ',num2str(cov_beta)])
    disp(['Anderson test pass: ' num2str(result) ]);
    
    
    if strcmp(opt,'plot')
        figure
        grid
        hold on
        %Plot anderson
        subplot(2,1,1);
        plot(1:length(rho),beta*ones(length(rho),1),'r--','linewidth',1); hold on;
        plot(1:length(rho),-beta*ones(length(rho),1),'r--','linewidth',1); hold on;
        plot(1:length(rho),sqrt(N)*rho,'ko'); hold on;
        ylabel('sqrt(\rho)')
        xlabel('N');
        title('Anderson Test');
        legend('Tolerance');
        
        
        %Plot covariance
        subplot (2,1,2);
        plot(1:length(process_cov), process_cov); hold on;
        plot(1:length(process_cov),cov_beta*ones(length(process_cov),1),'r--','linewidth',1); hold on;
        plot(1:length(process_cov),-cov_beta*ones(length(process_cov),1),'r--','linewidth',1); hold on;
        legend('Covariance','Tolerances');
        grid;
        xlabel('N');
        ylabel('Cov');
        title('Covariance input');
    end
   

end
