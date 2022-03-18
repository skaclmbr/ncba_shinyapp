## COVID-2019 interactive mapping tool
## Edward Parker, London School of Hygiene & Tropical Medicine (edward.parker@lshtm.ac.uk), last updated April 2020

## includes code adapted from the following sources:
# https://github.com/rstudio/shiny-examples/blob/master/087-crandash/
# https://rviews.rstudio.com/2019/10/09/building-interactive-world-maps-in-shiny/
# https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example

print("======= app started ========")
# update data with automated script
#source("jhu_data_daily_cases.R") # option to update daily cases
# source("jhu_data_weekly_cases.R") # run locally to update numbers, but not live on Rstudio server /Users/epp11/Dropbox (VERG)/GitHub/nCoV_tracker/app.R(to avoid possible errors on auto-updates)
# source("ny_data_us.R") # run locally to update numbers, but not live on Rstudio server (to avoid possible errors on auto-updates)

# load required packages
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

# set mapping colour for each outbreak
checklist_col = "#cc4c02"
covid_col = "#cc4c02"
covid_other_col = "#662506"
sars_col = "#045a8d"
h1n1_col = "#4d004b"
ebola_col = "#016c59"

plot_date = as.Date("2021-12-06","%Y-%m-%d")

# NCBA Data API key
ncba_key = "Ua2hT4poHBphbXGycSDvocyrg2ESobqZgXERkdi0uf8x4ks2Xt6HKtkF72R1kO4R"
ncba_data_endpoint = "https://data.mongodb-api.com/app/data-blvuy/endpoint/data/beta"

#BLOCK DATAA (local)
# blocks = geojson_read("input_data/blocks.geojson", what = "sp") # return spatial class
blocks_priority = geojson_read("input_data/blocks_priority.geojson", what = "sp") # return spatial class
# blocks_priority <- blocks[blocks$PRIORITY == "1"]
# blocks_other <- blocks[blocks$PRIORITY == "0"]

#####################################################################
######### Connect and retrieve data from Mongo ######################
# import data

# pc_data = read.csv("input_data/point_counts_pts.csv") #for now this is download - connect to MDB later

# other relevant collections include: blocks and ebd_taxonomy

# test, local data
# ebd_checklists = read.csv("input_data/ebd_no_obs.csv") #for now (testing), this is only Raleigh West
# ebd_checklists <- read.csv("input_data/ebd_full_no_obs.csv") #Production
ebd_checklists <- read.csv("input_data/ebd_check_sub.csv") #TESTING
# write.csv(head(ebd_checklists,1000),"input_data/ebd_check_test.csv")

# ebd_obs = read.csv("input_data/ebd_full_obs_parsed.csv") #PRODUCTION
ebd_obs = read.csv("input_data/ebd_obs_sub.csv") #TESTING

#EBD Stats
ebd_max_date = as.Date(max(ebd_checklists$OBSERVATION_DATE), "%Y-%m-%d")
# print (ebd_max_date)
spp_list <- unique(ebd_obs$COMMON_NAME)
# print(head(spp_list, 10))
spp_list_order <- order(spp_list)
# print (head(spp_list[spp_list_order],10))
# ebd_obs <- read.csv("input_data/ebd_full_obs.csv")

## add observation count to checklist

# ebd_checklists = read.csv("input_data/ebd_no_obs.csv") #for now (testing), this is only Raleigh West
# ebd_obs = read.csv("input_data/ebd_obs_subset.csv") #for now (testing), this is only Raleigh West
# ebd_checklists <- fromJSON(file = "input_data/ebd.csv") #for now (testing), this is only Raleigh West


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
#
# sp <- "American Goldfinch"
#
#
# mongotime <- proc.time() - time1
# query <- str_interp('{"OBSERVATIONS.COMMON_NAME":"${sp}", "OBSERVATIONS.BREEDING_CODE":{$not:""}}')
# mfilter <- str_interp('{"OBSERVATIONS.COMMON_NAME":1,"OBSERVATIONS.SCIENTIFIC_NAME":1,"OBSERVATIONS.OBSERVATION_COUNT":1,"NCBA_BLOCK":1,"SAMPLING_EVENT_IDENTIFIER":1,"OBSERVATION_DATE":1,"OBSERVER_ID":1,"BREEDING_CODE":1,"BREEDING_CATEGORY":1,"COUNTY":1,"LOCALITY":1,"LOCALITY_ID":1,"LATITUDE":1,"LONGITUDE":1,"DURATION_MINUTES":1,"PROTOCOL_TYPE":1, "PROJECT_CODE":1, "ALL_SPECIES_REPORTED":1}')
# ebd_checklists <- m$find(query, mfilter) %>%
#              unnest(cols = (c(OBSERVATIONS))) %>% # Expand observations
#              filter(COMMON_NAME == sp)

