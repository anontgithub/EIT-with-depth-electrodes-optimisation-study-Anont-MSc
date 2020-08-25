%% EIT depth electrode optimisation model with COMSOL by ANONT HEWCHAIYAPHUM
% This version is for perturbation size 0.2mm diameter
function out = model
% mainmodel4sel.m
%
% Model exported on Mar 7 2020, 22:30 by COMSOL 5.3.0.316.
clear
load('errorlist.mat') % list of configs that have resulted in meshing errors, used to skip them, more explaination in README

%% Defining constants

mmt = 1e-3;   %millimeters
shnkhgt = 9*mmt;        %shank height in meters
shnkwdt = 0.05*mmt;     %shank width in meteres (in thesis width and depth are switched)
blockwdt = 10*mmt;      %block width (modelled volume height)
NExy = 3;               % Number of shank per axis (x and y)
current =  5*10^-5;     % injecting current
l = 36;                 %max number of injecting electrodes
%% Defining values of parameters to be varied as a log value so it can be logarithmically spaced
%If want to adjust parameters to vary, adjust in this section  %defining different number to use with logspace 
shnkspcmin = 0.3; % shank spacing miniumum value
shnkspcmax = 4;   % shank spacing maxiumum value
shnkdptmin = 0.01; %shank depth min
shnkdptmax = 1;    % shank depth max
elespcmin = 0.337;  %electrode spacing min
elespcmax = 5;     %electrode spacing max

shnkspclg = logspace(log(shnkspcmin)/log(10),log(shnkspcmax)/log(10),10);  %shank spacing 10 values log spaced, from 0.3 to 4mm
shnkdptlg = logspace(log(shnkdptmin)/log(10),log(shnkdptmax)/log(10),10); % shank depth from 0.01 to 1 mm
elespcg = logspace(log(elespcmin)/log(10),log(elespcmax)/log(10),10);  % electrode spacing from 0.377 to 5 mm         
%% Making 'tconfig' the table of configurations

tconfig = combvec(shnkspclg,shnkdptlg,elespcg); %produce all possible combination of parameters 
cutcell = (tconfig(1,:) <= tconfig(2,:));       %delete configs where shank depth larger than shank spacing, otherwise domains overlap
indx = 1:length(tconfig);
indxcut = indx(cutcell);
tconfig(:,indxcut) = [];
tconfig(4,:) =(floor(9./tconfig(3,:)))*9;                                    %elenumtotal - total number of electrodes
tconfig(5,:) = floor(9./tconfig(3,:));                                       %maxNEz      - number of electrodes per shank
tconfig(6,:) = (9-(tconfig(5,:).*tconfig(3,:))+tconfig(3,:))./tconfig(5,:);  %elehgt      - electrode height
elehgtlogic = (tconfig(6,:) > 5 | tconfig(6,:)< 0.03);                       %making sure electrode height within defined ranges
indx = 1:length(tconfig);
indxcut = indx(elehgtlogic);
tconfig(:,indxcut) = [];
%% Outer loop - selecting the configuration

