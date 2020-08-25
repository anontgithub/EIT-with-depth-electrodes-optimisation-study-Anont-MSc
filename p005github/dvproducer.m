load('full005datarinj.mat') % P0.05mm data, injecting electrodes removed
load('fullBdatarinj.mat') % Background data injecting electrodes removed
load('scaleCB.mat')   %scaling factor from contact impedance investigation
load('tconfig2.mat')
load('errorlist.mat') %see readme
%%Produces the dV results from Background simulation and simulation with
%%perturbation 0.05mm. Also scales the dV for contact impedance using
%%scaling factor scaleCB so no voltages are higher than 12V
for i = 1:length(tconfig)
    if ismember(i,errorlist)
        continue
    else
        try
        A = full005datarinj{i}-fullBdatarinj{i};
        A = A*scaleCB*1e6;  %scale and voncert V to mV
        fdv{i}=A;
        catch
            disp(i)
        end
    end
end
%% 

duV005baseScF = fdv;
save('duV005baseScF','duV005baseScF')
    
    
    