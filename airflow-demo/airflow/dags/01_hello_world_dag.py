"""
Simple Hello World DAG demonstrating basic Airflow concepts.

This DAG shows:
- Basic DAG definition with Airflow 3.1.0
- BashOperator usage
- PythonOperator with TaskFlow API
- Task dependencies
"""
from datetime import datetime, timedelta
from airflow.sdk import DAG
from airflow.sdk.decorators import task
from airflow.providers.standard.operators.bash import BashOperator

# Default arguments for all tasks
default_args = {
    'owner': 'data-eng-workshop',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
with DAG(
    dag_id='01_hello_world',
    default_args=default_args,
    description='A simple Hello World DAG to demonstrate Airflow basics',
    schedule=None,  # Manual trigger only
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['tutorial', 'simple'],
) as dag:
    
    # Task 1: Simple bash command
    hello_bash = BashOperator(
        task_id='say_hello',
        bash_command='echo "Hello from Airflow 3.1.0!"',
    )
    
    # Task 2: Python function using TaskFlow API
    @task(task_id='get_current_time')
    def get_current_time():
        """Get and print the current time."""
        from datetime import datetime
        now = datetime.now()
        print(f"Current time is: {now.strftime('%Y-%m-%d %H:%M:%S')}")
        return now.isoformat()
    
    # Task 3: Process the time
    @task(task_id='process_time')
    def process_time(timestamp: str):
        """Process the timestamp from previous task."""
        print(f"Received timestamp: {timestamp}")
        print("Processing complete!")
        return f"Processed: {timestamp}"
    
    # Task 4: Final bash task
    goodbye_bash = BashOperator(
        task_id='say_goodbye',
        bash_command='echo "Goodbye from Airflow!"',
    )
    
    # Define task dependencies
    # hello_bash runs first, then get_current_time
    # process_time depends on get_current_time output
    # goodbye_bash runs after process_time
    current_time = get_current_time()
    processed = process_time(current_time)
    
    hello_bash >> current_time >> processed >> goodbye_bash
