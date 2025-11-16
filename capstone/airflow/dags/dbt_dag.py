from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import ClickHouseUserPasswordProfileMapping
import os 
from datetime import datetime, timedelta

profile_config = ProfileConfig(
    profile_name="airline",
    target_name="dev",
    profile_mapping=ClickHouseUserPasswordProfileMapping(
        conn_id='airline_clickhouse_conn',
        profile_args={
            "schema": "bookings",
            "threads": 2,
            "type": "clickhouse",
        }
    )
)

my_cosmos_dag = DbtDag(
    project_config=ProjectConfig(
        "/usr/local/airflow/dags/dbt/airline",
    ),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
    ),
    # normal dag parameters
    #schedule="0 1 * * *",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="dbt_airline",
    default_args={"retries": 2},
)