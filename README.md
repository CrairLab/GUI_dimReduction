# GUI_dimReduction

A graphic user interface for dimsionality reduction. Currently include t-SNE and diffusion map, will incorporate N-cut parcellation in the future.
Required environment:  Later than Matlab 2017a

! Note that any version after 12/18/2020 requires PHATE from https://github.com/KrishnaswamyLab/PHATE/tree/master/Matlab !

I.	Installation:
Download the GUI_dimReduction master package at https://github.com/CrairLab/GUI_dimReduction, which include:
a.	GUI_dimReduction.m and GUI_dimReduction.fig: main interface/control window
b.	CorrespondMaps.m and CorrespondMaps.fig: GUI that allows visualization of corresponding user-selected data points in tSNE or diffusion map to brain map (pixelwise analysis) or movie frames (framewise analysis)  
c.	MovieData and dimReduction classes: contain functions that will be called by the GUI_dimReduction and CorrespondMaps (e.g. functions that actually calculate t-SNE and diffusion map)
Run the GUI_dimReduction.m in matlab
   
II.	Workflow: 
See workflow.pptx

