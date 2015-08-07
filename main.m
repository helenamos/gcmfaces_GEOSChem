clear all; close all; 

%=================================================================
% OBJECTIVE
%   Driver for series of functions that allows you to regrid GEOS-
%   Chem output to MITgcm and vice versa. 
%
% NOTES
%   (01) Currently assumes GEOS-Chem output is on a 4x5 global grid.
%   (02) Currently assumes MITgcm output is on a LLC90 grid.
%   (03) You need a copy of two MATLAB packages:
%
%        gcmfaces available here:
%          /home/geos_harvard/helen/MATLAB/BPCHFunctions_v2/
%
%        BPCHFunctions_v2 available here:
%          http://wiki.seas.harvard.edu/geos-chem/index.php/Matlab_
%          software_tools_for_use_with_GEOS-Chem
%    
%
% REVISION HISTORY
%   25 May 2015 - H. Amos - v1.0 created. 
%
% Helen M. Amos (hamos@hsph.harvard.edu)
%=================================================================

%-----------------------------------------------------------------
% Regrid deposition: lat-lon ----> lat-lon-cap ("llc90")
%-----------------------------------------------------------------

% location of GEOS-Chem deposition data
GC_path         = '/home/clf/Geos/GEOS-Chem.v9-01-03_wPAHs/28_0422_MERRAseas/2010/';
GC_file         = '2010.bpch';   % <-- this has to be updated every time step
                                 %     we pass information from the atmosphere
                                 %     to the ocean

% year and month of simulated deposition
gc_yyyy         = 2010;          % <-- these have to be updated every time step
                                 %     we pass information from the atmosphere
                                 %     to the ocean
gc_mm           = 12;            % <--

% name deposition files that will go to the MITgcm
outfile_gasdep   = 'gasdep_llc90.bin'  ;  % gas-phase      deposition (kg/m2/s)
outfile_partdep  = 'partdep_llc90.bin' ;  % particle-phase deposition (kg/m2/s)
outfile_popgconc = 'popgconc_llc90.bin';  % atmospheric concentration (ng/m3)

% regrid GEOS-Chem lat-lon deposition to MITgcm llc90 grid
regrid_dep_ll2llc( GC_file         ,...
                   GC_path         ,...
                   outfile_gasdep  ,...
                   outfile_partdep ,...
                   outfile_popgconc,...
                   gc_yyyy         ,...
                   gc_mm           ,...
                   'PCB-28'        ,...  
                   'TRUE'          )
return

%-----------------------------------------------------------------
% Regrid evasion: llc90 --> lat-lon
%-----------------------------------------------------------------

% read MITgcm evasion (units?)
ocnpath       = '/net/fs02/d2/geos_harvard/helen/MITgcm_ECCOv4/verification/global_pcb_llc90/run/diags/';
ocndiag       = 'PCBaEVAS'; 
time_llc90    = 8;           % <-- this has to be updated every timestep we
                             %     pass information from the ocean to atmosphere

% name of netcdf file containing regridded evasion to pass to GEOS-Chem
outfile_evas = 'evasion_latlon.nc';

% regrid MITgcm evasion from llc90 to GEOS-Chem 4x5 lat-lon grid
regrid_evas_llc2ll( ocnpath, ocndiag, time_llc90, outfile_evas, 'TRUE' )
