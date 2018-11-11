# This program merges the terminal data onto the clean data file from data_clean.R

# set up_______________

# libraries
library(tidyverse)

# directories
input_dir  <- "data/redtomato"
output_dir <- "data/redtomato/output" 

# data
clean_data <- read_csv(file.path(output_dir, "cleaned_data_final_constance.csv"))
terminal_data <- read_csv(file.path(output_dir, "terminal_boston.csv"))

# processing_______________

# processing clean_data
data_clean_processed <- clean_data %>% 
  mutate(variety = str_remove(Item_group_clean, "Apple ") %>% tolower()) %>% 
  mutate_at(vars(variety), function(x){if_else(x == "grannysmith", "granny smith", x)}) %>% 
  mutate_at(vars(ECO_status), function(x){if_else(x == TRUE, "eco", "conventional")}) %>% 
  select(variety, ECO_status, total_customer_price) %>% 
  spread(ECO_status, total_customer_price)
  
# merging
all_price_dat <- data_clean_processed %>% 
  left_join(terminal_data, by = "variety") %>% 
  filter(!is.na(overall_avg)) %>% 
  spread(region, overall_avg)

# output for price comparison
price_output <- all_price_dat %>% 
  select(variety,
         conventional,
         eco,
         terminal_NE = Northeast,
         terminal_NW = Northwest)

write_csv(price_output, file.path(output_dir, "terminal_compare.csv"))

