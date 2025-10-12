NYC_TRIPS_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{}-{}.parquet"
DATSET_FOLDER = 'yellow_tripdata'
TAXI_ZONE_URL = "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"



DATABASE_NAME = "workshop"

SCHEMA_MAPPING = {
    'String': 'VARCHAR',
    'Int64': 'BIGINT',
    'Int32': 'INTEGER',
    'Float64': 'DOUBLE PRECISION',
    'Float32': 'REAL',
    'Datetime(time_unit=\'ns\', time_zone=None)': 'TIMESTAMP',
    'Null': 'VARCHAR'
}
