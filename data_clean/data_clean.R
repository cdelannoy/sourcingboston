library(tidyverse)
library(openxlsx)
library(tools)

##### Read files

path_dir <- "./data/redtomato"
output_dir <- "./data/redtomato/output"

pur <- read.xlsx(file.path(path_dir, "Purchase History/Pur_History_2014-2018.xlsx"), startRow = 4)
sal <- read.xlsx(file.path(path_dir, "Sales History/Sales Data 2014-2018.xlsx"), startRow = 5)

##### Summarize purchase data
pur$Itemcode %>%  trimws() %>% unique() %>% length()

apply(pur, 2, str)

pur_g <- pur %>% 
  mutate(Received.Quantity = as.numeric(Received.Quantity),
         Actual.Inventory.Cost = as.numeric(Actual.Inventory.Cost),
         `Actual.Add-on.Cost` = as.numeric(`Actual.Add-on.Cost`)) %>% 
  group_by(Itemcode) %>% 
  summarize(n_invoice = n(),
            received_quantity_tot = sum(Received.Quantity),
            actual_inv_cost_tot = sum(Actual.Inventory.Cost),
            actual_addon_cost_tot = sum(`Actual.Add-on.Cost`)) %>%
  mutate(actual_inv_cost_perunit = actual_inv_cost_tot / received_quantity_tot,
         actual_addon_cost_perunit =  actual_addon_cost_tot / received_quantity_tot,
         tot_cost_perunit = actual_inv_cost_perunit + actual_addon_cost_perunit) 
pur_g %>% View()

pur_g  %>% filter( !(Itemcode %in% sal$Itemcode)) %>%  
  filter(!(received_quantity_tot == 0 | actual_inv_cost_tot == 0)) %>%
  View()

###### Merge purchase and sales
ps <- left_join(sal, pur_g, by = "Itemcode") %>%
  mutate(Itemcode = trimws(Itemcode))


###### Keep only apples and peaches
ps <- ps %>% filter(grepl("^APP", Itemcode)) # how much aer yo upaying for eco bags, grep by apply after excluding ^APP

###### Drop one inactive row
ps <- ps %>% filter(!grepl("INACTIVE", Description))

###### Checks

# Check 1 ----------------------------------------------------------------------

# 124 rows passed out of 222,

check1 <- ps %>% select(Quantity_sold, received_quantity_tot) %>% 
  mutate(diff = Quantity_sold - received_quantity_tot,
         perc_diff = 100* diff/Quantity_sold)
table(check1$diff) 

# Check 2 ----------------------------------------------------------------------

# this check failed 
check2 <- ps %>% select(Number_of_invoices, n_invoice) %>% mutate(diff = Number_of_invoices - n_invoice,
                                                                  perc_diff = 100* diff/Number_of_invoices)
table(check2$diff) 


# Check 3 ----------------------------------------------------------------------

# Check 3 passed using avg_PRICE_each. Very small differences.
# note that avg_COST_each is RT's expenditure, but that variable failed this check

check3 <- ps %>% select(Ave_price_each, tot_cost_perunit, Gross_profit_per_muom) %>%
  mutate(ave_each = (tot_cost_perunit + Gross_profit_per_muom),
         diff_price = Ave_price_each - ave_each,
         perc_diff_price = 100*diff_price/Ave_price_each)


# Check 4 ----------------------------------------------------------------------

# Check 4 is passed! Very small difference
check4 <- ps %>% select(Line_gross_profit, received_quantity_tot, Gross_profit_per_muom) %>%
  mutate(calc_gross_profit = Line_gross_profit/received_quantity_tot,
         diff = calc_gross_profit - Gross_profit_per_muom,
         perc_diff = 100* diff/Gross_profit_per_muom)
table(check4$diff) 


##### Creating Indicators
ps <- ps %>%
  mutate(ECO_status = grepl("E", Itemcode)) %>%
  mutate(ECO_visible = (grepl("tote | polybag", Description) & ECO_status))

ps <- ps %>% 
  mutate(Item_group = gsub("[[:digit:][:punct:]]","", Description)) %>% 
  mutate(Item_group = gsub("ECO|tote|polybag", "", Item_group)) %>% 
  mutate(Item_group = trimws(Item_group)) %>% 
  mutate(Item_group = gsub(" s$", "", Item_group))

final <- ps %>%
  dplyr::select(Item_group, ECO_status, ECO_visible,
                actual_inv_cost_perunit, 
                actual_addon_cost_perunit,
                Gross_profit_per_muom,
                Ave_price_each) %>%
  rename(customer_to_farmer = actual_inv_cost_perunit,
         customer_to_logistics = actual_addon_cost_perunit,
         customer_to_RT = Gross_profit_per_muom,
         total_customer_price = Ave_price_each)

# TO DO, remove Eco from Apple Eco Fuji (it has an E in the itemcode)
# gsub out "bu" from the end of item_group
# McIntosh vs mcintosh
# Red Apple Delicious spelling rename them to Red Apple D
# remove white space
# remove double spacing between words
# filtered in alphabethical order
# FCY/XFCY
# HRML vs Hrml

final <- final %>% 
  mutate(Item_group_clean = tolower(Item_group))

final <- final %>% 
  mutate(Item_group_clean = trimws(Item_group_clean),
         Item_group_clean = gsub(" bu$", "", Item_group_clean),
         Item_group_clean = trimws(Item_group_clean),
         Item_group_clean = gsub("eco", "", Item_group_clean),
         Item_group_clean = gsub(".*apple red d.*", "apple red delicious", Item_group_clean),
         Item_group_clean = gsub("  ", " ", Item_group_clean),
         Item_group_clean = tools::toTitleCase(Item_group_clean)) 


final <- final[order(final$Item_group_clean),]


final <- final[c(
  "Item_group_clean",
  "ECO_status",
  "ECO_visible",
  "customer_to_farmer",
  "customer_to_logistics",
  "customer_to_RT",
  "total_customer_price"
)]

final_temp <- final %>% 
  group_by(Item_group_clean, ECO_status, ECO_visible) %>% 
  summarize(customer_to_farmer = mean(customer_to_farmer),
            customer_to_logistics = mean(customer_to_logistics),
            customer_to_RT = mean(customer_to_RT),
            total_customer_price = mean(total_customer_price))


# Dataset for Olivia's graph

write.csv(final_temp, file.path(output_dir, "cleaned_data_final.csv"), row.names = FALSE)

# Pie chart
final2 <- final %>% 






# Dataset for terminal merging

final_for_terminal <- final %>% 
  group_by(Item_group_clean, ECO_status) %>% 
  summarize(customer_to_farmer = mean(customer_to_farmer),
            customer_to_logistics = mean(customer_to_logistics),
            customer_to_RT = mean(customer_to_RT),
            total_customer_price = mean(total_customer_price))

write.csv(final_for_terminal, file.path(output_dir, "cleaned_data_final_constance.csv"), row.names = FALSE)