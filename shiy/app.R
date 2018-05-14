#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(plotly)
library(ggmap)
library(data.table)
library(dplyr)
library(tidyr)
library(plyr)
library(RColorBrewer) 
library(ggthemes)
library(shinythemes)

data <- read.csv("emails.country.csv")
generic <- read.csv("generic_email.csv")
genz <- read.csv("gen.and.org.csv")
genz <- subset(genz, select = -c(X))
data <- subset(data, select = -c(X))

# Define UI for application that draws a histogram
ui <- fluidPage( theme =shinytheme("cerulean"),
                 navbarPage("Article Relationships",
     
   
   tabPanel("Association",
            titlePanel("Associated Countries"),
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput("country",
                     "Select Country:",
                     choices = unique(data$Name)),
         hr(),
         helpText("Select a Country and a map
                  will render with the number of corresponding countries that
                  have articles that are associated with the selected country.")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotlyOutput("distPlot")
      )
   )
   ),
   tabPanel("Generic Emails",
            titlePanel("Investigating Generics"),
            sidebarLayout(
              sidebarPanel(
                h3("Academic Email vs Generic"),
                hr(),
                helpText('The bar Graph displays the 
                        overall quantity of academic email addresses that
                        are associated with an academic papers compared with
                        with the quantity of generic (gmail/yahoo) email addresses
                        that are associated with academic papers.')
                ),
              mainPanel(
                plotlyOutput("two")
              )
                )
),
   tabPanel("Overall View",
            titlePanel("Academic Emails"),
            sidebarLayout(
              sidebarPanel(
                h3("Geographic Representation of all Academic Emails"),
                hr(),
                helpText('This is a geographical representation of all
                         academic emails associated with Academic papers 
                         in our dataset.  We filtered by academic addresses by 
                         identifying the ending of an address, cross-referencing it
                         with a third party dataset in order to identify country
                         of origin for an address. ')
              ),
              mainPanel(plotlyOutput("three")) 
            )
            
)
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  genz1 <- nrow(genz)
  academic <- nrow(data)
  combin <- merge(genz,data,by="article")
  map <- map_data("world")
  
   
   output$distPlot <- renderPlotly({
     
     article <- data %>% 
       arrange(article)
     
     article1 <- article %>%
       select(article,Name) %>%
       filter(Name == input$country)
     
     ass <- article %>%
       select(article, Name) %>%
       filter(article %in% article1$article & Name != input$country)
     
     map.count <- data.frame(count(ass$Name))
     setnames(map.count, "x", "region")
     
     map1 <- left_join(map, map.count, by = "region")
     
     p <- ggplot() 
     p <- p + geom_polygon(data=map1, aes(x=long, y=lat, group = group, text = paste("Country: ",region,"\n","Count: ",freq) ,fill=log(freq)),colour="white"
     ) + scale_fill_continuous(low = "lightgreen", high = "darkgreen", guide="colorbar") +
       labs(title= paste("Countries Associated with", input$country))
     
     p <- ggplotly(p, tooltip = "text")
     p
   })
   
   
   output$two <- renderPlotly({
     simple <- rbind(genz1,academic)
     #names(simple) <- c("Generic", "Academic")
     #simple = data.frame(t(simple))
     names(simple) <- c("data")
     simple <- reshape2::melt(as.data.frame(simple), 1)
     
     p <- plot_ly(
       x = c("Generic", "Academic"),
       y = c(1527, 7125),
       name = "Generic vs Academic Email",
       type = "bar",
       color = c("green", "darkgreen"),
       showlegend=FALSE
     )
     p
     
     
   })
   
   output$three <- renderPlotly({
     data6<-data
     setnames(data6, "Name", "region")
     map <- map_data("world")

     data5 <- data.frame(count(data6$region))
     setnames(data5, "x", "region")
     map1 <- left_join(map, data5, by = "region")
     map1$freq %>% replace_na(0)
     
     map2<- map1 %>%
       mutate(
         fake = freq
       )
     
     p <- ggplot() 
     p <- p + geom_polygon(data=map2, aes(x=long, y=lat, group = group, text = paste("Country: ",region,"\n","Count: ",fake) ,fill=log(freq)),colour="white"
     ) + scale_fill_continuous(low = "lightgreen", high = "darkgreen", guide="colorbar") +
       labs(title= "Emails Associated with Publications") + theme_minimal()
     
     p <- ggplotly(p, tooltip = "text")
     p
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

