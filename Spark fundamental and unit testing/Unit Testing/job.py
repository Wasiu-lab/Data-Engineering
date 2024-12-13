from pyspark.sql import SparkSession
from pyspark.sql.functions import col, array, sum as spark_sum, explode, monotonically_increasing_id
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DateType
from datetime import timedelta

def create_pyspark_job(spark: SparkSession):
    # Assuming array_matrics is available as a DataFrame in Spark (replace with actual data source)
    df = spark.read.table("array_matrics")  # Or use any other method to load data if needed
    
    # Define the schema for your aggregated DataFrame
    schema = StructType([
        StructField("metric_name", StringType(), True),
        StructField("month_start", DateType(), True),
        StructField("summed_array", ArrayType(IntegerType()), True)
    ])
    
    # Perform the aggregation: sum across array columns
    agg_df = df.groupBy("metric_name", "month_start") \
        .agg(
            array(
                spark_sum(df["metric_array"].getItem(0)), 
                spark_sum(df["metric_array"].getItem(1)),
                spark_sum(df["metric_array"].getItem(2)),
                spark_sum(df["metric_array"].getItem(3))
            ).alias("summed_array")
        )
    
    # Explode the array (i.e., unnest the array) with ordinal values
    exploded_df = agg_df.withColumn("index", explode(col("summed_array"))) \
        .withColumn("index", monotonically_increasing_id()) \
        .withColumn("unnest_value", col("index")) \
        .select("metric_name", "month_start", "unnest_value", "index")
    
    # Add days to month_start using the index (ordinality)
    final_df = exploded_df.withColumn(
        "month_start",
        (col("month_start") + (col("index") - 1) * timedelta(days=1))
    )
    
    # Show the final DataFrame (or write it to a destination)
    final_df.show()

# Initialize the Spark session
if __name__ == "__main__":
    spark = SparkSession.builder \
        .appName("Unnest and Aggregate") \
        .getOrCreate()

    create_pyspark_job(spark)
