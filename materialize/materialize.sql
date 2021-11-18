CREATE SOURCE local_json_file
FROM FILE '/views/source.json'
WITH (tail=true)
FORMAT BYTES;

CREATE MATERIALIZED VIEW jsonified_bytes AS
SELECT CAST(data AS JSONB) AS data
FROM (
    SELECT CONVERT_FROM(data, 'utf8') AS data
    FROM local_json_file
);

 CREATE SINK IF NOT EXISTS materialized_sink
    FROM jsonified_bytes
    INTO KAFKA BROKER 'redpanda:9092'
    TOPIC 'sometopic'
    CONSISTENCY (
      TOPIC 'sometopic_materialized_consistency'
      FORMAT AVRO USING CONFLUENT SCHEMA REGISTRY 'http://redpanda:8081'
    )
    WITH (
      partition_count=1,
      replication_factor=1,
      reuse_topic=true,
      retention_ms=-1,
      retention_bytes=-1
    )
    FORMAT JSON;