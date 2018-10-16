# Time-Series-Analysis-of-Wells-in-Miami

## SUMMARY

We performed a time series analysis of the G-561 well data provided by the National Science Foundation and U.S Department of Agriculture’s program on Water Sustainability and Climate (WSC) located in Miami. The analysis showed no seasonal effects in the model. Clear evidence of correlations and random walk were found in the model and removed. An ARIMA (5, 1, 5) model yielded the best predictions. This model had a mean absolute percent error (MAPE) of 0.068 and was used to forecast the results during the second week of June 2018.

## BACKGROUND

The analysis performed in this report is part of a project for consulting the National Science Foundation and U.S Department of Agriculture’s program on Water Sustainability and Climate (WSC)  for the well G-561 near Miami, Florida. The dataset contained ten years of information for Well G-561 and included corrected water levels. The goal of the project was to illustrate and predict the water levels of well G-561 by fitting time series models to our data. 

## DATA MANAGEMENT

The original data included values for date, time, timezone, well measurement in feet, and the corrected well measurements for approximately 101,500 observations. The data was first modified to account for daylight savings time. The data included the well’s water levels in feet recorded over 15-minute intervals from October 5th, 2007 at 1:00 AM until June 4th, 2018 at 10:45 PM. However, the 15-minute intervals were not used consistently throughout the entire time frame, some measurements were recorded in hourly intervals. To compensate for this, we aggregated the data into hourly intervals. The dataset then contained 258 missing values, which were imputed. Data exploration showed evidence of high variance in well water levels between 2007 and 2014. In order to achieve better predictions, we subsetted the data for our model from June 2015 to June 2018. These were then split into a training and a holdout data set. We used the entire data set apart from the last seven days of well readings to first train our model. The last seven days of hourly well data were used to test the accuracy of our model’s predictions.

### METHODOLOGY

### Seasonality

First, we identified if any seasonality was present in our data. While we originally found yearly seasonality to be present based on a Seasonal Trend Loess (STL) decomposition, it was on a very small scale. The addition of a seasonal component using a Fourier series did not significantly reduce the amount of variability captured by our error component, illustrated in the decomposition plot (Figure 1) below. We also checked for daily and weekly seasonality and found none to be present. Since accounting for the long-term seasonality did not add much value to modeling our series, we decided not to include a seasonality component in our analysis. 


Figure 1 - STL decomposition plot

### Stationarity in the Mean

Next, we conducted a standard Dickey-Fuller Test to check for stationarity in the mean. From this test, we rejected the null hypothesis of stationarity and found that we had stochasticity around a non-zero mean. We took a difference of one to account for this stochasticity.

### Modeling Autocorrelation

We checked our autocorrelation function plots and found both autoregressive (AR) and moving averages (MA) terms to be present, due to exponentially decreasing autocorrelation in both the ACF and PACF plots. Our analysis found that five AR and five MA terms were needed to account for this correlation structure. After fitting these terms, autocorrelation in our model was accounted for, and any remaining autocorrelation present was acceptable, as it was within the bounds of a 95% confidence interval. (See Figures 3 & 4 in the Appendix for further details).

### White Noise

Finally, after accounting for seasonality, non-stationarity, and autocorrelation, we checked to make sure we were only left with white noise in our error terms. To test this, we conducted a Ljung Box Test and failed to reject the null hypothesis, meaning that we had indeed accounted for all non-error effects in our model and were left with white noise. These high p-values were reflected in our Ljung Box White Noise Test plot. (See Figure 5 in the Appendix for further details).

### Final Model

Our final model was an ARIMA(5, 1, 5) model with five AR and five MA terms, as well as one non-seasonal difference.

## RESULTS & ANALYSIS

The second week of June (June 6, 2018 through June 12, 2018) was used as a holdout dataset to demonstrate the accuracy of our model. When tested on this holdout dataset, our model gave a mean absolute percent error (MAPE) of  0.068. Generally, lower error values indicate a model that fits the data more accurately. The full model diagnostic statistics can be found in Table 1 below.

|    Model      |   MAE |  MAPE | sMAPE |    AIC   | 
| ------------- | ------| ------|------ |----------|
| ARIMA(5,1,5)  | 0.139 | 0.068 | 0.038 | -157729.9|

*Table 1 - Model Diagnostic Statistics*

Overall, our model (shown in orange) effectively predicts the actual well-depth values (shown in blue) within a 95% confidence interval, indicated by the red lines in Figure 2 below. While our model over-predicts values for most of the values throughout June 7th and moves to underpredicting values from June 8th to June 12th, it generally hovers around the mean to where the actual values reside.

Figure 2 - Actual well water values (blue) v.s. forecasted well water values (orange) for the holdout data set

## CONCLUSION

Our ARIMA(5,1,5) model with a mean absolute percent error (MAPE) of 0.068 was used to forecast the results during the second 
week of June 2018. The data showed several local maximums and minimums in well-depth (such as the rise in well depth around 
June 8th in Figure 2 above) that our model could not account for. This could possibly be due to an increase in rainfall on 
June 8th, leading to increased well water levels. In the future, incorporating related data such as rainfall or tide levels
into our model could help model some of these nuances.


