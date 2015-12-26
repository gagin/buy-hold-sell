library(shiny)

shinyUI(fluidPage(
        titlePanel("Buy, hold and sell"),
        sidebarLayout(
                sidebarPanel(
                        textInput('drop.level',
                                 'Percents to lose since last maximum',
                                 value = '10'),
                       textInput('drop.since',
                                 'Trading days to look for last maximum',
                                 value = '365'),
                       textInput('ema',
                                 'Period for moving average',
                                 value = '365'),
                       textInput('fee',
                                 'Trading fee per transaction',
                                 value = '10'),
                       textInput('money',
                                 'Starting capital',
                                 value = '10000'),
                       textInput('start',
                                 'Starting date',
                                 value = '2010-01-01')
                ),
                mainPanel(
                        plotOutput(p)
                )
)
)
)