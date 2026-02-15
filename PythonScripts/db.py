import pyodbc

def get_sql_connection():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost\\SQLEXPRESS;"
        "DATABASE=proje;"
        "Trusted_Connection=yes;"
    )
