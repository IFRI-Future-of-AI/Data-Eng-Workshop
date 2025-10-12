import polars as pl
from .logger import configure_logging
from .constants import SCHEMA_MAPPING, DATABASE_NAME, DATSET_FOLDER
from .database import connect_to_postgresql_database
logger = configure_logging(log_file="save.log", logger_name="save")

def generate_file_schema_for_postgresql_database(file_path: str) -> str:
    """
    Generate the schema for a Parquet file.

    Args:
        file_path (str): The path to the Parquet file.

    Returns:
        str: The schema of the Parquet file.
    """
    df = pl.read_parquet(file_path)
    schema = df.schema
    logger.info(f"Schema for file {file_path}: {schema} \n")
    schema_str = ", ".join([f"{col.lower()} {SCHEMA_MAPPING.get(str(dtype), 'VARCHAR')}" for col, dtype in schema.items()])
    logger.info(f"Schema for file {file_path}: {schema_str} \n")
    return schema_str

def create_table_in_postgresql_database(table_name: str, schema: str):
    """
    Create a table in a PostgreSQL database.

    Args:
        table_name (str): The name of the table to create.
        schema (str): The schema of the table.
    """
    conn = connect_to_postgresql_database(database_name=DATABASE_NAME)
    cur = conn.cursor()
    cur.execute(f"DROP TABLE IF EXISTS \"{table_name}\";")
    cur.execute(f"CREATE TABLE \"{table_name}\" ({schema});")
    conn.commit()
    cur.close()
    conn.close()
    logger.info(f"Table {table_name} created successfully in database {DATABASE_NAME}. \n")

def get_list_of_files_in_folder(folder_path: str) -> list:
    """
    Get a list of files in a folder.

    Args:
        folder_path (str): The path to the folder.

    Returns:
        list: A list of files in the folder.
    """
    import os
    if not os.path.exists(folder_path):
        os.makedirs(folder_path, exist_ok=True)
        logger.info(f"Created folder: {folder_path} \n")
    return [f for f in os.listdir(folder_path) if f.endswith('.parquet')]

def save_file_in_postgresql_database(file_path: str, table_name: str):
    """
    Save a Parquet file in a PostgreSQL database.
    Args:
        file_path (str): The path to the Parquet file.
        table_name (str): The name of the table to save the data in.
    """
    logger.info(f"Saving file {file_path} to table {table_name} in database {DATABASE_NAME}... \n")
    
    conn_str = f"postgresql://postgres:postgres@localhost:5432/{DATABASE_NAME}" 
    df = pl.read_parquet(file_path).head(100)
    if df.is_empty():
        logger.warning(f"File {file_path} is empty. Skipping... \n")
        return
    df = df.rename({col: col.lower() for col in df.columns})
    
    df.write_database(
        table_name=table_name,
        connection=conn_str,
        if_table_exists="append",
        engine="sqlalchemy"
    )
    # No need to close the connection explicitly here, as Polars manages it with connection string
    logger.info(f"File {file_path} saved in table {table_name} successfully in database {DATABASE_NAME}. \n")
    
    
def save_all_files_in_folder_in_postgresql_database(folder_path: str = f"./data/{DATSET_FOLDER}"):
    """
    Save all Parquet files in a folder in a PostgreSQL database.

    Args:
        folder_path (str): The path to the folder.
    """
    logger.info(f"Starting ingestion of Parquet files from folder: {folder_path} in database {DATABASE_NAME} \n")
    files = get_list_of_files_in_folder(folder_path)
    logger.info(f"Found {len(files)} Parquet files to process. \n")
    for file in files:
        logger.info(f"Processing file: {file} \n")
        # Remove .parquet extension and build table name
        base_name = file.replace('.parquet', '')
        table_name = f"{folder_path.lstrip('./')}_{base_name}".replace('/', '_').replace('-', '_')
        logger.info(f"Derived table name: {table_name} \n")
        try:
            schema = generate_file_schema_for_postgresql_database(f"{folder_path}/{file}")
            create_table_in_postgresql_database(table_name, schema)
            save_file_in_postgresql_database(f"{folder_path}/{file}", table_name)
            logger.info(f"Successfully ingested file {file} into table {table_name} \n")
        except pl.exceptions.ComputeError as e:
            logger.error(f"Skipping file {file} due to Parquet specification error: {e} \n")
        except Exception as e:
            logger.error(f"Failed to ingest file {file} into table {table_name}: {e} \n")
            raise
    logger.info(f"Completed ingestion of all Parquet files from folder: {folder_path} \n")
