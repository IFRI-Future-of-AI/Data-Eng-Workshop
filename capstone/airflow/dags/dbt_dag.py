from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping
import os 
from datetime import datetime, timedelta

profile_config = ProfileConfig(
    profile_name="ride_share",
    target_name="dev",
    profile_mapping= SnowflakeUserPasswordProfileMapping(
    conn_id = 'rentcar_snowflake_conn',
    profile_args ={
        "database": "RIDE_SHARE",
        "warehouse": "COMPUTE_WH",
        "schema": "RIDE_SHARE_V1",
        "threads": 2,
        "type": "snowflake",
        "role": "ACCOUNTADMIN"
    }
)
)

my_cosmos_dag = DbtDag(
    project_config=ProjectConfig(
        "/usr/local/airflow/dags/dbt/rentcar",
    ),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",
    ),
    # normal dag parameters
    #schedule="0 1 * * *",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="dbt_rentcar",
    default_args={"retries": 2},
)