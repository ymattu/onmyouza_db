shinyUI(fluidPage(
  titlePanel("陰陽座DB"),
  tabsetPanel(type = "tabs",
              tabPanel("DVD", DT::dataTableOutput("dvd")),
              tabPanel("Live Setlist", DT::dataTableOutput("setlist")),
              tabPanel("Album Songs", DT::dataTableOutput("songs")),
              tabPanel("Live House",
                       sidebarLayout(
                         sidebarPanel(
                            textInput("search_word1", "ライブハウス", value="東京ドームシティホール"),
                
                            h4("実行に数秒時間がかかります。"),
                            h4("また、Gmap APIがエラーを返す場合があります"),
                            actionButton("submit", "地図を描写")
                        ),
                         leafletOutput("leafletplot", width="100%", height = "900px")
              )))
))
