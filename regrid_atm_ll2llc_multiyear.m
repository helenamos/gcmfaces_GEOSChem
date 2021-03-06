clear all; close all; 
%=================================================================
% OBJECTIVE
%   Regrid multiple years of monthly atmospheric deposition and
%   concentration output from GEOS-Chem's 4x5 regular lat-lon
%   grid to a single binary file to pass to ECCO v4 MITgcm. 
%
% NOTES
%   (01) This script assumes the bpch files from GEOS-Chem are annual
%        files with 12 monthly means.
%
% REVISION HISTORY
%   23 Jun 2015 - H. Amos - v1.0 created. Based on regrid_dep_ll2llc.m
%
% Helen M. Amos
% amos@fas.harvard.edu
%=================================================================

%-----------------------------------------------------------------
% ------> If this becomes a function, these will be <--------
%         the input parameters.
%-----------------------------------------------------------------

% PCB congener of interest
% - string, format 'PCB#', where # is the congener number
PCB     = 'PCB153'; 

% supress plotting for now
LPLOT = 'TRUE';

% year and month of simulated deposition
% - note: must be a STRING
%gc_yyyy = {'1930','1931','1932','1933','1934','1935','1936','1937','1938','1939',...
%           '1940','1941','1942','1943','1944','1945','1946','1947','1948','1949'};

%gc_yyyy = {'1950','1951','1952','1953','1954','1955','1956','1957','1958','1959',...
%           '1960','1961','1962','1963','1964','1965','1966','1967','1968','1969'};

%gc_yyyy = {'1970','1971','1972','1973','1974','1975','1976','1977','1978','1979',...
%           '1980','1981','1982','1983','1984','1985','1986','1987','1988','1989'};

% for PCB 180 and 153
%gc_yyyy = {'1970','1971','1972','1973','1974','1975','1976','1977','1978','1979',...
%           '1980'};
%gc_yyyy = {'1981','1982','1983','1984','1985','1986','1987','1988','1989'};

gc_yyyy = {'1990','1991','1992','1993','1994','1995','1996','1997','1998','1999',...
           '2000','2001','2002','2003','2004','2005','2006','2007','2008','2009'};


% month of GEOS-Chem simualtion
% - note: must be an INTEGER
% - provide a specific month (e.g., gc_mm = 12)
% - or leave empty if you want all time slices (e.g., gc_mm = [ ]);
gc_mm   = [ ];

%-------------------------------------------
% location of Carey's archived GEOS-Chem PCB
%-------------------------------------------
%
% PCB-28
%--------
%...1930 thru 1989
%clf_path     = '/net/fs03/d1/clf/scratch_disk_overflow/GEOS-Chem.v9-01-03_wPAHs/PCB28_1930_2100/';
%...1990 thru 2009
%clf_path     = '/home/clf/Geos/GEOS-Chem.v9-01-03_wPAHs/28_0422_MERRAseas/';

% PCB-118
%--------
%...1930 thru 1989
%clf_path     = '/net/fs03/d1/clf/scratch_disk_overflow/GEOS-Chem.v9-01-03_wPAHs/PCB118_1930_2100/';
%... 1990 thru 2009
%clf_path     = '/home/clf/Geos/GEOS-Chem.v9-01-03_wPAHs/118_0422_MERRAseas/';

% PCB-153
%--------
%... 1930 thru 1980
%clf_path     = '/net/fs03/d1/clf/scratch_disk_overflow/GEOS-Chem.v9-01-03_wPAHs/PCB153_1930_2100/';
%... 1981 thru 2009
clf_path     = '/home/clf/Geos/GEOS-Chem.v9-01-03_wPAHs/153_0422_MERRAseas/';

% PCB-180
%--------
%... 1930 thru 1980
%clf_path     = '/net/fs03/d1/clf/scratch_disk_overflow/GEOS-Chem.v9-01-03_wPAHs/PCB180_1930_2100/';
%... 1981 thru 2009
%clf_path     = '/home/clf/Geos/GEOS-Chem.v9-01-03_wPAHs/180_0422_MERRAseas/';

disp(['Reading from ' clf_path]);
disp(' ');

%-----------------------------------------------------------------
% ------> If this becomes a function, this is <--------
%         where the function begins.
%-----------------------------------------------------------------

% add gcmfaces library
addpath( genpath('/home/geos_harvard/helen/MATLAB/gcmfaces/gcmfaces/') )