for h = 1:length(tconfig)  %loop for all configurations (or as many as you want, change length(tconfig) to a number you want)
    if ismember(h,errorlist)  % Skipping configurations that have caused meshing errors previously, trying to rerun them would again cause errors so just skipped (more explaination in README)
        sprintf('skipped loopresult0_05P%1$d',h)
        fileID = fopen('errorcatch.txt','a');   % writes the names of configs skipped into a file
        catchfilename = sprintf('loopresult0_05P%1$d\r\n',h);
        fprintf(fileID,catchfilename);
        fclose(fileID);        
        continue
    else
        %nothing
    end
    try
        shnkspc = (tconfig(1,h))*mmt;   %assigning the parameter values for this configuration                
        shnkdpt = (tconfig(2,h))*mmt;
        elespc = (tconfig(3,h))*mmt;
        elenumtotal = tconfig(4,h);
        NEz = tconfig(5,h);
        elehgt = (tconfig(6,h))*mmt;
        %% Creating the current injection protocol pairs for the configuration
        
        if NEz < l/9                                 %If configuration has less than 36 electrodes,all electrodes are injecting
            elecrtselall = zeros((NEz*9)-1,2);
            for v = 1:(NEz*9)-1
                elecrtselall(v,:) = [v,v+1];         %makes list of injecting electrode pairs          
            end
        else
            elecrtsel2 = zeros((l)-1,2);                 %Otherwise, make a list of 36 current injecting pairs for the configuration
            elenumspc = (NEz/(l/9));
            eledistr = floor(1:elenumspc:elenumtotal);   %floor for unique whole numbers
            for v = 1:(l)-1
                elecrtsel2(v,:) = [eledistr(v),eledistr(v+1)];       %makes list of injecting electrode pairs
            end
            
        end
        %% Some constants used for the model later
        
        elypossl2 = (blockwdt/2)-(elehgt/2);    %electrode position
        elicrm = (elehgt+elespc);               %electrode spacing increment
        elearea = shnkdpt*elehgt;               %electrode area
        curden = current/elearea;               %current density for an electrode
        %% Selects the appropriate current injection protocol for configuration, all electrodes or specified some
        
        if NEz >= l/9           
            elecrtsel = elecrtsel2;
        else
            elecrtsel = elecrtselall;
        end
        %% Inner loop, Runs the COMSOL model, records the data etc., one loop is one current injection pair
        
        for k = 1:length(elecrtsel)                                        %loop for injecting electrode selection, up to number of pairs
            geomselspf1 = sprintf('geom1_boxsel%d',elecrtsel(k,1));        %electrode pair no.1
            geomselspf2 = sprintf('geom1_boxsel%d',elecrtsel(k,2));        %electrode pair no.2
            
            cfgflname = sprintf('loopresult0_05P%1$d_%2$d.txt',h,k);           %creates the name to be used for the results file for each current injection loop. first number, h, is the config number and second number k is the injection pair number.
            
            xyshnk1 = [-1,-1];  %Defines shank locations with units of shankspacing, there are 9 shanks in total
            xyshnk2 = [0,-1];
            xyshnk3 = [1,-1];
            xyshnk4 = [-1,0];
            xyshnk5 = [0,0];
            xyshnk6 = [1,0];
            xyshnk7 = [-1,1];
            xyshnk8 = [0,1];
            xyshnk9 = [1,1];
            
            eltable = zeros(elenumtotal,3);  %creates matrix that defines the geometric coordinates of all elctrodes on each shank
            %shank1
            for j = 1:NEz
                eltable(j+0,:) = [xyshnk1 j-1];             %eltable allows box selection to know where the electrodes are
            end
            %shank2
            for j = 1:NEz
                eltable(j+NEz,:) = [xyshnk2 j-1];
            end
            %shank3
            for j = 1:NEz
                eltable(j+(2*NEz),:) = [xyshnk3 j-1];
            end
            %shank4
            for j = 1:NEz
                eltable(j+(3*NEz),:) = [xyshnk4 j-1];
            end
            %shank5
            for j = 1:NEz
                eltable(j+(4*NEz),:) = [xyshnk5 j-1];
            end
            %shank6
            for j = 1:NEz
                eltable(j+(5*NEz),:) = [xyshnk6 j-1];
            end
            %shank7
            for j = 1:NEz
                eltable(j+(6*NEz),:) = [xyshnk7 j-1];
            end
            %shank8
            for j = 1:NEz
                eltable(j+(7*NEz),:) = [xyshnk8 j-1];
            end
            %shank9
            for j = 1:NEz
                eltable(j+(8*NEz),:) = [xyshnk9 j-1];
            end
            %% COMSOL model starts from here
            
            import com.comsol.model.*
            import com.comsol.model.util.*
            
            model = ModelUtil.create('Model');
            
            model.modelPath('C:\Users\anont\OneDrive\Desktop\UCLtimes\MPHY0035\Comsol work\mainmodelmat4'); %I don't think this is needed
            
            model.label('mainmodel4sel.mph');
            
            model.comments(['Untitled\n\n']);
            
            model.param.set('shnkspc', shnkspc , 'shank spacing');   %defines global parameters in comsol taken from variable in outer loop
            model.param.set('shnkhgt', shnkhgt, 'shank height');
            model.param.set('shnkwdt', shnkwdt, 'shank width');
            model.param.set('shnkdpt', shnkdpt , 'shank depth');
            model.param.set('elehgt', elehgt, 'electrode height');
            model.param.set('blockwdt', blockwdt, 'block width');
            model.param.set('NExy', NExy, 'Number of  electrodes in x or y direction');
            model.param.set('NEz', NEz, 'Number of electrodes in z direction'); 
            model.param.set('elespc', elespc, 'Inter electrode spacing on shank');
            model.param.set('elypossl2', elypossl2, 'electrode selection y ');
            model.param.set('elicrm',elicrm, 'electrode selection increment');
            
            model.component.create('comp1', true);
            
            model.component('comp1').geom.create('geom1', 3);
            
            model.result.table.create('evl3', 'Table');    %A loop to create all the tables required to input results in
            for i = 1:(NEz*9)
                tblselspf = sprintf('tbl%d',i);
                model.result.table.create(tblselspf, 'Table');
            end
            
            model.component('comp1').mesh.create('mesh1');
            
            model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');
            model.component('comp1').geom('geom1').selection('csel1').label('ele1');
            model.component('comp1').geom('geom1').create('blk1', 'Block');
            model.component('comp1').geom('geom1').feature('blk1').set('pos', {'-shnkspc' '-shnkspc' '(blockwdt-shnkhgt)/2'});
            model.component('comp1').geom('geom1').feature('blk1').set('base', 'center');
            model.component('comp1').geom('geom1').feature('blk1').set('size', {'shnkwdt' 'shnkdpt' 'shnkhgt'});
            model.component('comp1').geom('geom1').create('arr1', 'Array');
            model.component('comp1').geom('geom1').feature('arr1').set('fullsize', [3 3 1]);
            model.component('comp1').geom('geom1').feature('arr1').set('displ', {'shnkspc' 'shnkspc' '0'});
            model.component('comp1').geom('geom1').feature('arr1').selection('input').set({'blk1'});
            model.component('comp1').geom('geom1').create('blk2', 'Block');
            model.component('comp1').geom('geom1').feature('blk2').set('base', 'center');
            model.component('comp1').geom('geom1').feature('blk2').set('size', {'blockwdt' 'blockwdt' 'blockwdt'});
            model.component('comp1').geom('geom1').create('dif1', 'Difference');
            model.component('comp1').geom('geom1').feature('dif1').selection('input').set({'blk2'});
            model.component('comp1').geom('geom1').feature('dif1').selection('input2').set({'arr1'});
            model.component('comp1').geom('geom1').create('wp1', 'WorkPlane');
            model.component('comp1').geom('geom1').feature('wp1').set('quickplane', 'yz');
            model.component('comp1').geom('geom1').feature('wp1').set('quickx', '-shnkspc + shnkwdt/2');
            model.component('comp1').geom('geom1').feature('wp1').set('unite', true);
            model.component('comp1').geom('geom1').feature('wp1').geom.create('r1', 'Rectangle');
            model.component('comp1').geom('geom1').feature('wp1').geom.feature('r1').set('pos', {'-shnkspc' '(blockwdt/2)-(elehgt/2)'});
            model.component('comp1').geom('geom1').feature('wp1').geom.feature('r1').set('base', 'center');
            model.component('comp1').geom('geom1').feature('wp1').geom.feature('r1').set('size', {'shnkdpt' 'elehgt'});
            model.component('comp1').geom('geom1').create('arr2', 'Array');
            model.component('comp1').geom('geom1').feature('arr2').set('selresult', true);
            model.component('comp1').geom('geom1').feature('arr2').set('selresultshow', 'bnd');
            model.component('comp1').geom('geom1').feature('arr2').set('fullsize', {'NExy' 'NExy' 'NEz'});
            model.component('comp1').geom('geom1').feature('arr2').set('displ', {'shnkspc' 'shnkspc' '-(elehgt+elespc)'});
            model.component('comp1').geom('geom1').feature('arr2').selection('input').set({'wp1'});
            model.component('comp1').geom('geom1').create('wp2', 'WorkPlane');
            model.component('comp1').geom('geom1').feature('wp2').set('quickz', '-5[mm]');
            model.component('comp1').geom('geom1').feature('wp2').set('unite', true);
            model.component('comp1').geom('geom1').feature('wp2').geom.create('sq1', 'Square');
            model.component('comp1').geom('geom1').feature('wp2').geom.feature('sq1').set('base', 'center');
            model.component('comp1').geom('geom1').feature('wp2').geom.feature('sq1').set('size', '1[mm]');
            
            model.component('comp1').geom('geom1').create('sel10', 'ExplicitSelection');
            model.component('comp1').geom('geom1').feature('sel10').label('Ground');
            model.component('comp1').geom('geom1').feature('sel10').selection('selection').init(2);
            model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('wp2.sq1', [1]);
            model.component('comp1').geom('geom1').create('sph1', 'Sphere');
            model.component('comp1').geom('geom1').feature('sph1').set('pos', {'-shnkspc/2' '-shnkspc/2' '(blockwdt/2)-(shnkhgt/2)'});
            model.component('comp1').geom('geom1').feature('sph1').set('r', '0.025e-3');
            model.component('comp1').geom('geom1').run('fin');
            
            %% This loops used COMSOL boxselection function to select all the electrodes
            %this loops for all electrodes, selecting each electrode using
            %the coordinates in eltable with elyposs12 and elicrm to get
            %the location
            
            for i = 1:(NEz*9)  
                boxsellspf = sprintf('boxsel%d',i);
                model.component('comp1').geom('geom1').create(boxsellspf, 'BoxSelection');
                model.component('comp1').geom('geom1').feature(boxsellspf).set('entitydim', 2);
                model.component('comp1').geom('geom1').feature(boxsellspf).set('xmin', shnkspc*(eltable(i,1)));
                model.component('comp1').geom('geom1').feature(boxsellspf).set('xmax', (shnkwdt+(shnkspc*(eltable(i,1)))));
                model.component('comp1').geom('geom1').feature(boxsellspf).set('ymin', shnkspc*(eltable(i,2)));
                model.component('comp1').geom('geom1').feature(boxsellspf).set('ymax', shnkspc*(eltable(i,2)));
                model.component('comp1').geom('geom1').feature(boxsellspf).set('zmin', (elypossl2-elicrm*(eltable(i,3))));
                model.component('comp1').geom('geom1').feature(boxsellspf).set('zmax', (elypossl2-elicrm*(eltable(i,3))));
                model.component('comp1').geom('geom1').feature(boxsellspf).set('contributeto', 'csel1');
            end
            %% 
            
            model.component('comp1').geom('geom1').run;
            model.component('comp1').material.create('mat1', 'Common');
            model.component('comp1').material.create('mat2', 'Common');
            model.component('comp1').material('mat1').selection.set([1]);
            model.component('comp1').material('mat1').propertyGroup('def').func.create('eta', 'Piecewise');
            model.component('comp1').material('mat1').propertyGroup('def').func.create('Cp', 'Piecewise');
            model.component('comp1').material('mat1').propertyGroup('def').func.create('rho', 'Piecewise');
            model.component('comp1').material('mat1').propertyGroup('def').func.create('k', 'Piecewise');
            model.component('comp1').material('mat1').propertyGroup('def').func.create('cs', 'Interpolation');
            model.component('comp1').material('mat2').selection.set([2]);
            model.component('comp1').material('mat2').propertyGroup('def').func.create('eta', 'Piecewise');
            model.component('comp1').material('mat2').propertyGroup('def').func.create('Cp', 'Piecewise');
            model.component('comp1').material('mat2').propertyGroup('def').func.create('rho', 'Piecewise');
            model.component('comp1').material('mat2').propertyGroup('def').func.create('k', 'Piecewise');
            model.component('comp1').material('mat2').propertyGroup('def').func.create('cs', 'Interpolation');

            model.component('comp1').physics.create('ec', 'ConductiveMedia', 'geom1');
            model.component('comp1').physics('ec').create('gnd1', 'Ground', 2);
            model.component('comp1').physics('ec').feature('gnd1').selection.named('geom1_sel10');
            model.component('comp1').physics('ec').create('ncd1', 'NormalCurrentDensity', 2);
            model.component('comp1').physics('ec').feature('ncd1').selection.named(geomselspf1);  % 'geom1_boxsel1' injecting electrode 1 selection
            model.component('comp1').physics('ec').create('ncd2', 'NormalCurrentDensity', 2);
            model.component('comp1').physics('ec').feature('ncd2').selection.named(geomselspf2); % 'geom1_boxsel2' injecting electrode 2 selection
            
            model.result.table('evl3').label('Evaluation 3D');
            model.result.table('evl3').comments('Interactive 3D values');
            model.result.table('tbl1').comments('Surface Average 1 (V)');
            
            model.component('comp1').view('view1').set('renderwireframe', true);
            model.component('comp1').view('view1').set('scenelight', false);
            model.component('comp1').view('view2').axis.set('xmin', -0.02065909095108509);
            model.component('comp1').view('view2').axis.set('xmax', 0.02065909095108509);
            model.component('comp1').view('view2').axis.set('ymin', -0.010780489072203636);
            model.component('comp1').view('view2').axis.set('ymax', 0.009992238134145737);
            model.component('comp1').view('view2').axis.set('abstractviewlratio', -1.538636326789856);
            model.component('comp1').view('view2').axis.set('abstractviewrratio', 1.538636326789856);
            model.component('comp1').view('view2').axis.set('abstractviewbratio', -0.5116279125213623);
            model.component('comp1').view('view2').axis.set('abstractviewtratio', 0.4418603777885437);
            model.component('comp1').view('view2').axis.set('abstractviewxscale', 4.545454430626705E-5);
            model.component('comp1').view('view2').axis.set('abstractviewyscale', 4.545454430626705E-5);
            model.component('comp1').view('view3').axis.set('xmin', -0.010442559607326984);
            model.component('comp1').view('view3').axis.set('xmax', 0.010442559607326984);
            model.component('comp1').view('view3').axis.set('ymin', -0.005249999929219484);
            model.component('comp1').view('view3').axis.set('ymax', 0.005249999929219484);
            model.component('comp1').view('view3').axis.set('abstractviewlratio', -0.5089465379714966);
            model.component('comp1').view('view3').axis.set('abstractviewrratio', 0.5089465379714966);
            model.component('comp1').view('view3').axis.set('abstractviewbratio', -0.05000000819563866);
            model.component('comp1').view('view3').axis.set('abstractviewtratio', 0.05000000819563866);
            model.component('comp1').view('view3').axis.set('abstractviewxscale', 1.8394650396658108E-5);
            model.component('comp1').view('view3').axis.set('abstractviewyscale', 1.8394648577668704E-5);
            
            model.component('comp1').material('mat1').label('Grey matter');
            model.component('comp1').material('mat1').set('family', 'water');
            model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('arg', 'T');
            model.component('comp1').material('mat1').propertyGroup('def').func('eta').set('pieces', {'273.15' '413.15' '1.3799566804-0.021224019151*T^1+1.3604562827E-4*T^2-4.6454090319E-7*T^3+8.9042735735E-10*T^4-9.0790692686E-13*T^5+3.8457331488E-16*T^6'; '413.15' '553.75' '0.00401235783-2.10746715E-5*T^1+3.85772275E-8*T^2-2.39730284E-11*T^3'});
            model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('arg', 'T');
            model.component('comp1').material('mat1').propertyGroup('def').func('Cp').set('pieces', {'273.15' '553.75' '12010.1471-80.4072879*T^1+0.309866854*T^2-5.38186884E-4*T^3+3.62536437E-7*T^4'});
            model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('arg', 'T');
            model.component('comp1').material('mat1').propertyGroup('def').func('rho').set('pieces', {'273.15' '553.75' '838.466135+1.40050603*T^1-0.0030112376*T^2+3.71822313E-7*T^3'});
            model.component('comp1').material('mat1').propertyGroup('def').func('k').set('arg', 'T');
            model.component('comp1').material('mat1').propertyGroup('def').func('k').set('pieces', {'273.15' '553.75' '-0.869083936+0.00894880345*T^1-1.58366345E-5*T^2+7.97543259E-9*T^3'});
            model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('table', {'273' '1403';  ...
                '278' '1427';  ...
                '283' '1447';  ...
                '293' '1481';  ...
                '303' '1507';  ...
                '313' '1526';  ...
                '323' '1541';  ...
                '333' '1552';  ...
                '343' '1555';  ...
                '353' '1555';  ...
                '363' '1550';  ...
                '373' '1543'});
            model.component('comp1').material('mat1').propertyGroup('def').func('cs').set('interp', 'piecewisecubic');
            model.component('comp1').material('mat1').propertyGroup('def').set('dynamicviscosity', 'eta(T[1/K])[Pa*s]');
            model.component('comp1').material('mat1').propertyGroup('def').set('ratioofspecificheat', '1.0');
            model.component('comp1').material('mat1').propertyGroup('def').set('electricconductivity', {'0.03' '0' '0' '0' '0.03' '0' '0' '0' '0.03'});
            model.component('comp1').material('mat1').propertyGroup('def').set('heatcapacity', 'Cp(T[1/K])[J/(kg*K)]');
            model.component('comp1').material('mat1').propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
            model.component('comp1').material('mat1').propertyGroup('def').set('thermalconductivity', {'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]'});
            model.component('comp1').material('mat1').propertyGroup('def').set('soundspeed', 'cs(T[1/K])[m/s]');
            model.component('comp1').material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
            model.component('comp1').material('mat1').propertyGroup('def').addInput('temperature');
            model.component('comp1').material('mat2').label('Perturbation');
            model.component('comp1').material('mat2').set('family', 'water');
            model.component('comp1').material('mat2').propertyGroup('def').func('eta').set('arg', 'T');
            model.component('comp1').material('mat2').propertyGroup('def').func('eta').set('pieces', {'273.15' '413.15' '1.3799566804-0.021224019151*T^1+1.3604562827E-4*T^2-4.6454090319E-7*T^3+8.9042735735E-10*T^4-9.0790692686E-13*T^5+3.8457331488E-16*T^6'; '413.15' '553.75' '0.00401235783-2.10746715E-5*T^1+3.85772275E-8*T^2-2.39730284E-11*T^3'});
            model.component('comp1').material('mat2').propertyGroup('def').func('Cp').set('arg', 'T');
            model.component('comp1').material('mat2').propertyGroup('def').func('Cp').set('pieces', {'273.15' '553.75' '12010.1471-80.4072879*T^1+0.309866854*T^2-5.38186884E-4*T^3+3.62536437E-7*T^4'});
            model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('arg', 'T');
            model.component('comp1').material('mat2').propertyGroup('def').func('rho').set('pieces', {'273.15' '553.75' '838.466135+1.40050603*T^1-0.0030112376*T^2+3.71822313E-7*T^3'});
            model.component('comp1').material('mat2').propertyGroup('def').func('k').set('arg', 'T');
            model.component('comp1').material('mat2').propertyGroup('def').func('k').set('pieces', {'273.15' '553.75' '-0.869083936+0.00894880345*T^1-1.58366345E-5*T^2+7.97543259E-9*T^3'});
            model.component('comp1').material('mat2').propertyGroup('def').func('cs').set('table', {'273' '1403';  ...
                '278' '1427';  ...
                '283' '1447';  ...
                '293' '1481';  ...
                '303' '1507';  ...
                '313' '1526';  ...
                '323' '1541';  ...
                '333' '1552';  ...
                '343' '1555';  ...
                '353' '1555';  ...
                '363' '1550';  ...
                '373' '1543'});
            model.component('comp1').material('mat2').propertyGroup('def').func('cs').set('interp', 'piecewisecubic');
            model.component('comp1').material('mat2').propertyGroup('def').set('dynamicviscosity', 'eta(T[1/K])[Pa*s]');
            model.component('comp1').material('mat2').propertyGroup('def').set('ratioofspecificheat', '1.0');
            model.component('comp1').material('mat2').propertyGroup('def').set('electricconductivity', {'0.0312' '0' '0' '0' '0.0312' '0' '0' '0' '0.0312'});
            model.component('comp1').material('mat2').propertyGroup('def').set('heatcapacity', 'Cp(T[1/K])[J/(kg*K)]');
            model.component('comp1').material('mat2').propertyGroup('def').set('density', 'rho(T[1/K])[kg/m^3]');
            model.component('comp1').material('mat2').propertyGroup('def').set('thermalconductivity', {'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]' '0' '0' '0' 'k(T[1/K])[W/(m*K)]'});
            model.component('comp1').material('mat2').propertyGroup('def').set('soundspeed', 'cs(T[1/K])[m/s]');
            model.component('comp1').material('mat2').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
            model.component('comp1').material('mat2').propertyGroup('def').addInput('temperature');
            
            model.component('comp1').physics('ec').feature('ncd1').set('nJ', curden);
            model.component('comp1').physics('ec').feature('ncd2').set('nJ', -curden);
            
            model.study.create('std1');
            model.study('std1').create('stat', 'Stationary');
            
            model.sol.create('sol1');
            model.sol('sol1').study('std1');
            model.sol('sol1').attach('std1');
            model.sol('sol1').create('st1', 'StudyStep');
            model.sol('sol1').create('v1', 'Variables');
            model.sol('sol1').create('s1', 'Stationary');
            model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
            model.sol('sol1').feature('s1').create('i1', 'Iterative');
            model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
            model.sol('sol1').feature('s1').feature.remove('fcDef');
            %% Loop to assign voltage surface average function to all electrode surfaces
            
            for i = 1:(NEz*9)
                geomselspf = sprintf('geom1_boxsel%d',i);
                avselspf = sprintf('av%d',i);
                model.result.numerical.create(avselspf, 'AvSurface');
                model.result.numerical(avselspf).selection.named(geomselspf);
                model.result.numerical(avselspf).set('probetag', 'none');
            end
