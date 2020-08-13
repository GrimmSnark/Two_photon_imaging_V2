# Two_photon_imaging_V2
New version of two photon imaging code


Complete Guide to 2P Code Installation and Use

This toolbox is designed to allow the user to present visual stimuli using pyschophysics toolbox and sync experimental events with Bruker Prairie Two Photon Systems. This toolbox also contains a number of analysis scripts to extract stimulus driven Calcium transient activity from imaging recordings. 

Hardware requirements:
1.	One Bruker-Prairie two photon imaging system (Ultima etc)
2.	One Windows computer with graphics card compatible with psychtoolbox
3.	RECOMMENDED, separate Windows analysis computer with good GPU (GTX 1070 and above).
4.	Interface box to communicate between stimulus computer and Bruker system (Measurement Computing USB-1408FS preferred)

Software requirements for analysis computer:
1.	Download toolbox and add to Matlab path
2.	Install psychophysics toolbox (http://psychtoolbox.org/)
3.	If you want to be able to use no rigid motion correction please clone the non-rigid motion correction toolkit (https://github.com/flatironinstitute/NoRMCorre) 
4.	Install an up to date version of FIJI (https://fiji.sc/) 
5.	Connect FIJI with matlab as explained here (http://bigwww.epfl.ch/sage/soft/mij/) NB, instead of using ij.jar, place the up to date version from your FIJI package (FIJI.app/jars), it will be named something like ij-1.52g.jar into the MATLAB folder.
6.	Install Cell Magic Wand into FIJI (https://www.maxplanckflorida.org/fitzpatricklab/software/cellMagicWand/) OR (https://github.com/GrimmSnark/Cell_Magic_Wand)
7.	Install CaImAn-MATLAB analysis package from github, this package uses some of their functions (https://github.com/flatironinstitute/CaImAn-MATLAB ).
8.	You may need to increase your java heap size for FIJI and matlab to work with large images see (https://www.mathworks.com/matlabcentral/answers/92813-how-do-i-increase-the-heap-space-for-the-java-vm-in-matlab-6-0-r12-and-later-versions) NB use the java.opts method. 
9.	You will need to modify the "intializeMIJ.m" to your local FIJI path.

Software requirements for stimulus computer:
1.	Download toolbox and add to Matlab path
2.	Install psychophysics toolbox (http://psychtoolbox.org/) 
3.	Install Measurement Computing USB-1408FS and MC package for Matlab

Stimulus computer setup:
	This system uses an analogue to digital conversion to communicate between the stimulus computer and the Bruker-Prairie two photon imaging system. This is achieved by splitting up the output range of the MC USB 1408FS (0-4V) into 255 discrete levels which are used to produce pulses by the stimulus computer which are recorded by the Bruker-Prairie two photon imaging system. These pulses are used event numbers to synchronize the experimental stimulus to the functional imaging. This conversion requires set up in the following procedure:
1.	Follow MC USB1408FS instructions to connect the first analogue channel out (AO0) to the first analogue in (AI0) on the Bruker- Prairie System
2.	Follow MC USB1408FS instructions to connect the digital port A to the trigger input on the Bruker- Prairie System
3.	Set up TSeries run on the Bruker- Prairie System, ensure that the ‘start with external trigger button’ is selected. Be sure that you have the ‘voltage recording’ set up to record the first analogue channel. 
4.	Run testDAQOutSignal and save the resulting TSeries data. We are only interested in the voltage excel file. 
5.	Copy this TSeries folder to the stimulus computer and run readEventFileSetup.m to create PrairieVoltageInfo.mat, which contains the event voltage level information which is the basis of the stimulus computer to Bruker computer communication.
6.	Open readEventFilePrairie and change the “keyFilepath” variable to the location of the newly created PrairieVoltageInfo.mat.
7.	Set up stimulus monitor position and create entry in degreeVisualAngle2Pixels so that stimulus are created as the correct size. NB Make sure all PTB experiment scripts run use the correct setup number.

Now you can run stimulus experiment code from the PTB_Experiments folder.

Please refer to the documents in the "Doc" folder for more setup and usage information

Any questions please email msavage@uabmc.edu
