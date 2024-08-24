#!/usr/bin/python3

#author: Andreia Fortuna 
#last updated: 1/06/24

import sys
import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import OLSInfluence

def main(filename, col_x, col_y):
    # Load data into a DataFrame
    data = pd.read_csv(filename, delim_whitespace=True)

    # Extract the compound names and specified columns
    compounds = data.iloc[:, 0].values
    x = data[col_x].values
    y = data[col_y].values

    # Add a constant to the predictor variables for the intercept
    x_with_const = sm.add_constant(x)

    # Fit a simple linear regression model
    model = sm.OLS(y, x_with_const).fit()

    # Calculate leverage and residuals
    influence = OLSInfluence(model)
    leverage = influence.hat_matrix_diag
    studentized_residuals = influence.resid_studentized_internal

    # Determine thresholds for identifying outliers
    leverage_threshold = 2 * (len(model.params) / len(x))
    residual_threshold = 1  # Adjusted threshold for studentized residuals

    # Print leverage and Studentized residuals with corresponding compound names
    print("Leverage:", leverage)
    print("Studentized Residuals:")
    outliers = []
    for i in range(len(studentized_residuals)):
        is_outlier = abs(studentized_residuals[i]) > residual_threshold or leverage[i] > leverage_threshold
        if is_outlier:
            outliers.append(i)
        print(f"  Compound: {compounds[i]}, x: {x[i]}, y: {y[i]}, Leverage: {leverage[i]}, Studentized Residual: {studentized_residuals[i]}, Outlier: {is_outlier}")

    if outliers:
        print("\nPotential outliers detected at indices:", outliers)
    else:
        print("\nNo potential outliers detected.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: script.py <filename> <col_x> <col_y>")
        sys.exit(1)
    
    filename = sys.argv[1]
    col_x = sys.argv[2]
    col_y = sys.argv[3]
    
    main(filename, col_x, col_y)