# print(head(ebd_checklists))
# spp_list =  c("Brown-headed Nuthatch","Northern Cardinal", "Black-throated Green Warbler")

block_list = c("RALEIGH-WEST-SE", "ABBOTTSBURG-CE")



### MAP FUNCTIONS ###

# # function to plot cumulative COVID cases by date
# ncba_checklist_plot = function(ebd_aggregated, plot_date) {
#   plot_df = subset(ebd_aggregated, date<=plot_date)
#   g1 = ggplot(plot_df, aes(x = date, y = checklists, color = region)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
#     ylab("Checklists") +  xlab("Date") + theme_bw() +
#     scale_colour_manual(values=c(checklist_col)) +
#     # scale_y_continuous(labels = function(l) {trans = l; paste0(trans)}) +
#     theme(legend.title = element_blank(), legend.position = "", plot.title = element_text(size=10),
#           plot.margin = margin(5, 12, 5, 5))
#   g1
# }

#sum checklists by date
# CALCULATE EBD STATS
#number of checklists



ebd_aggregated = aggregate(ebd_checklists$DURATION_MINUTES,by=list(Category=ebd_checklists$OBSERVATION_DATE),FUN=sum)
names(ebd_aggregated) = c("date", "minutes") #rename column headers
ebd_aggregated$date = as.Date(ebd_aggregated$date, "%m/%d/%Y") #store as a date

#loop through ebd records, get # new spp added
unique_spp = c()
# for (i in 1:nrow(ebd_checklists)) {
#   ebd_checklists$[i]
# }

spp_accumulation_plot = function(ebd_aggregated, block) {
  # plot_df = subset(ebd_aggregated, date<=plot_date) #potentially use this to parse by block?

  g1 = ggplot(ebd_aggregated, aes(x = date, y = minutes, color=checklist_col)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
    ylab("Minutes Birding") +  xlab("Date") + theme_bw() +
    scale_colour_manual(values=c(checklist_col)) +
    # scale_y_continuous(labels = function(l) {trans = l; paste0(trans)}) +
    theme(legend.title = element_blank(), legend.position = "", plot.title = element_text(size=10),
          plot.margin = margin(5, 12, 5, 5))
  g1
}
#
# print("ncba_checklist_plot plot loaded")
#
# ### DATA PROCESSING: COVID-19 ###
#
# # extract dates from ebd data
# if (any(grepl("/", ebd_checklists$OBSERVATION_DATE))) {
#   ebd_checklists$OBSERVATION_DATE = format(as.Date(ebd_checklists$OBSERVATION_DATE, format="%d/%m/%Y"),"%Y-%m-%d")
# } else { ebd_checklists$OBSERVATION_DATE = as.Date(ebd_checklists$OBSERVATION_DATE, format="%Y-%m-%d") }
# ebd_checklists$OBSERVATION_DATE = as.Date(ebd_checklists$OBSERVATION_DATE)
# ebd_min_date = as.Date(min(ebd_checklists$OBSERVATION_DATE),"%d/%m/%Y")
# current_date = as.Date(max(ebd_checklists$OBSERVATION_DATE),"%d/%m/%Y")
# # current_date = as.Date(max(cv_cases$date),"%Y-%m-%d")
# ebd_max_date_clean = format(as.POSIXct(current_date),"%d %B %Y")

###############################################################################
# blocks
# ebd_checklists =
# create base map
block_basemap = leaflet(blocks_priority) %>%
  setView(lng = -78.6778808, lat = 35.7667941, zoom = 12) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(stroke = TRUE, fillOpacity = 0, group = "Blocks", label = sprintf("<strong>%s</strong>", blocks_priority$ID_BLOCK) %>% lapply(htmltools::HTML),
  labelOptions = labelOptions(
    style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
    textsize = "15px", direction = "auto") )


spp_basemap = leaflet(blocks_priority) %>%
  setView(lng = -78.6778808, lat = 35.7667941, zoom = 12) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron)


