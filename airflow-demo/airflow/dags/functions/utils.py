"""
Utility Functions for Flight Data ETL Pipeline

This module contains helper functions for extracting, transforming, and loading
flight data from PostgreSQL to MongoDB. It uses DuckDB for efficient in-memory
data transformations and provides various SQL queries for computing KPIs and
aggregations.

Functions:
    fetch_table_from_postgresql: Extract data from PostgreSQL and save to CSV
    compute: Execute SQL queries on CSV data and save results as JSON
    serialize: Helper function for JSON serialization of datetime and Decimal types
    load_to_mongo: Load JSON data into MongoDB collections
    clean_up_files: Remove temporary CSV and JSON files from dump directory

SQL Queries:
    The module defines various SQL queries for computing metrics:
    - total_flights_per_week: Count flights per week
    - delayed_flights_per_week: Count delayed flights per week
    - average_delay_time_per_week: Average delay in minutes per week
    - flights_over_time: Daily flight counts
    - top_airports_by_departures: Top 10 airports by departure count
    - average_passengers_per_flight_per_week: Average passenger count per week
    - last_weeks_revenue: Total revenue per week
    - flights_lines: Flight routes with geographic coordinates
"""
import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.mongo.hooks.mongo import MongoHook
import os 
import json
import duckdb as db
from datetime import datetime, date, timedelta
from decimal import Decimal

queries = {
    "total_flights_per_week": """
    SELECT 
        DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day') AS week_end,
        COUNT(flight_id) AS total_flights
    FROM flights
    WHERE actual_departure IS NOT NULL
    GROUP BY DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day')
    ORDER BY week_end DESC
    LIMIT 2;
    """, 
    
    "delayed_flights_per_week": """
    SELECT
        DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day') AS week_end,
        COUNT(flight_id) AS delayed_flights
    FROM flights
    WHERE actual_departure IS NOT NULL
    AND scheduled_departure < actual_departure
    GROUP BY DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day')
    ORDER BY week_end DESC
    LIMIT 2;
    """,
    
    "flights_over_time": """
    SELECT 
        DATE_TRUNC('day', actual_departure) AS day,
        COUNT(flight_id) AS num_flights
    FROM flights
    WHERE actual_departure IS NOT NULL
    GROUP BY DATE_TRUNC('day', actual_departure)
    ORDER BY day;
    """,
    
    "average_delay_time_per_week": """
    SELECT 
        DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day') AS week_end,
        AVG(EXTRACT(EPOCH FROM (actual_departure - scheduled_departure)) / 60) AS average_delay_minutes
    FROM flights
    WHERE actual_departure IS NOT NULL
    AND scheduled_departure IS NOT NULL
    GROUP BY DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day')
    ORDER BY week_end DESC
    LIMIT 2;
    """ ,
    
    "top_airports_by_departures" : f"""
    SELECT
        a.airport_code,
        a.airport_name,
        COUNT(f.flight_id) AS num_departures
    FROM airports_data a, flights f
    WHERE a.airport_code = f.departure_airport
    GROUP BY a.airport_code, a.airport_name
    ORDER BY num_departures DESC
    LIMIT 10 ;
    """,
    
    "average_passengers_per_flight_per_week": """
    WITH nb_pss AS (
        SELECT
            f.flight_id,
            COUNT(b.*) AS nb_pass
        FROM flights f
        JOIN boarding_passes b ON f.flight_id = b.flight_id
        GROUP BY f.flight_id
    )
    SELECT 
        DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day') AS week_end,
        AVG(nb_pss.nb_pass) AS average_passengers
    FROM flights f
    JOIN nb_pss ON f.flight_id = nb_pss.flight_id
    WHERE actual_departure IS NOT NULL
    GROUP BY DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER) * INTERVAL '1 day')
    ORDER BY week_end DESC
    LIMIT 2;
    """,
    "last_weeks_revenue": """
    SELECT 
        DATE_TRUNC('day', book_date) + ((7 - EXTRACT(DOW FROM book_date)::INTEGER) * INTERVAL '1 day') AS week_end,
        SUM(total_amount) AS total_revenue
    FROM bookings
    GROUP BY DATE_TRUNC('day', book_date) + ((7 - EXTRACT(DOW FROM book_date)::INTEGER) * INTERVAL '1 day')
    ORDER BY week_end DESC
    LIMIT 2;
    """,
    "flights_lines" : f"""
        WITH lines AS (
            SELECT 
                d.city AS departure_city,
                d.coordinates AS departure_coords,
                a.city AS arrival_city,
                a.coordinates AS arrival_coords,
                DATE_TRUNC('day', (DATE_TRUNC('day', actual_departure) + ((7 - EXTRACT(DOW FROM actual_departure)::INTEGER ) * INTERVAL '1 day'))) AS week_end
            FROM flights f, airports_data d, airports_data a
            WHERE f.departure_airport = d.airport_code
            AND f.arrival_airport = a.airport_code
        )
        SELECT 
            departure_city,
            departure_coords AS departure_coordinates,
            arrival_city,
            arrival_coords AS arrival_coordinates
        FROM lines;
            
    """
    
}
stats = [
    "flights_over_time",
    "total_flights_per_week",
    "delayed_flights_per_week",
    "average_delay_time_per_week",
    "top_airports_by_departures",
    "average_passengers_per_flight_per_week",
    "last_weeks_revenue",
    "flights_lines"
    
]
kpis = [v for v in stats if "week" in v]
aggs = [v for v in stats if "week" not in v ]



