from src import (
    download_data_month_to_month, 
    save_all_files_in_folder_in_postgresql_database,
    download_taxi_zones
                 )
def main():
    download_taxi_zones()
    download_data_month_to_month(
        start_month='2024-01', 
        end_month='2025-10'
    )
    save_all_files_in_folder_in_postgresql_database()


if __name__ == "__main__":
    main()
