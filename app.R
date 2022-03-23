# NC Bird Atlas Shiny App
# v0.2
# 03/18/2022
# Scott K. Anderson
# https://github.com/skaclmbr

library(shiny)
library(tidyverse)
library(mongolite) #connecting to the mongodb
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
if(!require(geojsonio)) install.packages("geojsonio", repos = "http://cran.us.r-project.org")
if(!require(shinythemes)) install.packages("shinythemes", repos = "http://cran.us.r-project.org")

#get functions from other files
source("blocks.r")
source("utils.r") #utilities file


# SETUP FILES
# basemap = leaflet(ebd_data) %>% setView(lng = -78.6778808, lat = 35.7667941, zoom = 12) %>% addTiles() %>% addProviderTiles(providers$CartoDB.Positron) %>% addCircles()
current_block = ""

move_map <- function(lng, lat, zoom=12){
  # add code here to move the map
}


# Define UI for miles per gallon app ----
ui <- bootstrapPage(
  # titlePanel("NC Bird Atlas Explorer"),
  navbarPage(
    theme = shinytheme("cosmo"), collapsible=TRUE,
    HTML('<a style="text-decoration:none;cursor:default;color:#FFFFFF;" class="active" href="#">NC Bird Atlas Data Explorer</a>'), id="nav",
    windowTitle = "NCBA Explorer",
    tabPanel("Blocks",
      div(class="outer",
          tags$head(includeCSS("styles.css")),
          leafletOutput("mymap", width="100%", height="100%"),

          absolutePanel(id = "controls", class = "panel panel-default",
                        top = 60, left = 55, width = 250, fixed=TRUE,
                        draggable = TRUE, height = "auto",

                        span(tags$i(h6("Checklists submitted to the NC Bird Atlas.")), style="color:#045a8d"),
                        checkboxInput("portal_records","Portal Records Only", FALSE ),
                        selectInput("block_select", h3("Priority Blocks"),
                          choices = priority_block_list),
                        htmlOutput("selected_block", inline=FALSE),
                        verbatimTextOutput("testoutput"),
                        plotOutput("blockhours"),
          )
        )
    ),
    tabPanel("Species",
      mainPanel(
        selectInput("spp_select", h3("Species"),
          choices = species_list)
      )
    ),
    tabPanel("About",
      tags$div(
        tags$h4("NC Bird Atlas Data Explorer"),
        p("This site is a work in progress, designed to provide access to data collected through the North Carolina Bird Atlas. Data submitted to eBird is updated on a monthly basis."),
        tags$br(),
        tags$img(src = "ncba_logo_blue_halo_final.png", width = "150px", height = "75px")

        )
    )
  )

)

# Define server logic to plot various variables against mpg ----
server <- function(input, output, session) {
  #BLOCK TAB
  #
  current_block_r <- reactive({
    # get(input$block_select)
    current_block <- input$block_select

    #ADD CODE HERE TO RE-ORIENT THE MAP (make a function?)

  })

  #used for testing changes in values
  output$testoutput <- renderPrint({input$block_select})

  #block hours summary
  output$blockhours <- renderPlot({
    print(current_block_r())
    # ggplot2(get_block_hours(current_block_r())$Value)
    # ggplot(get_block_hours(current_block_r()), aes(YEAR_MONTH, Value, color="#2a3b4d"))
    # ggplot(data=get_block_hours("RALEIGH_EAST-SE")) + geom_bar(mapping = aes(YEAR_MONTH, Value, color="#2a3b4d"))
    ggplot(data=get_block_hours(current_block_r()),aes(YEAR_MONTH, Value)) + geom_col(fill="#2a3b4d")+ guides(x = guide_axis(angle = 90))
  })


  ## reactive listener for portal checkboxInput
  reactive_portal = reactive({
    if (input$portal_records){
      print("portal records true")
      ebd_data %>% filter(PROJECT_CODE == "EBIRD_ATL_NC")
    } else {
      print("portal records false")
      ebd_data
    }
  })

  # reactive listener for block select
  output$selected_block <-renderText({
    paste(current_block_r())
  })

  # renders basemap on leaflet
  output$mymap <- renderLeaflet({
    leaflet() %>%
      setView(lng = -78.6778808, lat = 35.7667941, zoom = 6) %>%
      # addTiles() %>%
      addGeoJSON(priority_block_geojson, weight= 1, color="#2a3a4d", fill = FALSE) %>%
      addProviderTiles(providers$CartoDB.Positron)
  })

  # plots checklists on map
  observeEvent(input$portal_records,{
    leafletProxy("mymap") %>%
      clearMarkers() %>%
      clearShapes() %>%
      addCircles(data=reactive_portal())

  })


}

shinyApp(ui, server)
