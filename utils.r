# utilities


block_data = read.csv("input_data/blocks.csv")
priority_block_data <- subset(block_data, PRIORITY=1)
priority_block_list <- select(priority_block_data,ID_NCBA_BLOCK,ID_BLOCK_CODE)
