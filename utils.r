# utilities


block_data <- read.csv("input_data/blocks.csv") %>% filter(COUNTY == "WAKE") 
priority_block_geojson <- readLines("input_data/blocks_priority.geojson")
priority_block_data <- subset(block_data, PRIORITY=1)
priority_block_list <- select(priority_block_data,ID_NCBA_BLOCK,ID_BLOCK_CODE)