# count checklists by date

# ebd_aggregated = aggregate(ebd_checklists$SAMPLING_EVENT_IDENTIFIER, by=list(Date=ebd_checklists$OBSERVATION_DATE), FUN=length)
# names(ebd_aggregated) = c("date","checklists")
#
# print("ebd_aggregated testing")
# print(head(ebd_aggregated, 5))
# ebd_aggregated$date = as.Date(ebd_aggregated$date, "%m/%d/%Y")
# ebd_aggregated$region = "Global"
# print(head(ebd_aggregated, 5))


print("done with data management, ready to plot to shiny ui")

### SHINY UI ###
# Pages to include
#  - Block Mapper (accumulation curves)
#  - Point Count Mapper/Explorer (locations, data entry stats)
#  - Species Explorer (spp distribution records)
#  - About

ui <- bootstrapPage(
  tags$head(includeHTML("gtag.html")), #google analytics tag
  navbarPage(theme = shinytheme("flatly"), collapsible = TRUE,
             HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">NC Bird Atlas Block Mapper</a>'), id="nav",
             windowTitle = "Blocks",

             tabPanel("Blocks",
                      div(class="outer",
                          tags$head(includeCSS("styles.css")),
                          leafletOutput("block_map", width="100%", height="100%"),

                          absolutePanel(id = "controls", class = "panel panel-default",top = 75, left = 55, width = 250, fixed=TRUE,draggable = TRUE, height = "auto",

                          # h3(textOutput("max_data_date"), align = "right"),
                          span(tags$i(h6("Priority blocks")), style="color:#045a8d"),
                          textInput("block_name","Block"),
                          plotOutput("spp_accumulation_plot", height="130px", width="100%")

                          ),

                          absolutePanel(id = "logo", class = "card", bottom = 20, left = 60, width = 80, fixed=TRUE, draggable = FALSE, height = "auto",
                                        tags$a(href='https://ncbirdatlas.org', tags$img(src='ncba_logo_blue_halo_final.png',height='40',width='80'))),

                          absolutePanel(id = "logo", class = "card", bottom = 20, left = 20, width = 30, fixed=TRUE, draggable = FALSE, height = "auto",
                                        actionButton("twitter_share", label = "", icon = icon("twitter"),style='padding:5px',
                                                     onclick = sprintf("window.open('%s')",
                                                                       "https://twitter.com/intent/tweet?text=%20@ncbirdatylas%20Checklist%20Mapper")))


                      )
             ),
             tabPanel("Species",
                      div(class="outer",
                          tags$head(includeCSS("styles.css")),
                          leafletOutput("spp_map", width="100%", height="100%"),

                          absolutePanel(id = "controls", class = "panel panel-default",
                                        top = 75, left = 55, width = 250, fixed=TRUE,
                                        draggable = TRUE, height = "auto",

                                        span(tags$i(h6("Checklists submitted to the NC Bird Atlas.")), style="color:#045a8d"),
                                        # h3(textOutput("max_data_date"), align = "right"),
                                        checkboxInput("portal_records","Portal Records Only", FALSE ),
                                        selectInput("spp_list_picker","Species", spp_list[spp_list_order], multiple = FALSE, selectize=TRUE),
                                        # sliderTextInput("plot_date",
                                        # label = h5("Select date"),choices = format(unique(ebd_checklists$OBSERVATION_DATE), "%d %b %y"),selected = format(ebd_max_date, "%d %b %y"),
                                        #                 grid = FALSE,
                                        #                 animate=animationOptions(interval = 3000, loop = FALSE))

                          ),

                          absolutePanel(id = "logo", class = "card", bottom = 20, left = 60, width = 80, fixed=TRUE, draggable = FALSE, height = "auto",
                                        tags$a(href='https://ncbirdatlas.org', tags$img(src='ncba_logo_blue_halo_final.png',height='40',width='80'))),

                          absolutePanel(id = "logo", class = "card", bottom = 20, left = 20, width = 30, fixed=TRUE, draggable = FALSE, height = "auto",
                                        actionButton("twitter_share", label = "", icon = icon("twitter"),style='padding:5px',
                                                     onclick = sprintf("window.open('%s')",
                                                                       "https://twitter.com/intent/tweet?text=%20@ncbirdatylas%20Checklist%20Mapper")))


                      )
             ),

             tabPanel("About this site",
                      tags$div(
                        tags$h4("NC Bird Atlas Data Explorer"),
                        "This site is updated monthly. It is an experiment to see if using Shiny is a good solution to finding patterns in the data.",
                        tags$br(),
                        tags$img(src = "ncba_logo_blue_halo_final.png", width = "150px", height = "75px")

                      )
             )

  )
)





