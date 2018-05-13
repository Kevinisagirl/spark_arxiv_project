library(ggplot2)
library(plotly)
library(ggmap)
library(data.table)
library(dplyr)
library(tidyr)
library(plyr)
#setnames(DF, "Name", "region")
data <- read.csv("emails.country.csv")

#data$Name[which(data$Name=="Russian Federation")]<-"Russia"


#data$Name <- as.character(data$Name)
#data$Name[data$Name == "Russian Federation"] <- "Russia"

setnames(data, "Name", "region")
map <- map_data("world")


data1 <-data %>% count(data$region)

data5 <- data.frame(count(data$region))
setnames(data5, "x", "region")


map1 <- left_join(map, data5, by = "region")
map1$freq %>% replace_na(0)

p <- ggplot() 
p <- p + geom_polygon(data=map1, aes(x=long, y=lat, group = group, text = region, fill=log(freq)),colour="white"
) + scale_fill_continuous(low = "lightgreen", high = "darkgreen", guide="colorbar")


p <- ggplotly(p)
p