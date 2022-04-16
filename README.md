# bike_sharing_demand_proj

In the bike sharing demand competition, hourly bike rental data is given for a period of two years. The training data contains first 19 days of each month and the test data is from day 20 onwards to the month end. The objective is to predict number of bikes for each hour in the test dataset after creating a model using the training data. The bike sharing demand dataset can be found on Kaggle at this link: https://www.kaggle.com/c/bike-sharing-demand/overview

<b>Why I selected this Kaggle competition?</b>

Being an avid biker myself, I wanted to explore factors that may impact the rentals in large cities such as Washington, D.C. Living within proximity to Toronto I can relate to how bike sharing systems such as Bike Share Toronto can be a very useful option for commuting short distances to work.

Another reason I chose the bike sharing demand competition over other options is because I thought there are some interesting insights that can be drawn from this dataset. For instance, weather conditions such as clear, cloudy, or rainy day along with feels like temperature, relative humidity, and windspeed are all factors that influence the number of bikes rented on a given day or hour. This meant that new features to capture favorable conditions for biking could be created to capture how the weather conditions would jointly affect the rentals. Even though this would be considered time series data, the datetime feature can be decomposed into separate features such as day, time, hour, and a log-linear model can be used to make predictions.


<b>Exploratory Data Analysis(EDA)</b>
I built a log linear regression model to predict the number of bike rentals. The first step was to understand the structure of the data and look at the summary statistics of the features.

The features in the data include datetime, season, holiday, working day, weather, temperature/air temperature, humidity, and windspeed. The goal is to predict the count variable which represents the number of total bike rentals including casual and registered. I decided to remove redundant features such as casual and registered which both add up to give the count of bikes rented from the dataset.

Next, I extracted all the key components from the datetime field using the lubridate functions. These included month, hour, weekday, and day. These features along with season, holiday, working day, and weather were converted to factor data types to be used in the model. I aggregated the count to find the average count. Then I created visualization to assess how the demand of bikes tends to vary based on these features. The visualizations I created are shown below.

![](/images/avg_num_of_rentals_by_month.JPG)

![](/images/num_bike_rentals_by_day_of_week.JPG)

The graph shows that there is a peak in the bike rentals in the morning and evening hours around 8 AM and 5 PM through Monday to Friday which is expected. On the weekends however the rentals peak during the middle of the day between 12 PM to 4 PM.

I also looked at distribution of all the features along with the count. While the distribution of features seemed to have no issues, the count of bikes seemed to be skewed to the right. To resolve this issue, I decided to apply a log transformation to the count. The histograms of the count distribution are shown on the next page before and after applying the log transformation.

![](/images/bike_data_training_histogram.JPG)

![](/images/bike_data_log_transform_training_histogram.JPG)


I created a boxplot to check for outliers for the count variable. There appear to be many outliers on the higher end of the spectrum that can impact model performance. For the first few model iterations I decided to keep them and then later drop some of them to determine how if the model performance improves.

![](/images/boxplot.JPG)


<b> Feature Engineering </b>

I created a new variable in the train and test data called favorable conditions to capture the conditions that will be ideal for biking. First, an air temperature within the range of 0 and 30 degree Celsius would be considered reasonable for biking. In the dataset there are some days with extreme cold or hot temperatures which would be coded with a 0 to signify that the conditions are not favorable. In terms of the humidity, I chose a broad range of 30% to 85% since anything outside this range can be considered too low or high humidity for biking.

In addition, any wind speed less than 30 mph would also be ideal for biking as anything above this would be a strong breeze or gale which can make biking difficult. Lastly, for weather a value of 1 indicates clear (few clouds) and 2 indicates some mist (cloudy) while 3 and 4 indicate conditions with snow/rain. Thus, I included 1 or 2 in the favorable conditions feature to capture the weather conditions suitable for biking as well.

<b> Model Training and Selection </b>

First model I developed included all the predictors given in the training dataset.

This resulted in a relatively low adjusted R2 of 0.6368 even though the overall F-test showed strong predictive power of the model. One interesting observation here was that based on individual t-tests for all predictors, all hours seemed to have very low p-values indicating that hour has high significance in affecting the count of bikes rented. To improve performance of the model, I investigated the training data for any missing values, outliers, and skewness.

For skewness, I created visualizations such as histogram for count which shows that it is skewed to the right. To resolve this issue a log transformation was applied to it which can make its distribution more normal. For the predictor variables such as air temperature, windspeed, and humidity the skewness did not seem to be an issue. Therefore, I decided to create a log-linear model to predict the count of the bikes rented. This resulted in a much-improved R2 of 0.8024.

I created interactions for the variables including hour, favorable conditions, and season since these features all seem to have high importance and significance in affecting the bike rentals. Another interaction was created using weekday, weather, hour, and temperature since all these variables jointly can impact the number of rentals. To these interactions, additional features such as air temperature, windspeed, and humidity were added.

To assess the outliers in conjunction with other features in the datasets I looked at the diagnostic plots such as the Cook’s distance plot and decided to drop some outliers from the test dataset which significantly improved the model predictions. For this model I used a stepwise regression, using the AIC approach. The diagnostic plots obtained from the analysis are shown below.

![](/images/residuals_vs_fitted.JPG)

![](/images/normal_Q-Q_plot.JPG)

![](/images/cooks_distance_plot.JPG)

<b> Regression Model Results </b>

Normal Q-Q: There appear to be no issues related to the normality of the error term as the plot shows a relatively close distribution to the diagonal line.
Residuals vs Fitted values: There are no patterns that are noticeable (such as cone shaped, parabola, or clusters) which means heteroscedasticity does not seem to be an issue. Thus, there appears to be equal variance in error terms.
Cook's Distance Plot: Since some outliers were removed from the test data, there appear to be no outliers or observations with high leverage outside the Cook's distance line that may be impacting the final model.

![](/images/final_model_results.JPG)

The adjusted R-squared in the final model was much better compared to the previous models. This means that a much greater proportion of variation in the number of bike rentals can be explained by the predictors in the model. The residual standard error of 0.4223 can further be improved. To get better results, regularization techniques such as Lasso/Ridge can also be applied to deal with issues such as overfitting which may be impacting the model performance.

