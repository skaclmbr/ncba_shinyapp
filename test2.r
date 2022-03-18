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
if(!require(tidyr)) install.packages("tidyr", repos = "http://cran.us.r-project.org")
if(!require(auk)) install.packages("auk", repos = "http://cran.us.r-project.org")
if(!require(stringr)) install.packages("stringr", repos = "http://cran.us.r-project.org")

print("packages loaded")

#ebd_checklists <- read.csv("input_data/ebd_full_no_obs.csv")
#write.csv(head(ebd_checklists,1000),"input_data/ebd_check_sub.csv")

ebd_check_sub <- read.csv("input_data/ebd_check_sub.csv")

ebd_obs = read.csv("input_data/ebd_full_obs_parsed.csv")


# Set your paths and credentials here
sp <- "American Goldfinch"
ebd_file <- ""
EBD_output <- ""

# ebd_data <- fromJSON("ebd.json", flatten = TRUE)
# ebd_checklists <- read.csv("input_data/ebd_full_no_obs.csv")
#
# print(head(ebd_checklists,10))
#
# ebd_checklists = read.csv("input_data/ebd_full_no_obs.csv")
# print(head(ebd_checklists, 10))
#
# ebd_obs = read.csv("input_data/ebd_full_obs_parsed.csv")
# print(head(ebd_obs, 10))
#
# test_block <- ebd_obs %>% filter(ID_BLOCK_CODE == "35078G6SE")

# create a function to

# for (i in 1:length(test_block)) {
#
#
# }
