#! /usr/bin/python3.8
import sys
import numpy as np
import pandas as pd  # To read data
import math 
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error 
from scipy import stats
from scipy.stats import kendalltau, spearmanr, pearsonr

def usage():
    print( "\nUsage: %s  <file> <column1 name> <column2 name>\n" %(sys.argv[0]))

if len(sys.argv[:]) != 4:
    print( "\nError: Wrong number of arguments!")
    usage()
    sys.exit(1)

arg_1 = sys.argv[1]
arg_2 = sys.argv[2]
arg_3 = sys.argv[3]

df = pd.read_csv(arg_1, sep = '\s+') # load data set, space separated 
df = df.dropna()

y = df[[arg_2]] # target variable
X = df[[arg_3]] # features

linear_regressor = LinearRegression() # Define the model; Linear regression
linear_regressor.fit(X, y)  # Fit the model
y_pred = linear_regressor.predict(X)  # make predictions

# Print coeficients

r_sq = linear_regressor.score(X, y) # R^2
mae = mean_absolute_error(y, y_pred) # MAE


print("-----------------------")
print("The linear model is: {:.5} = {:.5} * {:.5} + {:.5} ".format(arg_2,arg_3,linear_regressor.coef_[0][0], linear_regressor.intercept_[0],))
print("-----------------------")
print("R^2 = {:4.2}".format(r_sq))
print("R = {:4.2}".format(math.sqrt(r_sq)))
print("-----------------------")
print("MAE = {:4.2}".format(mae))


# Use a Pandas series to calculate correlation coefficients
column_1 = df[arg_2]
column_2 = df[arg_3]
correlation_p = column_1.corr(column_2, method ='pearson')
correlation_kt = column_1.corr(column_2, method ='kendall')
correlation_sp = column_1.corr(column_2, method ='spearman')
print("-----------------------")
print("Pearson {:4.2}".format(correlation_p))
print("Kendall {:4.2}".format(correlation_kt))
print("Spearman {:4.2}".format(correlation_sp))
print("-----------------------")
