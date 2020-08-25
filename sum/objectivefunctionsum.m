%% Load the results for normalised design parameters and the table of configurations (tconfig2)
load('overnoiseN02.mat')
load('shankdepthN.mat')
load('overnoiseN005.mat')
load('tconfig2.mat')
load('numshnkN.mat')
load('top10meanN02.mat')
load('top10meanN005.mat')
%% The objective function

objfun = [overnoiseN02;overnoiseN005;top10meanN02;top10meanN005;2*(-numshnkN);2*(-shankdepthN)];

%% to exclude all which do not have electrodes over noise

logic0 =(objfun(1,:)==0)|(objfun(2,:)==0); %excludes for both P005 and P02
index = 1:819;
dellogic = index(logic0);
for i = 1:819
    if ismember(i,dellogic)
        objfun(:,i) = 0;
    else 
    end
end

%% Sums up the different design parameters to form the objective function

sumobjfun = sum(objfun);
[M,I] = max(sumobjfun);

 %%  Plot the objective function omitting thoses with value 0
sumplot=sumobjfun;        % make a copy of the data specifically for plotting and will be used for script objfunanalyse for exploring neighbouring configurations
sumplot(sumplot==0)=nan;  % replace 0 elements with NaN
%save('sumplot','sumplot') Uncomment if want to save file for objfunanalyse

plot(sumplot,'Linestyle','none','Marker','*')
 xlabel('Configuration number')
 ylabel('objective function')
title('Objective function combining both 0.2mm and 0.05mm perturbation data')

 
