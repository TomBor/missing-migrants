#!/bin/bash

# set Satellite projection parameters
PROJECTION='d3.geoSatellite().distance(1.6).scale(3000).rotate([-34, -23, -35]).center([-2, 25]).tilt(20).clipAngle(45)'

# GRID PART -----------------------------------------------
# reproject geojson (create from R) and re-inverse Y to open it in QGIS
geoproject "${PROJECTION}" \
    < data/input/iomGrid.geojson \
    | geoproject 'd3.geoIdentity().reflectY(true)' \
    > data/output/iomGrid-SAT.json
    
# duplicate in svg to superpose it with basemap in Illustrator
geoproject "${PROJECTION}" \
    < data/input/iomGrid.geojson \
    | geo2svg \
    > data/output/iomGrid-SAT.svg
    
# BASEMAP PART -----------------------------------------------
# convert shapefile (from Natural Earth) to geojson and reproject it
# -p = coordinate precision in number of digits, default = 6
shp2json --ignore-properties \
    data/input/10m_coastline.shp \
    | geoproject -p 3 "${PROJECTION}" \
    | geo2svg \
    > data/output/coastlines.svg
    
shp2json --ignore-properties \
    data/input/10m_lines.shp \
    | geoproject -p 3 "${PROJECTION}" \
    | geo2svg \
    > data/output/lines.svg
        
shp2json --ignore-properties \
    data/input/10m_lines_disputed.shp \
    | geoproject -p 3 "${PROJECTION}" \
    | geo2svg \
    > data/output/lines-disputed.svg
    
shp2json --ignore-properties \
    data/input/10m_countries_lakes.shp \
    | geoproject -p 3 "${PROJECTION}" \
    | geo2svg \
    > data/output/land.svg


# RASTER PART
# reproject raster (from Natural Earth) with GDAL
# need to save projection parameters in a .prj file
# ------------------------
# PROJCS["satellite",
#     GEOGCS["satellite"],
#     PROJECTION["satellite"],
#     EXTENSION["PROJ4","+proj=tpers +azi=-35 +tilt=20 +lon_0=34 +lat_0=23 +h=3826860 + ellps=WGS84 +datum=WGS84 +units=m"]]
# ------------------------
# conversion between 'Satellite projection' (d3.js) and 'Tilted perspective' (proj4)
# > In 'tpers'
#   - +lon_0, +lat_0 and +azi arguments = three-axis rotation
#   - +tilt argument = tilt angle in degrees
#   - +h option = height above the surface of the Earth, in meters relative to the Earth’s radius (6,378,100).
#     D3’s satellite projection uses a distance property, measured from the center of the sphere,
#     as a multiple of the radius. So 3826860 = 0.6 * 6378100, which corresponds to a distance property of 1.6.
gdalwarp -t_srs 'data/input/sat.prj' \
    data/input/HYP_HR_SR_OB_DR.tif \
    data/input/raster.tif
    
# crop raster values in pixel    
gdal_translate -srcwin 3500 0 8143 6000 \
    data/input/raster.tif \
    data/output/raster-clip.tif