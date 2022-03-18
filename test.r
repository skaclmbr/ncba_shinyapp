if(!require(magrittr)) install.packages("magrittr", repos = "http://cran.us.r-project.org")
if(!require(rvest)) install.packages("rvest", repos = "http://cran.us.r-project.org")
if(!require(readxl)) install.packages("readxl", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(maps)) install.packages("maps", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(reshape2)) install.packages("reshape2", repos = "http://cran.us.r-project.org")
if(!require(ggiraph)) install.packages("ggiraph", repos = "http://cran.us.r-project.org")
if(!require(RColorBrewer)) install.packages("RColorBrewer", repos = "http://cran.us.r-project.org")
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
if(!require(plotly)) install.packages("plotly", repos = "http://cran.us.r-project.org")
if(!require(geojsonio)) install.packages("geojsonio", repos = "http://cran.us.r-project.org")
if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
if(!require(shinyWidgets)) install.packages("shinyWidgets", repos = "http://cran.us.r-project.org")
if(!require(shinydashboard)) install.packages("shinydashboard", repos = "http://cran.us.r-project.org")
if(!require(shinythemes)) install.packages("shinythemes", repos = "http://cran.us.r-project.org")
if(!require(mongolite)) install.packages("mongolite", repos = "http://cran.us.r-project.org")
if(!require(jsonlite)) install.packages("jsonlite", repos = "http://cran.us.r-project.org")
# Load packages
library(auk)
library(tidyr)
library(stringr)

print("packages loaded")


knitr::opts_chunk$set(echo = TRUE)

# Set your paths and credentials here
sp <- "American Goldfinch"
ebd_file <- ""
EBD_output <- ""

# ebd_data <- fromJSON("ebd.json", flatten = TRUE)
ebd_checklists <- read.csv("input_data/ebd_full_no_obs.csv")

print(head(ebd_checklists,10))


# # source("config.r")
# USER = "ncba_ruser"
# PASS = "Sternacaspia"
# HOST = "cluster0-shard-00-00.rzpx8.mongodb.net:27017"
# DB = "ebd_mgmt"
# COLLECTION = "ebd"
#
# time1 <- proc.time()
# URI = sprintf("mongodb://%s:%s@%s/%s?authSource=admin&replicaSet=atlas-3olgg1-shard-0&readPreference=primary&ssl=true&tls=true",USER, PASS, HOST, DB)
# print (URI)
# #
# #> establish connection to a specific collection (table)print
# m <- mongo(COLLECTION, url = URI, options = ssl_options(weak_cert_validation = T))
#
# # return records for the species
# # this query follows JSON based query syntax (see here for the basics: https://jeroen.github.io/mongolite/query-data.html#query-syntax)
# query <- str_interp('{"OBSERVATIONS.COMMON_NAME":"${sp}", "BREEDING_CODE":{$not:""}}')
# filter <- str_interp('{OBSERVATIONS.COMMON_NAME:1,OBSERVATIONS.SCIENTIFIC_NAME:1,OBSERVATIONS.OBSERVATION_COUNT:1,NCBA_BLOCK:1,SAMPLING_EVENT_IDENTIFIER:1,OBSERVATION_DATE:1,OBSERVER_ID:1,BREEDING_CODE:1,BREEDING_CATEGORY:1,COUNTY:1,LOCALITY:1,LOCALITY_ID:1,LATITUDE:1,LONGITUDE:1,DURATION_MINUTES:1,PROTOCOL_TYPE:1, PROJECT_CODE:1, ALL_SPECIES_REPORTED:1}')
# # mongodata <- m$find(query,filter) %>%
# #              unnest(cols = (c(OBSERVATIONS))) %>% # Expand observations
# #              filter(COMMON_NAME == sp)
#
# agmatch <- str_interp('{$match:{"OBSERVATIONS.COMMON_NAME":"American Goldfinch"}}')
# aggroup <- str_interp('{$group:{"_id":"$OBSERVATIONS.BREEDING_STATUS", "sumQuantity":{$sum:1}}}')
#
# mongodata <- m$aggregate('[{"$match":{"OBSERVATIONS.COMMON_NAME":"American Goldfinch"}},{$group:{"_id":"$OBSERVATIONS.BREEDING_STATUS", "sumQuantity":{$sum:1}}}]') %>%
# unnest(cols = (c(OBSERVATIONS))) %>% # Expand observations
# filter(COMMON_NAME == sp)


# Calculate processing time
mongotime <- proc.time() - time1

# Print number of records returned
print(paste("Records returned:", nrow(mongodata)))
print(paste("Runtime: ", mongotime[["elapsed"]]))

mongodata2 <- mongodata %>%
              # Summarize by number checklists within each block
              group_by(BREEDING_CODE) %>%
              summarize(reports=n())
print(mongodata2)



# m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
# m %>% addTiles()
#
# basemap = leaflet() %>% setView(lng = -79, lat = 35, zoom = 10)
# basemap %>% addProviderTiles(providers$CartoDB.Positron)
