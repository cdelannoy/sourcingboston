# Tab 1


dropdown_apple <- selectInput('apple_opts1', label = HTML("Select an Apple"), 
                              choices = c(sort(unique(df1$Item_group_clean))), 
                              selected = 1
)

box1 <- box(width = NULL,
            title = "Customer Costs Breakdown",
            solidHeader = TRUE,
            status = "danger",
            column(width = 12,
                   plotlyOutput('graph1')
            ))


tab1 <- fluidPage(
  tabsetPanel(
    fluidRow(
      dropdown_apple
    ),
    fluidRow(
      box1
    )
  )
)

# Tab 2

box2 <- box(width = NULL,
            title = "Red Tomato Store Markup vs. Terminal Markets",
            solidHeader = TRUE,
            status = "danger",
            column(width = 12#,
                   #plotlyOutput('overall_agree_msr')
            ))

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