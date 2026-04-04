**Model building**

I used a preprocessing and dimension-reduction strategy rather than relying on a tree-based ensemble. The analysis began by removing metadata and identifier-type fields such as usernames, timestamps, and windowing variables, since these are not true biomechanical predictors and could introduce noise or leakage. Next, variables with substantial missingness were excluded based on the training set, and only numeric predictors were retained.

To further improve model stability, I removed near-zero variance predictors and filtered highly correlated variables. This reduced redundancy in the sensor measurements and made the predictor space more efficient. The remaining variables were then median-imputed, centered, and scaled. After preprocessing, principal component analysis was used to retain 95% of the total variance while compressing the original predictor set into a smaller number of orthogonal components.

**Modeling strategy**

The final classifier was Linear Discriminant Analysis (LDA) trained on the principal components. This approach differs from common black-box methods because it emphasizes separation among classes in a reduced and standardized feature space. The PCA step helps reduce noise and multicollinearity, while LDA provides a simple and interpretable classification framework.

**Cross-validation**

Model tuning and evaluation were performed using repeated 5-fold cross-validation with 3 repeats. In each repeat, the training data were split into five folds, and each fold was used once as a validation subset while the remaining folds were used for fitting. Repeating this process improves the stability of the performance estimate and reduces dependence on a single partition of the data.

**Expected out-of-sample error**

The expected out-of-sample error is low because the model was developed using a strict train-based preprocessing workflow and evaluated with repeated cross-validation and a held-out validation subset. The final misclassification rate should be consistent with the validation performance, though some errors are expected where movement patterns overlap across classes. In general, this type of dataset tends to produce strong predictive performance because the sensor signals contain substantial structure related to the activity classes.

**Why these choices were made**

This strategy was chosen to produce a more original and statistically structured workflow. Instead of depending entirely on a flexible nonlinear model, the analysis first summarized the dominant movement patterns and then classified observations in that reduced space. Removing unstable and redundant predictors makes the workflow more defensible, while PCA plus LDA provides a different modeling logic that is easier to explain in a report.

**Prediction of the 20 test cases**

The trained model was then applied to the 20 unlabeled test cases using exactly the same preprocessing pipeline derived from the training data. The final predictions were stored in a table linking each problem_id to its predicted class.
