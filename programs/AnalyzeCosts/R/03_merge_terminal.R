# This program merges the terminal data onto the clean data file from data_clean.R

# set up_______________

# libraries
library(tidyverse)

#' Merge terminal and sales/purchase data
#'
#' This function is the last step in the cleaning process
#' @param sales_path path of sales/purchasing data (cleaned)
#' @param terminal_path path of terminal data (cleaned)
#' @keywords cats
#' @export
#' @examples
#' merge_terminal_sales("C:/Users/Documents/Data/cleaned_sales_data.xlsx", "C:/Users/Documents/Data/cleaned_terminal_data.xlsx")

merge_terminal_sales <- function(sales_path, terminal_path){
    
  # directories
  input_dir  <- "data/redtomato"
  output_dir <- "data/redtomato/output" 
  
  # data
  clean_data <- read_csv(sales_path)
  terminal_data <- read_csv(terminal_path)
  
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

}