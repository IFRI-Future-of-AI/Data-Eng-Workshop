from src import download_data_month_to_month, save_all_files_in_folder_in_postgresql_database
def main():
    download_data_month_to_month()
    save_all_files_in_folder_in_postgresql_database()


if __name__ == "__main__":
    main()
