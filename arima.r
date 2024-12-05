### ESTIMASI PARAMETER
library(readxl)
library(starma)
library(tseries)
library(cursr)
library(lmtest)
library(forecast)
library(nortest)
library(astsa)
library(CausalImpact)
library(MASS)
library(tsoutliers)
library(TSA)
library(lmtest)
library(ggplot2)

dataTA <- read_excel('D:/ITS/TA/Data TA/data_TA.xlsx', sheet = 'Data_Keseluruhan')
pma <- dataTA$Aktual
preIntv <- ts(pma[1:51])

arima1 <- sarima(preIntv, 1,1,0, no.constant = TRUE)
arima1$ttable

arima2 <- sarima(preIntv, 0,1,1, no.constant = TRUE)
arima2$ttable

arima3 <- sarima(preIntv, 1,1,1, no.constant = TRUE)
arima3$ttable

#### PLOT PREDIKSI ARIMA DAN DATA ASLI

data1 <- ts(pma[1:54])
juml <- dataTA$t
tot <- ts(juml[1:54])

model_arima <- Arima(preIntv, order = c(1,1,1))

predicted_values <- fitted(model_arima)

forecast_values <- forecast(model_arima, h=3)$mean
forecast_values
combined_values <- c(predicted_values, forecast_values)

df_plot <- data.frame(t=tot, Actual = data1, Predicted = combined_values)

ggplot(df_plot) +
  geom_line(aes(x = t, y = Actual, color = "Data Asli")) +
  geom_line(aes(x = t, y = Predicted, color = "Nilai Prediksi ARIMA")) +
  labs(title = "Plot Nilai Prediksi Model ARIMA(1,1,1)dan Data Asli",
       x = "Data Ke-", y = "Jumlah Proyek",
       color = NULL) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "bottom") +
  scale_color_manual(values = c("Data Asli" = "mediumblue", "Nilai Prediksi ARIMA" = "magenta")) +
  annotate("text", x = 52, y = Inf, label = "Intervensi", vjust = 1, hjust = 1.1, color="red") +
  geom_vline(xintercept = 52, linetype = "dashed", color = "red") + # Garis putus-putus pada t=52
  geom_vline(xintercept = 0,  color = "black") + # Garis vertikal pada data_pre$t[1]
  geom_hline(yintercept = 0,  color = "black") + # Garis horizontal pada y = 0
  scale_x_continuous(breaks = seq(0, 50, by = 10))

# Plot residual
int <- ts(pma[52:54])

error <- rep(0,54)
error[1:51] <- model_arima$residuals
error[52:54] <- int[1:3]-forecast_values

plot(error,type="h", xlab = "Waktu (T)", ylab = "Residual", xaxt="n", ylim = c(-250,250))
abline(v=52, col="red", lty=3, lwd=1.5)
abline(h=c(-3*sd(model_arima$residuals),3*sd(model_arima$residuals)),col="blue",lty=2)
abline(h=0,col="black")
text(52,-210,"T=52",cex=1,pos=3)
axis(1,at=c(2,12,22,32,42,52,54),labels=c("T-50","T-40","T-30","T-20","T-10","T","T+2"))
