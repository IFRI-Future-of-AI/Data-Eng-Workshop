from src.download import *
from src.constants import *
from src.database import *
from src.save import *

import psycopg2

# Only create database if we're in an execution context, not during DAG parsing
# This prevents connection errors during DAG file parsing
try:
    create_database_in_postgresql_database(DATABASE_NAME)
except (psycopg2.OperationalError, psycopg2.Error):
    # Silently fail during import - database will be created when tasks run
    pass
