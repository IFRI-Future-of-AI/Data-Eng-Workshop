NYC_TRIPS_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/fhvhv_tripdata_{}-{}.parquet"
DATSET_FOLDER = 'fhvhv_tripdata'


DATABASE_NAME = "workshop"

SCHEMA_MAPPING = {
    'String': 'VARCHAR',
    'Int64': 'BIGINT',
    'Float64': 'DOUBLE PRECISION',
    'Datetime(time_unit=\'ns\', time_zone=None)': 'TIMESTAMP',
'Null': 'VARCHAR'
}
