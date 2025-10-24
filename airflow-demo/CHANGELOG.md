# Changelog - Airflow Demo Refactoring

## 2024-10-24 - Complete Refactoring

### Added

#### DAG Files
1. **01_hello_world_dag.py** - Simple introduction DAG
   - Demonstrates basic Airflow concepts
   - Uses BashOperator and PythonOperator
   - Shows TaskFlow API with `@task` decorator
   - Manual trigger only (schedule=None)
   - Tags: `['tutorial', 'simple']`

2. **02_simple_etl_dag.py** - ETL pattern demonstration
   - Complete Extract, Transform, Load workflow
   - Uses TaskGroups for organization
   - Demonstrates data validation and error handling
   - Shows XCom data passing between tasks
   - Daily schedule (`@daily`)
   - Tags: `['tutorial', 'etl']`

3. **03_nyc_data_pipeline.py** - Production-ready pipeline (refactored from nyc_dag.py)
   - Downloads NYC taxi trip data
   - Generates PostgreSQL schema from Parquet files
   - Creates database tables dynamically
   - Loads data into PostgreSQL
   - Uses code from python_project (via local src module)
   - Monthly schedule (`@monthly`)
   - Tags: `['production', 'nyc', 'etl']`

#### Documentation
- **README.md** - Comprehensive Airflow guide (1000+ lines)
  - Philosophy and overview of Airflow
  - Detailed architecture explanation
  - Core concepts with extensive examples:
    - DAG (Directed Acyclic Graph)
    - Task and TaskGroup
    - Operators
    - Connections (expanded with best practices and examples)
    - XCom (expanded with explicit/automatic usage, custom backends)
    - Variables (runtime configuration)
    - Pools (resource management and concurrency control)
    - Sensors (waiting for conditions, modes, common types)
    - Hooks (interface to external systems, custom hooks)
    - Executors (Sequential, Local, Celery, Kubernetes)
  - Step-by-step guide on writing DAGs
  - Best practices for DAG design, task design, performance, testing, and monitoring
  - Project structure explanation
  - Troubleshooting guide
  - Quick start guide
  - Links to official documentation

#### Tools
- **validate_dags.py** - DAG validation script
  - Validates DAG syntax without running Airflow
  - Checks all Python files in dags directory
  - Provides clear success/failure reporting
  - Usage: `python3 validate_dags.py`

### Changed
- **nyc_dag.py** renamed to **03_nyc_data_pipeline.py** for consistency
- Fixed Airflow imports to use standard API instead of `airflow.sdk`
  - Changed from `airflow.sdk` to `airflow`
  - Changed from `airflow.sdk.decorators` to `airflow.decorators`
  - Changed from `airflow.providers.standard.operators` to `airflow.operators`
- Improved task dependencies and error handling in NYC pipeline
- Updated import structure to properly use python_project code
- Enhanced README.md with additional core concepts:
  - Expanded Connections section with multiple examples and best practices
  - Expanded XCom section with explicit push/pull, automatic TaskFlow, and custom backends
  - Added Variables section for runtime configuration
  - Added Pools section for resource management and concurrency control
  - Added Sensors section covering modes, common types, and best practices
  - Added Hooks section with examples and custom hook creation
  - Added Executors section comparing Sequential, Local, Celery, and Kubernetes executors

### Removed
- **example_dag.py** - Replaced with better examples (01_hello_world_dag.py)

### Technical Details
- Airflow version: 3.1.0
- Python version: >=3.10
- All DAGs tested and validated
- Syntax validation: ✓ Passed

### Migration Notes
The `src` folder in `airflow/dags/` contains shared code from `python_project`. This duplication is intentional and necessary for Airflow DAG parsing. The code is kept in sync with the main project.

### Usage
```bash
# Validate DAGs
python3 validate_dags.py

# Run Airflow
export AIRFLOW_HOME="$(pwd)/airflow"
uv run --project . airflow standalone

# Access UI
# Open http://localhost:8080 in your browser
```
