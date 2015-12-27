library(shiny)

shinyUI(fluidPage(
        titlePanel("Buy, hold and sell"),
        p("Can buy and hold investing strategy be improved by using
stop-loss rules, and buying only when stock is
          above moving average by a certain percent? Chart compare result of this strategy
          to base stock itself (wide market index S&P500 traded as SPY ETF)."),
        sidebarLayout(
                sidebarPanel(
                        h2("Sell signal"),
                        sliderInput('drop.level',
                                 'Drop from last max since buy, %',
                                 min=1, max=30, value = 10),
                        h2("Buy signal"),
                       sliderInput('ema',
                                 'Period for moving average',
                                 min=20, max=365, value = 150),
                       sliderInput('ema.over',
                                   'Buy when price > average + %',
                                   min=-5, max=10, value = 2),
                       h2("Trading conditions"),
                       textInput('fee',
                                 'Broker fee per transaction',
                                 value = '10'),
                       textInput('money',
                                 'Starting capital',
                                 value = '10000'),
                       textInput('start',
                                 'Starting date YYYY-MM-DD',
                                 value = '2006-01-01')
                ),
                mainPanel(
                       textOutput("txt"),
                        plotOutput("p", height=700)
                )
)
)
)