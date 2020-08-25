load('tconfig2.mat')
load('errorlist.mat')
%%  Design parameter shank depth (not actually needed as shank depth naturally normalised but included for completeness)
for i = 1:819
    if ismember(i,errorlist)
        continue
    else
        shankdepth(i) = tconfig(2,i);
    end
end
%% 
[M,I] = max(shankdepth);
shankdepthN = shankdepth./M;
save('shankdepthN','shankdepthN')