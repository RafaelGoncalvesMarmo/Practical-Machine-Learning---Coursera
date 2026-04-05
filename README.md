**1. Objective**

The goal of this analysis was to develop a predictive model capable of classifying exercise execution quality into five categories (A–E) using wearable sensor data. The final model was also used to predict the class labels for 20 unseen test observations.

**2. Data preprocessing**

The dataset consisted of a large number of sensor-derived variables capturing motion from different body locations. To improve model performance and robustness, several preprocessing steps were applied:

Variables with more than 10% missing values were removed to retain only stable and consistently recorded features.
Predictors with zero variance were eliminated, as they do not contribute to discrimination between classes.
Remaining missing values were imputed using median imputation, which is robust to outliers commonly present in sensor data.
Non-informative variables such as identifiers (user_name) and time-related variables (timestamp, window) were removed to prevent potential bias and ensure the model relied only on movement signals.

After preprocessing, the dataset contained 52 predictors used for modeling.

**3. Model selection**

A Random Forest classifier was used for this analysis. This method was chosen because:

It handles high-dimensional data effectively
It captures nonlinear relationships between predictors
It is robust to multicollinearity among sensor variables
It performs well in classification problems with complex interactions

**4. Cross-validation**

Model performance was evaluated using 5-fold cross-validation. The training data were split into five subsets, and each subset was used once as a validation set while the remaining subsets were used for training.

This approach provides a reliable estimate of model performance and reduces the risk of overfitting to a single data partition.

**5. Model performance**

The Random Forest model was trained using different values of the tuning parameter mtry (number of variables randomly sampled at each split).

mtry	Accuracy	Kappa
2	0.9896	0.9868
27	0.9910	0.9887
52	0.9857	0.9819

The optimal model was selected with:

mtry = 27

This model achieved a cross-validated accuracy of approximately: 99.1%

**6. Expected out-of-sample error**

Based on cross-validation results and model stability, the expected out-of-sample error is very low, approximately: < 1%

This indicates strong generalization performance. The high accuracy reflects the strong signal present in the sensor data and the ability of Random Forest to capture complex movement patterns.

**7. Variable importance**

Variable importance analysis identified the most influential predictors in the model:

Top contributors include:

roll_belt (most important)
pitch_forearm
yaw_belt
magnet_dumbbell_z
pitch_belt
roll_forearm

These results suggest that: Movement signals from the belt (core) and forearm play a dominant role in distinguishing exercise quality.

This aligns with the expectation that core stability and arm coordination are key indicators of movement correctness.

**8. Model interpretation**

The model effectively captures relationships across multiple sensor locations, integrating signals from different body parts. The importance of belt and forearm variables indicates that global body coordination, rather than isolated movements, drives classification performance.

**9. Prediction on test data**

The final model was applied to the 20 unlabeled test observations. Predictions were generated using the trained Random Forest model and are shown below:

problem_id	user_name	prediction
1	pedro	B
2	jeremy	A
3	jeremy	B
4	adelmo	A
5	eurico	A
6	jeremy	E
7	jeremy	D
8	jeremy	B
9	carlitos	A
10	charles	A
11	carlitos	B
12	jeremy	C
13	eurico	B
14	jeremy	A
15	jeremy	E
16	eurico	E
17	pedro	A
18	carlitos	B
19	pedro	B
20	eurico	B
10. Conclusion

The Random Forest model demonstrated excellent performance in classifying exercise quality, with very high accuracy and strong generalization capability. The preprocessing strategy ensured that only reliable and informative variables were used, while cross-validation provided a robust estimate of model performance.

The results highlight the importance of coordinated sensor signals, particularly from the belt and forearm, in distinguishing movement patterns. The model was successfully applied to unseen data, producing consistent and interpretable predictions.
