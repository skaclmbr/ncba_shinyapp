# utility function to use throughout


#####################################################################################
# MongoDB
# this is a read only account
HOST = "cluster0-shard-00-00.rzpx8.mongodb.net:27017"
DB = "ebd_mgmt"
COLLECTION = "ebd"
USER = "ncba_ruser"
PASS = "Sternacaspia"
# other relevant collections include: blocks and ebd_taxonomy

URI = sprintf("mongodb://%s:%s@%s/%s?authSource=admin&replicaSet=atlas-3olgg1-shard-0&readPreference=primary&ssl=true",USER, PASS, HOST, DB)

# connect to a specific collection (table)
m <- mongo(COLLECTION, url = URI, options = ssl_options(weak_cert_validation = T))
m_spp <- mongo("ebd_taxonomy", url = URI, options = ssl_options(weak_cert_validation = T))


# return records for the species
# this query follows JSON based query syntax (see here for the basics: https://jeroen.github.io/mongolite/query-data.html#query-syntax)
# TESTING INFO
# low checklist block -> "PAMLICO_BEACH-CW" or "GRIMESLAND-NW"
# this works:
#   get_mongo_data('{"ID_NCBA_BLOCK":"GRIMESLAND-CW"}', '{"OBSERVATION_DATE":1, "SAMPLING_EVENT_IDENTIFIER":1}', FALSE)
#   get_mongo_data('{"OBSERVATIONS.COMMON_NAME":"Cerulean Warbler"}', '{"OBSERVATION_DATE":1, "SAMPLING_EVENT_IDENTIFIER":1, "OBSERVATIONS.COMMON_NAME":1, "OBSERVATIONS.OBSERVATION_COUNT":1, "OBSERVATIONS.BEHAVIOR_CODE":1, "OBSERVATIONS.BREEDING_CATEGORY":1}')

get_ebd_data <- function(query="{}", filter="{}"){
  print(filter)
  #  example query format str_interp('{"OBSERVATIONS.COMMON_NAME":"${sp}"}')

  # do not perform query if no query passed
  if (query != "{}"){

    if (grepl("OBSERVATIONS", filter, fixed=TRUE)){
      print("return obs")
      # EXAMPLE/TESTING
      # USE aggregation pipeline syntax to return only needed observations
      # pipeline <- str_interp('[{$match: ${query}}, {$project:${filter}}, {$unwind: {path: "$OBSERVATIONS"}}]')
      #
      # mongodata <- m$aggregate(pipeline) %>%
      # unnest(cols = (c(OBSERVATIONS)))

      # OLD VERSION - downloads and returns all checklist obs
      # mongodata <- m$find(query, filter)
      mongodata <- m$find(query, filter) %>%
      unnest(cols = (c(OBSERVATIONS))) # Expand observations
      # print(head(mongodata))

    } else {
      print("do not return obs")
      mongodata <- m$find(query, filter)

    }

    return(mongodata)
  }
}


#####################################################################################
# Species
get_spp_obs <- function(species, filter){
  # wrapper function for retrieving species records
  query <- str_interp('{"OBSERVATIONS.COMMON_NAME":"${species}"}')
  print(query)
  results <- get_ebd_data(query, filter) %>%
  filter(COMMON_NAME == species)
  print(head(results))
  # results <- get_ebd_data(query, filter) %>%
  # filter("COMMON_NAME" == species)

  # print(head(results))
  return(results)
}

# Get Species List
get_spp_list <- function(query="{}",filter="{}"){

  mongodata <- m_spp$find(query, filter)

  return(mongodata)
}

species_list = get_spp_list(filter='{"PRIMARY_COM_NAME":1}')$PRIMARY_COM_NAME



#####################################################################################
# Block level summaries

block_data <- read.csv("input_data/blocks.csv") %>% filter(COUNTY == "WAKE")
priority_block_geojson <- readLines("input_data/blocks_priority.geojson")
priority_block_data <- subset(block_data, PRIORITY=1)
priority_block_list <- select(priority_block_data,ID_NCBA_BLOCK,ID_BLOCK_CODE)


block_hours_month <- read.csv("input_data/block_month_year_hours.csv")
block_hours_total <- read.csv("input_data/block_total_hours.csv")


# get_block_hours <- function(id_ncba_block, view, project_code) {
get_block_hours <- function(id_ncba_block) {
  result <- filter(block_hours_month, ID_NCBA_BLOCK == id_ncba_block)
  return(result)
}
