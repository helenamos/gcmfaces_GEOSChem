function regrid_dep_ll2llc( infile_bpch     ,...
                            GC_path         ,...
                            outfile_gasdep  ,...
                            outfile_partdep ,...
                            outfile_popgconc,...
                            gc_yyyy         ,...
                            gc_mm           ,...
                            PCB             ,...
                            LPLOT           )

%=================================================================
% OBJECTIVE
%  Regrid 2D GEOS-Chem atmospheric deposition and atmospheric 
%  concentrations from a 4x5 lat-lon grid to the MITgcm ECCOv4 
%  lat-lon-cap ("llc90") grid. Write result to binary files to be 
%  read by MITgcm as forcing fields. 
%
% INPUTS
%   infile_bpch      : Character string providing filename for the 
%                      GEOS-Chem atmospheric deposition. Must end in 
%                      ".bpch".
%   GC_path          : Character string with filepath to the directory
%                      where infile_bpch is, as well as the tracerinfo.dat
%                      and diaginfo.dat files.
%   outfile_gasdep   : Character string to name regridded gas-phase
%                      deposition to feed to the MITgcm. Must end in
%                      ".bin".
%   outfile_partdep  : Character string to name regridded part-phase
%                      deposition to feed to the MITgcm. Must end in
%                      ".bin".
%   outfile_popgconc : Character string to name regridded part-phase
%                      deposition to feed to the MITgcm. Must end in
%                      ".bin".
%   gc_yyyy          : Year of simulated deposition.
%   gc_mm            : Month of simulated deposition.
%   PCB              : String indicating the PCB congener. Accepted strings:
%                         PCB-28  or PCB28  or PCB 28
%                         PCB-52  or PCB52  or PCB 52
%                         PCB-101 or PCB101 or PCB 101
%                         PCB-118 or PCB118 or PCB 118
%                         PCB-138 or PCB138 or PCB 138
%                         PCB-153 or PCB153 or PCB 153
%                         PCB-180 or PCB180 or PCB 180   
%   LPLOT            : Logical for plotting regridded depostion. 
%                      'TRUE'  will produce plots.
%                      'FALSE' will supress plots. 
%
% NOTES
%   (01) Currently assumes GEOS-Chem output is on a 4x5 global grid.
%   (02) Currently assumes MITgcm output is on a LLC90 grid.
%   (03) You need a copy of Gael Forget's gcmfaces package and Seb
%        Eastham's BPCHFunctions_v2 package.
%
%        gcmfaces available here:
%        /home/geos_harvard/helen/MATLAB/BPCHFunctions_v2/
%
%        BPCHFunctions_v2 available here:
%        http://wiki.seas.harvard.edu/geos-chem/index.php/Matlab_software_tools_for_use_with_GEOS-Chem
%    
%
% REVISION HISTORY
%   25 May 2015 - H. Amos - v1.0 created. 
%   19 Jun 2015 - H. Amos - Came back to fix issues left unresolved. 
%   23 Jun 2015 - H. Amos - Add atmospheric concentrations
%   
%
% Helen M. Amos 
% amos@fas.harvard.edu
%=================================================================

% close all open figure windows
close all;

% path to BPCH functions
addpath('/home/geos_harvard/helen/MATLAB/BPCHFunctions_v2/')

%-----------------------------------------------------------------
% Physical constants
%-----------------------------------------------------------------

% molecular weight (g/mol)
if     strcmp(PCB,'PCB-28' ) | strcmp(PCB,'PCB28' ) | strcmp(PCB,'PCB 28' )
   MW = 257.54; 
elseif strcmp(PCB,'PCB-52' ) | strcmp(PCB,'PCB52' ) | strcmp(PCB,'PCB 52' )
   MW = 291.99; 
elseif strcmp(PCB,'PCB-101') | strcmp(PCB,'PCB101') | strcmp(PCB,'PCB 101')
   MW = 326.43; 
elseif strcmp(PCB,'PCB-118') | strcmp(PCB,'PCB118') | strcmp(PCB,'PCB 118')
   MW = 326.43; 
elseif strcmp(PCB,'PCB-138') | strcmp(PCB,'PCB138') | strcmp(PCB,'PCB 138')
   MW = 360.88; 
