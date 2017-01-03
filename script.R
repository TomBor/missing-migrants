library(jsonlite)
library(geojsonio)
library(geostatsp)
library(raster)
library(rgdal)
library(sp)
library(tidyr)
library(vegalite)

# DATA CLEANING -----------------------------------------------
# Load IOM missing migrants database at 2016 december 22 from https://missingmigrants.iom.int/
rawData <- read.csv("data-raw/IOM-MMP_all_data_2016-12-22.csv")

# Sum DEAD and MISSING
rawData$deadMissing <- rowSums(rawData[,c("DEAD", "MISSING")],na.rm = TRUE)

# Extract "Mediterranean" in INCIDENTREGION
iom <- subset(rawData, rawData$INCIDENTREGION == "Mediterranean",
              select=c(1:24))
# Drop NA coordinates in 'X' or 'Y'
iom <- drop_na(iom, X,Y)



# GEOREFERENCE CSV -----------------------------------------------
# transform dataframe to a spdf (SpatialPointsDataFrame) 
iomSp <- SpatialPointsDataFrame(iom[,1:2],                                         # x and y columns number
                                iom,                                               # the R object to convert
                                proj4string = CRS("+proj=longlat +datum=WGS84"))   # assign a CRS



# GRID CREATION -----------------------------------------------
ext <- extent(-20, 50, -20, 50)                        # define exten xmin, xmx, ymn, ymx
grid <- squareRaster(extent(ext), cells=300)           # create grid with geostatsp package
proj4string(grid) <- CRS("+proj=longlat +datum=WGS84") # Assign projection wgs84
gridpolygon <- rasterToPolygons(grid)                  # Transform raster in polygon
gridpolygon@data$layer <- gridpolygon@plotOrder        # assign an ID to each grid cell in 'layer' data



# GRID CALCULATION -----------------------------------------------
# Count points in Grid and preserve attribute 'deadMissing'
iomCell <- intersect(iomSp, gridpolygon)  # Add layer ID from grid to each point location with raster::intersect
iomCell <- data.frame(iomCell@data)       # extract results in a data frame
iomCell <- subset(iomCell,                # keep only : 'deadMissing' and 'd'
                select = c(24,25))

# Count number of 'deadMissing' by layer ID (or cell grid)
gridAgg <- aggregate(deadMissing ~ d, iomCell, sum)

# Merge count number to the spdf 'gridpolygon'
gridData <- merge(gridpolygon, gridAgg, by.x="layer", by.y="d")

# remove cell with no value (NA)
keep <- !is.na(gridData$deadMissing)       # save value 'is not NA' in a variable
gridDataLight <- gridData[keep,]           # keep object who respect 'keep' variable condition
geojson_write(gridDataLight,               # export in geojson with 'geojsonio'
              file = "data/input/iomGrid")



# TEST TO PUT DOTS IN GRID CELL -----------------------------------------------
# iomDots <- dotsInPolys(gridDataLight,                           # Create random dots with 'maptools' package
#                        as.integer(gridDataLight$deadMissing),   # function needs integer!
#                        f="regular")
# proj4string(iomDots) <- CRS("+proj=longlat +datum=WGS84")       # Assign projection wgs84
# 
# geojson_write(as(iomDots, Class = "SpatialPoints"),             # Output as geojson with 'geojsonio'
#               file = "data/input/iomDots")                            # Keep only @polygons and drop @data



# GRAPHIC -----------------------------------------------
# convert to string, then split date and time, then convert to date
iom$DATEREPORTED <- as.character(iom$DATEREPORTED)
iom <- separate(data = iom, col = DATEREPORTED, into = c("date", "time"), sep = "T")
iom$date <- as.Date(iom$date)

# visualize with vegalite 'Evolution of dead and missing migrants from 2014 to 2016 by month'
vegalite(export=TRUE) %>% 
  cell_size(400, 400) %>%                                         # graphic size ou matrix cell
  add_data(iom) %>%                                               # dataframe type
  encode_x("date", "temporal") %>%                                # field in x + type (temporal, ordinal, nominal, quantitative)
  encode_y("deadMissing", "quantitative", aggregate="sum") %>%    # field in y + type + aggregation
  timeunit_x("yearmonth") %>%                                     # time unit in x (year, month, yearmonth...)
  mark_bar() %>%                                                  # viz type (line, area, point, circle, bar)
  saveWidget("graph-YeahMonth.html")                              # export html + file name

# annotation of graphic with 'number of dead and missing per year'
aggregate(iom$deadMissing, by = list (year = substr(iom$date, 1, 4)), FUN = sum)
