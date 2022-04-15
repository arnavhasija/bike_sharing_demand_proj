library(tidyverse)
library(lubridate)
library(caret)
library(MASS)
library(sqldf)
library(ggplot2)


bike.data.training<-read.csv(file.choose(), header=TRUE, sep=",", )
bike.data.prediction <- read.csv(file.choose(), header=TRUE, sep=",", )


bike.data.training$datetime <- ymd_hms(bike.data.training$datetime)


bike.data.training$month <- month(bike.data.training$datetime, label = T)
bike.data.training$hour <- hour(bike.data.training$datetime)
bike.data.training$weekday <- wday(bike.data.training$datetime, label=T)
bike.data.training$day   <- day(bike.data.training$datetime)
str(bike.data.training)
summary(bike.data.training)


bike.data.training$month <- as.factor(bike.data.training$month)
bike.data.training$hour <- as.factor(bike.data.training$hour)
bike.data.training$day <- as.factor(bike.data.training$day)
bike.data.training$weekday <- as.factor(bike.data.training$weekday)


bike.data.prediction$datetime <- ymd_hms(bike.data.prediction$datetime)

bike.data.prediction$month <- month(bike.data.prediction$datetime, label = T)
bike.data.prediction$hour <- hour(bike.data.prediction$datetime)
bike.data.prediction$weekday <- wday(bike.data.prediction$datetime, label=T)
bike.data.prediction$day   <- day(bike.data.prediction$datetime)


bike.data.prediction$month <- as.factor(bike.data.prediction$month)
bike.data.prediction$hour <- as.factor(bike.data.prediction$hour)
bike.data.prediction$weekday <- as.factor(bike.data.prediction$weekday)
bike.data.prediction$day   <- as.factor(bike.data.prediction$day)

bike.data.training$datetime <- NULL
bike.data.prediction$datetime <- NULL

names <- c('season','holiday','workingday','weather')
bike.data.training[,names] <- lapply(bike.data.training[,names], factor)
bike.data.prediction[,names] <- lapply(bike.data.prediction[,names], factor)
str(bike.data.training)
str(bike.data.prediction)


# Dropping columns that are not needed
bike.data.training$casual <- NULL
bike.data.training$registered <- NULL

train <- bike.data.training[,]


############## Creating New Features #######################

bike.data.training$favorable_conditions <- ifelse(bike.data.training$atemp>=0 & bike.data.training$atemp<=30 & bike.data.training$humidity> 30 & bike.data.training$humidity<85 & bike.data.training$windspeed<30 & (bike.data.training$weather==1 | bike.data.training$weather==2), 1, 0 )

bike.data.training$favorable_conditions <- as.factor(bike.data.training$favorable_conditions)


bike.data.prediction$favorable_conditions <- ifelse(bike.data.prediction$atemp>=0 & bike.data.prediction$atemp<=30 & bike.data.prediction$humidity> 30 & bike.data.prediction$humidity<85 & bike.data.prediction$windspeed<30 & (bike.data.prediction$weather==1 | bike.data.prediction$weather==2), 1, 0 )

bike.data.prediction$favorable_conditions <- as.factor(bike.data.prediction$favorable_conditions)

bike.data.prediction$count <- NA

summary(bike.data.training)

############## Visualizations #######################


hist(bike.data.training$count)

hist(log(bike.data.training$count))

hist(bike.data.training$count)
hist(bike.data.training$atemp)


avg_count_per_hour <- sqldf('select weekday, hour, avg(count) as count from train group by weekday, hour')

avg_count_per_day <- sqldf('select day, avg(count) as count from train group by day')

ggplot(avg_count_per_day, aes(x=day, y=count))+
  geom_point(colour="red")+
  ylab("Average Count")+ ggtitle("Average number of bike rentals by day of month")



ggplot(train, aes(x=hour, y=count, color=weekday))+
   geom_line(data = avg_count_per_hour, aes(group = weekday))+
  ggtitle("Number of bike rentals by hour and day of week")+ scale_colour_hue('Weekday',breaks = levels(train$weekday),
                                                     labels=c('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'))




############## Regression Model - First iterations #######################



fit_v1<-lm(count~., data=bike.data.training)

summary(fit_v1)


fit2<-lm(log(count)~., data=bike.data.training)

summary(fit2)


predicted.bike.count <- exp(predict(fit, bike.data.prediction))

write.csv(predicted.bike.count, "submission.csv")




# Move the ID column to be the first column
bike.data.training <- bike.data.training[,c(ncol(bike.data.training),1:(ncol(bike.data.training)-1))]
bike.data.prediction <- bike.data.prediction[,c(ncol(bike.data.prediction),1:(ncol(bike.data.prediction)-1))]


fit2<-lm(log(count)~season+holiday+workingday+weather+hour+month+day+favorable_conditions+atemp+windspeed+humidity, data=bike.data.training)

summary(fit2)
plot(fit2)


predicted.bike.count_v2 <- exp(predict(fit2, bike.data.prediction))

write.csv(predicted.bike.count_v2, "submission.csv")


boxplot(bike.data.training$count)

outliers_boxplot <- boxplot(bike.data.training$count, plot = FALSE)$out

sort(outliers_boxplot)


# Removing outliers from the dataset that were identified based on diagnostic plots and box plot

outliers <- c(9000, 9009, 9010, 9008, 9011, 8334,
              8331, 8332, 8335, 8307, 8333, 8312)
bike.data.training.new <- bike.data.training[-outliers,]



fit2<-lm(log(count)~.-ID, data=bike.data.training_2)

summary(fit2)
predicted.bike.count <- exp(predict(fit2, bike.data.testing))



fit.log.step<-stepAIC(fit,direction="both")


predicted.prices.fit.log.step.i<-exp(predict(fit.log.step, bike.data.testing))
percent.errors.log.step.i <- abs((bike.data.testing$count-predicted.prices.fit.log.step.i)/bike.data.testing$count)*100
mean(percent.errors.log.step.i) 


summary(fit.log.step)



############## Regression Model - Feature Interactions and stepwise regression #######################


fit.log.step<-lm(log(count)~hour*favorable_conditions*season + hour*weekday*weather*temp + atemp + windspeed + humidity, data=bike.data.training.new)

summary(fit.log.step)

fit.log.step.AIC <-stepAIC(fit.log.step,direction="both")


summary(fit.log.step.AIC) 


fit.log.step.2<-lm(log(count)~hour*favorable_conditions*season + hour*weekday*weather + temp + windspeed + humidity, data=bike.data.training.new)

summary(fit.log.step.2)



fit.log.step.3<-lm(log(count)~hour*workingday*season + hour*weekday*weather + hour*temp*favorable_conditions + windspeed + humidity, data=bike.data.training)

summary(fit.log.step.3)

fit.log.step.AIC.3 <-stepAIC(fit.log.step.3,direction="forward")

summary(fit.log.step.AIC.3)


plot(fit.log.step.AIC)

predicted.bike.count_v6 <- exp(predict(fit.log.step.AIC, bike.data.prediction))

write.csv(predicted.bike.count_v6, "submission_v6.csv")

                  
predicted.bike.count_v7 <- exp(predict(fit.log.step.AIC.3, bike.data.prediction))

write.csv(predicted.bike.count_v7, "submission_v7.csv")
# This was the submission made on the Kaggle competition