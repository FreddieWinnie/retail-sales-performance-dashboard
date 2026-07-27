import pandas as pd
from sqlalchemy import create_engine

# -----------------------
# CHANGE THESE SETTINGS
# -----------------------

username = "root"
password = "###########"
host = "localhost"
port = 3306
database = "retail_sales_analysis"

csv_path = r"D:\Data Analytics Portfolio\Retail Sales analytics\data\superstore.csv"

# -----------------------

# Read CSV
df = pd.read_csv(csv_path)

print("Rows:", len(df))
print("Columns:", len(df.columns))

# Connect to MySQL
engine = create_engine(
    f"mysql+pymysql://{username}:{password}@{host}:{port}/{database}"
)

# Import into MySQL
df.to_sql(
    "orders",
    con=engine,
    if_exists="replace",
    index=False
)

print("Data imported successfully!")