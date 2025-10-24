from psycopg2 import connect
from .logger import configure_logging
import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env file from the airflow-demo directory
# This handles cases where the script is run from different working directories
# Path structure: database.py -> src -> dags -> airflow -> airflow-demo
env_path = Path(__file__).resolve().parents[3] / '.env'
load_dotenv(dotenv_path=env_path)

POSTGRESQL_HOST = os.getenv("POSTGRESQL_HOST")
POSTGRESQL_PORT = os.getenv("POSTGRESQL_PORT")
POSTGRESQL_DATABASE = os.getenv("POSTGRESQL_DATABASE")
POSTGRESQL_USER = os.getenv("POSTGRESQL_USER")
POSTGRESQL_PASSWORD = os.getenv("POSTGRESQL_PASSWORD")

logger = configure_logging(log_file="database.log", logger_name="database")


def connect_to_postgresql_database(database_name: str = POSTGRESQL_DATABASE):
    """
    Connect to a PostgreSQL database.

    Args:
        database_name (str, optional): The name of the database to connect to. Defaults to POSTGRESQL_DATABASE.

    Returns:
        psycopg2.connection: The connection object.
    """
    conn = connect(
        dbname=database_name,
        user=POSTGRESQL_USER,
        password=POSTGRESQL_PASSWORD,
        host=POSTGRESQL_HOST,
        port=POSTGRESQL_PORT,
    )
    return conn

def create_database_in_postgresql_database(database_name: str):
    """
    Create a database in a PostgreSQL database.

    Args:
        database_name (str): The name of the database to create.
    """
    conn = connect_to_postgresql_database(database_name='postgres')
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{database_name}';")
    exists = cur.fetchone()
    if not exists:
        cur.execute(f"CREATE DATABASE {database_name};")
    cur.close()
    conn.close()
    logger.info(f"Database {database_name} created successfully. \n")