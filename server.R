library(shiny)
library(quantmod)
library(ggplot2)
#require(PerformanceAnalytics)

# It's supposed to load only once outside of server, but it does many times
# So let's fix it this way
if(!exists("SPY")) getSymbols('SPY', from = "1900-01-01")  

shinyServer(function(input, output) {
        
react <- reactive({
                money <- as.numeric(input$money)
                drop.level <- as.numeric(input$drop.level)
                cooldown <- as.numeric(input$cooldown)
                ema.length <- as.numeric(input$ema)
                start.date.string <- as.character(input$start)
                fee <- as.numeric(input$fee)
                # Debug init values
                if(FALSE) {
                        money <- 10000
                        cooldown <- 10
                        drop.level <- 10
                        ema.length <- 365
                        start.date.string <- '2000-01-01'
                        fee <- 10
                }
                
                start.date <- as.Date(start.date.string, "%Y-%m-%d")
                if(is.na(start.date)) cat("Wrong date format")
                if(start.date < index(SPY)[1]) cat(paste("Start date shouldn't be before",index(SPY)[1]))
                
                work <- SPY[paste0(start.date,"::")]
                
                days <- length(index(work))
                
                ema <- EMA(Cl(SPY), n = ema.length, wilder = TRUE)
                ema <- as.vector(last(ema, days))
                
                price <- as.vector(Cl(work))
                bull <- price > ema
                drop.coeff <- 1 - drop.level / 100
                
                # Init
                stock <- 0
                last.max <- price[1]
                assets <- numeric(days)
                ret <- numeric(days)
                cooldown.counter <- cooldown + 1
                
                for(i in 1:days) {
                        last.max <- max(last.max, price[i])
                        if(money > 0 & bull[i] & cooldown.counter > cooldown) {
                                stock <- (money - fee) / price[i]
                                money <- 0
                                last.max <- price[i]
                        }
                        if(stock > 0 & price[i] < (drop.coeff * last.max)) {
                                money <- stock * price[i] - fee
                                stock <- 0
                                cooldown.counter <- 0
                        }
                        assets[i] <- money + stock * price[i]
                        cooldown.counter <- cooldown.counter + 1
                }
                DF <- data.frame(dates=index(work), assets=assets, bull=bull)
                p<-ggplot(aes(dates, assets, color=bull), data=DF) +
                        geom_point() +
                        xlab("Date") +
                        ylab("Assets")
                DF1 <- data.frame(date=index(work), SPY=price, bull=bull)
                p1<-ggplot(aes(date,SPY), data=DF1) +
                        geom_point() +
                        geom_line(aes(dates, ema, color="EMA"),
                                  data = data.frame(dates=index(work), ema))
                txt<- paste0(
                        "Strategy result ",
                        round((assets[days]/assets[1]-1)*100),
                        "%, while stock did ",
                        round((price[days]/price[1]-1)*100),
                        "%.")
                list(p=p,
                     p1=p1,
                     txt=txt)
                })
output$p <- renderPlot({react()$p})
output$p1 <- renderPlot({react()$p1})
output$txt <- renderText({react()$txt})
})