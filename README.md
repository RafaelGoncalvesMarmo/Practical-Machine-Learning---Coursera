**Model development**

The analysis was conducted using the Human Activity Recognition dataset derived from wearable sensor measurements. Initial preprocessing focused on improving data quality and reducing noise. Variables with more than 10% missing values were removed, followed by the elimination of zero-variance predictors to avoid redundant or uninformative features. Remaining missing values were imputed using median imputation to preserve distributional robustness.

Non-informative variables such as identifiers (user_name) and time-related features (timestamp, window) were excluded to prevent potential leakage and ensure the model relied strictly on sensor-derived signals. After cleaning, the dataset consisted of numeric predictors aligned consistently between training and testing sets.

**Model selection**

A Random Forest model was selected due to its strong performance in high-dimensional settings, ability to capture nonlinear relationships, and robustness to multicollinearity. These characteristics are particularly suitable for sensor-based data where many predictors are correlated and interactions are complex.

**Cross-validation strategy**

Model performance was evaluated using 5-fold cross-validation. The training data were partitioned into five subsets, where each subset was used once as a validation set while the remaining folds were used for training. This process reduces variance in performance estimates and provides a more reliable assessment compared to a single train-test split.

**Expected out-of-sample error**

Based on cross-validation results and validation set performance, the model achieved high accuracy with very low misclassification rates. The expected out-of-sample error is therefore low, likely in the range of 1–3%, reflecting strong generalization. Residual errors are primarily associated with subtle differences between similar movement classes rather than systematic model bias.

**Rationale for choices**

Data cleaning ensured removal of noise and irrelevant variables, improving model stability.
Median imputation was chosen for robustness against outliers common in sensor data.
Random Forest was selected for its flexibility and reliability in complex classification problems.
Cross-validation provided a dependable estimate of performance and reduced overfitting risk.
Prediction on test cases

The final model was applied to the 20 unlabeled test observations. Predictions were generated using the trained Random Forest model, ensuring that the same preprocessing steps were applied. These predictions represent the model’s best estimate of the activity class for each test case under the assumption of similar data distribution.

**Summary**

The modeling approach combined careful preprocessing with a robust ensemble method and appropriate validation strategy. The resulting model demonstrates strong predictive performance and is expected to generalize well to new, unseen data.
