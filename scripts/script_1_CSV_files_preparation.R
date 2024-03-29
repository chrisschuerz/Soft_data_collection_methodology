#### SCRIPTS FOR ANALYSING HYDROLOGICAL PROCESSES: Calculation of Runoff coefficient and Baseflow index ####
#### Script 1: Creating csv files ####

   # Methodology: two csv files are necessary to perform this methodology. These files can be created from two vector layers; one 
   # with the basins delineated, and the other with the grid of weather data. This script can be used as example to create these csv
   # files.
   
   # Used libraries
   library(sf)
   library(tidyverse)
   
   
   # FILE 1.- Subbasins csv file
   
   # Input data: Shapefile with the delineated subbasins 
   subbasins <- read_sf("used_files/GIS/Shapefiles/basins_studied.shp") %>% arrange(., id)
   # Changing column names
   subbasins_csv <- subbasins %>% rename(Basin_ID = id) %>% 
   #Calculating area
   mutate(area = st_area(.)) %>% 
   # Introducing the gauging stations codes (Manually)
   mutate(gauging_code = c(3231, 3049, 3211, 3001, 3045, 3040,
                           3249, 3172, 3193, 3251, 3186, 3173,
                           3164, 3165, 3212, 3268, 3237, 3030, 3060)) %>% 
   # Spatial data is no longer necessary
   st_drop_geometry(.) %>% 
   # Ordering table
   .[,c("Basin", "Basin_ID", "area", "gauging_code", "region")]
   write.csv(x = subbasins_csv, file = "used_files/Created_csv/1_basins_file.csv", row.names = F)
   
   
   # FILE 2. Gauging points csv file
   
   #Input data: weather grid and delineated subbasins
   
   # Gauging points: Note that the IDs for precipitation and temperature stations is constant, and therefore only one file is necessary.
   pcp_points <- read_sf("used_files/GIS/Shapefiles/grid_tagus.shp")
   
   subbasins <- read_sf("used_files/GIS/Shapefiles/basins_studied.shp") %>% arrange(., id)
   
   # 2.1. Buffer created for subbasins (1 km distance)
   
   subbasins_buffer <- st_buffer(subbasins, dist = 1000) 
   
   # 2.2.Clipping grid points with the subbasins buffer (region column is not necessary)
   
   grid_points_clip <- st_intersection(pcp_points, subbasins_buffer[, c("id", "Basin", "geometry")])
   
   # Spatial data is no longer necessary, and a variable is renamed before saving
   
   grid_points_clip_csv <- grid_points_clip %>% st_drop_geometry(.) %>% rename(Basin_ID = id)
   
   write.csv(x = grid_points_clip_csv, file = "used_files/Created_csv/ids_stations_file.csv", row.names = F)
   
   
   
   # Plot to see the selected points
   
   subbasins$region <- factor(subbasins$region, levels = c("DTAL", "DTBJ", "CRB", "MIX", "IMP"), 
                                       labels = c("Detrital, High permeability", "Detrital, Low permeability", 
                                                  "Carbonate", "Mixed", "Impervious"))
   pcps_selected_id <- grid_points_clip$ID
   grid_points <- pcp_points %>% mutate(Selected_points = case_when(ID %in% pcps_selected_id ~ "Selected", 
                                   TRUE ~ "No selected"))
   
   tagus_upp <- read_sf("used_files/GIS/Shapefiles/modeled_basin.shp")
   
     ggplot()+
     geom_sf(data = tagus_upp, fill = "transparent", color = "black", linewidth = 1)+
     geom_sf(data = subbasins, aes(fill = as.factor(id), color = region), linewidth = 1)+ labs(color = "Lithology")+
     scale_color_manual(values = c("orange", "darkgrey", "blue", "purple", "red"))+
     geom_sf(data = subbasins_buffer, fill = "transparent", linetype = 2, linewidth = 0.7)+
     guides(fill = "none")+ 
     geom_sf(data = grid_points, aes(shape = Selected_points), size = 2)+
     scale_shape_manual(values = c(1, 16))+
     theme_bw()
   












