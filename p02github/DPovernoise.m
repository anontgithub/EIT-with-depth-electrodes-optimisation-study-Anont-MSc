load('tconfig2.mat')
load('duV02baseScF.mat')
load('errorlist.mat')
%% %% Design parameter - number of electrodes over the noise floor. Noise floor has already been calculated is stored in row 9 of tconfig2 for all configurations
% for data from pertbation 0.2 mm diameter
for i = 1:819
        try
            dvlogic=(abs(duV02baseScF{i}))>tconfig(9,i);
            sumdvlogic = sum(dvlogic,'all');
            overnoise(i) =sumdvlogic;          
        catch
            disp(i)
        end
%     end
end
%% normalise and save
[M,I] = max(overnoise);
overnoiseN02 = overnoise./M;  %These are the normalised values for this design parameter, it can then be summed up with other design parameters to form the objective function which leads to the 'best' configuration
save('overnoiseN02','overnoiseN02')
