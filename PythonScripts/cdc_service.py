from db import get_sql_connection
from mongo import get_mongo_collection

def process_logs():
    sql_conn = get_sql_connection()
    cursor = sql_conn.cursor()
    mongo_collection = get_mongo_collection()

    cursor.execute("""
        SELECT
            log_id,
            operation_type,
            order_id,
            customer_id,
            old_order_product,
            old_order_amount,
            old_order_status,
            new_order_product,
            new_order_amount,
            new_order_status,
            changed_at
        FROM Orders_log
        WHERE is_processed = 0
        ORDER BY changed_at
    """)

    rows = cursor.fetchall()

    for row in rows:
        log_document = {
            "operation": row.operation_type,
            "table": "Orders",
            "order_id": row.order_id,
            "customer_id": row.customer_id,
            "old": {
                "product": row.old_order_product,
                "amount": float(row.old_order_amount) if row.old_order_amount else None,
                "status": row.old_order_status
            },
            "new": {
                "product": row.new_order_product,
                "amount": float(row.new_order_amount) if row.new_order_amount else None,
                "status": row.new_order_status
            },
            "changed_at": row.changed_at
        }

        mongo_collection.insert_one(log_document)

        cursor.execute(
            "UPDATE Orders_log SET is_processed = 1 WHERE log_id = ?",
            row.log_id
        )

    sql_conn.commit()
    cursor.close()
    sql_conn.close()
