# Apache Airflow Demo

## 📚 Table of Contents

- [Philosophy & Overview](#philosophy--overview)
- [Architecture](#architecture)
- [Core Concepts](#core-concepts)
- [Getting Started](#getting-started)
- [Writing DAGs](#writing-dags)
- [Best Practices](#best-practices)
- [Project Structure](#project-structure)
- [Documentation](#documentation)

## Philosophy & Overview

### What is Apache Airflow?

Apache Airflow is an **open-source platform for developing, scheduling, and monitoring batch-oriented workflows**. It allows you to programmatically author, schedule, and monitor data pipelines as **Directed Acyclic Graphs (DAGs)** using Python code.

### Key Philosophy

- **Dynamic**: Pipelines are defined as Python code, allowing for dynamic pipeline generation
- **Extensible**: Easily define your own operators and extend libraries to fit your environment
- **Elegant**: Pipelines are lean and explicit with parameterization built into the core using Jinja templating
- **Scalable**: Modular architecture with message queue for orchestrating arbitrary numbers of workers

### When to Use Airflow

✅ **Good for:**
- Batch data processing pipelines
- ETL/ELT workflows
- Machine learning pipelines
- Data warehouse maintenance
- Scheduled report generation
- Multi-step data transformations

❌ **Not ideal for:**
- Real-time data streaming (use Kafka, Flink instead)
- Event-driven architectures with immediate response requirements
- Simple cron jobs (might be overkill)

## Architecture

### High-Level Architecture

```
┌─────────────────┐
│   Web Server    │  ← User Interface for monitoring & management
└────────┬────────┘
         │
┌────────┴────────┐
│   Scheduler     │  ← Triggers tasks based on schedule & dependencies
└────────┬────────┘
         │
┌────────┴────────┐
│    Executor     │  ← Determines how tasks are executed
└────────┬────────┘
         │
┌────────┴────────┐
│    Workers      │  ← Execute the actual task logic
└────────┬────────┘
         │
┌────────┴────────┐
│    Metadata DB  │  ← Stores state, configuration, logs
└─────────────────┘
```

### Components

1. **Web Server**: Provides the UI for monitoring and managing DAGs
2. **Scheduler**: Monitors DAGs and triggers tasks when dependencies are met
3. **Executor**: Defines how tasks run (local, sequential, parallel, Celery, Kubernetes, etc.)
4. **Workers**: Execute the actual task logic
5. **Metadata Database**: Stores DAG definitions, task states, variables, connections, etc.

### Execution Flow

```
1. Scheduler reads DAG files → Parses DAGs
2. Scheduler checks DAG schedules → Creates DAG Runs
3. Scheduler evaluates task dependencies → Queues tasks
4. Executor picks up queued tasks → Assigns to workers
5. Workers execute tasks → Report status back
6. Metadata DB stores results → Web Server displays status
```

## Core Concepts

### 1. DAG (Directed Acyclic Graph)

A **DAG** is a collection of tasks organized to reflect their relationships and dependencies.

**Properties:**
- **Directed**: Tasks flow in one direction
- **Acyclic**: No circular dependencies (no loops)
- **Graph**: Collection of nodes (tasks) and edges (dependencies)

**Example:**
```python
from airflow.sdk import DAG
from datetime import datetime

with DAG(
    dag_id='my_dag',
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
) as dag:
    # Tasks go here
    pass
```

**Key Parameters:**
- `dag_id`: Unique identifier for the DAG
- `start_date`: When the DAG should start running
- `schedule`: How often to run (`@daily`, `@hourly`, cron expression, or `None`)
- `catchup`: Whether to backfill missed runs
- `default_args`: Default arguments for all tasks
- `tags`: Organize and filter DAGs in UI

### 2. Task

A **Task** is a unit of work within a DAG. It represents a single operation in your pipeline.

**Types:**
- **Operators**: Pre-built tasks (BashOperator, PythonOperator, etc.)
- **Sensors**: Wait for a condition (FileSensor, S3KeySensor, etc.)
- **TaskFlow API**: Python functions decorated with `@task`

**Example:**
```python
from airflow.sdk.decorators import task

@task
def my_function():
    print("Hello from a task!")
    return "result"
```

**Task States:**
- `none`: Not yet scheduled
- `scheduled`: Scheduled to run
- `queued`: Assigned to executor
- `running`: Currently executing
- `success`: Completed successfully
- `failed`: Failed with error
- `skipped`: Skipped due to branching
- `upstream_failed`: Failed because upstream task failed
- `up_for_retry`: Waiting to retry

### 3. TaskGroup

A **TaskGroup** is used to organize related tasks in the UI without affecting the DAG structure.

**Example:**
```python
from airflow.utils.task_group import TaskGroup

with TaskGroup('data_processing') as processing_group:
    task1 = extract_data()
    task2 = transform_data()
    task3 = validate_data()
    
    task1 >> task2 >> task3
```

**Benefits:**
- Better organization in UI
- Collapsible groups for cleaner view
- Reusable task patterns

### 4. Operators

**Operators** are predefined templates for common tasks.

**Common Operators:**

```python
# BashOperator - Run bash commands
from airflow.providers.standard.operators.bash import BashOperator

bash_task = BashOperator(
    task_id='run_script',
    bash_command='echo "Hello World"'
)

# PythonOperator - Run Python functions
from airflow.providers.standard.operators.python import PythonOperator

def my_function():
    print("Hello from Python")

python_task = PythonOperator(
    task_id='run_python',
    python_callable=my_function
)

# EmailOperator - Send emails
from airflow.providers.standard.operators.email import EmailOperator

email_task = EmailOperator(
    task_id='send_email',
    to='user@example.com',
    subject='Pipeline Complete',
    html_content='<p>Pipeline finished successfully</p>'
)
```

**Provider Packages:**
- `apache-airflow-providers-amazon` - AWS services
- `apache-airflow-providers-google` - GCP services
- `apache-airflow-providers-postgres` - PostgreSQL
- And many more...

### 5. Connections

**Connections** store credentials and connection details for external systems securely. They enable tasks to interact with databases, APIs, cloud services, and other external resources without hardcoding credentials.

**Managing Connections:**
- **Via Web UI**: Admin → Connections → Add
- **Via CLI**: `airflow connections add my_conn --conn-type postgres --conn-host localhost --conn-login user --conn-password pass`
- **Via Environment Variables**: `AIRFLOW_CONN_{CONN_ID}` (format: `type://user:password@host:port/schema`)

**Common Connection Types:**
- `postgres`, `mysql`, `sqlite` - Databases
- `http`, `https` - HTTP APIs
- `aws`, `google_cloud_platform`, `azure` - Cloud providers
- `ftp`, `sftp`, `ssh` - File transfers
- `slack`, `email` - Notifications

**Example Usage:**
```python
from airflow.providers.postgres.hooks.postgres import PostgresHook

# Using connection in a task
@task
def query_database():
    hook = PostgresHook(postgres_conn_id='my_postgres_connection')
    records = hook.get_records('SELECT * FROM users WHERE active = true')
    return len(records)

# Using connection with operators
from airflow.providers.postgres.operators.postgres import PostgresOperator

create_table = PostgresOperator(
    task_id='create_table',
    postgres_conn_id='my_postgres_connection',
    sql='''
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            created_at TIMESTAMP DEFAULT NOW()
        )
    '''
)
```

**Best Practices:**
- Never hardcode credentials in DAG files
- Use descriptive connection IDs (`prod_postgres_db`, `staging_api`)
- Store sensitive data in Airflow Connections, not Variables
- Test connections before using in production
- Document required connections in DAG docstrings

### 6. XCom (Cross-Communication)

**XCom** (short for "cross-communication") enables tasks to exchange small amounts of data. XComs are stored in Airflow's metadata database and identified by a key, task_id, and dag_id.

**How XCom Works:**
- Tasks can **push** values to XCom (explicitly or via return values)
- Other tasks can **pull** values from XCom
- With TaskFlow API, XCom is handled automatically

**Example - Explicit Push/Pull:**
```python
from airflow.operators.python import PythonOperator

def push_function(**context):
    # Explicitly push to XCom
    context['ti'].xcom_push(key='my_key', value='my_value')

def pull_function(**context):
    # Pull from XCom
    value = context['ti'].xcom_pull(key='my_key', task_ids='push_task')
    print(f"Retrieved: {value}")

push_task = PythonOperator(
    task_id='push_task',
    python_callable=push_function
)

pull_task = PythonOperator(
    task_id='pull_task',
    python_callable=pull_function
)

push_task >> pull_task
```

**Example - TaskFlow API (Automatic):**
```python
@task
def extract():
    # Return value is automatically pushed to XCom
    return {'data': [1, 2, 3], 'count': 3}

@task
def transform(data):
    # Parameter automatically pulls from XCom
    processed = [x * 2 for x in data['data']]
    return {'processed': processed, 'count': data['count']}

@task
def load(result):
    print(f"Loading {result['count']} processed items")

# Data flows automatically
result = extract()
transformed = transform(result)
load(transformed)
```

**XCom Best Practices:**
- ✅ Use for small metadata (IDs, counts, statuses, file paths)
- ✅ Use TaskFlow API for cleaner code
- ✅ Keep XCom values under 1MB (database limitations)
- ❌ Don't use for large datasets or binary data
- ❌ Don't rely on XCom for long-term storage
- 💡 For large data, store in S3/GCS/HDFS and pass the path via XCom

**Custom XCom Backends:**
For larger data, you can configure custom XCom backends (S3, GCS) that store data externally and only store references in the database:
```python
# In airflow.cfg
[core]
xcom_backend = airflow.providers.amazon.aws.xcom_backends.s3.S3XComBackend
```

### 7. Variables

**Variables** are key-value pairs stored in Airflow's metadata database for runtime configuration. They allow you to parameterize your DAGs without modifying code.

**Managing Variables:**
- **Via Web UI**: Admin → Variables → Add
- **Via CLI**: `airflow variables set my_var "my_value"`
- **Via Python**: `Variable.get('my_var')`

**Example Usage:**
```python
from airflow.models import Variable

@task
def process_data():
    # Get variable (throws KeyError if not found)
    api_key = Variable.get("api_key")
    
    # Get with default value
    batch_size = Variable.get("batch_size", default_var=100)
    
    # Get JSON variable
    config = Variable.get("db_config", deserialize_json=True)
    # Returns: {'host': 'localhost', 'port': 5432}
    
    print(f"Processing with batch size: {batch_size}")

# Using variables in DAG definition
max_active_runs = int(Variable.get("max_active_runs", default_var="1"))

with DAG(
    dag_id='my_dag',
    max_active_runs=max_active_runs,
    ...
) as dag:
    process_data()
```

**Best Practices:**
- ✅ Use Variables for configuration that changes between environments
- ✅ Store JSON objects for complex configurations
- ✅ Set default values to prevent KeyError
- ✅ Cache frequently-used variables to reduce DB queries
- ❌ Don't use Variables for secrets (use Connections instead)
- ❌ Don't read Variables in the DAG file top-level (causes DB query on every parse)
- 💡 Prefix variables with environment: `prod_api_key`, `staging_api_key`

**Environment Variables:**
Variables can also be set via environment variables with prefix `AIRFLOW_VAR_`:
```bash
export AIRFLOW_VAR_API_KEY="my_secret_key"
export AIRFLOW_VAR_BATCH_SIZE="50"
```

### 8. Pools

**Pools** limit the concurrent execution of tasks to manage resource usage. They prevent overloading external systems or controlling parallel task execution.

**Use Cases:**
- Limiting database connections
- Controlling API rate limits
- Managing computational resources
- Preventing system overload

**Managing Pools:**
- **Via Web UI**: Admin → Pools → Add
- **Via CLI**: `airflow pools set my_pool 5 "My pool description"`

**Example Usage:**
```python
# Define tasks with pool assignment
@task(pool='database_pool')
def query_database():
    # This task will respect the database_pool slot limit
    return run_query()

@task(pool='api_pool', pool_slots=2)
def call_api():
    # This task uses 2 slots from api_pool
    return make_api_call()

# In traditional operators
from airflow.operators.bash import BashOperator

heavy_task = BashOperator(
    task_id='heavy_processing',
    bash_command='python process_large_file.py',
    pool='processing_pool',
    pool_slots=3  # Uses 3 slots
)
```

**Default Pool:**
- Airflow has a default pool with 128 slots
- Tasks without explicit pool assignment use the default pool
- You can modify the default pool size

**Example Pool Configuration:**
```python
# Create pools via CLI
airflow pools set postgres_pool 5 "PostgreSQL connection pool"
airflow pools set api_pool 10 "External API calls pool"
airflow pools set heavy_compute 2 "Heavy computation tasks"

# List pools
airflow pools list

# Check pool usage
airflow pools get postgres_pool
```

**Best Practices:**
- ✅ Create pools for shared external resources
- ✅ Set pool sizes based on resource capacity
- ✅ Monitor pool usage in the UI (Admin → Pools)
- ✅ Use descriptive pool names
- ❌ Don't create too many small pools (management overhead)
- 💡 Start with conservative pool sizes and increase as needed
- 💡 Use `priority_weight` to prioritize important tasks when pool is full

**Priority with Pools:**
```python
@task(pool='limited_pool', priority_weight=10)
def high_priority_task():
    # Runs before lower priority tasks when pool is full
    pass

@task(pool='limited_pool', priority_weight=1)
def low_priority_task():
    # Runs after higher priority tasks
    pass
```

### 9. Sensors

**Sensors** are special operators that wait for a certain condition to be met before proceeding. They periodically check (poke) for the condition and succeed when it's true.

**Common Sensors:**
- `FileSensor` - Wait for file to exist
- `S3KeySensor` - Wait for S3 object
- `DateTimeSensor` - Wait for specific datetime
- `ExternalTaskSensor` - Wait for another DAG/task
- `HttpSensor` - Wait for HTTP endpoint
- `SqlSensor` - Wait for SQL query condition

**Example Usage:**
```python
from airflow.sensors.filesystem import FileSensor
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.sensors.external_task import ExternalTaskSensor

# Wait for file to appear
wait_for_file = FileSensor(
    task_id='wait_for_input_file',
    filepath='/data/input.csv',
    poke_interval=30,  # Check every 30 seconds
    timeout=600,  # Give up after 10 minutes
    mode='poke',  # or 'reschedule'
)

# Wait for S3 object
wait_for_s3 = S3KeySensor(
    task_id='wait_for_s3_file',
    bucket_name='my-bucket',
    bucket_key='data/{{ ds }}/input.parquet',
    aws_conn_id='aws_default',
    poke_interval=60,
    timeout=3600,
)

# Wait for another DAG to complete
wait_for_upstream = ExternalTaskSensor(
    task_id='wait_for_upstream_dag',
    external_dag_id='upstream_pipeline',
    external_task_id='final_task',
    timeout=7200,
)

# Custom sensor
from airflow.sensors.base import BaseSensorOperator

class CustomApiSensor(BaseSensorOperator):
    def poke(self, context):
        # Return True when condition is met
        response = check_api_status()
        return response.status == 'ready'

# Usage in DAG
wait_for_file >> process_file >> save_results
```

**Sensor Modes:**
- **poke** (default): Sensor takes a worker slot while waiting
  - Simple, immediate response when condition met
  - Uses worker slot continuously
  - Good for short waits (< 5 minutes)

- **reschedule**: Sensor releases worker slot between pokes
  - Frees worker for other tasks
  - Small delay when condition is met (next sensor check)
  - Good for long waits (> 5 minutes)

**Best Practices:**
- ✅ Use `mode='reschedule'` for long-running sensors
- ✅ Set appropriate `timeout` values
- ✅ Use `poke_interval` to avoid excessive checking
- ✅ Consider using `exponential_backoff=True` for some sensors
- ❌ Don't use poke mode for sensors that wait hours/days
- 💡 Use sensors instead of sleep() in tasks
- 💡 Chain multiple sensors with timeouts for complex conditions

### 10. Hooks

**Hooks** are interfaces to external systems that encapsulate connection logic and provide reusable methods for interacting with databases, APIs, and services.

**Purpose:**
- Abstract connection details
- Provide consistent interface
- Reusable across multiple tasks/DAGs
- Handle connection pooling and retries

**Common Hooks:**
```python
# PostgreSQL Hook
from airflow.providers.postgres.hooks.postgres import PostgresHook

hook = PostgresHook(postgres_conn_id='my_postgres')
records = hook.get_records('SELECT * FROM users')
hook.run('INSERT INTO logs VALUES (%s, %s)', parameters=('event', 'now'))

# S3 Hook
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

s3_hook = S3Hook(aws_conn_id='aws_default')
s3_hook.load_file('/local/file.csv', 'my-bucket', 's3-key')
files = s3_hook.list_keys('my-bucket', prefix='data/')

# HTTP Hook
from airflow.providers.http.hooks.http import HttpHook

http_hook = HttpHook(http_conn_id='api_default', method='GET')
response = http_hook.run('endpoint/path')
data = response.json()

# Slack Hook
from airflow.providers.slack.hooks.slack import SlackHook

slack_hook = SlackHook(slack_conn_id='slack_default')
slack_hook.call('chat.postMessage', json={
    'channel': '#alerts',
    'text': 'Pipeline completed!'
})
```

**Custom Hook Example:**
```python
from airflow.hooks.base import BaseHook

class CustomApiHook(BaseHook):
    """Hook for Custom API interactions."""
    
    def __init__(self, api_conn_id='custom_api_default'):
        self.api_conn_id = api_conn_id
        self.base_url = None
        self.api_key = None
    
    def get_conn(self):
        """Get connection details."""
        conn = self.get_connection(self.api_conn_id)
        self.base_url = f"{conn.host}:{conn.port}"
        self.api_key = conn.password
        return self
    
    def fetch_data(self, endpoint):
        """Fetch data from API."""
        import requests
        self.get_conn()
        url = f"{self.base_url}/{endpoint}"
        headers = {'Authorization': f'Bearer {self.api_key}'}
        response = requests.get(url, headers=headers)
        return response.json()

# Using custom hook
@task
def get_api_data():
    hook = CustomApiHook(api_conn_id='my_custom_api')
    data = hook.fetch_data('users')
    return data
```

**Best Practices:**
- ✅ Use hooks instead of directly managing connections
- ✅ Create custom hooks for frequently-used APIs
- ✅ Leverage provider packages for common systems
- ✅ Use connection pooling features
- ❌ Don't create new connections in every task
- 💡 Hooks make testing easier (can mock connections)
- 💡 Check if a provider package exists before writing custom code

### 11. Executors

**Executors** determine how and where tasks are run. They define the parallelism and infrastructure for task execution.

**Types of Executors:**

**1. SequentialExecutor** (Default, Development)
- Executes one task at a time
- Uses SQLite database
- Good for: Testing, learning, debugging
- Limitations: No parallelism

**2. LocalExecutor** (Local Parallelism)
- Runs multiple tasks in parallel on the same machine
- Uses separate processes
- Requires: PostgreSQL or MySQL (not SQLite)
- Good for: Single-machine production, development
```python
# In airflow.cfg
[core]
executor = LocalExecutor
parallelism = 32  # Max concurrent tasks
```

**3. CeleryExecutor** (Distributed)
- Distributes tasks across multiple worker machines
- Uses message queue (Redis, RabbitMQ)
- Requires: Celery setup, message broker
- Good for: Large-scale production, horizontal scaling
```python
# In airflow.cfg
[core]
executor = CeleryExecutor

[celery]
broker_url = redis://localhost:6379/0
result_backend = db+postgresql://user:pass@localhost/airflow
```

**4. KubernetesExecutor** (Cloud-Native)
- Spawns new Kubernetes pod for each task
- Dynamic resource allocation
- Excellent isolation between tasks
- Good for: Cloud environments, varying resource needs
```python
# In airflow.cfg
[core]
executor = KubernetesExecutor

[kubernetes]
namespace = airflow
```

**5. CeleryKubernetesExecutor** (Hybrid)
- Combines Celery and Kubernetes executors
- Route tasks to different executors based on queue
- Maximum flexibility

**Choosing an Executor:**
```
Development/Learning:
  └─> SequentialExecutor (simple, included)

Single Machine Production:
  └─> LocalExecutor (parallel, reliable)

Multiple Machines:
  └─> CeleryExecutor (distributed, scalable)

Cloud/Kubernetes:
  └─> KubernetesExecutor (dynamic, isolated)

Hybrid Needs:
  └─> CeleryKubernetesExecutor (flexible)
```

**Executor Configuration Example:**
```python
# airflow.cfg for LocalExecutor
[core]
executor = LocalExecutor
parallelism = 32          # Max tasks across all DAGs
dag_concurrency = 16      # Max tasks per DAG
max_active_runs_per_dag = 3

# Per-DAG configuration
with DAG(
    dag_id='my_dag',
    max_active_runs=2,     # Override global setting
    concurrency=8,         # Max parallel tasks in this DAG
    ...
) as dag:
    pass
```

**Best Practices:**
- ✅ Start with SequentialExecutor for learning
- ✅ Use LocalExecutor for production single-node deployments
- ✅ Use CeleryExecutor when you need multiple machines
- ✅ Use KubernetesExecutor in cloud environments
- ✅ Monitor executor performance and adjust parallelism
- ❌ Don't use SequentialExecutor in production
- 💡 Consider task resource requirements when choosing executor
- 💡 KubernetesExecutor provides best isolation but has overhead

## Getting Started

### Installation

This project uses `uv` for dependency management:

```bash
# Dependencies are already defined in pyproject.toml
# To install: uv sync
```

### Running Airflow

**Standalone Mode (for development):**
```bash
# Set Airflow home directory
export AIRFLOW_HOME="$(pwd)/airflow"

# Run Airflow in standalone mode
uv run --project . airflow standalone
```

This command:
- Initializes the metadata database
- Creates an admin user
- Starts the web server (port 8080)
- Starts the scheduler
- Starts the executor

**Access the UI:**
- URL: http://localhost:8080
- Username: admin
- Password: Check the terminal output on first run

### Project Structure

```
airflow-demo/
├── airflow/
│   ├── dags/                      # DAG definitions
│   │   ├── 01_hello_world_dag.py # Simple example
│   │   ├── 02_simple_etl_dag.py  # ETL pattern
│   │   ├── 03_nyc_data_pipeline.py # Production example
│   │   └── src/                   # Shared Python modules
│   ├── logs/                      # Task execution logs
│   └── airflow.db                 # SQLite metadata DB (dev)
├── pyproject.toml                 # Project dependencies
└── README.md                      # This file
```

**Note about `src` folder:**
The `src` folder in `airflow/dags/` contains shared code used by the DAGs. This is a copy of code from the `python_project` directory, which is necessary because:
- Airflow DAGs need direct access to modules they import
- The DAG folder must be self-contained for proper parsing
- This is a common pattern in Airflow projects

## Writing DAGs

### Basic DAG Structure

```python
from datetime import datetime, timedelta
from airflow.sdk import DAG
from airflow.sdk.decorators import task

# 1. Define default arguments
default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# 2. Create DAG
with DAG(
    dag_id='my_pipeline',
    default_args=default_args,
    description='My data pipeline',
    schedule='@daily',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['production'],
) as dag:
    
    # 3. Define tasks
    @task
    def extract_data():
        return {'records': 100}
    
    @task
    def process_data(data):
        print(f"Processing {data['records']} records")
        return True
    
    # 4. Set dependencies
    result = extract_data()
    process_data(result)
```

### Task Dependencies

**Linear dependencies:**
```python
task1 >> task2 >> task3  # Sequential
```

**Multiple dependencies:**
```python
task1 >> [task2, task3]  # Fan-out
[task2, task3] >> task4  # Fan-in
```

**Complex dependencies:**
```python
task1 >> task2
task1 >> task3
[task2, task3] >> task4
```

### Schedule Intervals

**Presets:**
- `None` - Manual trigger only
- `@once` - Run once
- `@hourly` - Every hour
- `@daily` - Every day at midnight
- `@weekly` - Every Sunday at midnight
- `@monthly` - First day of month at midnight
- `@yearly` - January 1st at midnight

**Cron expressions:**
```python
schedule='0 12 * * *'    # Daily at noon
schedule='*/15 * * * *'  # Every 15 minutes
schedule='0 9 * * 1-5'   # Weekdays at 9 AM
```

### Templating with Jinja

Airflow supports Jinja templating for dynamic values:

```python
@task
def process_date(execution_date):
    print(f"Processing data for {execution_date}")

# In operators:
bash_task = BashOperator(
    task_id='process',
    bash_command='echo "Date: {{ ds }}"'  # ds = YYYY-MM-DD
)
```

**Common template variables:**
- `{{ ds }}` - Execution date (YYYY-MM-DD)
- `{{ ds_nodash }}` - Execution date (YYYYMMDD)
- `{{ execution_date }}` - Full execution datetime
- `{{ dag }}` - Current DAG object
- `{{ task }}` - Current task object

## Best Practices

### 1. DAG Design

✅ **Do:**
- Keep DAGs idempotent (can be run multiple times safely)
- Make tasks atomic (single responsibility)
- Use meaningful task_id names
- Set appropriate retries and timeouts
- Use tags for organization
- Document your DAGs with docstrings

❌ **Don't:**
- Create circular dependencies
- Put heavy computation in the DAG file (runs on every parse)
- Use dynamic DAG generation unless necessary
- Create too many small tasks (overhead)

### 2. Task Design

✅ **Do:**
- Keep tasks focused on single operations
- Use XCom for small metadata only
- Handle errors gracefully
- Log important information
- Use connections for external systems

❌ **Don't:**
- Pass large data through XCom
- Create tasks with external dependencies in DAG file
- Use global variables for state

### 3. Performance

✅ **Do:**
- Minimize DAG file parsing time
- Use appropriate executors for scale
- Set reasonable schedule intervals
- Use pools to limit concurrency
- Monitor task duration

❌ **Don't:**
- Import large libraries in DAG file top-level
- Create thousands of tasks
- Run everything in sequential mode
- Ignore failed task notifications

### 4. Testing

✅ **Do:**
- Test task logic independently
- Validate DAG structure with `airflow dags test`
- Use staging environment
- Check DAG for import errors

```bash
# Test DAG import
python airflow/dags/my_dag.py

# Test entire DAG
airflow dags test my_dag 2024-01-01

# Test specific task
airflow tasks test my_dag my_task 2024-01-01
```

### 5. Monitoring

✅ **Do:**
- Monitor DAG run duration
- Set up alerts for failures
- Review task logs regularly
- Use SLAs for critical pipelines
- Track data quality metrics

## Example DAGs in This Project

### 1. Hello World (`01_hello_world_dag.py`)
Simple introduction to:
- BashOperator
- TaskFlow API
- Task dependencies
- Manual trigger

**Use case:** Learning Airflow basics

### 2. Simple ETL (`02_simple_etl_dag.py`)
Demonstrates:
- Extract, Transform, Load pattern
- TaskGroups for organization
- Data validation
- Error handling
- Daily schedule

**Use case:** Understanding ETL patterns

### 3. NYC Data Pipeline (`03_nyc_data_pipeline.py`)
Production example with:
- Real data download
- Database interactions
- Schema generation
- Data loading
- Integration with python_project code

**Use case:** Real-world data pipeline

## Documentation

### Official Resources

- **Official Documentation**: https://airflow.apache.org/docs/
- **API Reference**: https://airflow.apache.org/docs/apache-airflow/stable/python-api-ref.html
- **Concepts**: https://airflow.apache.org/docs/apache-airflow/stable/concepts/index.html
- **Best Practices**: https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html

### Key Documentation Sections

1. **Core Concepts**: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/index.html
2. **DAGs**: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html
3. **Tasks**: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html
4. **Operators**: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/operators.html
5. **TaskFlow API**: https://airflow.apache.org/docs/apache-airflow/stable/tutorial/taskflow.html
6. **Connections**: https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html

### Community

- **GitHub**: https://github.com/apache/airflow
- **Slack**: https://apache-airflow-slack.herokuapp.com/
- **Stack Overflow**: Tag `apache-airflow`

## Troubleshooting

### Common Issues

**DAG not appearing in UI:**
- Check for syntax errors: `python airflow/dags/my_dag.py`
- Verify DAG file is in correct location
- Check scheduler logs

**Tasks not running:**
- Verify schedule and start_date
- Check task dependencies
- Review scheduler logs
- Ensure executor is running

**Import errors:**
- Verify all dependencies installed
- Check Python path
- Review DAG parsing logs

### Useful Commands

```bash
# Validate DAG syntax (without Airflow running)
python3 validate_dags.py

# List all DAGs
airflow dags list

# Check DAG structure
airflow dags show my_dag

# Trigger DAG manually
airflow dags trigger my_dag

# Check task status
airflow tasks state my_dag my_task 2024-01-01

# View logs
airflow tasks logs my_dag my_task 2024-01-01
```

---

## Quick Start Guide

1. **Start Airflow:**
   ```bash
   export AIRFLOW_HOME="$(pwd)/airflow"
   uv run --project . airflow standalone
   ```

2. **Access UI:** http://localhost:8080

3. **Enable a DAG:** Toggle the switch in the UI

4. **Trigger manually:** Click the play button

5. **View logs:** Click on task → View Log

6. **Monitor:** Check the Graph/Grid view for pipeline status

---

**Version:** Apache Airflow 3.1.0  
**Last Updated:** 2024-10-24