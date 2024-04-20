#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(randomForest)

# Define UI for application that draws a histogram
fluidPage(
  titlePanel( h1("Boston Housing Price Prediction",  align = "center"),),
  sidebarPanel(
    strong('Scatter Plot Parameters (Exploration Page)'), p(''),
    selectInput('scatterX', 'Select x Axis for Scatter Plot', 
                names(dfBoston), selected = 'CRIM'),
    selectInput('scatterY', 'Select y Axis for Scatter Plot', 
                names(dfBoston), selected = 'MEDV'),
    selectInput('scatterCol', 'Select Color for Scatter Plot', 
                names(dfBoston), selected = 'AGE'),
    h3("Random Forest Regression Model"),
    checkboxGroupInput("features", "Select Features:",
                       choices = c("CRIM", "ZN", "INDUS", "CHAS", "NOX", 
                                   "RM", "AGE", "DIS", "RAD", "TAX", "PTRATIO", "B", "LSTAT"),
                       selected = c("INDUS", "CHAS", "NOX", "RM", "AGE", "DIS", "RAD", "TAX", "PTRATIO", "LSTAT")
    ),
    actionButton("train_button", "Train Model")
  ),
  mainPanel(
    p('This project explores the Boston dataset, which contains information collected by the 
        U.S Census Service concerning housing in the area of Boston Mass. The data was 
        originally published by Harrison, D. and Rubinfeld, 1978.'),
    p(''),
    p('This app allows the exploration of the following:'),
    p('(1) Explore the context of the project.'),
    p('(2) Analyze the data preparation of the project.'),
    p('(3) Understand the mathemical/statistical background of the project.'),
    p('(4) Demonstrate the model.'),
    tabsetPanel(
      tabPanel("Project Overview",
               h5("As a soon to be graduate from Worcester Polytechnic Institute, I am actively
                 looking for positions in Boston, Massachusetts. While the median age of Boston is 
                 rather young compared to most major cities, the housing market is still
                 very competitive and expensive. By using the Boston Housing
                 dataset I wanted to extract insights from the housing market that are not previously
                 known to rent/buy a home that is in my best pricing interest."),
               h5("In this project, I extract and manipulate the data in order to create regression model
                  to predict the MEDV - Median value of owner-occupied homes in $1000's.")
               ),
      tabPanel("Exploration",
               h2("Step 1: Data Understanding"),
               p("Before diving into building a model, I first needed to understand what type of data
                 I was working with and how it can be manipulated."),
               p(""),
               verbatimTextOutput("head"),
               verbatimTextOutput("summary"),
               p("According to dataset notes, the columns represent the following: "),
               p("CRIM - per capita crime rate by town"),
               p("ZN - proportion of residential land zoned for lots over 25,000 sq.ft"),
               p("INDUS - proportion of non-retail business acres per town."),
               p("CHAS - Charles River dummy variable (1 if tract bounds river; 0 otherwise)"),
               p("NOX - nitric oxides concentration (parts per 10 million)"),
               p("RM - average number of rooms per dwelling"),
               p("AGE - proportion of owner-occupied units built prior to 1940"),
               p("DIS - weighted distances to five Boston employment centres"),
               p("RAD - index of accessibility to radial highways"),
               p("TAX - full-value property-tax rate per 10,000 dollars"),
               p("PTRATIO - pupil-teacher ratio by town"),
               p("B - 1000(Bk - 0.63)^2 where Bk is the proportion of blacks by town"),
               p("LSTAT - % lower status of the population"),
               p("MEDV - Median value of owner-occupied homes in $1000's"),
               plotOutput("scatter"),
               h2("Step 2: Data Preparation"),
               plotOutput("density_plot"),
               plotOutput("corr_plot"),
               plotOutput("boxplot"),
               p("In this boxplot above we can see 3 attributes that have a lot of variance (B, CRIM, ZN).
                 Therefore, I remove these variables from the dataset to not impact the model further on."),
               verbatimTextOutput("null"),
               p("As you can see, the data provided did have null values throughout, so in order to combat this
                 I set all values that are null equal to the median value of the column. I chose median over mean
                 as the median is a better measurement of central tendency for data as it is not skewed by abnormally
                 large or small values.")),
      tabPanel("Math Background",
               h2("Understanding Random Forrest Regression"),
               h3("Ensemble Learning"),
               p("What is ensemble learning? Ensemble learning is a machine learning technique that enhances accuracy in forecasting
                 by merging predictions from multiple models or algorithms. There are three types of ensemble learning: boosting, bagging, and stacking.
                 Ensmeble learnign aims to mitigate errors or bias in the data by leveraging the overall 'intellignece' of the ensemble of the data. Due 
                 to its robustness, ensemble learning is commonly practiced throughout the machine learning world."),
               h3("Bootstrapping"),
               p("Bootsrapping is a resampling technique used to estimate the sampling distribution of a statistic by repeatedly sampling with 
                 replacement from the original dataset. In the context of ML and random forrest, bootstrapping is used to create multiple subsets of the 
                 original training data, each of which is used to train a separate decision tree. For each bootstrap sample, a decision tree is trained 
                 using the CART (Classification and Regression Trees) algorithm. However, at each node of the tree, instead of considering all features 
                 for splitting, a random subset of features (typically sqrt(p), where p is the total number of features) is considered. This introduces 
                 additional randomness and diversity into the trees. The probability of an observation being selected in each bootstrap sample is approximately 1 - (1/n) with n
                 being the observations. This process is repeated multiple times to create multiple bootstrap samples."),
               h3("Decision Tree"),
               p("'A decision tree is a non-parametric supervised learning algorithm, which is utilized for [regression] tasks' (IBM, 2024).
                 A decision tree is a hierarchical structure starting with a root node which has no parent branches and has branches feeding into the child nodes, also known
                 as decision nodes. Each node represent a decision based on a feature in the dataset, and each leaf node represent the output (numerical value
                 in our case since we are using regression). At each internal node of the tree, the algorithm selects the best feature to split the dataset. The process
                 of splitting the tree based on the best feature is called mean squared regression. The splitting process continues recursively for each subset
                 until one of the stopping critera is met, such as reaching a maximum tree depth or having a minimum number of samples in a node. In the end,
                 the predicted output for the instance is the mean value of the training instances in the leaf node."),
               h3("Mean Squared Error (MSE)"),
               p("MSE measures the average squared difference between the actual values and the predicted values obtained from a regression model. 
                 Features that result in lower MSE values are considered more informative or predictive. Oftentime, the combination of multiple features
                 may result in a lower MSE than using a standalone feature. To prevent a model such as random forrest from overfitting, regularization
                 techniques can be used to penalize the model for using additional features. MSE is calculated as: https://en.wikipedia.org/wiki/Mean_squared_error. 
                 "),
               h3("Random Forrest Regression"),
               p("Random Forest regression begins by creating multiple bootstrap samples from the original dataset. Each bootstrap sample is created by 
               randomly selecting observations from the original dataset with replacement. This results in multiple subsets of the original data, each of 
                 which is used to train a separate decision tree. For each bootstrap sample, a decision tree is grown using the CART algorithm. However, 
                 at each node of the tree, instead of considering all features for splitting, a random subset of features is considered. This introduces 
                 additional randomness and diversity into the trees. Each decision tree is trained independently and does not have access to the entire dataset.
                 During training, each decision tree is optimized to minimize the mean squared error (MSE) of the predictions on its training data. 
                 The MSE measures the average squared difference between the actual target values and the predicted values.
                  Once all decision trees are trained, predictions are made for each observation in the original dataset using each individual tree. 
                 For regression tasks, the final prediction is typically the average of the predictions from all trees (ensemble averaging). 
                 By aggregating the predictions from multiple trees, Random Forest regression reduces the variance of the predictions and improves the overall model performance.
                  Once all decision trees are trained, predictions are made for each observation in the original dataset using each individual tree. For regression tasks, 
                 the final prediction is typically the average of the predictions from all trees (ensemble averaging). By aggregating the predictions from multiple trees, 
                 Random Forest regression reduces the variance of the predictions and improves the overall model performance.")),
      tabPanel("Model",
               h2("Random Forest Model Evaluation"),
               h5("To test the model, select the features you want to use in the sidepar panel and hit the 'Train Model'
               button. Feel free to try with different features!"),
               h5("Below you will see two outputs. The first output is the a graph representing the random forrest regression quantity
                 of tree's versus the percent error. The text output is a series of 3 error measurements for the feature-set that you chose
                 for the model. These error values are pulled when trees = 500"),
               plotOutput("model_plot"),
               verbatimTextOutput("evaluation_metrics")
      )
    )
  )
)
