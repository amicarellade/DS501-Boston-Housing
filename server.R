server <- function(input, output) {
  # Reactive expression to handle missing values
  dfBoston_no_null <- reactive({
    na.aggregate(dfBoston, FUN = median)
  })
  
  output$density_plot <- renderPlot({
    ggplot(dfBoston, aes(x = MEDV)) +
      geom_histogram(aes(y = ..density..), color = "black") +
      geom_density(alpha = .2, fill = "#FF6666") +
      geom_vline(aes(xintercept = mean(MEDV)), color = "blue", linetype = "dashed", size = 1) +
      labs(title = "Density of Median value of home in $1000")
  })
  
  long_df <- reactive({
    gather(dfBoston, key = "variable", value = "value")
  })
  
  output$boxplot <- renderPlot({
    ggplot(long_df(), aes(x = variable, y = value, fill = variable)) +
      geom_boxplot() +
      labs(title = "Box Plot for Each Column")
  })
  
  output$head <- renderPrint({
    head(dfBoston)
  })
  
  output$summary <- renderPrint({
    summary(dfBoston)
  })
  
  output$null <- renderPrint({
    colSums(is.na(dfBoston))
  })
  
  output$feature_checkboxes <- renderUI({
    checkboxGroupInput("feature_checkboxes", "Select Features:",
                       choices = names(dfBoston),  # Features from the dataset
                       selected = names(dfBoston))  # All features selected by default
  })
  
  rf_model <- eventReactive(input$train_button, {
    features <- c(input$features, "MEDV")  # Include target variable
    data_selected <- dfBoston_no_null()[, features]
    train_index <- sample(1:nrow(data_selected), 0.7 * nrow(data_selected))
    train_data <- data_selected[train_index, ]
    test_data <- data_selected[-train_index, ]
    rf <- randomForest(MEDV ~ ., data = train_data)
    list(model = rf, test_data = test_data)
  })
  
  output$model_plot <- renderPlot({
    plot(rf_model()$model)
  })
  
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
    corr <- cor(dfBoston_no_null())  # Ensure reactive value is called correctly
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
  
  output$scatter <- renderPlot({
    ggplot(data = dfBoston, aes(x = scatX(), y = scatY(), color = scatCol())) +
      geom_point() +
      xlab(input$scatterX) + ylab(input$scatterY) +
      labs(colour = input$scatterCol) +
      ggtitle(paste('Scatter plot of', input$scatterX, 'vs', input$scatterY)) +
      theme(plot.title = element_text(hjust = 0.5))
  })
}