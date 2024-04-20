library(ggplot2)
library(tidyr)
library(zoo)
library(ggcorrplot)
library(caTools)
library(caret)
library(dplyr)
library(randomForest)

# Boston Housing Dataset
boston <- "/Users/danteamicarella/Downloads/HousingData.csv"
dfBoston <- readr::read_csv(boston)

head(dfBoston)

summary(dfBoston)

null_values <- colSums(is.na(dfBoston))
null_values
# some table's have NA's therefore we need to place data there or remove

str(dfBoston)
# all columns are doubles

ggplot(dfBoston, aes(x = MEDV)) + geom_histogram(aes(y=..density..), color="black") + 
  geom_density(alpha=.2, fill="#FF6666") + 
  geom_vline(aes(xintercept=mean(MEDV)),color="blue", linetype="dashed", size=1) +
  labs(title = "Density of Median value of home in $1000")

long_df <- gather(dfBoston, key = "variable", value = "value")

ggplot(long_df, aes(x = variable, y = value, fill = variable)) +
  geom_boxplot() +
  labs(title = "Box Plot for Each Column")

#B, CRIM, ZN have problematic outliers
subset_df <- dfBoston[, c("B", "CRIM", "ZN")]

long_df <- gather(subset_df, key = "variable", value = "value")

ggplot(long_df, aes(x = variable, y = value, fill = variable)) +
  geom_boxplot() +
  labs(title = "Box Plot for Columns B, CRIM, and ZN") +
  scale_fill_discrete(name = "Variable")
# Therefore, we are not going to use these columns in the model. 

# Replacing the null values with the median for that column
dfBoston_no_null <- na.aggregate(dfBoston, FUN = median)
null_values <- colSums(is.na(dfBoston_no_null))

corr <- cor(dfBoston_no_null)
ggcorrplot(corr, hc.order = TRUE,
           outline.col = "white",
           ggtheme = ggplot2::theme_gray,
           colors = c("#6D9EC1", "white", "#E46726"))

features <- select(dfBoston_no_null, -MEDV)

# Extract the target variable (MEDV)
target <- dfBoston_no_null$MEDV

# Split the data into training and testing sets (80% train, 20% test)
set.seed(123) # for reproducibility
train_index <- createDataPartition(target, p = 0.7, list = FALSE)
train_data <- features[train_index, ]
train_target <- target[train_index]
test_data <- features[-train_index, ]
test_target <- target[-train_index]

# Train linear regression model
lm_model <- lm(train_target ~ ., data = train_data)

# Make predictions
predictions <- predict(lm_model, newdata = test_data)

# Evaluate the model
rmse <- sqrt(mean((predictions - test_target)^2))
mae <- mean(abs(predictions - test_target))
r_squared <- cor(predictions, test_target)^2

cat("Root Mean Squared Error (RMSE):", rmse, "\n")
cat("Mean Absolute Error (MAE):", mae, "\n")
cat("R-squared:", r_squared, "\n")

rf_model <- randomForest(train_target ~ ., data = train_data)

plot(rf_model)

# saveRDS(rf_model, file = "rf_model.rds")

# Make predictions on the test set
predictions_rf <- predict(rf_model, newdata = test_data)

# Evaluate the model
rmse_rf <- sqrt(mean((predictions_rf - test_target)^2))
mae_rf <- mean(abs(predictions_rf - test_target))
r_squared_rf <- cor(predictions_rf, test_target)^2

# Print evaluation metrics
cat("Random Forest Regression Model Evaluation\n")
cat("Root Mean Squared Error (RMSE):", rmse_rf, "\n")
cat("Mean Absolute Error (MAE):", mae_rf, "\n")
cat("R-squared:", r_squared_rf, "\n")