% binary input files to be read into MITgcm
% - units on file binary files will be:
%      deposition    (mol/m2/s)
%      concentration (mol/m3)
%
if numel(gc_yyyy) > 1
   outfile_gasdep   = [PCB, '_gasdep_'  ,gc_yyyy{1},'-',gc_yyyy{end},'_eccov4_llc90.bin'];  
   outfile_partdep  = [PCB, '_partdep_' ,gc_yyyy{1},'-',gc_yyyy{end},'_eccov4_llc90.bin'];  
   outfile_popgconc = [PCB, '_popgconc_',gc_yyyy{1},'-',gc_yyyy{end},'_eccov4_llc90.bin'];  
else
   outfile_gasdep   = [PCB, '_gasdep_'  ,gc_yyyy{1},'_eccov4_llc90.bin'];  
   outfile_partdep  = [PCB, '_partdep_' ,gc_yyyy{1},'_eccov4_llc90.bin'];  
   outfile_popgconc = [PCB, '_popgconc_',gc_yyyy{1},'_eccov4_llc90.bin'];  
end

% initialize counter
tt = 1;

% intialize arrays for monthly output
gasdep_llc90   = zeros( 90, 1170, 12*numel(gc_yyyy) ); 
partdep_llc90  = zeros( 90, 1170, 12*numel(gc_yyyy) );
popgconc_llc90 = zeros( 90, 1170, 12*numel(gc_yyyy) );

% loop over years
for YR = 1:numel(gc_yyyy);

 % GEOS-Chem file path
 GC_path     = [clf_path, gc_yyyy{YR}, '/'];      
 infile_bpch = [gc_yyyy{YR}, '.bpch'];   

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
 % read GEOS-Chem PCB deposition (kg)
 %   --> will read all time slices into a single variable
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

 % the ocean only cares about the surface level
 popgconc_latlon = squeeze( popgconc_latlon(:,:,1,:) );

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
 if numel(size(gasdep_latlon)) == 2 % if you have 2D (lon x lat) data
   gasdep_latlon   = circshift( gasdep_latlon  , [76/2, 0] );
   partdep_latlon  = circshift( partdep_latlon , [76/2, 0] );
   popgconc_latlon = circshift( popgconc_latlon, [76/2, 0] );
 else % if you have 3D data (lon x lat x time)
   gasdep_latlon   = circshift( gasdep_latlon  , [76/2, 0, 0] );
   partdep_latlon  = circshift( partdep_latlon , [76/2, 0, 0] );
   popgconc_latlon = circshift( popgconc_latlon, [76/2, 0, 0] );
 end

 % leap years since between 1920 and 2012
 leapyr = [1924:4:2012];

 % days per month
 if abs(str2num(gc_yyyy{YR})-leapyr)==0
    dpm = [31 29 31 30 31 30 31 31 30 31 30 31];  % non-leap year
 else
    dpm = [31 28 31 30 31 30 31 31 30 31 30 31];  % non-leap year
 end

 % convert units of deposition
 if numel(gc_mm) == 1; % for a specific month
 
   % number of seconds in desired month of output
   numsec = 24 * 3600 * dpm( gc_mm ); 

   % convert units: kg --> mol/m2/sec
   gasdep_latlon(:,:,gc_mm)  = 1e3/(MW*numsec) * gasdep_latlon(:,:,gc_mm)  ./ surfarea;
   partdep_latlon(:,:,gc_mm) = 1e3/(MW*numsec) * partdep_latlon(:,:,gc_mm) ./ surfarea;

 elseif numel(gc_mm) == 0; % grab all time slices in bpch file

   % number of seconds per month
   numsec = 24 * 3600 * dpm;

   % convert units: kg --> mol/m2/sec
   for j = 1:12; % loop over months
     gasdep_latlon(:,:,j)  = 1e3/(MW*numsec(j)) * gasdep_latlon(:,:,j)  ./ surfarea;
     partdep_latlon(:,:,j) = 1e3/(MW*numsec(j)) * partdep_latlon(:,:,j) ./ surfarea; 
   end

 else
   message('*ERROR* At unit conversion, gc_mm must be a single integer or empty [ ].')
 end


 %-----------------------------------------------------------------
 % convert concentration from ppbv to mol/m3
 %-----------------------------------------------------------------

 % 1 ppbv PCB is:
 %
 %   1 mol PCB
 % -------------
 %  1e9 mol air

