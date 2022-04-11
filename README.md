# bike_sharing_demand_proj

In the bike sharing demand competition, hourly bike rental data is given for a period of two years. The training data contains first 19 days of each month and the test data is from day 20 onwards to the month end. The objective is to predict number of bikes for each hour in the test dataset after creating a model using the training data. The bike sharing demand dataset can be found on Kaggle at this link: https://www.kaggle.com/c/bike-sharing-demand/overview

<b>Why I selected this Kaggle competition?</b>

Being an avid biker myself, I wanted to explore factors that may impact the rentals in large cities such as Washington, D.C. Living within proximity to Toronto I can relate to how bike sharing systems such as Bike Share Toronto can be a very useful option for commuting short distances to work.

Another reason I chose the bike sharing demand competition over other options is because I thought there are some interesting insights that can be drawn from this dataset. For instance, weather conditions such as clear, cloudy, or rainy day along with feels like temperature, relative humidity, and windspeed are all factors that influence the number of bikes rented on a given day or hour. This meant that new features to capture favorable conditions for biking could be created to capture how the weather conditions would jointly affect the rentals. Even though this would be considered time series data, the datetime feature can be decomposed into separate features such as day, time, hour, and a log-linear model can be used to make predictions.


<b>Exploratory Data Analysis(EDA)</b>
- I built a log linear regression model to predict the number of bike rentals. The first step was to understand the structure of the data and look at the summary statistics of the features.
- The features in the data include datetime, season, holiday, working day, weather, temperature/air temperature, humidity, and windspeed. The goal is to predict the count variable which represents the number of total bike rentals including casual and registered. I decided to remove redundant features such as casual and registered which both add up to give the count of bikes rented from the dataset.
- Next, I extracted all the key components from the datetime field using the lubridate functions. These included month, hour, weekday, and day. These features along with season, holiday, working day, and weather were converted to factor data types to be used in the model. I aggregated the count to find the average count. Then I created visualization to assess how the demand of bikes tends to vary based on these features. The visualizations I created are shown below.
