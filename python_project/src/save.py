from .logger import configure_logging
from .constants import SCHEMA_MAPPING
logger = configure_logging(log_file="save.log", logger_name="save")

def generate_file_schema_for_postgresql_database(file_path: str) -> str:
    """
    Generate the schema for a Parquet file.

    Args:
        file_path (str): The path to the Parquet file.

    Returns:
        str: The schema of the Parquet file.
    """
    import polars as pl
    df = pl.read_parquet(file_path)
    schema = df.schema
    schema_str = ", ".join([f"{col} {SCHEMA_MAPPING.get(str(dtype), 'VARCHAR')}" for col, dtype in schema.items()])
    return schema_str

def connect_to_postgresql_database():
    """
    Connect to a PostgreSQL database.

    Returns:
        psycopg2.connection: The connection object.
    """
    import psycopg2
    conn = psycopg2.connect(
        dbname="nyc_trips",
        user="postgres",
        password="postgres",
        host="localhost",
        port="5432",
    )
    return conn
def create_table_in_postgresql_database(table_name: str, schema: str):
    """
    Create a table in a PostgreSQL database.

    Args:
        table_name (str): The name of the table to create.
        schema (str): The schema of the table.
    """
    import psycopg2
    conn = psycopg2.connect(
        dbname="nyc_trips",
        user="postgres",
        password="postgres",
        host="localhost",
        port="5432",
    )
    cur = conn.cursor()
    cur.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({schema});")
    conn.commit()
    cur.close()
    conn.close()
    logger.info(f"Table {table_name} created successfully.")
