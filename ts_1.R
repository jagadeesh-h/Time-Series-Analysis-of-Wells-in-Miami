#------------------------------------#
#         Time Series Project        #
#------------------------------------#

# Needed Libraries for Analysis #
library(readxl)
library(xts)
library(dplyr)
library(imputeTS)
library(forecast)
library(tseries)
library(readxl)
library(expsmooth)
library(lmtest)
library(lubridate)
library(imputeTS)
library(haven)
library(ggplot2)

# load data according to your file address
G_561_Well <- read_excel("/Users/jagadeesh/Downloads/MSA_Fall_2/Time Series II/Project/G-561_T.xlsx", sheet = "Well")

# This combines date * time and fixes formatting, adjusting for daylight savings time
G_561_Well$NewTime = substr(G_561_Well$time,12,19)
G_561_Well$DateTime = as.POSIXct(paste(G_561_Well$date, G_561_Well$NewTime), format="%Y-%m-%d %H:%M:%S")
G_561_Well$TimeFix = with(G_561_Well, ifelse(G_561_Well$tz_cd == "EDT", -3600,0))
G_561_Well$FinalTime = G_561_Well$DateTime + G_561_Well$TimeFix

# This aggregates dataframe into hourly observations (values are averaged)
data.xts <- xts(G_561_Well$Corrected, 
                as.POSIXct(G_561_Well$FinalTime))  
Means.xts <- period.apply(data.xts, INDEX=endpoints(data.xts, "hours"), FUN=mean)

# Begins cleaning data.frame
CleanedWell <- data.frame(Means.xts)
CleanedWell <- cbind(DateTime = rownames(CleanedWell), CleanedWell)
rownames(CleanedWell) <- 1:nrow(CleanedWell)

# # Strips minutes from timeframes (the results are hourly, otherwise the combined hours end in :45)
CleanedWell$DateTime = as.POSIXct(CleanedWell$DateTime, format="%Y-%m-%d %H")

# Creates final, clean data.frame
Welldata = data.frame(DateTime=CleanedWell$DateTime,Corrected=CleanedWell$Means.xts)

#create time sequence df
time_sequence <- data.frame(seq(ymd_hm('2007-10-04 23:00'),ymd_hm('2018-06-12 22:00'), by = '60 mins'))

#changing column name so that we can merge on date_time
colnames(time_sequence) <- 'DateTime'

#merging time sequence and Well data to identify missing values
Welldata <- time_sequence %>%
  left_join(Welldata, by="DateTime")

#df of missing values
well_mis <- Welldata[!complete.cases(Welldata),]

##Creates Time Series Object (start: c(first year in series, hours from begining of 2007 at first obs) freq:24*365 = hours per year)
Well_Series <- ts(Welldata$Corrected, start = c(2007,10))

#imputing missing values using imputeTS package by using mean method.
Well_Series <- na.mean(Well_Series)

# Time Series Decomposition
decomp_well <- stl(Well_Series, s.window = 7, na.action = na.approx) #sliding window is 7.

# Weekly plot
# doesnt seem to be weekly seasonality based on this plot
plot (Well_Series [93000:93696])

# This means that to determine the value for a season, it averages the values of three before and three after to get the value for that season
plot(decomp_well)


# Subsetting Time Series into Training  & Hold out
# training data is hours in last 3 years minues the last week
Well_Train=na.mean(ts(Welldata$Corrected[67398:(nrow(Welldata)-168)]))
subset(Well_Train[])
Well_Holdout=subset(Well_Series,start=length(Well_Series)-167)

View(Well_Train)

# Note: it is easier to do differences in ARIMA rather than doing them beforehand
#ACF plot is exponentially decreasing, meaning we have an AR and also maybe a MA term
Acf(Well_Train, lag = 168) # checking lags up to a week
Pacf(Well_Train, lag = 168)

# Through the DF Test (not seasonal), we fail to reject the null hypothesis
# This means that we do not yet have stationarity about the mean and need to take differences
adf.test(Well_Train, alternative = "stationary", k=0) #standard DF test for k=0

ndiffs(Well_Train)

Well.Model <- Arima(Well_Train, order = c(5, 1, 5), method = "ML")
#summary(auto.arima(Well_Train, seasonal = FALSE))
# since we are differencing, does this mean we have a random walk in our trend?
# how do we see zero mean/single mean/trend if we can't see decomp?

summary(Well.Model)

# Note: yes there's some autocorrelation but it's okay since they're within the CI
Acf(Well.Model$residuals, main = "")$acf
Pacf(Well.Model$residuals, main = "")$acf


# Double check that these numbers match # of AR Terms
# start testing at sum of p&q, because you've modeled the previous autocorrelation terms
# In this case, we have 10 total (AR + MA)
White.LB <- rep(NA, 40)
for(i in 10:40){
  White.LB[i] <- Box.test(Well.Model$residuals, lag = i, type = "Ljung", fitdf = 10)$p.value
}

# This is another way to check residuals etc. to see if you've modeled everything you can
checkresiduals(Well.Model)

# Plot the white noise to check it
barplot(White.LB, main = "Ljung-Box Test P-values", ylab = "Probabilities", xlab = "Lags", ylim = c(0, 0.2), col = '#99CCFF')
abline(h = 0.01, lty = "dashed", col = "black")
abline(h = 0.05, lty = "dashed", col = "black")
segments(24,10, 24,0)

# Forecasting the values on our holdout set
Forecasted_Model <- forecast (Well.Model, h=168)
plot(as.numeric(Well_Holdout), ylim=c(1,3))
points(as.numeric(Forecasted_Model$mean), col='red')
lines(as.numeric(Forecasted_Model$lower[,2]), col='orange')
lines(as.numeric(Forecasted_Model$upper[,2]), col='orange')

start2 = nrow(Welldata)-167
end2 = nrow(Welldata)
actual_2 <- Welldata[start2:end2, ]
actual_2$pred = Forecasted_Model$mean

ggplot(actual_2, aes(actual_2$DateTime)) +
  geom_point(aes(y=actual_2$Corrected), colour='blue') +
  geom_point(aes(y=actual_2$pred), colour='orange') + xlab('Time (hourly)')+ylab('Well Depth in Feet') +
  geom_line(aes(y=Forecasted_Model$lower[,2]), colour='red') +
  geom_line(aes(y=Forecasted_Model$upper[,2]), colour='red') +
  ggtitle('Actual VS Forecasted Well Water Values (hourly) for June 6 - June 12 2018')+
  ylim(1,2.75)


## Model Diagnostic Statistics
error=as.numeric(Well_Holdout)-as.numeric(Forecasted_Model$mean)
error
MAE=mean(abs(error))
MAE
MAPE=mean(abs(error)/abs(as.numeric(Well_Holdout)))
MAPE
SMAPE=mean(abs(error)/(abs(as.numeric(Well_Holdout))+abs(as.numeric(Forecasted_Model$mean))))
SMAPE

