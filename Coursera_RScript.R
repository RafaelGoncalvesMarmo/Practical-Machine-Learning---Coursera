rm(list = ls())

library(caret)
library(tidyverse)
library(randomForest)

train_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
test_url  <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

train <- read.csv(train_url, na.strings = c("NA", "", "#DIV/0!"))
test  <- read.csv(test_url,  na.strings = c("NA", "", "#DIV/0!"))

dim(train)
dim(test)
str(train)

# =====================================================
# Remove columns with many missing values
# =====================================================
na_threshold <- 0.10

train_clean <- train %>%
  select(where(~ mean(is.na(.)) <= na_threshold))

# =====================================================
# Remove zero-variance predictors
# =====================================================
nzv <- nearZeroVar(train_clean, saveMetrics = TRUE)

train_clean <- train_clean %>%
  select(-which(nzv$zeroVar))

dim(train_clean)

# =====================================================
# Apply same structure to test
# =====================================================
predictor_names <- setdiff(names(train_clean), "classe")
test_clean <- test[, predictor_names]

# =====================================================
# Impute missing values
# =====================================================
pp <- preProcess(train_clean, method = "medianImpute")

train_clean <- predict(pp, train_clean)
test_clean  <- predict(pp, test_clean)

# =====================================================
# Remove non-informative columns
# =====================================================
train_clean <- train_clean[, -1]
test_clean  <- test_clean[, -1]

train_clean <- train_clean[, !grepl("^X|timestamp|window", names(train_clean))]
test_clean  <- test_clean[,  !grepl("^X|timestamp|window", names(test_clean))]

train_clean <- train_clean[, !names(train_clean) %in% "user_name"]
test_clean  <- test_clean[,  !names(test_clean) %in% "user_name"]

# =====================================================
# Align predictors
# =====================================================
predictors <- setdiff(names(train_clean), "classe")
test_clean <- test_clean[, predictors]

all(names(test_clean) == predictors)

# =====================================================
# Train/test split
# =====================================================
set.seed(123)

inTrain <- createDataPartition(train_clean$classe, p = 0.70, list = FALSE)

trainData <- train_clean[inTrain, ]
testData  <- train_clean[-inTrain, ]

# =====================================================
# Cross-validation setup
# =====================================================
control <- trainControl(
  method = "cv",
  number = 5
)

# =====================================================
# Train Random Forest
# =====================================================
set.seed(123)

modelRf <- train(
  classe ~ .,
  data = trainData,
  method = "rf",
  trControl = control
)

modelRf

# =====================================================
# Evaluate on held-out data
# =====================================================
predictRf <- predict(modelRf, newdata = testData)
predictRf <- factor(predictRf, levels = levels(testData$classe))

# =====================================================
# Variable importance
# =====================================================
varImp(modelRf)
plot(varImp(modelRf), top = 20)

# =====================================================
# Predict unlabeled test set
# =====================================================
validation <- predict(modelRf, newdata = test_clean)

validation_df <- data.frame(
  problem_id = test$problem_id,
  user_name  = test$user_name,
  prediction = validation
)

validation_df