% want final units to be mol/m3 (hma, 29 jun 2015)
% % STEP 1
% %  convert mol PCB to ng:
% %
% %               (MW) g     1e9 ng
% %  1 mol PCB x -------- x --------
% %                mol         g
% popgconc_latlon = MW * 1e9 * popgconc_latlon;

 % STEP 2
 %  convert 1e9 mol air to m3 using PV = nRT
 %  
 %  V = nRT / P
 V_L  = 1e9 * R * T0 / P0; % volume (liters)
 V_m3 = 1e-3 * V_L;        % volume (m3)

 % STEP 3
 %  Finish conversion, by dividing by volume
 popgconc_latlon = (1/V_m3) * popgconc_latlon; % (mol/m3)

 %=================================================================
 % Regrid 2D GEOS-Chem 4x5 lat-lon output to MITgcm ECCOv4 llc90 
 %=================================================================

% Move outside of yyyy loop (hma, 29 jun 2015)
% % add gcmfaces library
% addpath( genpath('/home/geos_harvard/helen/MATLAB/gcmfaces/gcmfaces/') )

 % load ECCOv4 grid information
 grid_load('/home/geos_harvard/helen/MATLAB/gcmfaces/GRID/',5,'compact');
 
 % remap lat-lon to llc90
 disp(' '); disp('Regridding lat-lon deposition to llc90.'); disp(' ');

 if numel(gc_mm) == 1; % a single time slice
   % remap lat-lon to lat-lon-cap
   gasdep_temp    = gcmfaces_remap_2d( lon_gc, lat_gc, gasdep_latlon  , 4 );
   partdep_temp   = gcmfaces_remap_2d( lon_gc, lat_gc, partdep_latlon , 4 );
   popgconc_temp  = gcmfaces_remap_2d( lon_gc, lat_gc, popgconc_latlon, 4 );  
  
   % convert to gcmfaces format
   gasdep_llc90   = convert2gcmfaces( gasdep_temp   );
   partdep_llc90  = convert2gcmfaces( partdep_temp  );
   popgconc_llc90 = convert2gcmfaces( popgconc_temp );

 elseif numel(gc_mm) == 0; % process all months in the bpch file
 
% Move outside of yyyy loop (hma, 29 jun 2015)
% 
%   % intialize arrays for montly output
%   gasdep_llc90   = zeros( 90, 1170, 12*numel(gc_yyyy) ); 
%   partdep_llc90  = zeros( 90, 1170, 12*numel(gc_yyyy) );
%   popgconc_llc90 = zeros( 90, 1170, 12*numel(gc_yyyy) );

   % display year being processed
   disp(' '); disp(['Processing year ',gc_yyyy{YR} ]); 

   % loop over months
   clear j; % for safety's sake
   for j = 1:12;
     % display month  currently being regrid
     disp(['   month : ', num2str(j) ])
    
     % for safety's sake
     clear gasdep_temp partdep_temp popgconc_temp; 

     % remap lat-lon to lat-lon-cap
     gasdep_temp   = gcmfaces_remap_2d( lon_gc, lat_gc, gasdep_latlon(:,:,j)  , 4 );
     partdep_temp  = gcmfaces_remap_2d( lon_gc, lat_gc, partdep_latlon(:,:,j) , 4 );
     popgconc_temp = gcmfaces_remap_2d( lon_gc, lat_gc, popgconc_latlon(:,:,j), 4 );  

     % convert to gcmfaces format
     gasdep_llc90(:,:,tt)   = convert2gcmfaces( gasdep_temp   );
     partdep_llc90(:,:,tt)  = convert2gcmfaces( partdep_temp  );
     popgconc_llc90(:,:,tt) = convert2gcmfaces( popgconc_temp );

     % increment counter
     tt = tt + 1;
   end

 else
   message('*ERROR* At regridding, gc_mm must be a single integer or empty [ ].')
 end

end % end loop over years

% write llc90 file to binary to feed into MITgcm
disp('Writting llc90 deposition to binary.'); disp(' ');
write2file( outfile_gasdep  , gasdep_llc90    );
write2file( outfile_partdep , partdep_llc90   );
write2file( outfile_popgconc, popgconc_llc90  );

% success message
disp('Regridding lat-lon to llc90 was a success!'); disp(' ');


%-----------------------------------------------------------------
% Visual check that regridding didn't produce garbarge
%-----------------------------------------------------------------

if strcmp( LPLOT, 'TRUE' )
  figure(1);
  m_map_gcmfaces( gasdep_temp );
  title('GAS DEPOSITION','FontSize',20)

  figure(2);
  m_map_gcmfaces( partdep_temp );
  title('PARTICLE DEPOSITION','FontSize',20)

  figure(3);
  m_map_gcmfaces( popgconc_temp );
  title('ATMOSPHERIC CONCENTRATION','FontSize',20)
end
