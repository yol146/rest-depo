
import sqlite3
import pandas as pd

# load the csv file 
df = pd.read_csv("SQL_SAMPLE.csv")

#1.data cleaning 

#remove the empty space in the name of column 
df.columns = df.columns.str.strip() 

#check for duplicate
duplicates = df[df.duplicated()]
print(" The Duplicate rows:" ,duplicates)

#check for empty value
empty_values = df.isna()
print(empty_values.sum())


# 2.Create the database in sqlite
connection = sqlite3.connect("task3.db")
# load the data file to SQLite
df.to_sql("SQL_SAMPLE", connection, if_exists = 'replace')
#clode the conneciton
connection.close()