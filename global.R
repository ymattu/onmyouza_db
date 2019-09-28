library(tidyverse)
library(shiny)
library(DT)
library(leaflet)
library(ggmap)

df_dvd_songs <- read_rds('data/df_dvd_songs.rds')
df_setlists <- read_rds('data/df_setlists.rds')
df_songs <- read_rds('data/df_songs.rds')

dt_options <- list(lengthMenu = c(5, 10, 20, 50, 100, 200),
                   pageLength = 200, 
                   scrollY = "500px",
                   scrollCollapse = TRUE)

