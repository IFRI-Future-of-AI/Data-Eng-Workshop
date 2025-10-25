"""
PostgreSQL to MongoDB ETL Pipeline DAG

This DAG demonstrates a complete ETL pipeline that:
1. Extracts flight-related data from PostgreSQL database
2. Computes KPIs and aggregations using DuckDB
3. Loads the processed data into MongoDB for visualization

The pipeline processes the following tables:
- flights: Flight schedules and actual departure/arrival times
- boarding_passes: Passenger boarding information
- bookings: Booking details and revenue data
- tickets: Ticket information
- airports_data: Airport metadata and locations
- aircrafts_data: Aircraft specifications
- ticket_flights: Relationship between tickets and flights

Computed metrics include:
- Weekly KPIs: flights per week, delays, average passengers, revenue
- Aggregations: top airports, flight lines, historical trends
"""
from airflow import DAG
from functions.utils import *
import datetime 
from datetime import timedelta
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
import pandas as pd


tables = ["flights", "boarding_passes",
          "bookings","tickets","airports_data",
          "aircrafts_data",
          "ticket_flights"] 

stats = [
    "flights_over_time",
    "total_flights_per_week",
    "delayed_flights_per_week",
    "average_delay_time_per_week",
    "top_airports_by_departures",
    "average_passengers_per_flight_per_week",
    "last_weeks_revenue",
    "flights_lines"
    
]
kpis = [v for v in stats if "week" in v]
aggs = [v for v in stats if "week" not in v ]






default_args = {
    'owner': 'data-eng-workshop', 
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 5,
    'retry_delay': timedelta(minutes=1),
}

with DAG (
    dag_id='postgres_to_mongo',
    default_args=default_args,
    description='PostgreSQL to MongoDB ETL pipeline for flight data analytics',
    schedule='@daily',
    start_date=datetime.datetime(2024, 1, 1),
    catchup=False,
    tags=['production', 'flights', 'etl', 'postgres', 'mongodb'],
) as dag:
    # Start marker task
    start_task = EmptyOperator(task_id='start_task')
    
    # Task Group 1: Extract data from PostgreSQL
    # Fetches all required tables from the PostgreSQL database
    with TaskGroup("fetch_postgres_data", tooltip="Extract flight data from PostgreSQL") as fetch_postgres_data:
        extract_tasks = []
        for table in tables:
            extract_task = PythonOperator(
                task_id = f"fetch_table_from_postgres_{table}",
                python_callable = fetch_table_from_postgresql,
                op_kwargs = {
                    'table_name': table
                }
            )
            extract_tasks.append(extract_task) 
    
    # Task Group 2: Compute weekly KPIs
    # Calculates key performance indicators aggregated by week
    with TaskGroup("compute_kpis", tooltip="Compute weekly KPI metrics") as compute_kpis_group:
        compute_kpis_tasks = []
        for kpi in kpis:
            compute_task = PythonOperator(
                task_id = f"compute_{kpi}",
                python_callable = compute,
                op_kwargs = {
                    'stats': kpi
                }
            )
            compute_kpis_tasks.append(compute_task)
    
    # Task Group 3: Compute aggregate statistics
    # Calculates overall aggregations not time-bound
    with TaskGroup("compute_aggs", tooltip="Compute aggregate statistics") as compute_aggs_group:
        compute_aggs_tasks = []
        for agg in aggs:
            compute_task = PythonOperator(
                task_id = f"compute_{agg}", 
                python_callable = compute,
                op_kwargs = {
                    'stats': agg
                }
            )
            compute_aggs_tasks.append(compute_task)
    
    # Task Group 4: Load KPIs to MongoDB
    # Stores computed weekly KPIs in MongoDB for visualization
    with TaskGroup("load_kpis", tooltip="Load KPI data to MongoDB") as load_kpis_group:
        load_kpis_tasks = []
        for kpi in kpis:
            load_task = PythonOperator(
                task_id = f"load_{kpi}_to_mongo",
                python_callable = load_to_mongo,
                op_kwargs = {
                    'stat': kpi,
                    'file_path': f"dump/{kpi}.json"
                }
            )
            load_kpis_tasks.append(load_task)
    
    # Task Group 5: Load aggregations to MongoDB
    # Stores computed aggregations in MongoDB for visualization
    with TaskGroup("load_aggs", tooltip="Load aggregate data to MongoDB") as load_aggs_group:
        load_aggs_tasks = []
        for agg in aggs:
            load_task = PythonOperator(
                task_id = f"load_{agg}_to_mongo",
                python_callable = load_to_mongo,
                op_kwargs = {
                    'stat': agg,
                    'file_path': f"dump/{agg}.json"
                }
            )
            load_aggs_tasks.append(load_task)
    
    # Cleanup task: Remove temporary files
    cleanup_task = PythonOperator(
        task_id='cleanup_files',
        python_callable=clean_up_files
    )
    
    # End marker task
    end_task = EmptyOperator(task_id='end_task')
    
    # Define pipeline dependencies:
    # 1. Start -> Extract from Postgres
    # 2. Extract -> Compute KPIs and Aggregations in parallel
    # 3. Compute KPIs -> Load KPIs -> Cleanup -> End
    # 4. Compute Aggs -> Load Aggs -> Cleanup -> End
    start_task >> fetch_postgres_data  >> [compute_kpis_group,compute_aggs_group]  
    compute_kpis_group >> load_kpis_group >> cleanup_task >> end_task
    compute_aggs_group >> load_aggs_group >> cleanup_task >> end_task