def fetch_table_from_postgresql(table_name, conn_id='postgres_default'):
    """
    Extract a table from PostgreSQL database and save it as a CSV file.
    
    This function connects to a PostgreSQL database using Airflow's PostgresHook,
    executes a SELECT query with a limit, and saves the results to a CSV file
    in the 'dump' directory.
    
    Args:
        table_name (str): Name of the PostgreSQL table to extract
        conn_id (str): Airflow connection ID for PostgreSQL. Defaults to 'postgres_default'
    
    Returns:
        str: Path to the created CSV file (e.g., "dump/flights.csv")
    
    Note:
        - Creates 'dump' directory if it doesn't exist
        - Limits extraction to 100,000 rows for performance
        - Commented code shows examples for date-filtered queries
    """
    pg_hook = PostgresHook(postgres_conn_id=conn_id)
    conn = pg_hook.get_conn()
    # if table_name == "flights":
    #     query = f"SELECT * FROM {table_name} WHERE scheduled_arrival <= '2017-05-15' "
    # elif table_name == "bookings" :
    #     query = f"SELECT * FROM {table_name} WHERE book_date <= '2017-05-15' LIMIT 100000"
    # else : 
    query = f"SELECT * FROM demo.bookings.{table_name} LIMIT 100000"  
     
    df = pd.read_sql(query, conn)
    conn.close()
    # Ensure the directory exists
    output_dir = "dump"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    df.to_csv(f"{output_dir}/{table_name}.csv", index=False)
    return f"dump/{table_name}.csv"

def compute(stats):
    """
    Compute statistics from CSV files using DuckDB and save results as JSON.
    
    This function reads CSV files from the 'dump' directory, executes predefined
    SQL queries on them using DuckDB, and saves the results as JSON files.
    DuckDB is used for efficient in-memory SQL processing without needing a
    full database server.
    
    Args:
        stats (str): Name of the statistic to compute. Must match a key in the
                    'queries' dictionary (e.g., 'total_flights_per_week',
                    'top_airports_by_departures')
    
    Returns:
        str: Path to the created JSON file (e.g., "dump/total_flights_per_week.json")
    
    Note:
        - Reads all required tables into DuckDB in-memory
        - Uses the serialize function for datetime and Decimal conversion
        - Results are stored as an array of dictionaries
    """
    ticket_flights = db.read_csv("dump/ticket_flights.csv")
    boarding_passes = db.read_csv("dump/boarding_passes.csv")
    bookings = db.read_csv("dump/bookings.csv")
    airports_data = db.read_csv("dump/airports_data.csv")
    aircrafts_data = db.read_csv("dump/aircrafts_data.csv")
    tickets = db.read_csv("dump/tickets.csv")
    flights = db.read_csv("dump/flights.csv")
    
    file_path = f"dump/{stats}.json"
    columns = [desc[0] for desc in db.sql(queries[stats]).description]
    rows = db.sql(queries[stats]).fetchall()
    data = [dict(zip(columns, row)) for row in rows]
    with open(file_path, "w") as f:
        json.dump(data, f, default=serialize)
    return file_path
    
def serialize(obj):
    """
    Serialize Python objects to JSON-compatible types.
    
    Custom JSON serializer for handling objects that are not natively
    JSON-serializable, specifically Decimal and datetime objects.
    
    Args:
        obj: Object to serialize
    
    Returns:
        str: ISO-formatted string for datetime/date objects, or string
             representation for Decimal objects
    
    Raises:
        TypeError: If the object type is not supported for serialization
    """
    if isinstance(obj, Decimal ):
        return str(obj)
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError(f"Object of type {type(obj)} is not serializable")

def load_to_mongo(stat, file_path):
    """
    Load JSON data into a MongoDB collection.
    
    This function reads JSON data from a file and loads it into MongoDB,
    replacing any existing data in the collection. This ensures each run
    provides fresh data without duplicates.
    
    Args:
        stat (str): Name of the statistic, used as the MongoDB collection name
        file_path (str): Path to the JSON file containing the data to load
    
    Note:
        - Uses Airflow's MongoHook with connection ID 'mongo_flights'
        - Deletes all existing documents in the collection before inserting
        - Inserts data only if the JSON file contains records
        - Closes the MongoDB connection after operation
    """
    with open(file_path, 'r') as f:
        data = json.load(f)
    mongo_hook = MongoHook(conn_id="mongo_flights")
    client = mongo_hook.get_conn()
    db = client["kpi_graph"]
    collection = db[stat]
    collection.delete_many({})
    if data:
        collection.insert_many(data)
    client.close()
    
def clean_up_files():
    """
    Remove all temporary files from the dump directory.
    
    This cleanup function deletes all CSV and JSON files created during the
    ETL process to free up disk space and ensure the next run starts fresh.
    
    Note:
        - Removes only files, not subdirectories
        - Iterates through all files in the 'dump' directory
        - Should be called as the final step after data is loaded to MongoDB
    """
    for file in os.listdir("dump"):
        file_path = os.path.join("dump", file)
        if os.path.isfile(file_path):
            os.remove(file_path)