elseif strcmp(PCB,'PCB-153') | strcmp(PCB,'PCB153') | strcmp(PCB,'PCB 153')
   MW = 360.88; 
elseif strcmp(PCB,'PCB-180') | strcmp(PCB,'PCB180') | strcmp(PCB,'PCB 180')
   MW = 395.32; 
else
  message('*ERROR* Must provide valid PCB congener!')   
end

% for PV = nRT
P0 = 1;      % standard pressure (atm)
T0 = 298.15; % standard temperature (K)
R  = 0.0821; % universal gas constant (L atm mol^-1 K^-1)

%-----------------------------------------------------------------
% read monthly total PCB deposition (kg)
%   --> 2D field
%   --> sum of dry + wet deposition
%   --> dimensions of output are [longitude latitude time]
%-----------------------------------------------------------------

% deposition of gas-phase PCB
disp(' '); disp('Reading GasDep from GEOS-Chem bpch output.');
gasdep_latlon  = readBPCHSingle( [GC_path, infile_bpch],... 
                                 'C_POP_DEPO',...
                                 'T_GasDep',...
                                 [GC_path 'tracerinfo.dat'],...
                                 [GC_path 'diaginfo.dat'],...
                                 true, false );

% deposition of OCPO-phase PCB
disp(' '); disp('Reading OCPODep from GEOS-Chem bpch output.'); 
ocpodep_latlon = readBPCHSingle( [GC_path, infile_bpch],... 
                                 'C_POP_DEPO',...
                                 'T_OCPODep',...
                                 [GC_path 'tracerinfo.dat'],...
                                 [GC_path 'diaginfo.dat'],...
                                 true, false );

% deposition of OCPI-phase PCB
disp(' '); disp('Reading OCPIDep from GEOS-Chem bpch output.'); 
ocpidep_latlon = readBPCHSingle( [GC_path, infile_bpch],... 
                                 'C_POP_DEPO',...
                                 'T_OCPIDep',...
                                 [GC_path 'tracerinfo.dat'],...
                                 [GC_path 'diaginfo.dat'],...
                                 true, false );
% deposition of BCPO-phase PCB
disp(' '); disp('Reading BCPODep from GEOS-Chem bpch output.'); 
bcpodep_latlon = readBPCHSingle( [GC_path, infile_bpch],... 
                                 'C_POP_DEPO',...
                                 'T_BCPODep',...
                                 [GC_path 'tracerinfo.dat'],...
                                 [GC_path 'diaginfo.dat'],...
                                 true, false );

% deposition of BCPI-phase PCB
disp(' '); disp('Reading BCPIDep from GEOS-Chem bpch output.'); 
bcpidep_latlon = readBPCHSingle( [GC_path, infile_bpch],... 
                                 'C_POP_DEPO',...
                                 'T_BCPIDep',...
                                 [GC_path 'tracerinfo.dat'],...
                                 [GC_path 'diaginfo.dat'],...
                                 true, false );

% sum OC and BC deposition
partdep_latlon = ocpodep_latlon + ocpidep_latlon + ...
                 bcpodep_latlon + bcpidep_latlon; 

% ----> Comeback and remove this when coupling is live <----
%
% we'll be regridding/passing one snapshot at a time, so for now
% just take the last time month of GEOS-Chem output and write the
% regridding code with that
gasdep_latlon  = squeeze( gasdep_latlon(:,:,end) );
partdep_latlon = squeeze( partdep_latlon(:,:,end) );

% make sure data is double
gasdep_laton   = double(gasdep_latlon);
partdep_laton  = double(partdep_latlon);

%-----------------------------------------------------------------
% read monthly gaseous PCB atmospheric concentrations (ppbv)
%   --> 3D field
%-----------------------------------------------------------------

disp(' '); disp('Reading POPG concentration from GEOS-Chem bpch output.'); 
popgconc_latlon = readBPCHSingle( [GC_path, infile_bpch],... 
                                 'C_IJ_AVG',...
                                 'T_POPG',...
                                 [GC_path 'tracerinfo.dat'],...
                                 [GC_path 'diaginfo.dat'],...
                                 true, false );

