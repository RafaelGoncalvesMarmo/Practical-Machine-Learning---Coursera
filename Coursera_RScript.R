rm(list = ls())

# =========================
# Libraries
# =========================
library(caret)
library(tidyverse)

# =========================
# Load data
# =========================
train_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
test_url  <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

train <- read.csv(train_url, na.strings = c("NA", "", "#DIV/0!"))
test  <- read.csv(test_url,  na.strings = c("NA", "", "#DIV/0!"))

# check
dim(train)
dim(test)
str(train)

# =========================
# Cleaning: NA + Zero Variance
# =========================
na_threshold <- 0.10

train_clean <- train %>%
  select(where(~ mean(is.na(.)) <= na_threshold))

nzv <- nearZeroVar(train_clean, saveMetrics = TRUE)

train_clean <- train_clean %>%
  select(-which(nzv$zeroVar))

# check
dim(train_clean)

# =========================
# Imputation
# =========================
preproc <- preProcess(train_clean, method = "medianImpute")

train_clean <- predict(preproc, train_clean)

# Apply same to test
predictor_names <- setdiff(colnames(train_clean), "classe")
test_clean <- test[, predictor_names]
test_clean <- predict(preproc, test_clean)

# =========================
# Basic checks
# =========================
table(train_clean$classe)

# remove first column
train_clean <- train_clean[, -1]
test_clean  <- test_clean[, -1]

# =========================
# Remove unwanted columns
# =========================
remove_cols_train <- grepl("^X|timestamp|window", names(train_clean))
train_clean <- train_clean[, !remove_cols_train]

remove_cols_test <- grepl("^X|timestamp|window", names(test_clean))
test_clean <- test_clean[, !remove_cols_test]

# =========================
# Align predictors
# =========================
predictors <- setdiff(names(train_clean), "classe")
test_clean <- test_clean[, predictors]

# check
all(names(test_clean) == predictors)

# =========================
# Remove user_name
# =========================
str(train_clean)

train_clean <- train_clean[, !names(train_clean) %in% "user_name"]
test_clean  <- test_clean[, !names(test_clean) %in% "user_name"]

# =========================
# Train/Test split
# =========================
set.seed(123)

inTrain <- createDataPartition(train_clean$classe, p = 0.70, list = FALSE)

trainData <- train_clean[inTrain, ]
testData  <- train_clean[-inTrain, ]

# =========================
# Training control
# =========================
control <- trainControl(method = "cv", number = 5)

# =========================
# Models
# =========================

# Random Forest
modelRf <- train(
  classe ~ .,
  data = trainData,
  method = "rf",
  trControl = control
)

modelRf


# =========================
# Predictions
# =========================

predictRf <- predict(modelRf, newdata = testData)
confusionMatrix(table(predictRf, testData$classe))

modelRf$finalModel

varImp(modelRf)

ggpairs()

pca <- prcomp(select(train_clean, -classe), scale = TRUE)

pc_df <- data.frame(
  PC1 = pca$x[,1],
  PC2 = pca$x[,2],
  classe = train_clean$classe
)

ggplot(pc_df, aes(PC1, PC2, color = classe)) +
  geom_point(alpha = 0.6) +
  theme_minimal()


# =========================
# Validation
# =========================

validation <- predict(modelRf, test_clean)

validation_df <- data.frame(
  user_name = test$user_name,
  prediction = validation
)

head(validation_df)
length(validation) == nrow(test)

errors <- testData %>%
  mutate(
    pred = predictRf,
    correct = pred == classe
  ) %>%
  filter(!correct)

table(errors$classe, errors$pred)
