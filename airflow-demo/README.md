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

**Connections** store credentials and connection details for external systems.

**Managing Connections:**
- Via Web UI: Admin → Connections
- Via CLI: `airflow connections add`
- Via Environment Variables: `AIRFLOW_CONN_{CONN_ID}`

**Example:**
```python
from airflow.providers.postgres.hooks.postgres import PostgresHook

hook = PostgresHook(postgres_conn_id='my_postgres_connection')
records = hook.get_records('SELECT * FROM users')
```

### 6. XCom (Cross-Communication)

**XCom** enables tasks to exchange data.

**Example:**
```python
@task
def extract():
    return {'data': [1, 2, 3]}

@task
def transform(data):
    return {'processed': data['data']}

# Data flows automatically with TaskFlow API
result = transform(extract())
```

**Limitations:**
- XCom values stored in metadata DB (limit size)
- Use for metadata, not large datasets
- For large data, use external storage (S3, HDFS, etc.)

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