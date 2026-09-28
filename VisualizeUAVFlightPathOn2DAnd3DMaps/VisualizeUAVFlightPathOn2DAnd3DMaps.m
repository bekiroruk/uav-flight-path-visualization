%% İHA Uçuş Yolunu 2-B ve 3-B Haritalar Üzerinde Görselleştirme
% Taksim Meydanı'ndan Çamlıca Kulesi'ne kadar simüle edilmiş bir İHA uçuşu.
% Bu .m dosyası, orijinal MATLAB Live Script (.mlx) içindeki kod hücrelerinin
% okunabilir kaynak-kod dışa aktarımıdır.

%% Taksim Meydanı'nın Koordinatlarını Alın
taksimLat = 41.0369;
taksimLon = 28.9868;
taksimH = 78;

%% Çamlıca Kulesi'nin Koordinatlarını Alın
camlicaLat = 41.0522;
camlicaLon = 29.0762;
camlicaH = 219; %#ok<NASGU>

%% Taksim Meydanı ve Çamlıca Kulesi'ni 2-B'de Görüntüleme
figure
geoaxes(Basemap = "satellite",ZoomLevel = 12)
hold on
geoplot(taksimLat, taksimLon, "ow", MarkerSize = 10, MarkerFaceColor= "magenta", DisplayName = "Taksim Meydanı")
geoplot(camlicaLat, camlicaLon, "ow", MarkerSize = 10, MarkerFaceColor= "blue", DisplayName = "Çamlıca Kulesi")
legend
geolimits([40.979 41.094],[28.951 29.144])

%% Taksim Meydanı'nı 2-B ve 3-B'de Senkronize Görüntüleme
figpos = [1000 500 800 400];
uif = uifigure("Position",figpos);
ug = uigridlayout(uif, [1, 2]);
p1 = uipanel(ug);
p2 = uipanel(ug);
gx = geoaxes(p1, Basemap= "satellite");
gg = geoglobe(p2);
gx.InnerPosition = gx.OuterPosition;
gg.Position = [0 0 1 1];

%% Taksim Meydanı'nı 2-D Görüntüleyin
heightAboveTerrain = 200;
gx.MapCenter = [taksimLat, taksimLon];
zoomLevel = heightToZoomLevel(heightAboveTerrain, taksimLat);
gx.ZoomLevel = zoomLevel;

%% Taksim Meydanı'nı 3-D Görüntüleyin
N = egm96geoid(taksimLat, taksimLon);
obsh = taksimH + N;
ellipsoidalHeight = obsh + heightAboveTerrain;
campos(gg, taksimLat, taksimLon, ellipsoidalHeight);
drawnow

%% Uçuş Rotası Verilerini İçe Aktarın ve Yön ile 3-D Mesafeyi Hesaplayın
T = readgeotable("sample_uavtrack.gpx", Layer="track_points");
tlat = T.Shape.Latitude';
tlon = T.Shape.Longitude';
talt = T.Elevation';

%% Uçuş Yönlerini Hesaplayın
wgs84 = wgs84Ellipsoid;
theading = azimuth(tlat(1:end-1),tlon(1:end-1),tlat(2:end),tlon(2:end),wgs84);
theading = [theading(1);theading(:)];

%% 3-D Mesafeleri Hesaplayın
N = egm96geoid(tlat,tlon);
h = talt + N;

lat1 = tlat(1:end-1);
lat2 = tlat(2:end);
lon1 = tlon(1:end-1);
lon2 = tlon(2:end);
h1 = h(1:end-1);
h2 = h(2:end);
[dx,dy,dz] = ecefOffset(wgs84,lat1,lon1,h1,lat2,lon2,h2);

distanceIncrementIn3D = hypot(hypot(dx, dy), dz);
cumulativeDistanceIn3D = cumsum(distanceIncrementIn3D);
totalDistanceIn3D = sum(distanceIncrementIn3D);
fprintf("Toplam İHA izleme mesafesi %f metre.\n",totalDistanceIn3D)

tdist = [0 cumulativeDistanceIn3D];

%% Taksim Meydanı'ndan Çamlıca Kulesi'nin Zirvesine Kadar Olan Uçuş Hattını Çizin
geoplot3(gg,tlat,tlon,talt,"c","LineWidth",2,"HeightReference","geoid")
ptrack = geoplot(gx,tlat,tlon,"c","LineWidth",2);

[clat,clon,cheight] = campos(gg);
gx.MapCenter = [clat,clon];
gx.ZoomLevel = heightToZoomLevel(cheight, clat);
drawnow

%% İlk Görünümü Taksim Meydanı'ndan Çamlıca Kulesi'nin Zirvesine Ayarlayın
campos(gg,tlat(1),tlon(1))
camheight(gg,talt(1) + 75)
campitch(gg,-90)
camheading(gg,theading(3))

hold(gx,"on")
marker = geoplot(gx,tlat(1),tlon(1),"ow","MarkerSize",10,"MarkerFaceColor","k");
mstart = geoplot(gx,tlat(1),tlon(1),"ow","MarkerSize",10,"MarkerFaceColor","magenta");
mend = geoplot(gx,tlat(end),tlon(end),"ow","MarkerSize",10,"MarkerFaceColor","blue");

marker.DisplayName = "Current Location";
mstart.DisplayName = "Start Location";
mend.DisplayName = "End Location";
ptrack.DisplayName = "UAV Track";
legend(gx)

gx.Basemap = "topographic";

dt = datatip(ptrack,"DataIndex",1,"Location","southeast");
dtrow = dataTipTextRow("Distance",tdist);
dtrow(end+1) = dataTipTextRow("Altitude",talt);
dtrow(end+1) = dataTipTextRow("Heading",theading);
ptrack.DataTipTemplate.DataTipRows(end+1:end+3) = dtrow;

%% Taksim Meydanı'ndan Çamlıca Kulesi'nin Zirvesine Uçun
pitch = -2.7689;
campitch(gg,pitch)

for k = 2:(length(tlat)-1)
    campos(gg,tlat(k),tlon(k))
    camheight(gg,talt(k)+100)
    camheading(gg,theading(k))

    set(marker,"LatitudeData",tlat(k),"LongitudeData",tlon(k));
    dt.DataIndex = k;

    drawnow
    pause(.25)
end

campos(gg,tlat(end),tlon(end),talt(end)+100)
dt.DataIndex = length(tlat);

%% Çamlıca Kulesi'nin Zirvesinden 360 Derecelik Bir Panorama Görüntüleyin
initialHeading = camheading(gg);
increment = 5;
initialHeading = initialHeading + (increment - mod(initialHeading,increment));

filename = 'panoramic.gif'; %#ok<NASGU>
for degree = initialHeading:increment:initialHeading+360
    heading = mod(degree,360);
    ptrack.DataTipTemplate.DataTipRows(end).Value(dt.DataIndex) = heading;
    camheading(gg,heading);
    drawnow
end

%% Yerel Fonksiyonlar
function zoomLevel = heightToZoomLevel(height, lat)
    earthCircumference = 2 * pi * 6378137;
    zoomLevel = log2((earthCircumference *cosd(lat)) / height) + 1;
    zoomLevel = max(0, zoomLevel);
    zoomLevel = min(19, zoomLevel);
end
