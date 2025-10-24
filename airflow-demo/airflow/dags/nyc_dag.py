from src import *
from airflow.sdk import DAG
from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
import pendulum

with DAG(
    dag_id="nyc_data_pipeline",
    schedule="@monthly",
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    tags=["example"],
) as dag:
    download_task = PythonOperator(
        task_id="extract",
        python_callable=download_data_for_month,
        op_kwargs={
            "year": "2025",
            "month": "10",
            "download_dir": "./data/nyc_data"
        },
    )

    with TaskGroup("save_file_task", tooltip="Transformation tasks") as save_task:
        generate_file_schema_for_postgresql_database = PythonOperator(
            task_id="generate_file_schema_for_postgresql_database",
            python_callable=generate_file_schema_for_postgresql_database ,
            op_kwargs={
                "file_path" : download_task
            },
        )

    download_task >> save_task




