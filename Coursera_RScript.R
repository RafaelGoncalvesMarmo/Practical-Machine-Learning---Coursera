rm(list = ls())

library(caret)
library(tidyverse)
library(ranger)
library(glmnet)
library(xgboost)
library(caretEnsemble)
library(nnet)

train_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
test_url  <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

train <- read.csv(train_url, na.strings = c("NA", "", "#DIV/0!"))
test  <- read.csv(test_url,  na.strings = c("NA", "", "#DIV/0!"))

dim(train)
dim(test)

na_threshold <- 0.10

train_clean <- train %>%
  select(where(~ mean(is.na(.)) <= na_threshold))

nzv <- nearZeroVar(train_clean, saveMetrics = TRUE)

train_clean <- train_clean %>%
  select(-which(nzv$zeroVar))

predictor_names <- setdiff(colnames(train_clean), "classe")
test_clean <- test[, predictor_names]

train_clean <- train_clean[, -1]
test_clean  <- test_clean[, -1]

remove_cols_train <- grepl("^X|timestamp|window", names(train_clean))
train_clean <- train_clean[, !remove_cols_train]

remove_cols_test <- grepl("^X|timestamp|window", names(test_clean))
test_clean <- test_clean[, !remove_cols_test]

train_clean <- train_clean[, !names(train_clean) %in% "user_name"]
test_clean  <- test_clean[, !names(test_clean) %in% "user_name"]

predictors <- setdiff(names(train_clean), "classe")
test_clean <- test_clean[, predictors]

pp <- preProcess(
  train_clean[, predictors],
  method = c("medianImpute", "center", "scale")
)

train_x <- predict(pp, train_clean[, predictors])
test_x  <- predict(pp, test_clean)

train_clean <- cbind(train_x, classe = train_clean$classe)
train_clean$classe <- factor(train_clean$classe)

set.seed(123)
inTrain <- createDataPartition(train_clean$classe, p = 0.70, list = FALSE)

trainData <- train_clean[inTrain, ]
testData  <- train_clean[-inTrain, ]

ctrl <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 2,
  savePredictions = "final",
  classProbs = TRUE
)

set.seed(123)
model_list <- caretList(
  classe ~ .,
  data = trainData,
  trControl = ctrl,
  metric = "Accuracy",
  tuneList = list(
    ranger = caretModelSpec(
      method = "ranger",
      tuneLength = 5,
      importance = "impurity"
    ),
    glmnet = caretModelSpec(
      method = "glmnet",
      tuneLength = 10
    ),
    xgbTree = caretModelSpec(
      method = "xgbTree",
      tuneGrid = expand.grid(
        nrounds = c(100, 200),
        max_depth = c(3, 6),
        eta = c(0.05, 0.3),
        gamma = 0,
        colsample_bytree = c(0.8, 1.0),
        min_child_weight = 1,
        subsample = c(0.8, 1.0)
      )
    )
  )
)

model_list

stack_ctrl <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 2,
  savePredictions = "final",
  classProbs = TRUE
)

set.seed(123)
stack_model <- caretStack(
  model_list,
  method = "multinom",
  metric = "Accuracy",
  trControl = stack_ctrl,
  trace = FALSE
)

stack_model

pred_ranger <- predict(model_list$ranger, newdata = testData)
pred_glmnet <- predict(model_list$glmnet, newdata = testData)
pred_xgb    <- predict(model_list$xgbTree, newdata = testData)
pred_stack  <- predict(stack_model, newdata = testData)

pred_ranger <- factor(pred_ranger, levels = levels(testData$classe))
pred_glmnet <- factor(pred_glmnet, levels = levels(testData$classe))
pred_xgb    <- factor(pred_xgb,    levels = levels(testData$classe))
pred_stack  <- factor(pred_stack,  levels = levels(testData$classe))

cm_ranger <- confusionMatrix(pred_ranger, testData$classe)
cm_glmnet <- confusionMatrix(pred_glmnet, testData$classe)
cm_xgb    <- confusionMatrix(pred_xgb, testData$classe)
cm_stack  <- confusionMatrix(pred_stack, testData$classe)

cm_ranger
cm_glmnet
cm_xgb
cm_stack

acc_df <- data.frame(
  Model = c("ranger", "glmnet", "xgbTree", "stack"),
  Accuracy = c(
    cm_ranger$overall["Accuracy"],
    cm_glmnet$overall["Accuracy"],
    cm_xgb$overall["Accuracy"],
    cm_stack$overall["Accuracy"]
  )
)

acc_df <- acc_df %>%
  arrange(desc(Accuracy))

acc_df

best_model_name <- acc_df$Model[1]
best_model_name

best_model <- switch(
  best_model_name,
  ranger = model_list$ranger,
  glmnet = model_list$glmnet,
  xgbTree = model_list$xgbTree,
  stack = stack_model
)

validation <- predict(best_model, newdata = test_x)

validation_df <- data.frame(
  problem_id = test$problem_id,
  user_name = test$user_name,
  prediction = validation
)

validation_df
