library(shiny)
library(randomForest)
library(tidyr)
library(dplyr)
library(caTools)
library(ggplot2)
library(ggcorrplot)
library(rsconnect)

# Read the data
boston <- "data/HousingData.csv"
dfBoston <- readr::read_csv(boston)