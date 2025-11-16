from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.airbyte.hooks.airbyte import AirbyteHook
from airflow.operators.python import PythonOperator
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.providers.airbyte.sensors.airbyte import AirbyteJobSensor
from airflow.operators.trigger_dagrun import TriggerDagRunOperator



default_args = {
    'owner': 'abraham',
    'depends_on_past': False,
    'email': ['abklb27@gmail.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='airbyte_dag',
    description='This dag orchestrate data loading from Postgres via Airbyte to ClickHouse',
    default_args=default_args,
    start_date=datetime(2025, 7, 2),
    catchup=False,
    schedule="@daily",
    tags=['airbyte', 'airline', 'clickhouse'],
) as dag:

    # test_airbyte_conn = PythonOperator(
    #     task_id='test_airbyte_connection',
    #     python_callable=lambda: AirbyteHook(airbyte_conn_id="airbyte_conn").test_connection(),
    # )

    trigger_airbyte = AirbyteTriggerSyncOperator(
        task_id='trigger_airbyte_sync',
        airbyte_conn_id='airbyte_conn',
        connection_id='cefbd9ed-0b69-4e93-b213-aa176f27a1e2',
        asynchronous=True,
    )
    airbyte_sensor = AirbyteJobSensor(
        task_id='airbyte_sensor',
        airbyte_conn_id='airbyte_conn',
        airbyte_job_id=trigger_airbyte.output,
        poke_interval=30,
        timeout=60*60*24
    )
    
    trigger_dbt = TriggerDagRunOperator(
        task_id='trigger_dbt_dag',
        trigger_dag_id='dbt_airline',
        wait_for_completion=False,         
        reset_dag_run=True,    
    )

    trigger_airbyte >> airbyte_sensor >> trigger_dbt