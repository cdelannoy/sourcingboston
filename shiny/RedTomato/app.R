library(shiny)
library(shinydashboard)
library(tidyverse)
library(dplyr)
library(plotly)




### Read in data ---------------------------------------------------------------
dir <- "./data/redtomato/output"
df1 <- read.csv(file.path(dir, "cleaned_data_final.csv"))

### Tabs -----------------------------------------------------------------------
# Tab 1


dropdown_apple1 <- selectInput('apple_opts1', label = HTML("Select an Apple"), 
                              choices = c(sort(unique(df1$Item_group_clean))), 
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
                               choices = c(sort(unique(df2$Item_group_clean))), 
                               selected = 1
)

box2 <- box(width = NULL,
            title = "Red Tomato Store Markup vs. Terminal Markets",
            solidHeader = TRUE,
            status = "danger",fluidRow(
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
box3 <- box(width = NULL,
            title = "Proportion of ECO Apples out of all Red Tomato Apples",
            solidHeader = TRUE,
            status = "danger",
            column(width = 12#,
                   #plotlyOutput('overall_agree_msr')
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
    menuItem("Red Tomato vs. Terminal Markets", tabName = "terminal", icon = shiny::icon("chart-pie", lib = "font-awesome")),
    menuItem("Proportion of ECOApples", tabName = "proportions", icon = shiny::icon("apple-alt", lib = "font-awesome"))
    
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css")
  ),
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
  header, 
  sidebar,
  body
)

## Server ----------------------------------------------------------------------
server <- function(input, output) {
  
  # plot_ly(graph1, 
  #         x = ~measure, 
  #         y = ~rate, 
  #         text = ~str_c(round(rate), "% <br>", info),
  #         hoverinfo = 'text+x',
  #         type = 'bar',
  #         marker = list(color = sel_cols)
  # ) %>%
  #   config(displayModeBar = F) %>%
  #   layout(
  #     yaxis = list(showgrid = F, title = "Rate"),
  #     xaxis = list(title = "Measure")
  #   )
}

# Run the application 
shinyApp(ui = ui, server = server)

