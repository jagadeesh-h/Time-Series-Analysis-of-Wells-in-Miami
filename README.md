# Time-Series-Analysis-of-Wells-in-Miami

## SUMMARY

This report discusses time series analysis of data provided by the National Science Foundation and U.S Department of Agriculture’s program on Water Sustainability and Climate (WSC). Specifically, this analysis focused on Well G-561, located in Miami. The analysis considered a subset of the data from June 2015 to June 2018 to obtain a more accurate forecast. The result of the analysis was an ARIMA(8, 1, 8) model with 72 (hourly) lags of the rain variable for Well G-561. This model accurately forecasted ninety-five percent of the values during the second week of June 2018, with a mean absolute percent error (MAPE) value of 0.053. 


## BACKGROUND

The analysis performed in this report is part of a larger consulting project for the National Science Foundation and U.S Department of Agriculture’s program on Water Sustainability and Climate (WSC). One of the wells studied in the WSC is Well G-561 and is located near Port Laudania, Miami, Florida. The dataset for Well G-561 contained ten years of information and included corrected water levels, well, rain, and tidal data. The goal of this report is to forecast the water levels of Well G-561. 

## DATA MANAGEMENT

The original data included values for date, time, timezone, well measurement in feet, and the corrected well measurements for approximately 101,500 observations. The data were standardized to account for daylight savings time. The data included the well water levels in feet recorded over 15-minute intervals from October 5th, 2007 at 1:00 AM until June 4th, 2018 at 10:45 PM. Due to inconsistencies in recorded time intervals, it was necessary to standardize these intervals by aggregating to hourly intervals using the mean well depth values within each hour. 
Because the data contained 258 missing values, imputation was done using mean values. The data contained high variance in well water levels between 2007 and 2014. Due to this variance, the data were subset to include only observations after June 2015 in order to improve the quality of forecasted values. A validation dataset was created using the last seven days of values, during the second week of June 2018. This same process was applied to the tide and rain datasets. 


### METHODOLOGY

### Seasonality

From the analysis, the tide variable was determined to be insignificant in predicting well water levels and was not included in the model. No seasonality was found at hourly, daily or weekly levels. Results from the standard Dickey-Fuller Test indicated one non-seasonal difference was needed to account for stochasticity of the mean well water levels. The analysis indicated that after a rain event, well levels were not affected for several hours. To account for this delay, a lag of 72 was taken on the rain variable.
 
![alt text](https://github.com/jagadeesh-h/Time-Series-Analysis-of-Wells-in-Miami/blob/master/img/stl.png "STL")

Figure 1 - STL decomposition plot

### Stationarity in the Mean

Next, we conducted a standard Dickey-Fuller Test to check for stationarity in the mean. From this test, we rejected the null hypothesis of stationarity and found that we had stochasticity around a non-zero mean. We took a difference of one to account for this stochasticity.

### Modeling Autocorrelation

We checked our autocorrelation function plots and found both autoregressive (AR) and moving averages (MA) terms to be present, due to exponentially decreasing autocorrelation in both the ACF and PACF plots. Our analysis found that eight AR and eight MA terms were needed to account for this correlation structure. After fitting these terms, autocorrelation in our model was accounted for, and any remaining autocorrelation present was acceptable, as it was within the bounds of a 95% confidence interval. 

![alt text](https://github.com/jagadeesh-h/Time-Series-Analysis-of-Wells-in-Miami/blob/master/img/ACF.png "ACF")
*Figure 2 - ACF*

![alt text](https://github.com/jagadeesh-h/Time-Series-Analysis-of-Wells-in-Miami/blob/master/img/PACF.png "PACF")
*Figure 3 - PACF*

### White Noise

Finally, after accounting for seasonality, non-stationarity, and autocorrelation, we checked to make sure we were only left with white noise in our error terms. To test this, we conducted a Ljung Box Test and failed to reject the null hypothesis, meaning that we had indeed accounted for all non-error effects in our model and were left with white noise. These high p-values were reflected in our Ljung Box White Noise Test plot. 

![alt text](https://github.com/jagadeesh-h/Time-Series-Analysis-of-Wells-in-Miami/blob/master/img/white_noise.png "White Noise")
*Figure 4 - Ljung Box White Noise Test plot*

### Final Model

The final result of the analysis was an ARIMA(8, 1, 8) model with 72 (hourly) lags of the rain variable. This indicates that 8 AR terms, 8 MA terms, and one non-seasonal difference were incorporated to achieve stationarity in the series and white noise in the error term. 

## RESULTS & ANALYSIS

The ARIMA(8, 1, 8) model was used to forecast one week’s worth of well levels for the second week of June (June 6, 2018 through June 12, 2018). The model accurately forecasted ninety-five percent of the values in the validation dataset using the mean absolute percent error (MAPE) as the diagnostic statistic. See Table 1 for the diagnostic statistics results of the validation test.

|    Model              |   MAE |  MAPE | sMAPE |    AIC   | 
| --------------------- | ------| ------|------ |----------|
| 
|ARIMA(8,1,8) with lags | 0.139 | 0.068 | 0.038 | -157729.9|
|of 72 hours            |       |       |       |          |

*Table 1 - Model Diagnostic Statistics*

Overall, our model (shown in orange) effectively predicts the actual well-depth values (shown in blue) within a 95% confidence interval, indicated by the red lines in Figure 5 below. 

![alt text](https://github.com/jagadeesh-h/Time-Series-Analysis-of-Wells-in-Miami/blob/master/img/Actual_vs_predict.png "Actual VS Prediction")
*Figure 5 - Actual well water values (blue) v.s. forecasted well water values (orange) for the holdout data set*

## CONCLUSION

Utilizing the Water Sustainability and Climate data, an ARIMA(8,1,8) model with up to 72 lags of rainfall was used to forecast the second week of June 2018 for Well G-561. The model accurately predicted ninety-five percent of the values in the forecast using the mean absolute percent error (MAPE) as the diagnostic statistic. The data showed a slight dip, followed by a peak and gradual decay in well-depth (see Figure 1 above) that the model successfully accounts for. Incorporating rainfall levels as a predictor accounts for an increase in rainfall on June 8th, leading to increased well water levels shortly after.



