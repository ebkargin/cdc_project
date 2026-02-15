import time
from cdc_service import process_logs

if __name__ == "__main__":
    print("CDC Service started...")

    while True:
        process_logs()
        time.sleep(5)  # 5 saniyede bir polling
