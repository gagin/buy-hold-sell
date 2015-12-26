library(shiny)

shinyUI(fluidPage(
        titlePanel("Buy, hold and sell"),
        sidebarLayout(
                sidebarPanel(
                        sliderInput('drop.level',
                                 'Percents to lose since last maximum',
                                 min=1, max=20, value = 10),
                        textInput('cooldown',
                                    'Trading days to pause since last sell',
                                    value = '10'),
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
                       textOutput("txt"),
                                
                        plotOutput("p"),
                        plotOutput("p1")
                )
)
)
)