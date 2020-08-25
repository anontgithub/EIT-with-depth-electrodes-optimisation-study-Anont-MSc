load('tconfig2.mat')
load('duV005baseScF.mat') 
load('errorlist.mat')
%% %% Design parameter mean of top 10% of electrodes volatage differences, for perturbation 0.2mm
for i = 1:length(tconfig)
    if ismember(i,errorlist)
        continue
    else
        try
            rdmat = duV005baseScF{i};
            rdmat = rdmat(:);
            srtrd = sort(abs(rdmat),'descend');
            tenpct = round(length(srtrd)*0.1);
            tptenmean = mean(srtrd(1:tenpct));
            top10mean(i) = tptenmean; 
            
        catch
            disp(i)
        end
    end
end


    
%% normalise
[M,I] = max(top10mean);
top10meanN005 = top10mean./M; 
save('top10meanN005','top10meanN005')