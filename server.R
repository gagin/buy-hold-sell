library(shiny)
library(quantmod)
library(ggplot2)
#require(PerformanceAnalytics)

getSymbols('SPY', from = "1900-01-01")  

shinyServer(function(input, output) {
        
        money <- input$money
        drop.level <- input$drop.level
        drop.since <- input$drop.since
        ema.length <- input$ema
        start.date.string <- input$start
        fee <- input$fee
        # Debug init values
        if(FALSE) {
                money <- 10000
                drop.level <- 2
                drop.since <- 365
                ema.length <- 256
                start.date.string <- '2010-01-01'
                fee <- 10
        }
        
        start.date <- as.Date(start.date.string, "%Y-%m-%d")
        if(is.na(start.date)) return("Wrong date format")
        if(start.date < index(SPY)[1]) return(paste("Start date shouldn't be before",index(SPY)[1]))
 
        work <- SPY[paste0(start.date,"::")]
        
        prev.max <- sapply(index(work), function(x)
                max(last(Cl(SPY[paste0("::",x)]),drop.since)))

        days <- length(index(work))
        
        ema <- EMA(Cl(SPY), n = ema.length, wilder = TRUE)
        ema <- as.vector(last(ema, days))
        
        price <- as.vector(Cl(work))
        bull <- price > ema
        drop.coeff <- 1-drop.level/100

        # Init
        stock <- 0
        last.buy <- 0
        assets <- numeric(days)
        ret <- numeric(days)

        for(i in 1:days) {
                if(money > 0 & bull[i]) {
                        stock <- (money - fee) / price[i]
                        money <- 0
                        last.buy <- price[i]
                }
                bear <- price[i] < (drop.coeff * min(prev.max[i], last.buy))
                if(stock > 0 & bear) {
                        money <- stock * price[i] - fee
                        stock <- 0
                }
                assets[i] <- money + stock * price[i]
        }
        
        p <- qplot(index(work),assets, xlab="Date", ylab="Assets")
        output$p <- renderPlot(p)
})