"""
NYC Taxi Data Pipeline DAG

This DAG demonstrates a complete data pipeline using the python_project code:
1. Download NYC taxi trip data for a specific month
2. Generate database schema from the downloaded file
3. Create table in PostgreSQL
4. Load data into the database

The pipeline uses the existing functions from the python_project.
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.decorators import task
from airflow.utils.task_group import TaskGroup
# Import functions from the local src module (copied from python_project)
# This is the standard pattern in Airflow - DAGs need direct access to code
from src import (
    download_data_for_month,
    generate_file_schema_for_postgresql_database,
    create_table_in_postgresql_database,
    save_file_in_postgresql_database,
    DATABASE_NAME,
    DATSET_FOLDER,
)
import os

# Default arguments
default_args = {
    'owner': 'data-eng-workshop',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id="03_nyc_data_pipeline",
    default_args=default_args,
    description='NYC Taxi data ETL pipeline - downloads, processes and loads data',
    schedule='@monthly',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['production', 'nyc', 'etl'],
) as dag:
    
    # Task 1: Download data for a specific month
    @task(task_id='download_nyc_data')
    def download_data(year: str, month: str, download_dir: str):
        """Download NYC taxi data for specified month."""
        print(f"Downloading NYC taxi data for {year}-{month}")
        file_path = download_data_for_month(year, month, download_dir)
        print(f"Downloaded to: {file_path}")
        return file_path
    
    # Task Group: Process and Load Data
    with TaskGroup('process_and_load', tooltip='Process and load data into database') as process_group:
        
        @task(task_id='generate_schema')
        def generate_schema(file_path: str):
            """Generate PostgreSQL schema from parquet file."""
            print(f"Generating schema for: {file_path}")
            schema = generate_file_schema_for_postgresql_database(file_path)
            print(f"Generated schema: {schema[:100]}...")
            return {'file_path': file_path, 'schema': schema}
        
        @task(task_id='create_table')
        def create_table(data: dict):
            """Create table in PostgreSQL database."""
            file_path = data['file_path']
            schema = data['schema']
            
            # Generate table name from file path
            file_name = os.path.basename(file_path).replace('.parquet', '')
            table_name = f"data_{DATSET_FOLDER}_{file_name}".replace('-', '_')
            
            print(f"Creating table: {table_name}")
            create_table_in_postgresql_database(table_name, schema)
            print(f"Table {table_name} created successfully")
            
            return {'file_path': file_path, 'table_name': table_name}
        
        @task(task_id='load_data')
        def load_data(data: dict):
            """Load data from parquet file into PostgreSQL table."""
            file_path = data['file_path']
            table_name = data['table_name']
            
            print(f"Loading data from {file_path} into {table_name}")
            save_file_in_postgresql_database(file_path, table_name)
            print(f"Data loaded successfully into {table_name}")
            
            return table_name
        
        # Process group task flow
        schema_data = generate_schema(download_data(
            year="{{ execution_date.year }}",
            month="{{ execution_date.strftime('%m') }}",
            download_dir=f"./data/{DATSET_FOLDER}"
        ))
        table_data = create_table(schema_data)
        loaded_table = load_data(table_data)
    
    # Task 3: Generate summary
    @task(task_id='generate_summary')
    def summarize_pipeline(table_name: str):
        """Generate pipeline execution summary."""
        print("="*60)
        print("NYC Data Pipeline Summary")
        print("="*60)
        print(f"Database: {DATABASE_NAME}")
        print(f"Table: {table_name}")
        print(f"Status: SUCCESS")
        print(f"Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
    
    # Pipeline flow
    summarize_pipeline(loaded_table)
