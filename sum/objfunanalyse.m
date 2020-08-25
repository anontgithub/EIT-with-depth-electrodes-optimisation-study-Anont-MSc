load('sumplot.mat'); %objective function data from objectivefunctionsum script, omits configurations with value 0
load('tconfig2.mat');
%% This script plots the objection function for the optimal config and the configs that are neighbouring it. 
% Varying only one parameter at a time and fixing all the others
index = 1:length(tconfig);

%% Varying shank spacing from optimal, fixing all the other parameters

cfgnum =611;   %configuration of interest (in this case the optimal)
Pcen = [tconfig(1,cfgnum);tconfig(2,cfgnum);tconfig(3,cfgnum)];
figure
%subplot(3,1,1)   can use subplot if want separate graphs
a=2;   % fixing shank width
b=3;   % fixing electrode spacing
set= tconfig(a,:)==Pcen(a)&tconfig(b,:)==Pcen(b);
seti = index(set);
setCF = tconfig(:,seti);
setCF(12,:) = seti;
setCF(13,:) = sumplot(seti);
plot( setCF(1,:),setCF(13,:),'Marker','*','MarkerSize',20,'Linewidth',1,'Color','#4DBEEE');
title('Plot of objective function showing effect of varying one parameter at a time from the optimal model')
ylabel('Objective function')
xlabel('Parameter length (mm)')
hold on
%% Varying shank depth parameter from optimal, fixing other parameters

%subplot(3,1,2)
a=1;     %fixing shank spacing
b=3;     %fixing electrode spacing
set= tconfig(a,:)==Pcen(a)&tconfig(b,:)==Pcen(b);
seti = index(set);
setCF = tconfig(:,seti);
setCF(12,:) = seti;
setCF(13,:) = sumplot(seti);
plot( setCF(2,:),setCF(13,:),'Marker','*','MarkerSize',20,'Linewidth',1,'Color','#D95319');
% %title('Varying shank width only') %Can uncomment if doing separate plots
% ylabel('Objective function')
% xlabel('Shank width (mm)')
hold on
%% Varying electrode spacing from optimal, fixing all the other parameters

%subplot(3,1,3)
a=1;     %fixing shak spacing
b=2;     %fixing shank width
set= tconfig(a,:)==Pcen(a)&tconfig(b,:)==Pcen(b);
seti = index(set);
setCF = tconfig(:,seti);
setCF(12,:) = seti;
setCF(13,:) = sumplot(seti);
%plot([tconfig(2,582) setCF(2,5:9)],[ sumplot(582) setCF(13,5:9)],'Marker','*','MarkerSize',10);
plot( setCF(3,:),setCF(13,:),'Marker','*','MarkerSize',20,'Linewidth',1,'Color','#77AC30');
% %title('Varying inter electrode spacing only') %Can uncomment if doing separate plots
% ylabel('Objective function')
% xlabel('Inter electrode spacing (mm)')

legend('Shank spacing','Shank width','Inter electrode spacing')
