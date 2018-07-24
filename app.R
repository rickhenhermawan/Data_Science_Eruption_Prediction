rm(list=ls())
library(ggedit)
library(shiny)
library(shinyAce)
library(ggplot2)
library(prophet)
library(rpart)
library(plotly)

#Main Data Filter
MyData <- read.csv(file="C:/Users/Rickhen Hermawan/Desktop/VolcanoData.csv", header=TRUE, sep=",")
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

#Erup.VEI Prediction
veidata <- MyData
veidata <- subset(veidata, select=-c(Date))
set.seed(3)
id<-sample(2,nrow(veidata),prob = c(0.7,0.3),replace = TRUE)
vei_train<-veidata[id==1,]
vei_test<-veidata[id==2,]
# View(langdata)
# colnames(langdata)
vei_model<-rpart(Erup.VEI~., data = vei_train)
vei_model$frame$yval<-round(vei_model$frame$yval)
# lang_model
pred_vei<-predict(vei_model,newdata = vei_test, type = "vector")
pred_vei<-round(pred_vei)
pred_vei<-as.data.frame(pred_vei)
pred_vei$Latitude<-vei_test$Latitude
pred_vei$Longitude<-vei_test$Longitude
pred_vei<-pred_vei[c(2,3,1)]
pred_model<-rpart(pred_vei~.,data = pred_vei)
pred_model$frame$yval<-round(pred_model$frame$yval)
# pred_lang
# table(pred_lang, lang_test$Latitude)
# plot(pred_lang)
# View(pred_lang)


################################################################################################################
################################################################################################################

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Eruption Prediction"),
   conditionalPanel("input.tbPanel=='a'",
                    sidebarPanel(
                      h4('Erup.VEI before Prediction using Prophet'))),
   conditionalPanel("input.tbPanel=='b'",
                    sidebarPanel(
                      h4('Erup.VEI after Prediction using Prophet'))),
   conditionalPanel("input.tbPanel=='c'",
                    sidebarPanel(
                      h4('Erup.VEI Component Conclusion using Prophet'))),
   conditionalPanel("input.tbPanel=='d'",
                    sidebarPanel(
                      h4('DT Erup.VEI before Prediction '))),
   conditionalPanel("input.tbPanel=='e'",
                    sidebarPanel(
                      h4('DT Erup.VEI after Prediction'))),
   conditionalPanel("input.tbPanel=='f'",
                    sidebarPanel(
                      h4('Erup.VEI before Prediction using DT'))),
   conditionalPanel("input.tbPanel=='g'",
                    sidebarPanel(
                      h4('Erup.VEI after Prediction using DT'))),
                    
   mainPanel(
     tabsetPanel(id = 'tbPanel',
     tabPanel('Erup.VEI before Prediction using Prophet',value = 'a',
              plotOutput('plot1'),
              tableOutput('table1')
              ),
     tabPanel('Erup.VEI after Prediction using Prophet',value = 'b',
              plotOutput('plot2'),
              tableOutput('table2')
              ),
     tabPanel('Erup.VEI Component Conclusion',value = 'c',
              plotOutput('plot3'),
              tableOutput('table3')
              ),
     tabPanel('DT Erup.VEI before Prediction',value = 'd',
              plotOutput('plot4'),
              tableOutput('table4')
              ),
     tabPanel('DT Erup.VEI after Prediction',value = 'e',
              plotOutput('plot5'),
              tableOutput('table5')
              ),
     tabPanel('Erup.VEI before Prediction using DT',value = 'f',
              plotOutput('plot6'),
              tableOutput('table6')
              ),
     tabPanel('Erup.VEI after Prediction using DT',value = 'g',
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
     plot(vei_model,margin = 0.1)
     text(vei_model,use.n = TRUE,pretty = TRUE,cex=0.8)
   })

   output$table4 <- renderTable({
     veidata$Latitude <- as.character(veidata$Latitude)
     veidata$Longitude <- as.character(veidata$Longitude)
     head(veidata, n=500)
   })

   output$plot5 <- renderPlot({
     plot(pred_model, margin=0.1)
     text(pred_model,use.n = TRUE,pretty = TRUE,cex=0.8)
   })

   output$table5 <- renderTable({
     pred_vei$Latitude <- as.character(pred_vei$Latitude)
     pred_vei$Longitude <- as.character(pred_vei$Longitude)
     head(pred_vei, n=155)
   })
   
   output$plot6 <- renderPlot({
     vein<-veidata
     vein$Erup.VEI<-factor(vein$Erup.VEI)
     ggplot(vein,aes(Latitude,Longitude,group=Erup.VEI, colour=Erup.VEI))+geom_line()+geom_point()
   })
   
   output$table6 <- renderTable({
     veidata$Latitude <- as.character(veidata$Latitude)
     veidata$Longitude <- as.character(veidata$Longitude)
     head(veidata, n=500)
   })
   
   output$plot7 <- renderPlot({
     prev<-pred_vei
     prev$pred_vei<-factor(prev$pred_vei)
     ggplot(prev,aes(Latitude,Longitude,group=pred_vei, colour=pred_vei))+geom_line()+geom_point()
   })
   
   output$table7 <- renderTable({
     pred_vei$Latitude <- as.character(pred_vei$Latitude)
     pred_vei$Longitude <- as.character(pred_vei$Longitude)
     head(pred_vei, n=155)
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

