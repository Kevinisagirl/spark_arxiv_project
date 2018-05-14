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
library(circlize)
library(migest)


data <- read.csv("emails.country.csv")
generic <- read.csv("generic_email.csv")
genz <- read.csv("gen.and.org.csv")
genz <- subset(genz, select = -c(X))
data <- subset(data, select = -c(X))

# Define UI for application that draws a histogram
ui <- fluidPage( theme =shinytheme("cerulean"),
                 navbarPage("Article Relationships",
     
   
   tabPanel("Collaboration",
            titlePanel("Collaborating Countries"),
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
          
            
),
tabPanel("Chord Diagram",
         sidebarLayout(
           sidebarPanel(
             h3("Chord Diagram"),
             hr(),
             helpText("This graph represents the interactions between
                      the countries with the highest count of authors 
                      from these countries")
           ),
           mainPanel(
             plotOutput('chord')
           )
         )),
tabPanel('Authors',
         sidebarLayout(
           sidebarPanel(
             h3('Authors per Article'),
             hr(),
             helpText('Write some text')
           ),
           mainPanel(plotlyOutput('graph1'))
         ))
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
       labs(title= paste("Countries Collaborating with", input$country))
     
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
     data6<-read.csv("emails.country.csv")
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
       labs(title= "Email Locations of Publications") + theme_minimal()
     
     p <- ggplotly(p, tooltip = "text")
     p
   })
   
   output$chord <- renderPlot({
     m <- data.frame(order = 1:6,
                     country = c("United States", "China", "Switzerland", "Germany", "Italy", "Japan"),
                     V3 = c(1, 101, 123, 87, 32, 32),
                     V4 = c(101, 1, 0, 0, 0, 11),
                     V5 = c(123, 0, 1, 16, 16, 15),
                     V6 = c(87, 0, 16, 1, 12, 0),
                     V7 = c(32, 0, 16, 12, 1, 0),
                     V8 = c(32, 11, 15, 0, 0, 1),
                     r = c(255,255,255,153,51,51),
                     g = c(51, 153, 255, 255, 255, 255),
                     b = c(51, 51, 51, 51, 51, 153),
                     stringsAsFactors = FALSE)
     df1 <- m[, c(1,2, 9:11)]
     m <- m[,-(1:2)]/4
     m <- as.matrix(m[,c(1:6)])
     dimnames(m) <- list(orig = df1$country, dest = df1$country)
     #Sort order of data.frame and matrix for plotting in circos
     df1 <- arrange(df1, order)
     df1$country <- factor(df1$country, levels = df1$country)
     m <- m[levels(df1$country),levels(df1$country)]
     
     
     ### Define ranges of circos sectors and their colors (both of the sectors and the links)
     df1$xmin <- 0
     df1$xmax <- rowSums(m) + colSums(m)
     n <- nrow(df1)
     df1$rcol<-rgb(df1$r, df1$g, df1$b, max = 255)
     df1$lcol<-rgb(df1$r, df1$g, df1$b, alpha=200, max = 255)
     
     ### Plot sectors (outer part)
     par(mar=rep(0,4))
     circos.clear()
     
     ### Basic circos graphic parameters
     circos.par(cell.padding=c(0,0,0,0), track.margin=c(0,0.15), start.degree = 90, gap.degree =4)
     
     ### Sector details
     circos.initialize(factors = df1$country, xlim = cbind(df1$xmin, df1$xmax))
     
     ### Plot sectors
     circos.trackPlotRegion(ylim = c(0, 1), factors = df1$country, track.height=0.1,
                            #panel.fun for each sector
                            panel.fun = function(x, y) {
                              #select details of current sector
                              name = get.cell.meta.data("sector.index")
                              i = get.cell.meta.data("sector.numeric.index")
                              xlim = get.cell.meta.data("xlim")
                              ylim = get.cell.meta.data("ylim")
                              
                              #text direction (dd) and adjusmtents (aa)
                              theta = circlize(mean(xlim), 1.3)[1, 1] %% 360
                              dd <- ifelse(theta < 90 || theta > 270, "clockwise", "reverse.clockwise")
                              aa = c(1, 0.5)
                              if(theta < 90 || theta > 270)  aa = c(0, 0.5)
                              
                              #plot country labels
                              circos.text(x=mean(xlim), y=1.7, labels=name, facing = dd, cex=0.6,  adj = aa)
                              
                              #plot main sector
                              circos.rect(xleft=xlim[1], ybottom=ylim[1], xright=xlim[2], ytop=ylim[2], 
                                          col = df1$rcol[i], border=df1$rcol[i])
                              
                              #blank in part of main sector
                              circos.rect(xleft=xlim[1], ybottom=ylim[1], xright=xlim[2]-rowSums(m)[i], ytop=ylim[1]+0.3, 
                                          col = "white", border = "white")
                              
                              #white line all the way around
                              circos.rect(xleft=xlim[1], ybottom=0.3, xright=xlim[2], ytop=0.32, col = "white", border = "white")
                              
                              #plot axis
                              circos.axis(labels.cex=0.6, direction = "outside", major.at=seq(from=0,to=floor(df1$xmax)[i],by=5), 
                                          minor.ticks=1, labels.away.percentage = 0.15)
                            })
     
     ### Plot links (inner part)
     ### Add sum values to df1, marking the x-position of the first links
     ### out (sum1) and in (sum2). Updated for further links in loop below.
     df1$sum1 <- colSums(m)
     df1$sum2 <- numeric(n)
     
     ### Create a data.frame of the flow matrix sorted by flow size, to allow largest flow plotted first
     df2 <- cbind(as.data.frame(m),orig=rownames(m),  stringsAsFactors=FALSE)
     df2 <- reshape(df2, idvar="orig", varying=list(1:n), direction="long",
                    timevar="dest", time=rownames(m),  v.names = "m")
     df2 <- arrange(df2,desc(m))
     
     ### Keep only the largest flows to avoid clutter
     df2 <- subset(df2, m > quantile(m,0.6))
     
     ### Plot links
     p <- for(k in 1:nrow(df2)){
       #i,j reference of flow matrix
       i<-match(df2$orig[k],df1$country)
       j<-match(df2$dest[k],df1$country)
       
       #plot link
       circos.link(sector.index1=df1$country[i], point1=c(df1$sum1[i], df1$sum1[i] + abs(m[i, j])),
                   sector.index2=df1$country[j], point2=c(df1$sum2[j], df1$sum2[j] + abs(m[i, j])),
                   col = df1$lcol[i])
       
       #update sum1 and sum2 for use when plotting the next link
       df1$sum1[i] = df1$sum1[i] + abs(m[i, j])
       df1$sum2[j] = df1$sum2[j] + abs(m[i, j])
     }
     p
   }
   )
   
   output$graph1 <- renderPlotly({
     
     data44 <- read.csv("numbers.csv")
     df <- subset(data44, select = "X1")
     
     df$bins <- cut(df$X1, breaks=c(0,4,10,15,20,500), labels=c("1-4","5-10","10-15","15-20","20+"))
     setnames(df, "X1", "Number_of_Authors")
     p <- ggplot(df, aes(bins)) + 
       geom_bar(fill = "Green") + 
       xlab("Number of Authors") + ggtitle("Total authors binned")
     p <- ggplotly(p)
     p
   })

}

# Run the application 
shinyApp(ui = ui, server = server)

