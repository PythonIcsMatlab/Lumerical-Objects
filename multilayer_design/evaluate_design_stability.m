clear
close all
addpath('functions');

design_name = "TM_gd3_buriedDBR";
design_file = strcat("designs/design_",design_name,".mat");
load(design_file);
pol='p';                            % polarisation: 'p' or 's'
design_type='buried';               % either 'buried' or empty

n1=idx_layers;

lambda = 570*1e-9;
theta = linspace(40,68,1e4); 

N_tests = 2e3;
peak_values = zeros(N_tests,2);
peak_thetas= zeros(N_tests,2);
tic
parfor j = 1:N_tests
    % insert uncertainty in the thickness
    d1=d_layers+1e-9*normrnd(0,sqrt(5),length(n1),1);
    for k = 1:2
        if strcmp(design_type,'buried')
            n = n1;
            d = d1;
            n(end-2)=n1(end-k);
        else
            n = [n1(1:end-k) ; n1(end)];
            d = [d1(1:end-k) ; d1(end)];
        end
        
        [dr,nr,~,~] = prepare_multilayer(d,n);
        
        R = reflectivity(lambda,theta,dr,nr,pol);
        
        [pks,idxs] = findpeaks(1-R);
        [~,pk_ix] = max(pks);
        idx = idxs(pk_ix);
        
        peak_values(j,k) = R(idx);
        peak_thetas(j,k) = theta(idx);
    end
end
toc
%%

save(strcat("stability_analysis_design_",design_name),...
                                        'peak_thetas','peak_values')
for k=1:2
    figure(1), hold on
    histfit(peak_thetas(:,k),30)
    figure(2), hold on
    histogram(1-peak_values(:,k),30)
end