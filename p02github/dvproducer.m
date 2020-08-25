load('full02datarinj.mat')% P0.2mm data, injecting electrodes removed
load('fullBdatarinj.mat')  %Background data injecting electrodes removed
load('errorlist.mat') % see readme
load('tconfig2.mat')
load('scaleCB.mat') %scaling factor
%%%%Produces the dV results from Background simulation and simulation with
%%perturbation 0.2mm. Also scales the dV for contact impedance using
%%scaling factor scaleCB so no voltages are higher than 12V
for i = 1:819
    if ismember(i,errorlist)
        continue
    else
        try
        A = full02datarinj{i}-fullBdatarinj{i}; 
        A = A*scaleCB*1e6;  %scale and voncert V to uV
        fdv{i}=A;
        catch
            disp(i)
        end
    end
end

duV02baseScF = fdv;
save('duV02baseScF','duV02baseScF')

    
    
    