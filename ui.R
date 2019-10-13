shinyUI(fluidPage(
  titlePanel("陰陽座データベース"),
  tabsetPanel(type = "tabs",
              tabPanel("DVD", DT::dataTableOutput("dvd")),
              tabPanel("Live Setlist", DT::dataTableOutput("setlist")),
              tabPanel("Album Songs", DT::dataTableOutput("songs"))#,
              # tabPanel("Live House",
              #          sidebarLayout(
              #            sidebarPanel(
              #               textInput("search_word1", "ライブハウス", value="東京ドームシティホール"),
              #               actionButton("submit", "地図を描写")
              #           ),
              #            leafletOutput("leafletplot", width="100%", height = "900px")
              # ))
              )
))
