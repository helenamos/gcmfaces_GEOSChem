function regrid_evas_llc2ll( ocnpath, ocndiag, time_llc90, outfile_evas, LPLOT )

%=================================================================
% OBJECTIVE
%  Regrid 2D MITgcm ECCOv4 ocean evasion from the llc90 grid to 
%  GEOS-Chem's 4x5 lat-lon grid. Write the result to a netcdf file
%  to be read into GEOS-Chem. 
%
% INPUTS
%   LPLOT           : Logical for plotting regridded depostion. 
%                     'TRUE'  will produce plots.
%                     'FALSE' will supress plots. 
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
%   25 May 2015 - H. Amos - v1.0 created. Code structure adapted
%                           from gcmfaces/sample_analysis/example_
%                           faces2latlon2faces.m.
%
% Helen M. Amos (hamos@hsph.harvard.edu)
%=================================================================

% close all open figure windows
close all;

% add gcmfaces library
addpath(genpath('/home/geos_harvard/helen/MATLAB/gcmfaces/gcmfaces'));

% read evasion from MITgcm (mol/m2/s) 
disp(' '); disp('Reading MITgcm ECCOv4 ocean evasion...')
ocnevas_llc90 = rdmds( [ocnpath, ocndiag], time_llc90 );

% ------> Comeback and delete when you have 2D output from GCM <-----
%
% just take the surface layer, so you have a 2D field
ocnevas_llc90 = squeeze( ocnevas_llc90(:,:,1) );

%-----------------------------------------------------------------
% load parameters for llc90 grid
%-----------------------------------------------------------------
gcmfaces_global; global mytri;

gcmfaces_global;
dir0        = '/home/geos_harvard/helen/MATLAB/gcmfaces/gcmfaces/sample_input/'; 
nF          = 5; % number of faces ( 5 = llc90)
fileFormat  = 'compact';
dirGrid     = [dir0 '../../GRID/'];

% load grid information for llc90 grid
mygrid = [ ]; 
grid_load(dirGrid,nF,fileFormat,1);

% store reference grid
mygrid_refgrid = mygrid;

%-----------------------------------------------------------------
% load parameters for lat-lon grid
%-----------------------------------------------------------------

% load lat-lon grid info
disp(' '); disp('Loading GEOS-Chem grid information...')
GC_gridinfo

% convert [0,360] to [-180,180]
lon_gc = -180 + lon_gc;

% prepare mygrid for lat-lon with no mask
mygrid_latlon.nFaces     = 1;
mygrid_latlon.XC         = gcmfaces({lon_gc}); 
mygrid_latlon.YC         = gcmfaces({lat_gc});
mygrid_latlon.dirGrid    = 'none';
mygrid_latlon.fileFormat = 'straight';
mygrid_latlon.ioSize=size(lon_gc);

%-----------------------------------------------------------------
% interpolate llc90 ocean evasion to lat-lon grid
%-----------------------------------------------------------------

mygrid = mygrid_latlon; gcmfaces_bindata; 

veclon = convert2array(mygrid.XC); 
veclon = veclon(mytri.kk);
veclat = convert2array(mygrid.YC); 
veclat = veclat(mytri.kk);

% interpolate from llc90 grid to lat-lon grid
disp(' '); disp('Regridding ocean evasion from llc90 to lat-lon...')
mygrid = mygrid_refgrid; gcmfaces_bindata; 
vecfld = gcmfaces_interp_2d( convert2gcmfaces(ocnevas_llc90) ,veclon,veclat);

mygrid = mygrid_latlon; gcmfaces_bindata; 
ocnevas_latlon           = NaN*convert2array(mygrid.XC);  % make a dummy array
ocnevas_latlon(mytri.kk) = vecfld;                        % fill with data
ocnevas_latlon           = convert2array(ocnevas_latlon); % convert data to array

%-----------------------------------------------------------------
% Visual check that regridding didn't produce garbarge
%-----------------------------------------------------------------

if strcmp(LPLOT, 'TRUE')
  FLD = ocnevas_latlon{1};
  figure(1); 
  set(gca,'FontSize',14);
  pcolor(lon_gc,lat_gc,FLD); shading flat;
  colorbar;
  title('OCEAN EVASION: llc90 --> latlon') ;
end

%-----------------------------------------------------------------
% Write to netCDF for GEOS-Chem
%-----------------------------------------------------------------
    
% Note: dimensions of Hg data need to be [lon,lat] and the upper left
% corner should start at [-180,-90]
lat_nc = lat_gc_vec; 
lon_nc = lon_gc_vec - 180.;  % convert [0,360] to [-180,180]

% create the netcdf file
nc_filename = ( outfile_evas );
ncid        = netcdf.create( nc_filename, 'NC_CLOBBER' );
    
% define the dimensions
lat_name    = 'latitude';
lat_dimid   = netcdf.defDim( ncid, lat_name, numel( lat_nc ) );
    
lon_name    = 'longitude';
lon_dimid   = netcdf.defDim( ncid, lon_name, numel( lon_nc ) );
    
% define the coordinate variables
lat_varid   = netcdf.defVar( ncid, lat_name, 'double', lat_dimid );
lon_varid   = netcdf.defVar( ncid, lon_name, 'double', lon_dimid );
    
% assign units attributes to coordinate variables
units       = 'units';
lat_units   = 'degrees_north';
lon_units   = 'degrees_east';
    
netcdf.putAtt( ncid, lat_varid, units, lat_units );
netcdf.putAtt( ncid, lon_varid, units, lon_units );
    
% Define the NETCDF variables. The dimids array is used to pass the
% dimids of the dimensions of the NETCDF variables.
dimids      = [ lon_dimid, lat_dimid ];
evas_name    = 'ocean_evasion';
evas_varid   = netcdf.defVar( ncid, evas_name, 'double', dimids );
        
% assign units attributes to NETCDF variables
evas_units    = 'mol/m2/s';  % <---- double check (hma, 28 may 2015)
    
netcdf.putAtt( ncid, evas_varid, units, evas_units );
netcdf.putAtt( ncid, evas_varid, units, evas_units );
    
% end define mode
netcdf.endDef( ncid );
    
% write the coordinate variable data
netcdf.putVar( ncid, lat_varid, lat_nc );
netcdf.putVar( ncid, lon_varid, lon_nc );
    
% write Hg data
netcdf.putVar( ncid, evas_varid, ocnevas_latlon{1} );
    
% close the file
netcdf.close( ncid );