%             
%% 
%uncomment the 2 lines below if want a 3d plot in comsol results, did not use in project
%             model.result.create('pg1', 'PlotGroup3D'); 
%             model.result('pg1').create('mslc1', 'Multislice');
            
            model.sol('sol1').attach('std1');
            model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'cg');
            model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'amg');
            model.sol('sol1').runAll;
            %% Loop to add all surface average results into the results table created earlier
                               
            for i = 1:(NEz*9)
                avselspf = sprintf('av%d',i);
                tblselspf = sprintf('tbl%d',i);
                model.result.numerical(avselspf).set('table',tblselspf);
                model.result.numerical(avselspf).set('expr', {'V'});
                model.result.numerical(avselspf).set('unit', {'V'});
                model.result.numerical(avselspf).set('descr', {'Electric potential'});
                model.result.numerical(avselspf).setResult;
            end
            
            % I think the 3 lines below are only required if you want a 3D plot
%             model.result('pg1').label('Electric Potential (ec)');
%             model.result('pg1').set('frametype', 'spatial');
%             model.result('pg1').feature('mslc1').set('resolution', 'normal');
            
            %% Loop to extract result from table in Comsol and then save the table as a txt file.

            dtbl = zeros(1,NEz*9);
            for t = 1:(NEz*9)
                str = sprintf('tbl%d',t);
                etbl = mphtable(model,str);
                dtbl(t) = etbl.data;
            end
            writematrix(dtbl,cfgflname)
        end
    catch %to note and write into file which configs have ended up as an error
        sprintf('skipped loopresult0_05P%1$d',h)
        fileID = fopen('errorcatch.txt','a');
        catchfilename = sprintf('loopresult0_05P%1$d\r\n',h);
        fprintf(fileID,catchfilename);
        fclose(fileID);
    end
end
%mphsave(model,'D450')  %can be uncommented if want to save the model to
%open in comsol
out = model;
