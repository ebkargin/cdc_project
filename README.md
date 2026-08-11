# SQL Server to MongoDB CDC (Change Data Capture) Service

This project is a data synchronization service that tracks changes (Insert, Update, Delete) occurring in the `Orders` table on SQL Server via a log table and asynchronously transfers them to **MongoDB**.

## 🚀 Project Purpose
The purpose of this project is to transfer critical data changes from a relational database (SQL Server) to a document-based structure (MongoDB) in near real-time for analysis or fast querying purposes.

## 🛠️ Technologies Used
* **Python 3.x**
* **SQL Server (T-SQL):** Source database.
* **MongoDB:** Target data store.
* **PyODBC:** Library used for SQL Server connection.
* **PyMongo:** Library used for MongoDB integration.

## 📋 Database Requirements
For the service to run, an `Orders_log` table must exist on the SQL Server side, and this table must contain an `is_processed` flag indicating its processing status.

## ⚙️ Installation and Execution

### 1. Install Dependencies
You can install the Python libraries required for the system to run using the following command:
`pip install pyodbc pymongo`

### 3. Start the Service
After all settings are completed, spin up the service via the terminal:

`python main.py`

## 🔄 Operating Logic and Architecture
1. **Polling:** The infinite loop inside `main.py` triggers the `process_logs()` function every 5 seconds.
2. **Capture:** All unprocessed records (`is_processed = 0`) in the `Orders_log` table are retrieved from SQL Server ordered by `changed_at`.
3. **Mapping:** The fetched row data is transformed into a JSON object compatible with MongoDB's flexible document structure. Old data is grouped under the `old` key, and updated data under the `new` key.
4. **Load:** The prepared documents are saved to the `cdc_logs` database in MongoDB.
5. **Update:** Each record successfully transferred is updated as `is_processed = 1` on the SQL side so that it is not processed again.

## 📁 Project File Structure
* **`main.py`**: Entry point of the application and loop management.
* **`cdc_service.py`**: Data processing, transformation, and logical flow between SQL-NoSQL.
* **`db.py`**: SQL Server connection configuration.
* **`mongo.py`**: MongoDB connection configuration.

---
**Developer:** [Ertuğrul Berk Kargın](https://github.com/ebkargin)
