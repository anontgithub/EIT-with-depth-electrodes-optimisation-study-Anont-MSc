
%This script collates all the text file results and forms them into one file.
%It first uses the beginning of the mainmodel script to access each
%configuration, then does the removing injecting electrode results
clear
load('errorlist.mat')

mmt = 1e-3;   
shnkhgt = 9*mmt;
shnkwdt = 0.05*mmt;
blockwdt = 10*mmt;
NExy = 3;
current =  5*10^-5;
l = 36;

a0_3 = log(0.3)/log(10);
a4 = log(4)/log(10);
a0_01 = -2;
a1 = 0;
a5 = log(5)/log(10);
a0_377 = log(0.377)/log(10);

shnkspclg = logspace(a0_3,a4,10);       
shnkdptlg = logspace(a0_01,a1,10);
elespcg = logspace(a0_377,a5,10);                     

tconfig = combvec(shnkspclg,shnkdptlg,elespcg);
cutcell = (tconfig(1,:) <= tconfig(2,:));
indx = 1:length(tconfig);
indxcut = indx(cutcell);
tconfig(:,indxcut) = [];
tconfig(4,:) =(floor(9./tconfig(3,:)))*9;                                    %elenumtotal
tconfig(5,:) = floor(9./tconfig(3,:));                                       %maxNEz
tconfig(6,:) = (9-(tconfig(5,:).*tconfig(3,:))+tconfig(3,:))./tconfig(5,:);  %elehgt
elehgtlogic = (tconfig(6,:) > 5 | tconfig(6,:)< 0.03);
indx = 1:length(tconfig);
indxcut = indx(elehgtlogic);
tconfig(:,indxcut) = [];

for h = 1:length(tconfig)

    try
        shnkspc = (tconfig(1,h))*mmt;                   
        shnkdpt = (tconfig(2,h))*mmt;
        elespc = (tconfig(3,h))*mmt;
        elenumtotal = tconfig(4,h);
        NEz = tconfig(5,h);
        elehgt = (tconfig(6,h))*mmt;
        
        if NEz < l/9                                 
            elecrtselall = zeros((NEz*9)-1,2);
            for v = 1:(NEz*9)-1
                elecrtselall(v,:) = [v,v+1];            
            end
        else
            elecrtsel2 = zeros((l)-1,2);                
            elenumspc = (NEz/(l/9));
            eledistr = floor(1:elenumspc:elenumtotal);            
            for v = 1:(l)-1
                elecrtsel2(v,:) = [eledistr(v),eledistr(v+1)];                 
            end
            
        end
        if elehgt < (0.03*mmt) || elehgt > (5*mmt)               
            disp('electrode height outside range')
            continue
        end     
        if NEz >= l/9
            elecrtsel = elecrtsel2;
        else
            elecrtsel = elecrtselall;
        end
        datacell = [];
        for k = 1:length(elecrtsel)                                        %loop for all injecting electrode selections
            cfgflname = sprintf('loopresult0_2P%1$d_%2$d.txt',h,k);   
            datacell(k,:) = readmatrix(cfgflname);

        end

        
        full02dataRR{h} = datacell;    
    catch
        errordisp = sprintf('skipped loopresult%1$d',h);
        fileID = fopen('notrunmesh.txt','a');
        catchfilename = sprintf('loopresult0_2P%1$d\r\n',h);
        fprintf(fileID,catchfilename);
        fclose(fileID);
        disp(errordisp)
    end

end
save('full02dataRR.mat','full02dataRR')  %change


