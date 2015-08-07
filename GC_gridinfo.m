%-----------------------------------------------------------------
% GEOS-Chem 4x5 grid information
%
% lat and lon from GEOS-Chem Users' Guide:
% http://acmg.seas.harvard.edu/geos/doc/man/
%
% Last updated: 27 May 2015, Helen M. Amos
%-----------------------------------------------------------------

% latitude at grid center
lat_gc = [-89.000;  -86.000;  -82.000;  -78.000;  -74.000;  -70.000;  -66.000;  -62.000;
          -58.000;  -54.000;  -50.000;  -46.000;  -42.000;  -38.000;  -34.000;  -30.000;
	  -26.000;  -22.000;  -18.000;  -14.000;  -10.000;   -6.000;   -2.000;    2.000;
	    6.000;   10.000;   14.000;   18.000;   22.000;   26.000;   30.000;   34.000;
	   38.000;   42.000;   46.000;   50.000;   54.000;   58.000;   62.000;   66.000;
	   70.000;   74.000;   78.000;   82.000;   86.000;   89.000 ];
	     
% longitude at grid center
lon_gc = [ -180.000; -175.000; -170.000; -165.000; -160.000; -155.000; -150.000; -145.000;
           -140.000; -135.000; -130.000; -125.000; -120.000; -115.000; -110.000; -105.000;
           -100.000;  -95.000;  -90.000;  -85.000;  -80.000;  -75.000;  -70.000;  -65.000;
            -60.000;  -55.000;  -50.000;  -45.000;  -40.000;  -35.000;  -30.000;  -25.000;
            -20.000;  -15.000;  -10.000;   -5.000;    0.000;    5.000;   10.000;   15.000;
             20.000;   25.000;   30.000;   35.000;   40.000;   45.000;   50.000;   55.000;
             60.000;   65.000;   70.000;   75.000;   80.000;   85.000;   90.000;   95.000;
            100.000;  105.000;  110.000;  115.000;  120.000;  125.000;  130.000;  135.000;
            140.000;  145.000;  150.000;  155.000;  160.000;  165.000;  170.000;  175.000];

% convert lat and lon from row vectors to column vectors
lat_gc_vec = lat_gc.';
lon_gc_vec = lon_gc.';

% convert lon from [-180, 180] to [0, 360]
lon_gc_vec = 180. + lon_gc_vec;

% put lat and lon on 2D arrays
[lat_gc,lon_gc] = meshgrid(lat_gc_vec,lon_gc_vec);

% make sure lat and lon arrays are double
lat_gc = double( lat_gc );
lon_gc = double( lon_gc );

% read in GEOS-Chem grid area (m2)
% - columns: I  |  J | area
A_col = load('areas_4x5_m2.dat');

% convert column to array of grid areas (m2)
surfarea = zeros(size(lat_gc,1), size(lat_gc,2));  % initialize array
cc       = 1; % indexer / counter
 
for i = 1:size(lat_gc,1);
for j = 1:size(lat_gc,2);
  surfarea(i,j) = A_col(cc,3);  % store surface area
  cc            = cc + 1;       % increment counter
end
end

% quick visiual check -- looks as expected
if 0;
clc;
figure
pcolor(surfarea); shading flat;
end
