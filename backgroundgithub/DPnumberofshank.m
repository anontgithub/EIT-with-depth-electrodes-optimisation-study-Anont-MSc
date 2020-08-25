%% Design parameter - number of shanks in imaging volume, reasoning in thesis
%In summary, scale up all configuration to the configuration with the
%largest imaging volume and thus shank spacing.
%Used area of top surface of the imaging volume for each configuration
load('tconfig2.mat')
N = 9.*((4.*2)^2)./((tconfig(1,:).*2).^2);
maxN = max(N);
numshnkN = N/maxN;
save('numshnkN','numshnkN')
