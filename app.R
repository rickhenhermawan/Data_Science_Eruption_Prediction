rm(list=ls())
library(ggedit)
library(shiny)
library(shinyAce)
library(ggplot2)
library(prophet)
library(rpart)

#Main Data Filter
MyData <- read.csv(file="D:/Documents/Kuliah/INF/Semester 9/Frontier Technology/VolcanoData.csv", header=TRUE, sep=",")
na.strings=c("", "NA")
MyData$Erup.VEI[MyData$Erup.VEI=="NA"] <- 0
MyData[MyData==""] <- NA
MyData <- subset(MyData, select=-c(Tsu,EQ,Addl.Vol.Info,Name,Location,Country,Elevation,Type,Erupt.Agent,Death.Num,Death.De,Injured.Num,Injured.De,Damage..Mill,Damage.De,Houses.Num,Houses.De,Photos))
MyData<-na.omit(MyData)
MyData$Date <- as.Date(with(MyData, paste(MyData$Year, MyData$Mo, MyData$Dy, sep="-"), "%Y-%m-%d"))
MyData <- subset(MyData, select=-c(Year,Mo,Dy))
MyData <- MyData[c(4,1,2,3)]
data <- MyData[484:500, ]
data <- subset(data, select=-c(Latitude,Longitude))

#Date & Erup.VEI Prediction
data$Erup.VEI[data$Erup.VEI==0] <- NA
ds <-data$Date
y <- log(data$Erup.VEI)
df <- data.frame(ds,y)

m <- prophet(df)
future <- make_future_dataframe(m, periods = 155)
forcast <- predict(m,future)
t <- data
t <- subset(data, select=-c(Erup.VEI))
f <- future
f$ds <- as.Date(f$ds)
temp <- f[18:172, ]

#Latitude Prediction
langdata <- MyData
langdata <- subset(langdata, select=-c(Date))
set.seed(3)
id<-sample(2,nrow(langdata),prob = c(0.7,0.3),replace = TRUE)
lang_train<-langdata[id==1,]
lang_test<-langdata[id==2,]
# View(langdata)
# colnames(langdata)
lang_model<-rpart(Latitude~., data = lang_train)
# lang_model
pred_lang<-predict(lang_model,newdata = lang_test, type = "vector")
# pred_lang
# table(pred_lang, lang_test$Latitude)
# plot(pred_lang)
# View(pred_lang)


#Longitude Prediction
longdata <- MyData
longdata <- subset(longdata, select=-c(Date))
set.seed(3)
id<-sample(2,nrow(longdata),prob = c(0.7,0.3),replace = TRUE)
long_train<-longdata[id==1,]
long_test<-longdata[id==2,]

colnames(longdata)
long_model<-rpart(Longitude~., data = long_train)
# long_model
# plot(long_model,margin = 0.1)
# text(long_model,use.n = TRUE,pretty = TRUE,cex=0.8)
pred_long<-predict(long_model,newdata = long_test, type = "vector")
# pred_long
# table(pred_long, long_test$Longitude)
# plot(pred_long)
# View(pred_long)


################################################################################################################
################################################################################################################

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Eruption Prediction"),
   conditionalPanel("input.tbPanel=='a'",
                    sidebarPanel(
                      h4('Erup.VEI before Prediction'))),
   conditionalPanel("input.tbPanel=='b'",
                    sidebarPanel(
                      h4('Erup.VEI after Prediction'))),
   conditionalPanel("input.tbPanel=='c'",
                    sidebarPanel(
                      h4('Erup.VEI Component Conclusion'))),
   conditionalPanel("input.tbPanel=='d'",
                    sidebarPanel(
                      h4('PlotOutput Latitude before Prediction'))),
   conditionalPanel("input.tbPanel=='e'",
                    sidebarPanel(
                      h4('PlotOutput Latitude after Prediction'))),
   conditionalPanel("input.tbPanel=='f'",
                    sidebarPanel(
                      h4('PlotOutput Longitude before Prediction'))),
   conditionalPanel("input.tbPanel=='g'",
                    sidebarPanel(
                      h4('PlotOutput Longitude after Prediction'))),
                    
   mainPanel(
     tabsetPanel(id = 'tbPanel',
     tabPanel('Erup.VEI before Prediction',value = 'a',
              plotOutput('plot1'),
              tableOutput('table1')
              ),
     tabPanel('Erup.VEI after Prediction',value = 'b',
              plotOutput('plot2'),
              tableOutput('table2')
              ),
     tabPanel('Erup.VEI Component Conclutsion',value = 'c',
              plotOutput('plot3'),
              tableOutput('table3')
              ),
     tabPanel('PlotOutput Latitude before Prediction',value = 'd',
              plotOutput('plot4'),
              tableOutput('table4')
              ),
     tabPanel('PlotOutput Latitude after Prediction',value = 'e',
              plotOutput('plot5'),
              tableOutput('table5')
              ),
     tabPanel('PlotOutput Longitude before Prediction',value = 'f',
              plotOutput('plot6'),
              tableOutput('table6')
              ),
     tabPanel('PlotOutput Longitude after Prediction',value = 'g',
              plotOutput('plot7'),
              tableOutput('table7')
              )
     )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
   
   output$plot1 <- renderPlot({
     p1=data%>%ggplot(aes(x=ds,y=y))+geom_point()
     p2=data%>%ggplot(aes(x=ds,y=y))+geom_line()+geom_point((aes(colour=Petal.Width)))
     p3=list(p1=p1,p2=p2)

     output$plot1<-renderPlot({p1})
     outp1<-callModule(ggEdit,'pOut1',obj=reactive(list(p1=p1)))
     outp2<-callModule(ggEdit,'pOut2',obj=reactive(p3),showDefaults=T,height=300)

   })

   output$table1 <- renderTable({
     data$Date <- as.character(data$Date)
     head(data, n = 172)
   })

   output$plot2 <- renderPlot({
     # n <- forcast[307:461, ]
     g <- plot(m, forcast)
     g+theme_classic()
   })

   output$table2 <- renderTable({
     h <- table(temp)
   })

   output$plot3 <- renderPlot({
     g <- prophet_plot_components(m, forcast)
   })

   output$table3 <- renderTable({
     h <- table(f)
   })

   output$plot4 <- renderPlot({
     g <- plot(langdata$Latitude)
   })

   output$table4 <- renderTable({
     langdata$Latitude <- as.character(langdata$Latitude)
     langdata$Longitude <- as.character(langdata$Longitude)
     head(langdata, n=500)
   })

   output$plot5 <- renderPlot({
     plot(pred_lang)
   })

   output$table5 <- renderTable({
     lang_test$Latitude <- as.character(lang_test$Latitude)
     lang_test$Longitude <- as.character(lang_test$Longitude)
     h <- table(pred_lang, lang_test$Latitude)
   })

   output$plot6 <- renderPlot({
     g <- plot(longdata$Longitude)
   })
   
   output$table6 <- renderTable({
     longdata$Latitude <- as.character(longdata$Latitude)
     longdata$Longitude <- as.character(longdata$Longitude)
     head(longdata, n=500)
   })
   
   output$plot7 <- renderPlot({
     plot(pred_long)
   })
   
   output$table7 <- renderTable({
     long_test$Latitude <- as.character(long_test$Latitude)
     long_test$Longitude <- as.character(long_test$Longitude)
     h <- table(pred_long, long_test$Latitude)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

