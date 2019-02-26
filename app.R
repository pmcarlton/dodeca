library(ggplot2)
#library(plotly)
#library(Cairo)   # For nicer ggplot2 output when deployed on Linux



#am1<-read.csv('dodecamers_amounts_umap.csv')
#am<-data.frame(am1,row.names=1)

load('dodeca_ge100_nn25_md0.2.Rdat')
ui <- fluidPage(
titlePanel(h3("Dodecamers in the C. elegans genome"), windowTitle="Dodecamers"),

mainPanel("Select points to examine their distribution - Double-click on selected points to zoom in - Click outside selection to unselect - Double-click with no points selected to zoom out"),
   fluidRow(
    column(width = 12, h4("Chromosomal distribution (sum of all selected 12-mers)"),
           plotOutput("plot2",height=400))) ,
 fluidRow(
    column(width = 6,h4("UMAP embedding"),
           plotOutput("plot1", height = 800,
                      # Equivalent to: click = clickOpts(id = "plot_click")
                      click = "plot1_click",
                      dblclick = "plot1_dblclick",
                      brush = brushOpts(
                        id = "plot1_brush"
                      )
           )
    
    ),
    column(width = 6,
           h4("Sequence of selected 12-mers"),
           verbatimTextOutput("brush_info")
           )
  )
  
)
  


server <- function(input, output) {
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$plot2 <- renderPlot({
    barplot(colSums(brushedPoints(dx, input$plot1_brush)[,1:60]))
  })
  
  output$plot1 <- renderPlot({
    ggplot(dx, aes(x=p1, y=p2, label=rownames(dx))) + 
      geom_point() +
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = TRUE)
  })
  
  observeEvent(input$plot1_dblclick, {
    brush <- input$plot1_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })
  
  output$click_info <- renderPrint({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    nearPoints(dx, input$plot1_click, addDist = TRUE)
  })
  
  output$brush_info <- renderPrint({
    rownames(brushedPoints(dx, input$plot1_brush))
  })
}

shinyApp(ui, server)
