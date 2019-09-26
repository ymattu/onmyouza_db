shinyServer(function(input, output) {
  
  output$dvd <- DT::renderDataTable(df_dvd_songs,
                                    options = dt_options)
  
  output$setlist <- DT::renderDataTable(df_setlists,
                                        options = dt_options)
  
  output$songs <- DT::renderDataTable(df_songs,
                                      options = dt_options)
  
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
