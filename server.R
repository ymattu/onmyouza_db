shinyServer(function(input, output) {
  
  output$dvd <- DT::renderDataTable(df_dvd_songs,
                                    server = F,
                                    extensions = c('Buttons'), 
                                    options = dt_options_dvd)
  
  output$setlist <- DT::renderDataTable(df_setlists,
                                        server = F,
                                        extensions = c('Buttons'),
                                        options = dt_options_setlist)
  
  output$songs <- DT::renderDataTable(df_songs,
                                      server = F,
                                      extensions = c('Buttons'),
                                      options = dt_options_album)
  
  # leaflet
  values = reactiveValues(geocodes = data.frame(lng = 139.7545, lat = 35.70346))
  
  observeEvent(input$submit, {
    geo1 = geocode(input$search_word1) %>%
      as.data.frame() %>% as.vector()
    
    if(is.na(geo1[1, 1])){
      geo1 = values$geocodes
    }
    
    values$geocodes = geo1
  })
  
  output$leafletplot = renderLeaflet({
    geo1_lng <- values$geocodes[1,1]
    geo1_lat <- values$geocodes[1,2]
    
    map_data <- leaflet() %>% 
      addTiles() %>%
      addMarkers(lng = geo1_lng, lat = geo1_lat,
                 label = input$search_word1)
    return(map_data)
  })
})
