library(shiny)
library(shinydashboard)
library(tidyverse)
library(dplyr)
library(plotly)




### Read in data ---------------------------------------------------------------
dir <- "./data/redtomato/output"
df1 <- read.csv(file.path(dir, "cleaned_data_final_constance.csv"))
df1 <- df1 %>% 
  rename(`Customer to Farmer` = customer_to_farmer,
         `Customer to Logistics` = customer_to_logistics,
         `Customer to RT` = customer_to_RT,
         `Total Customer Price` = total_customer_price)

df1 <- df1 %>% gather(costtype, value, -Item_group_clean, -ECO_status)
df1 <- df1 %>% 
  mutate(ECO_status = case_when(
    ECO_status == "FALSE" ~ "Not ECO Apple",
    TRUE ~ "ECO Apple"
  )) 



df2 <- read.csv(file.path(dir, "terminal_compare.csv"))
df2 <- df2 %>%
  mutate(conventional = conventional*1.3,
         eco = eco*1.3) %>%
  rename(`Not ECO Apple` = conventional,
         `ECO Apple` = eco,
         `Terminal Market NE` = terminal_NE,
         `Terminal Market NW` = terminal_NW)
df2 <- df2 %>% gather(retailer, value, -variety)


df3 <- read.csv(file.path(dir, "pie_data.csv"))

### Tabs -----------------------------------------------------------------------
# Tab 1


dropdown_apple1 <- selectInput('apple_opts1', label = HTML("Select an Apple"), 
                              choices = c(as.character(sort(unique(df1$Item_group_clean)))), 
                              selected = 1
)

box1 <- box(width = NULL,
            title = "Customer Costs Breakdown",
            solidHeader = TRUE,
            status = "danger",
            fluidRow(
              column(width = 12,
              dropdown_apple1)
            ),
            fluidRow(
              column(width = 12,
                     plotlyOutput('graph1')
              )))


tab1 <- fluidPage(
  tabsetPanel(
    
    fluidRow(
      box1
    )
  )
)

# Tab 2
dropdown_apple2 <- selectInput('apple_opts2', label = HTML("Select an Apple"), 
                               choices = c(as.character(sort(unique(df2$variety)))), 
                               selected = 1
)

box2 <- box(width = NULL,
            title = "Red Tomato Store Markup vs. Terminal Markets",
            solidHeader = TRUE,
            status = "danger",
            fluidRow(
              column(width = 12,
                     dropdown_apple2)
            ),
            fluidRow(
              column(width = 12,
                     plotlyOutput('graph2')
              )))

tab2 <- fluidPage(
  tabsetPanel(
    fluidRow(
      box2
      
    ) 
  )
)



# Tab 3


dropdown_apple3 <- selectInput('apple_opts3', label = HTML("Select an Apple"), 
                               choices = c(as.character(sort(unique(df3$Item_group_clean)))), 
                               selected = 1
)

box3 <- box(width = NULL,
            title = "How often were buyers aware of ECO Apples?",
            solidHeader = TRUE,
            status = "danger",
            fluidRow(
              column(width = 12,
                     dropdown_apple3)
            ),
            column(width = 12,
                   plotOutput('graph3')
            ))


tab3 <- fluidPage(
  tabsetPanel(
    fluidRow(
      box3
      
    ) 
  )
)
### UI -------------------------------------------------------------------------
header <- dashboardHeader(title = "Red Tomato Apple Sales",
                          titleWidth = "90%")

sidebar <- dashboardSidebar(
  width = 250,
  sidebarMenu(
    menuItem("Customer Costs", tabName = "customer", icon = shiny::icon("bar-chart", lib = "font-awesome")),
    menuItem("Red Tomato vs. Terminal Markets", tabName = "terminal", icon = shiny::icon("apple-alt", lib = "font-awesome")),
    menuItem("Proportion of ECOApples", tabName = "proportions", icon = shiny::icon("chart-pie", lib = "font-awesome"))
    
  )
)

body <- dashboardBody(

  tabItems(
    tabItem(
      tabName = 'customer',
      tab1
      
    ),
    tabItem(
      tabName = 'terminal',
      tab2
      
    ),
    tabItem(
      tabName = 'proportions',
      tab3
      
    )
    
  )
)

ui <- dashboardPage(
  skin = "red",
  header, 
  sidebar,
  body
)

## Server ----------------------------------------------------------------------
server <- function(input, output) {
  
  output$graph1 <- renderPlotly({
    df_sub <- df1 %>%
      filter(Item_group_clean == input$apple_opts1)
    
    plot_ly(df_sub, 
           x = ~costtype,
           y = ~value,
           type = "bar",
           color = ~ECO_status) %>%
      config(displayModeBar = F) %>%
      layout(
        yaxis = list(title = "Dollars"),
        xaxis = list(title = "Types of Cost")
      )
    
  })
  
  output$graph2 <- renderPlotly({
    df_sub <- df2 %>%
      filter(variety == input$apple_opts2)
    
    plot_ly(df_sub, 
            x = ~retailer,
            y = ~value,
            type = "bar",
            color = ~retailer) %>%
      config(displayModeBar = F) %>%
      layout(
        yaxis = list(showgrid = F, title = "Dollars"),
        xaxis = list(title = "Retailers")
      )
  })
  
  output$graph3 <- renderPlot({
    # Simple Pie Chart
    one <- df3 %>% filter(Item_group_clean == input$apple_opts3)
    
    eco_viz <- c()
    n <- c()
    
    
    for (row in 1:nrow(one)) {
      n <- c(n, one$received_quantity[row])
      eco_viz <- c(eco_viz, one$ECO_visible[row])
      
    }
    
    pie(n, labels = eco_viz, main="For ECO apples, was ECOApple label visible to consumers?")
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

