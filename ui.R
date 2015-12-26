library(shiny)

shinyUI(fluidPage(
        titlePanel("Buy, hold and sell"),
        p("Can buy and hold strategy be improved by using
stop-loss signals after significant drops, and buying only when stock is
          above moving average by a certain percent? Chart compare result of this strategy
          to base stock itself (wide market index S&P500 traded as SPY ETF)."),
        sidebarLayout(
                sidebarPanel(
                        h2("Sell signal"),
                        sliderInput('drop.level',
                                 'Percentage drop from last maximum since buy',
                                 min=1, max=20, value = 10),
                        h2("Buy signal"),
                        sliderInput('cooldown',
                                    'Days to pause since last sell',
                                    min=1,max=30,value = 10),
                        
                       sliderInput('ema',
                                 'Period for moving average',
                                 min=50, max=365, value = 150),
                       sliderInput('over.ema',
                                 'Percentage over EMA to buy',
                                 min=-5, max=10, value = 2),
                       h2("Trading conditions"),
                       textInput('fee',
                                 'Broker fee per transaction',
                                 value = '10'),
                       textInput('money',
                                 'Starting capital',
                                 value = '10000'),
                       textInput('start',
                                 'Starting date',
                                 value = '2006-01-01')
                ),
                mainPanel(
                       textOutput("txt"),
                        plotOutput("p"),
                        plotOutput("p1")
                )
)
)
)