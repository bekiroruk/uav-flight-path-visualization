%% UAV Flight Path Visualization in 2D and 3D Maps
% Undergraduate thesis project - Bekir Oruk, 2024
%
% This script visualizes a simulated UAV flight from Taksim Square to
% Camlica Tower in Istanbul. It creates synchronized 2D and 3D geographic
% views, computes heading and cumulative 3D distance, animates the flight,
% and performs a 360-degree panorama rotation at the destination.
%
% Required input:
%   sample_uavtrack.gpx  (track_points layer)
%
% Required MATLAB product:
%   Mapping Toolbox

clear; clc;

%% 1. Define start and destination coordinates
% Taksim Square coordinates (latitude, longitude, MSL height in meters)
taksimLat = 41.0369;
taksimLon = 28.9868;
taksimH = 78; % approximate height

% Camlica Tower coordinates (latitude, longitude, MSL height in meters)
camlicaLat = 41.0522;
camlicaLon = 29.0762;
camlicaH = 219; %#ok<NASGU> % approximate height; kept from thesis implementation

%% 2. Display Taksim Square and Camlica Tower on a 2D map
figure;
geoaxes(Basemap="satellite", ZoomLevel=12);
hold on;

geoplot(taksimLat, taksimLon, "ow", ...
    MarkerSize=10, MarkerFaceColor="magenta", ...
    DisplayName="Taksim Meydani");

geoplot(camlicaLat, camlicaLon, "ow", ...
    MarkerSize=10, MarkerFaceColor="blue", ...
    DisplayName="Camlica Kulesi");

legend;
geolimits([40.979 41.094], [28.951 29.144]);

%% 3. Create synchronized 2D and 3D geographic views
figpos = [1000 500 800 400];
uif = uifigure("Position", figpos);
ug = uigridlayout(uif, [1 2]);
p1 = uipanel(ug);
p2 = uipanel(ug);

gx = geoaxes(p1, Basemap="satellite");
gg = geoglobe(p2);

gx.InnerPosition = gx.OuterPosition;
gg.Position = [0 0 1 1];

%% 4. Position the 2D and 3D views over Taksim Square
heightAboveTerrain = 200;
gx.MapCenter = [taksimLat, taksimLon];
gx.ZoomLevel = heightToZoomLevel(heightAboveTerrain, taksimLat);

% Convert orthometric height to ellipsoidal height for the globe camera.
N = egm96geoid(taksimLat, taksimLon);
obsh = taksimH + N;
ellipsoidalHeight = obsh + heightAboveTerrain;
campos(gg, taksimLat, taksimLon, ellipsoidalHeight);
drawnow;

%% 5. Import the simulated UAV track
% The GPX file must contain latitude, longitude and elevation values in the
% track_points layer.
T = readgeotable("sample_uavtrack.gpx", Layer="track_points");
tlat = T.Shape.Latitude';
tlon = T.Shape.Longitude';
talt = T.Elevation';

%% 6. Calculate heading at each track point
wgs84 = wgs84Ellipsoid;
theading = azimuth( ...
    tlat(1:end-1), tlon(1:end-1), ...
    tlat(2:end), tlon(2:end), wgs84);
theading = [theading(1); theading(:)];

%% 7. Calculate cumulative 3D flight distance
% Convert orthometric elevations to WGS84 ellipsoidal heights.
N = egm96geoid(tlat, tlon);
h = talt + N;

lat1 = tlat(1:end-1);
lat2 = tlat(2:end);
lon1 = tlon(1:end-1);
lon2 = tlon(2:end);
h1 = h(1:end-1);
h2 = h(2:end);

[dx, dy, dz] = ecefOffset(wgs84, lat1, lon1, h1, lat2, lon2, h2);
distanceIncrementIn3D = hypot(hypot(dx, dy), dz);
cumulativeDistanceIn3D = cumsum(distanceIncrementIn3D);
totalDistanceIn3D = sum(distanceIncrementIn3D);

fprintf("Total UAV tracking distance: %.6f meters.\n", totalDistanceIn3D);

tdist = [0 cumulativeDistanceIn3D];

%% 8. Plot the complete flight track in 2D and 3D
geoplot3(gg, tlat, tlon, talt, "c", ...
    LineWidth=2, HeightReference="geoid");
ptrack = geoplot(gx, tlat, tlon, "c", LineWidth=2);

[clat, clon, cheight] = campos(gg);
gx.MapCenter = [clat, clon];
gx.ZoomLevel = heightToZoomLevel(cheight, clat);
drawnow;

%% 9. Configure the initial flight view
campos(gg, tlat(1), tlon(1));
camheight(gg, talt(1) + 75);
campitch(gg, -90);
camheading(gg, theading(3));

hold(gx, "on");
marker = geoplot(gx, tlat(1), tlon(1), "ow", ...
    MarkerSize=10, MarkerFaceColor="k");
mstart = geoplot(gx, tlat(1), tlon(1), "ow", ...
    MarkerSize=10, MarkerFaceColor="magenta");
mend = geoplot(gx, tlat(end), tlon(end), "ow", ...
    MarkerSize=10, MarkerFaceColor="blue");

marker.DisplayName = "Current Location";
mstart.DisplayName = "Start Location";
mend.DisplayName = "End Location";
ptrack.DisplayName = "UAV Track";
legend(gx);

gx.Basemap = "topographic";

%% 10. Add live distance, altitude and heading data tips
dt = datatip(ptrack, "DataIndex", 1, "Location", "southeast");
dtrow = dataTipTextRow("Distance", tdist);
dtrow(end+1) = dataTipTextRow("Altitude", talt);
dtrow(end+1) = dataTipTextRow("Heading", theading);
ptrack.DataTipTemplate.DataTipRows(end+1:end+3) = dtrow;

%% 11. Animate the flight from Taksim Square to Camlica Tower
pitch = -2.7689;
campitch(gg, pitch);

for k = 2:(length(tlat)-1)
    campos(gg, tlat(k), tlon(k));
    camheight(gg, talt(k) + 100);
    camheading(gg, theading(k));

    set(marker, "LatitudeData", tlat(k), "LongitudeData", tlon(k));
    dt.DataIndex = k;

    drawnow;
    pause(0.25);
end

campos(gg, tlat(end), tlon(end), talt(end) + 100);
dt.DataIndex = length(tlat);

%% 12. Rotate the camera through a 360-degree panorama at the destination
initialHeading = camheading(gg);
increment = 5;
initialHeading = initialHeading + (increment - mod(initialHeading, increment));

for degree = initialHeading:increment:(initialHeading + 360)
    heading = mod(degree, 360);
    ptrack.DataTipTemplate.DataTipRows(end).Value(dt.DataIndex) = heading;
    camheading(gg, heading);
    drawnow;
end

%% Local function
function zoomLevel = heightToZoomLevel(height, lat)
    earthCircumference = 2 * pi * 6378137;
    zoomLevel = log2((earthCircumference * cosd(lat)) / height) + 1;
    zoomLevel = max(0, zoomLevel);
    zoomLevel = min(19, zoomLevel);
end
