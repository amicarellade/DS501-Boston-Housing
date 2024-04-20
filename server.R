library(shiny)
library(randomForest)
library(tidyr)
library(ggplot2)
library(ggcorrplot)
library(rsconnect)

boston <- "HousingData.csv"
dfBoston <- readr::read_csv(boston)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$density_plot <- renderPlot({
    # Your ggplot code
    ggplot(dfBoston, aes(x = MEDV)) +
      geom_histogram(aes(y=..density..), color="black") +
      geom_density(alpha=.2, fill="#FF6666") +
      geom_vline(aes(xintercept=mean(MEDV)), color="blue", linetype="dashed", size=1) +
      labs(title = "Density of Median value of home in $1000")
  })
  
  long_df <- reactive({
    gather(dfBoston, key = "variable", value = "value")
  })
  
  # Render the box plot
  output$boxplot <- renderPlot({
    # Generate the box plot
    ggplot(long_df(), aes(x = variable, y = value, fill = variable)) +
      geom_boxplot() +
      labs(title = "Box Plot for Each Column")
  })
  
  output$head <- renderPrint({head(dfBoston)})
  
  output$summary <- renderPrint({summary(dfBoston)})
  
  output$null <- renderPrint({colSums(is.na(dfBoston))})
  
  output$feature_checkboxes <- renderUI({
    # Create checkboxes for each feature
    checkboxGroupInput("feature_checkboxes", "Select Features:",
                       choices = names(dfBoston),  # Features from the dataset
                       selected = names(dfBoston))  # All features selected by default
  })
  
  # Train the Random Forest model
  rf_model <- eventReactive(input$train_button, {
    features <- c(input$features, "MEDV")  # Include target variable
    data_selected <- dfBoston_no_null[, features]
    train_index <- sample(1:nrow(data_selected), 0.7 * nrow(data_selected))
    train_data <- data_selected[train_index, ]
    test_data <- data_selected[-train_index, ]
    rf <- randomForest(MEDV ~ ., data = train_data)
    list(model = rf, test_data = test_data)
  })
  
  # Output model plot
  output$model_plot <- renderPlot({
    plot(rf_model()$model)
  })
  
  # Output evaluation metrics
  output$evaluation_metrics <- renderPrint({
    predictions <- predict(rf_model()$model, newdata = rf_model()$test_data)
    rmse <- sqrt(mean((predictions - rf_model()$test_data$MEDV)^2))
    mae <- mean(abs(predictions - rf_model()$test_data$MEDV))
    r_squared <- cor(predictions, rf_model()$test_data$MEDV)^2
    
    cat("Random Forest Regression Model Evaluation\n")
    cat("Root Mean Squared Error (RMSE):", rmse, "\n")
    cat("Mean Absolute Error (MAE):", mae, "\n")
    cat("R-squared:", r_squared, "\n")
  })
  
  output$corr_plot <- renderPlot({
    # Calculate correlation matrix
    corr <- cor(dfBoston_no_null)
    
    # Plot correlation matrix using ggcorrplot
    ggcorrplot(corr, hc.order = TRUE,
               outline.col = "white",
               ggtheme = ggplot2::theme_gray,
               colors = c("#6D9EC1", "white", "#E46726"))
  })
  
  scatX <- reactive({
    dfBoston[[input$scatterX]]
  })
  
  scatY <- reactive({
    dfBoston[[input$scatterY]]
  })
  
  scatCol <- reactive({
    dfBoston[[input$scatterCol]]
  })
  
  # Make the Scatter Plot
  output$scatter <- renderPlot({
    ggplot(data = dfBoston, aes(x = scatX(), y = scatY(), color = scatCol())) +
      geom_point() +
      xlab(input$scatterX) + ylab(input$scatterY) +
      labs(colour = input$scatterCol) +
      ggtitle(paste('Scatter plot of', input$scatterX, 'vs', input$scatterY)) +
      theme(plot.title = element_text(hjust = 0.5))
  })
}
