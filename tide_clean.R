#------------------------------------#
#       Time Series Project          #
#     Code for cleaning tide data    #
#------------------------------------#
# Needed Libraries for Analysis #
#install.packages('imputeTS')
library(xts)
library(imputeTS)


# load data according to your file address
G_561_tide <- read.csv("/Users/jagadeesh/Downloads/MSA_Fall_2/Time Series II/Project/station_8722956.csv", header=TRUE)

# This combines date * time and fixes formatting, adjusting for daylight savings time
G_561_tide$Time = as.POSIXct(G_561_tide$Time,format="%H:%M")
G_561_tide$Time = substr(G_561_tide$Time,12,19)
G_561_tide$DateTime = as.POSIXct(paste(G_561_tide$Date, G_561_tide$Time), format="%Y-%m-%d %H:%M:%S")

# This aggregates dataframe into hourly observations (values are averaged)
data.xts <- xts(G_561_tide$Prediction, 
                as.POSIXct(G_561_tide$DateTime))  
Means.xts <- period.apply(data.xts, INDEX=endpoints(data.xts, "hours"), FUN=mean)


# Begins cleaning data.frame
Cleaned_tide <- data.frame(Means.xts)
Cleaned_tide <- cbind(DateTime = rownames(Cleaned_tide), Cleaned_tide)
rownames(Cleaned_tide) <- 1:nrow(Cleaned_tide)

# # Strips minutes from timeframes (the results are hourly, otherwise the combined hours end in :45)
Cleaned_tide$DateTime = as.POSIXct(Cleaned_tide$DateTime, format="%Y-%m-%d %H")

# Creates final, clean data.frame
tide = data.frame(DateTime=Cleaned_tide$DateTime,Prediction=Cleaned_tide$Means.xts)

#subset data for observations in well
tide = tide[ (tide$DateTime > as.Date("2007-10-05")), ]
tide= tide[ (tide$DateTime < as.Date("2018-06-13")), ]

#create time sequence df
time_sequence <- data.frame(seq(ymd_hm('2007-10-05 00:00'),ymd_hm('2018-06-12 23:00'), by = '60 mins'))

#changing column name so that we can merge on date_time
colnames(time_sequence) <- 'DateTime'

#merging time sequence and Well data to identify missing values
tide_data <- time_sequence %>%
  left_join(tide, by="DateTime")

#df of missing values
tide_miss <- tide_data[!complete.cases(tide_data),]


##Creates Time Series Object (start: c(first year in series, hours from begining of 2007 at first obs) freq:24*365 = hours per year)
tide_series <- ts(tide_data$Prediction, start = c(2007,10))

#imputing missing values using imputeTS package by using mean method.
tide_series <- na.mean(tide_series)

##############################################################################################
