"""
Simple ETL DAG demonstrating data pipeline concepts.

This DAG shows:
- Extract, Transform, Load pattern
- TaskFlow API with XCom for data passing
- TaskGroup for organizing related tasks
- Error handling
"""
from datetime import datetime, timedelta
from airflow.sdk import DAG
from airflow.sdk.decorators import task
from airflow.utils.task_group import TaskGroup

# Default arguments
default_args = {
    'owner': 'data-eng-workshop',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id='02_simple_etl',
    default_args=default_args,
    description='A simple ETL pipeline demonstrating data processing',
    schedule='@daily',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['tutorial', 'etl'],
) as dag:
    
    # Extract phase
    @task(task_id='extract_data')
    def extract():
        """Extract sample data."""
        print("Extracting data...")
        # Simulate data extraction
        data = {
            'users': [
                {'id': 1, 'name': 'Alice', 'score': 85},
                {'id': 2, 'name': 'Bob', 'score': 92},
                {'id': 3, 'name': 'Charlie', 'score': 78},
                {'id': 4, 'name': 'Diana', 'score': 95},
            ]
        }
        print(f"Extracted {len(data['users'])} records")
        return data
    
    # Transform phase with TaskGroup
    with TaskGroup('transform_tasks', tooltip='Data transformation tasks') as transform_group:
        
        @task(task_id='validate_data')
        def validate(data: dict):
            """Validate the extracted data."""
            print("Validating data...")
            users = data.get('users', [])
            
            if not users:
                raise ValueError("No users found in data!")
            
            for user in users:
                if 'id' not in user or 'name' not in user or 'score' not in user:
                    raise ValueError(f"Invalid user record: {user}")
                
                if not (0 <= user['score'] <= 100):
                    raise ValueError(f"Invalid score for {user['name']}: {user['score']}")
            
            print(f"Validated {len(users)} records successfully")
            return data
        
        @task(task_id='transform_data')
        def transform(data: dict):
            """Transform the data."""
            print("Transforming data...")
            users = data['users']
            
            # Add grade based on score
            for user in users:
                score = user['score']
                if score >= 90:
                    user['grade'] = 'A'
                elif score >= 80:
                    user['grade'] = 'B'
                elif score >= 70:
                    user['grade'] = 'C'
                else:
                    user['grade'] = 'D'
            
            # Calculate statistics
            scores = [u['score'] for u in users]
            data['stats'] = {
                'count': len(scores),
                'average': sum(scores) / len(scores),
                'min': min(scores),
                'max': max(scores),
            }
            
            print(f"Transformed data - Average score: {data['stats']['average']:.2f}")
            return data
        
        @task(task_id='enrich_data')
        def enrich(data: dict):
            """Enrich the data with additional information."""
            print("Enriching data...")
            
            # Add processing metadata
            data['metadata'] = {
                'processed_at': datetime.now().isoformat(),
                'record_count': len(data['users']),
                'pipeline': 'simple_etl',
            }
            
            print(f"Enriched data with metadata")
            return data
        
        # Transform task dependencies
        validated_data = validate(extract())
        transformed_data = transform(validated_data)
        enriched_data = enrich(transformed_data)
    
    # Load phase
    @task(task_id='load_data')
    def load(data: dict):
        """Load the processed data."""
        print("Loading data...")
        
        # Simulate data loading (in reality, this would write to a database or file)
        print(f"Loading {data['metadata']['record_count']} records")
        print(f"Statistics: {data['stats']}")
        
        for user in data['users']:
            print(f"  - {user['name']}: Score {user['score']}, Grade {user['grade']}")
        
        print("Data loaded successfully!")
        return True
    
    # Final summary task
    @task(task_id='generate_summary')
    def summarize(load_success: bool):
        """Generate a summary of the pipeline execution."""
        if load_success:
            print("="*50)
            print("ETL Pipeline Summary")
            print("="*50)
            print("Status: SUCCESS")
            print(f"Completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print("All tasks completed successfully!")
            print("="*50)
        else:
            raise ValueError("Load operation failed!")
    
    # Define the overall pipeline flow
    load_result = load(enriched_data)
    summarize(load_result)
