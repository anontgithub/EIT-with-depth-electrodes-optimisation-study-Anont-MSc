load('fulldataRROinj.mat') %full data only injecting electrodes
load('fullBdatarinj.mat') % full data baseline injecting electrodes removed
load('tconfig2.mat')  % table of configurations
%% This calculates the contact impedance voltage and add it onto the voltage of the results, equation in thesis
for i = 1:819
    try
    Vp(i) = max(max((abs(fulldataRROinj{i})+50e-6*2*tconfig(10,i)))); %this is the equation for adding on contact impedance
    catch
        disp(i)
    end
end
maxVp = max(Vp);        %These 3 lines find what scaling factor (scaleCB) is require so that the maximum injecting voltage is 12V.
scaleCB = 12/maxVp;
save('scaleCB','scaleCB');