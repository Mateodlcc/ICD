# THe file NOR2.xlsx has the following columns:
# alpha, dlh2, dhl2, dlh3, dhl3, dlh4, dhl4, dlh5, dhl5, dlh6, dhl6
# The last row has the baseline values for dlh and dhl, with alpha as 'Base'. The other rows have different alpha values and corresponding dlh and dhl values.

import os
import pandas as pd
import matplotlib.pyplot as plt

# Read the data from the Excel file
PATH = os.path.dirname(os.path.abspath(__file__))
file_path = 'NOR2.xlsx'
actual_path = os.path.join(PATH, file_path)
df = pd.read_excel(actual_path)
# Separate the baseline values
baseline = df[df['alpha'] == 'Base'].iloc[0]
# Filter out the baseline row for plotting
df = df[df['alpha'] != 'Base']

# Make a plot with a subplot for each of the dlh and dhl values over the alpha values:
plt.figure(figsize=(10, 12))

def add_subplot(n, dlh_col, dhl_col):
    plt.subplot(3, 2, n)
    plt.plot(df['alpha'], df[dlh_col], color='b', marker='o', label=dlh_col)
    plt.axhline(y=baseline[dlh_col], color='b', linestyle='--',
                label=f'Baseline {dlh_col}')
    plt.plot(df['alpha'], df[dhl_col], color='r', marker='o', label=dhl_col)
    plt.axhline(y=baseline[dhl_col], color='r', linestyle='--',
                label=f'Baseline {dhl_col}')
    plt.xlabel('Alpha')
    plt.ylabel('Values')
    plt.title(f'{dlh_col} and {dhl_col} over Alpha')
    plt.xticks(rotation=45)
    plt.legend()
    plt.tight_layout()

# Subplot 1: N = 2
add_subplot(1, 'dlh2', 'dhl2')

# Subplot 2: N = 3
add_subplot(2, 'dlh3', 'dhl3')

# Subplot 3: N = 4
add_subplot(3, 'dlh4', 'dhl4')

# Subplot 4: N = 5
add_subplot(4, 'dlh5', 'dhl5')

# Subplot 5: N = 6
add_subplot(5, 'dlh6', 'dhl6')

plt.suptitle('DLH and DHL Values over Alpha for Different N', fontsize=8)
plt.show()




