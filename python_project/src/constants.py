NYC_TRIPS_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/fhvhv_tripdata_{}-{}.parquet"
DATSET_FOLDER = 'fhvhv_tripdata'

SCHEMA_MAPPING = {
    'string': 'VARCHAR',
    'int64': 'BIGINT',
    'float64': 'DOUBLE PRECISION',
    'datetime[ns]': 'TIMESTAMP',
    'boolean': 'BOOLEAN',
    'list': 'ARRAY',
    'struct': 'JSONB',
    'null': 'NULL',
    'object': 'JSONB',
    'date': 'DATE',
}
