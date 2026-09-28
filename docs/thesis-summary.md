# Undergraduate Thesis Summary

**Official thesis title:** UAV Uçuş Yolunu 2-B ve 3-B Haritalarda Görselleştirme  
**Author:** Bekir Oruk  
**Degree:** Computer Engineering — Undergraduate Thesis  
**Institution:** Bolu Abant İzzet Baysal University, Faculty of Engineering  
**Year:** 2024  
**Advisor:** Assoc. Prof. Dr. Murat Beken

## Purpose

The project visualizes a simulated UAV flight between selected geographic locations. The implementation first marks the locations on a 2D geographic map, then creates synchronized 2D and 3D views, imports a simulated flight route, calculates navigation information, draws the route and animates the UAV flight.

The final demonstration uses a route described in the project as **Taksim Square → Camlica Tower**.

## Implemented workflow

- Start/destination coordinate definition
- 2D satellite-map visualization
- Synchronized 2D geographic axes and 3D `geoglobe`
- GPX track loading with `readgeotable`
- Heading calculation with `azimuth` and WGS84
- Orthometric-to-ellipsoidal height conversion using EGM96
- 3D route-distance calculation through ECEF offsets
- Route drawing with `geoplot` / `geoplot3`
- Current-location marker and live data tips
- Animated 3D camera flight
- 360-degree destination panorama behavior

## Reported result

The final thesis reports a total UAV tracking distance of **7,532.953887 m** for the demonstrated flight track.

## Original source

The project was developed as a MATLAB Live Script named:

`VisualizeUAVFlightPathOn2DAnd3DMaps.mlx`

A readable `.m` source export is kept in the repository alongside the GPX route so the implementation can also be reviewed directly on GitHub.
