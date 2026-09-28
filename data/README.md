# Flight Track Data

The thesis implementation reads the UAV route from:

```matlab
T = readgeotable("sample_uavtrack.gpx", Layer="track_points");
```

The original GPX file was **not included in the submitted project materials available for this repository**, so it is intentionally not fabricated here.

To run the project, place the original `sample_uavtrack.gpx` file in this directory or update the path in `src/uav_flight_path_visualization.m`.

Expected track fields:

- Latitude
- Longitude
- Elevation / altitude
- GPX layer: `track_points`

The thesis demonstration uses a simulated flight between **Taksim Square** and **Camlica Tower** in Istanbul.
