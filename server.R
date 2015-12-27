# Deployment with RRO
# library(checkpoint); checkpoint("2015-12-01"); library(rsconnect); deployApp()
library(shiny)
library(quantmod)
library(ggplot2)
library(gridExtra)
library(grid)

shinyServer(function(input, output) {
        output$p <- renderPlot({
                ### Load stock prices from Yahoo, if haven't yet
                if (!exists("SPY"))
                        getSymbols('SPY', from = "1900-01-01")
                
                ### Initialize inputs
                money <- as.numeric(input$money)
                drop.level <- as.numeric(input$drop.level)
                ema.length <- as.numeric(input$ema)
                ema.over <- as.numeric(input$ema.over)
                start.date.string <- as.character(input$start)
                start.date <- as.Date(start.date.string, "%Y-%m-%d")
                fee <- as.numeric(input$fee)
                
                ### Take working range
                # We model strategy from selected date to the latest moment
                work <- SPY[paste0(start.date,"::")]
                dates <- index(work)
                days <- length(dates)
                years.between <- as.numeric(difftime(dates[days],
                                                     dates[1])) / 365.25
                
                ### Prepare data vectors
                # Wilder's isn't really an exponential average, it's just
                # a smoothing trick for arithmetic average
                ema <- EMA(Cl(SPY), n = ema.length, wilder = TRUE)
                ema <- as.vector(last(ema, days))
                
                price <- as.vector(Cl(work))
                bull <- price > (ema * (1 + ema.over / 100))
                
                ### Init days cycle
                stock <- 0
                last.max <- price[1]
                assets <- numeric(days)
                state <- factor(levels = c("money","stock"))
                ret <- numeric(days)
                
                ### Run days cycle
                for (i in 1:days) {
                        last.max <- max(last.max, price[i])
                        if (money > 0 & bull[i]) {
                                stock <- (money - fee) / price[i]
                                money <- 0
                                last.max <- price[i]
                        }
                        if (stock > 0 & price[i] <
                            (last.max * (1 - drop.level / 100))) {
                                money <- stock * price[i] - fee
                                stock <- 0
                        }
                        assets[i] <- money + stock * price[i]
                        state[i] <-
                                ifelse(money > 0, "money", "stock")
                }
                
                ### Chart results
                DF1 <- data.frame(dates = index(work),
                                  assets = assets,
                                  state = state)
                asset.ratio <- assets[days] / assets[1]
                p1 <-
                        ggplot(aes(dates, assets, color = state), data = DF1) +
                        guides(color = guide_legend(title = "Position")) +
                        geom_point() +
                        xlab("Date") +
                        ylab("Equity") +
                        ggtitle(paste0(
                                "Strategy result ",
                                round((asset.ratio - 1) * 100),
                                "% (annual return ",
                                round((
                                        asset.ratio ^ (1 / years.between) - 1
                                ) * 100,1),
                                "%)"
                        ))
                
                DF2 <- data.frame(date = index(work),
                                  SPY = price,
                                  bull = bull)
                price.ratio <- price[days] / price[1]
                p2 <-
                        ggplot(aes(date,SPY, color = bull), data = DF2) +
                        guides(color = guide_legend(title = "Buy signal")) +
                        geom_point() +
                        xlab("Date") +
                        ylab("SPY price") +
                        ggtitle(paste0(
                                "Underlying stock: ",
                                round((price.ratio - 1) * 100),
                                "% (annual return ",
                                round((
                                        price.ratio ^
                                                (1 / years.between) - 1
                                ) * 100,1),
                                "%)"
                        )) +
                        geom_line(aes(dates, ema, color = "Average"),
                                  data = data.frame(dates = index(work), ema))
                
                # This next bit is needed to align axes
                # Credits to http://www.exegetic.biz/blog/2015/05/r-recipe-aligning-axes-in-ggplot2/
                p11 <- ggplot_gtable(ggplot_build(p1))
                p21 <- ggplot_gtable(ggplot_build(p2))
                p11$widths[2:3] <- p21$widths[2:3]
                grid.arrange(p11,p21)
        })
})