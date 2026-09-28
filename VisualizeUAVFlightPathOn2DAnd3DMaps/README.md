# Original MATLAB Project Folder

This directory mirrors the original project folder name used for the undergraduate thesis:

`VisualizeUAVFlightPathOn2DAnd3DMaps`

## Files

- `VisualizeUAVFlightPathOn2DAnd3DMaps.m` — readable source export of the code cells from the original MATLAB Live Script.
- `sample_uavtrack.gpx` — the actual GPX route file used by the project.
- `VisualizeUAVFlightPathOn2DAnd3DMaps.mlx` — original MATLAB Live Script (binary file; intended to live in this folder).
- `video.mp4` — full working-demo screen recording (binary file; intended to live in this folder).

The Live Script and the GPX file are designed to be kept together because the project calls:

```matlab
readgeotable("sample_uavtrack.gpx", Layer="track_points")
```