% ----> Comeback and remove this when coupling is live <----
%
% we'll be regridding/passing one snapshot at a time, so for now
% just take the last time month of GEOS-Chem output and write the
% regridding code with that
popgconc_laton = squeeze( popgconc_latlon(:,:,:,end) );

% the ocean only cares about the surface level
popgconc_latlon = squeeze( popgconc_latlon(:,:,1) );

% make sure data is double
popgconc_latlon = double( popgconc_latlon );

%-----------------------------------------------------------------
% GEOS-Chem 4x5 grid information
%
% lat and lon from GEOS-Chem Users' Guide:
% http://acmg.seas.harvard.edu/geos/doc/man/
%-----------------------------------------------------------------

% load lat-lon grid info
GC_gridinfo

% shift deposition arrays by 180 degrees to match longitude
gasdep_latlon   = circshift( gasdep_latlon  , [76/2, 0] );
partdep_latlon  = circshift( partdep_latlon , [76/2, 0] );
popgconc_latlon = circshift( popgconc_latlon, [76/2, 0] );

% leap years since between 1920 and 2012
leapyr = [1924:4:2012];

% days per month
if abs(gc_yyyy-leapyr)==0
   dpm = [31 29 31 30 31 30 31 31 30 31 30 31];  % non-leap year
else
   dpm = [31 28 31 30 31 30 31 31 30 31 30 31];  % non-leap year
end

% calculate number of seconds on month of current
% GEOS-Chem output
numsec = dpm( gc_mm ) * 24 * 3600;

% convert deposition from units of kg to kg/m2/sec
gasdep_latlon  = (1/numsec) * gasdep_latlon ./ surfarea;
partdep_latlon = (1/numsec) * partdep_latlon ./ surfarea;

%-----------------------------------------------------------------
% convert concentration from ppbv to ng/m3
%-----------------------------------------------------------------

% 1 ppbv PCB is:
%
%   1 mol PCB
% -------------
%  1e9 mol air

% STEP 1
%  convert mol PCB to ng:
%
%               (MW) g     1e9 ng
%  1 mol PCB x -------- x --------
%                mol         g
popgconc_latlon = MW * 1e9 * popgconc_latlon;

% STEP 2
%  convert 1e9 mol air to m3 using PV = nRT
%  
%  V = nRT / P
V_L  = 1e9 * R * T0 / P0; % volume (liters)
V_m3 = 1e-3 * V_L;        % volume (m3)

% STEP 3
%  Finish conversion, by dividing by volume
popgconc_latlon = (1/V_m3) * popgconc_latlon; % (ug/m3)

%=================================================================
% Regrid 2D GEOS-Chem 4x5 lat-lon output to MITgcm ECCOv4 llc90 
%=================================================================

% add gcmfaces library
addpath( genpath('/home/geos_harvard/helen/MATLAB/gcmfaces/gcmfaces/') )

% load ECCOv4 grid information
grid_load('/home/geos_harvard/helen/MATLAB/gcmfaces/GRID/',5,'compact');

% remap lat-lon to llc90
disp('Regridding lat-lon deposition to llc90.'); disp(' ');
gasdep_llc90   = gcmfaces_remap_2d( lon_gc, lat_gc, gasdep_latlon  , 4 );
partdep_llc90  = gcmfaces_remap_2d( lon_gc, lat_gc, partdep_latlon , 4 );
popgconc_llc90 = gcmfaces_remap_2d( lon_gc, lat_gc, popgconc_latlon, 4 );

% write llc90 file to binary to feed into MITgcm
disp('Writting llc90 deposition to binary.'); disp(' ');
write2file( outfile_gasdep  , convert2gcmfaces( gasdep_llc90   ) );
write2file( outfile_partdep , convert2gcmfaces( partdep_llc90  ) );
write2file( outfile_popgconc, convert2gcmfaces( popgconc_llc90 ) );

% success message
disp('Regridding lat-lon to llc90 was a success!'); disp(' ');


%-----------------------------------------------------------------
% Visual check that regridding didn't produce garbarge
%-----------------------------------------------------------------

if strcmp( LPLOT, 'TRUE' )
  figure(1);
  m_map_gcmfaces( gasdep_llc90 );
  title('GAS DEP')

  figure(2);
  m_map_gcmfaces( partdep_llc90 );
  title('PART DEP')
end
