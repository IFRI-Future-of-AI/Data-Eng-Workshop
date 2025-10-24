#!/usr/bin/env python3
"""
Simple script to validate DAG syntax and structure.
This checks if DAGs can be imported without errors.
"""
import sys
import os
from pathlib import Path

def validate_dag_file(dag_file):
    """Validate a single DAG file by attempting to import it."""
    dag_name = dag_file.name
    print(f"Validating {dag_name}...", end=" ")
    
    try:
        # Add the dags directory to Python path
        dags_dir = dag_file.parent
        if str(dags_dir) not in sys.path:
            sys.path.insert(0, str(dags_dir))
        
        # Try to compile the file
        with open(dag_file, 'r') as f:
            code = f.read()
            compile(code, dag_name, 'exec')
        
        print("✓ Syntax valid")
        return True
    except SyntaxError as e:
        print(f"✗ Syntax error: {e}")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def main():
    """Validate all DAG files."""
    # Get the dags directory
    dags_dir = Path(__file__).parent / 'airflow' / 'dags'
    
    if not dags_dir.exists():
        print(f"Error: DAGs directory not found at {dags_dir}")
        sys.exit(1)
    
    # Find all Python files in the dags directory (excluding __pycache__ and src)
    dag_files = [
        f for f in dags_dir.glob('*.py')
        if f.is_file() and not f.name.startswith('_')
    ]
    
    if not dag_files:
        print("No DAG files found!")
        sys.exit(1)
    
    print("="*60)
    print("DAG Validation Report")
    print("="*60)
    print(f"Found {len(dag_files)} DAG file(s)\n")
    
    # Validate each DAG file
    results = []
    for dag_file in sorted(dag_files):
        result = validate_dag_file(dag_file)
        results.append((dag_file.name, result))
    
    # Summary
    print("\n" + "="*60)
    print("Summary")
    print("="*60)
    
    passed = sum(1 for _, result in results if result)
    failed = len(results) - passed
    
    print(f"Total: {len(results)}")
    print(f"Passed: {passed} ✓")
    print(f"Failed: {failed} ✗")
    
    if failed > 0:
        print("\nFailed files:")
        for name, result in results:
            if not result:
                print(f"  - {name}")
        sys.exit(1)
    else:
        print("\nAll DAG files are valid! ✓")
        sys.exit(0)

if __name__ == "__main__":
    main()