### SHINY SERVER ###

server = function(input, output, session) {
  #block tab plots

  output$spp_accumulation_plot <- renderPlot({
    spp_accumulation_plot(ebd_aggregated, "Raleigh West SE")
  })

  current_block = reactive({
    input$block_name
  })

  # covid tab
  formatted_date = reactive({
    format(as.Date(input$plot_date, format="%d %b %y"), "%Y-%m-%d")
    # format(as.Date(input$plot_date, format="%d %b %y"), "%Y-%m-%d")
  })

  reactive_blocks = reactive({
    # blocks_priority
    blocks_priority
  })

  # output$max_data_date <- renderText({
  #   paste0("last updated: ", ebd_max_date)
  # })

  output$clean_date_reactive <- renderText({
    format(as.POSIXct(formatted_date()),"%d %B %Y")
  })

  reactive_db = reactive({
    ebd_checklists %>% filter(OBSERVATION_DATE == formatted_date())
  })

  filtered_data = reactive({
    if (input$portal_records){
      print("portal records true")
      ebd_checklists %>% filter(PROJECT_CODE == "EBIRD_ATL_NC")
    } else {
      print("portal records false")
      ebd_checklists
    }
  })

  filtered_spp = reactive({
    ebd_obs %>% filter(COMMON_NAME == input$spp_list_picker)
  })


  filtered_data_spp = reactive({
    #get data from mongo for spp selected
    ebd_spp_data <- "some data"
  })

  output$block_map <- renderLeaflet({
    block_basemap
  })
  output$spp_map <- renderLeaflet({
    spp_basemap
  })

  #Map controls
  ## map block click listener

  observeEvent(input$block_map_shape_click, {
    # click event
    click <- input$block_map_shape_click$id
    print(click)
    updateTextInput(session, input$block_name, value = paste(click))
    ebd_block_spp_data <- ebd_checklists[ebd_checklists$NCBA_BLOCK_CODE == click]
    print(head(ebd_block_spp_data,1))
    print(nrow(ebd_block_spp_data))
    if (nrow(ebd_block_spp_data)>0){
      leafletProxy("block_map") %>%
        clearMarkers() %>%
        addCircleMarkers(data = ebd_block_spp_data, lat= ~LATITUDE,lng = ~LONGITUDE, stroke = FALSE, radius = 5, group = "Checklist Locations", label = sprintf("<strong>%s</strong><br/>%s<br/>Protocol:%s<br/><a href='https://ebird.org/location/%s' target='_blank'>%s</a><br/>Block:%s<br/>%s Minutes", ebd_checklists$OBSERVATION_DATE, ebd_checklists$OBSERVER_ID, ebd_checklists$PROTOCOL_TYPE, ebd_checklists$SAMPLING_EVENT_IDENTIFIER, ebd_checklists$SAMPLING_EVENT_IDENTIFIER,ebd_checklists$NCBA_BLOCK,ebd_checklists$DURATION_MINUTES) %>% lapply(htmltools::HTML),
        labelOptions = labelOptions(
          style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
          textsize = "15px", direction = "auto"))
    } else {
      print("no checklists found")
    }
    #change block outline
    # selection <- blocks_priority[blocks_priority$ID_BLOCK == click]
    # print("block selected")
    # leafletProxy("block_map") %>% addPolygons(data = selection, color='red')
  })

  ## Portal toggle listener
  observeEvent(input$spp_list_picker,{
    # print("spp_list_picker changed", input$spp_list_picker)
    leafletProxy("spp_map") %>%
      clearMarkers() %>%
      clearShapes() %>%
      # addPolygons(layerId = ~ ID_BLOCK_CODE, stroke = TRUE, fillOpacity = 0, group = "Blocks", label = sprintf("<strong>%s</strong>", blocks_priority$ID_BLOCK) %>% lapply(htmltools::HTML),
      # labelOptions = labelOptions(
      #   style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
      #   textsize = "15px", direction = "auto") ) %>%
      addCircleMarkers(data = filtered_spp(), lat= ~LATITUDE,lng = ~LONGITUDE, stroke = FALSE, radius = 5, group = "Species Detections", label = sprintf("<strong>%s</strong><br/>Breeding Code:%s<br/>Breeding Cat:%s<br/>Block:%s<br/>%s Minutes<br/>%s", ebd_obs$OBSERVATION_DATE, ebd_obs$BREEDING_CODE, ebd_obs$BREEDING_CATEGORY, ebd_obs$ID_NCBA_BLOCK, ebd_obs$DURATION_MINUTES, ebd_obs$SAMPLING_EVENT_IDENTIFIER) %>% lapply(htmltools::HTML),
      labelOptions = labelOptions(
        style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
        textsize = "15px", direction = "auto") )
  })

  # observeEvent(input$spp_list,{
  #
  #   leafletProxy("spp_map") %>%
  #     clearMarkers() %>%
  #     clearShapes() %>%
  #     addCircleMarkers(data = filtered_data(), lat= ~LATITUDE,lng = ~LONGITUDE, stroke = FALSE, radius = 5, group = "Checklist Locations", label = sprintf("<strong>%s</strong><br/>%s<br/>Protocol:%s<br/><a href='https://ebird.org/location/%s' target='_blank'>%s</a><br/>Block:%s<br/>%g Minutes", ebd_checklists$OBSERVATION_DATE , ebd_checklists$OBSERVER_ID, ebd_checklists$PROTOCOL_TYPE, ebd_checklists$SAMPLING_EVENT_IDENTIFIER, ebd_checklists$SAMPLING_EVENT_IDENTIFIER,ebd_checklists$NCBA_BLOCK,ebd_checklists$DURATION_MINUTES) %>% lapply(htmltools::HTML),
  #     labelOptions = labelOptions(
  #       style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
  #       textsize = "15px", direction = "auto") )
  # })

  output$block_map <- renderLeaflet ({
    leaflet(blocks_priority) %>%
      setView(lng = -78.6778808, lat = 35.7667941, zoom = 12) %>%
      addTiles() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(layerId = ~ ID_BLOCK_CODE, stroke = TRUE, fillOpacity = 0, group = "Blocks", label = sprintf("<strong>%s</strong>", blocks_priority$ID_BLOCK) %>% lapply(htmltools::HTML),
      labelOptions = labelOptions(
        style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
        textsize = "15px", direction = "auto") )
  })


  # observeEvent(input$block_name,{
  #
  #   leafletProxy("block_map") %>%
  #     clearMarkers() %>%
  #     clearShapes() %>%
  #     addPolygons(data = reactive_blocks(), stroke = TRUE, fillOpacity = 0, group = "Blocks", label = sprintf("<strong>%s</strong>", blocks_prority$ID_BLOCK) %>% lapply(htmltools::HTML),
  #     labelOptions = labelOptions(
  #       style=list("font-weight" = "normal", padding = "3px 8px", "color" = checklist_col),
  #       textsize = "15px", direction = "auto") )
  # })



  # observeEvent(input$plot_date, {
  #   leafletProxy("block_map")
  # })

  # map

  output$ncba_checklist_plot <- renderPlot({
    ncba_checklist_plot(ebd_aggregated, formatted_date())
  })
}


#runApp(shinyApp(ui, server), launch.browser = TRUE)
shinyApp(ui, server)
#library(rsconnect)
#deployApp(account="vac-lshtm")
