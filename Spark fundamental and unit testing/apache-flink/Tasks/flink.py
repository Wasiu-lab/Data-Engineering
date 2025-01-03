import os
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import StreamTableEnvironment, EnvironmentSettings
from pyflink.table.expressions import col, lit
from pyflink.table.window import Session


def setup_environment():
    """Sets up the Stream and Table environments for PyFlink."""
    # Create a streaming execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)  # Set to 1 for simplicity; adjust as needed
    
    # Enable checkpointing for fault tolerance
    env.enable_checkpointing(60000)  # Every 60 seconds

    # Create a streaming table environment
    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)
    return t_env


def create_kafka_source(t_env):
    """Defines the Kafka source table."""
    kafka_source_ddl = f"""
        CREATE TABLE web_traffic (
            ip VARCHAR,
            host VARCHAR,
            url VARCHAR,
            event_time TIMESTAMP(3),
            WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
        ) WITH (
            'connector' = 'kafka',
            'topic' = '{os.getenv("KAFKA_TOPIC")}',
            'properties.bootstrap.servers' = '{os.getenv("KAFKA_URL")}',
            'properties.group.id' = '{os.getenv("KAFKA_GROUP")}',
            'properties.security.protocol' = 'SASL_SSL',
            'properties.sasl.mechanism' = 'PLAIN',
            'properties.sasl.jaas.config' = 
                'org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule required username="{os.getenv("KAFKA_WEB_TRAFFIC_KEY")}" password="{os.getenv("KAFKA_WEB_TRAFFIC_SECRET")}";',
            'format' = 'json'
        )
    """
    t_env.execute_sql(kafka_source_ddl)


def create_postgres_sink(t_env):
    """Defines the PostgreSQL sink table."""
    postgres_sink_ddl = f"""
        CREATE TABLE sessionized_results (
            host VARCHAR,
            session_start TIMESTAMP(3),
            session_end TIMESTAMP(3),
            ip VARCHAR,
            num_events BIGINT,
            avg_events_per_session DOUBLE
        ) WITH (
            'connector' = 'jdbc',
            'url' = '{os.getenv("POSTGRES_URL")}',
            'table-name' = 'sessionized_results',
            'username' = '{os.getenv("POSTGRES_USER", "postgres")}',
            'password' = '{os.getenv("POSTGRES_PASSWORD", "postgres")}',
            'driver' = 'org.postgresql.Driver'
        )
    """
    t_env.execute_sql(postgres_sink_ddl)


def process_events(t_env):
    """Processes events by sessionizing them and calculating statistics."""
    source_table = t_env.from_path("web_traffic")

    # Sessionize the data with a 5-minute gap
    sessionized_table = source_table \
        .window(Session.with_gap(lit(5).minutes).on(col("event_time")).alias("session_window")) \
        .group_by(col("session_window"), col("ip"), col("host")) \
        .select(
            col("host"),
            col("session_window").start.alias("session_start"),
            col("session_window").end.alias("session_end"),
            col("ip"),
            col("*").count.alias("num_events")
        )

    # Calculate average events per session grouped by host
    aggregated_table = sessionized_table \
        .group_by(col("host")) \
        .select(
            col("host"),
            col("session_start"),
            col("session_end"),
            col("ip"),
            col("num_events"),
            col("num_events").avg.alias("avg_events_per_session")
        )

    # Write the aggregated results to PostgreSQL
    aggregated_table.execute_insert("sessionized_results").wait()


def main():
    """Main entry point of the Flink job."""
    t_env = setup_environment()  # Initialize the environment
    create_kafka_source(t_env)  # Define Kafka source table
    create_postgres_sink(t_env)  # Define PostgreSQL sink table
    process_events(t_env)  # Perform sessionization and analysis


if __name__ == "__main__":
    main()
