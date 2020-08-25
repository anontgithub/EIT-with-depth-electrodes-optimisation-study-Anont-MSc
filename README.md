# EIT-with-depth-electrodes-optimisation-study-Anont-MSc
Imaging fast neural activity using EIT with depth electrodes: optimisation study by Anont for MSc

Hello, this is the README file for Anont's MSc Project on EIT depth electrodes optimisation using comsol and matlab  UCL (2019-2020)
BY Anont Hewchaiyaphum
If you have any questions feel free to contact me on anont.hewchaiyaphum.19@ucl.ac.uk (UCL email)
Github link:

The folder contains 4 folders, Backgroundgithub, P02github P005github and sum (the word github in the names will be omitted for the rest of the README)
Background contains files used to run the background simulation, without the perutabtion which the results are then used for calculating dVs.
P02 contains files for simulations with perturbation diameter 0.2mm
P005 contains files for simulations with perturbation diameter 0.05mm.
sum contains files for the objective function, the last stage of the project.

This README will hope to explain the contents of those files and how to use them. 

***There are two important files which you will see often in the scripts, they are errorlist and tconfig2. They will be explained at the end of this README.

Firstly each file, background P02 and P005 contain the matlab script used to run all simulations for that perutabtion size.
For background it is mainmodel6ver1.m
For P02 it's mainmodel6ver1P02.m
For P005 it's mainmodel6ver1P005.m
They are all commented. Just open them up and press run on matlab and they should start running. They produce textfile for results of electrode voltages of each current injection pair
in the file they are located in so just note that running them will produce a lot of files.
The files have have alreadly completed running are already in the same folder, they go by the format of
loopresultx_y, x beinging the configuration number and y being the current injecting pair. For P02 and P005 they are loopresult0_2Px_y abd loopresult0_05Px_y, respectively.

So after the models have run and you have all the results which are the loopresults files then you are ready for the processing the data.

Firstly, the data processing files for background will be explained first.
They should be run in the order explained here.
1) -collateall-
collateall collates all the loopresults textfiles all into matlab mat file called fulldataRR.mat
2) -removeinjele-
This script removes injecting electrode results from fulldataRR as they cannot be used to calculate the dVs. It produces fullBdatarinj.mat
3)-keepinjele-
This script keeps only results from injecting electrode results. It produces fulldataRROinj which will be used for contactimpedance scaling.
4) -contactimpedancescaling-
This script creates a scaling factor called scaleCB which can be applied to results so that no voltage is larger than 12V even with contact
impedance voltage added. scaleCB is used later on.
Background also includes two scripts that are the design parameters for the final objective function
5) -DPshankdepth-
Produces shankdepthN which is the normalised results for the the design parameter.
6) -DPnumberofshank-
Produces numshnkN which is the normalised results aswell for the design parameter. These will be later used for the objective function.

Secondly, we go to the data processing files of P02, some are quite similar
1) -collateall-
Same function as in background folder but for P02 instead, produces full02dataRR
2) - removeinjele-
Same function as in background folder but for P02 instead, produces full02datarinj
3) - dvproducer-
To run this script you must copy files fullBdatarinj and scaleCB created in the background folder into the P02 folder.
This script produces the dVs between the P02 and background voltages. It creates the dV between the files full02datarinj and fullBdatarinj.  
It also then applies scaleCB and scales the resulting dVs produced so that the results are contact impedance scaled. scaleCB was produced in the file contactimpedancescaling
in background. dvproducer produces the file duV02baseScF with the dVs.
4) -DPovernoise-
This script is the design parameter for total number of electrodes over the noisefloor for P02.
The script uses duV02baseScF as the dVs and tconfig(9,i) (row 9), which contains the noise for all configurations.
It produces overnoiseN02 which is a normalised value with 1 being maximum.
5) -DPtoptenmean-
Design parameter for mean of top 10% of electrode dVs for a configuration. Uses duV02baseScF for dVs.
Produces toptenmeanN02 which is normalised.

Then we go to P005, most files are similar to P02 but are just adressing different file names
1) -collateall-
Same function as in P02 and background folder but for P005 instead, produces full005dataRR
2) - removeinjele-
Same function as in P02 and background folder but for P005 instead, produces full005datarinj
3) - dvproducer-
To run this script you must copy files fullBdatarinj and scaleCB created in the background folder into the P005 folder.
Similar function as in P02. It creates the dV between the files full005datarinj and fullBdatarinj.  
Produces duV005baseScF
4) -DPovernoise-
Similar function as in P02. Uses duV005baseScF and noise from row 9 of tconfig2. Produces overnoiseN005.
5) -DPtoptenmean-
Similar function as in P02. Uses duV005baseScF and produces toptenmeanN005.

Now finally onto sum, the folder for the objective function
We have calculated the design parameter results already in the previous folders so now copy them to this folder.
They include shankdepthN, numshnkN, overnoiseN02, toptenmeanN02, overnoiseN005 and toptenmeanN005.
Also ensure that tconfig2 and errorlist are in the folder as they are required. errorlist may not be required in some circumstance as explained earlier. 
1) -objectivefunctionsum-
The script loads all the different design parameter results and sums them up to be the objective function results for all configurations.
It also omitts configurations with no electrode dVs over the noise.
It also plots the objective function against the all the configurations.
Addtionally it produces sumplot, a datafile used for objfunanalyse
2 -objfunanalyse-
This script plots the objective function values for configurations neighbouring the optimal configuration. 
It varys one parameter at a time while fixing all the other parameters.
The script can plot all line in one graph or it can be subplotted separately.

Explaination of errorlist and tconfig. The two files need to be in all folders or atleast always accessable by the scripts. Errorlist can be deleted 
in the circustance that is described below. 

Errorlist.mat is a file containing a list of configuration number that have resulting in a meshing error when I have previously run the simulation.
Consequently, by running the same simulation again, same parameters and same mesh, the same errors will occur again. 
Therfore, I have a included a functionality in the start of most scripts that just skip over the error configurations.
This means saved time not computing something that will end up as an error or looking for results that have not been simulated. 
Therefore, if you were to run a different simulation, one with different mesh or parameters then I would advise on deleting the if statements at the start 
of scripts that skip over configurations in the errorlist. 

tconfig2 (mat filename) contains tconfig (array name) which is the table of configurations commonly referred to in most scripts. The tconfig2 is an array that
contains parameters for all configurations in each row.
The rows are the parameters and each column is a different configuration.
The rows are:
1) shank spacing (mm)
2)shank depth (mm)   (shank depth is swapped with shank width in the thesis)
3)Intra shank electrode spacing (mm)
4)Total number of electrodes in a configuration
5) Number of electrodes per shank
6) Electrode height (mm)
7) Electrode surface area (m^2)
8) Electrode surface area (mm^2)
9) Noise for an electrode (microvolts)
10) Contact impedance for an electrode (ohms)
11) Number of current injecting electrode pairs for a configuration (not the number of current injecting electrodes, but that would be the pairs+1)

Thank you for reading,
Anont Hewchaiyaphum

