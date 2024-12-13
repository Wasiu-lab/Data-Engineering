from pyspark.sql import SparkSession
from pyspark.sql.functions import col, array, sum as spark_sum, explode, monotonically_increasing_id
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DateType, ArrayType
from datetime import timedelta
import unittest
from datetime import datetime

# Define the function for the PySpark job
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

# Define the test class for the PySpark job
class PySparkJobTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.spark = SparkSession.builder \
            .appName("PySparkJobTest") \
            .master("local[*]") \
            .getOrCreate()

        # Create a DataFrame to use as input data
        cls.input_data = cls.spark.createDataFrame([
            ("metric1", datetime(2024, 12, 1), [1, 2, 3, 4]),
            ("metric1", datetime(2024, 12, 1), [1, 2, 3, 4])
        ], ["metric_name", "month_start", "metric_array"])

        # Expected output DataFrame
        cls.expected_output_data = cls.spark.createDataFrame([
            ("metric1", datetime(2024, 12, 1), 2, 0),
            ("metric1", datetime(2024, 12, 2), 4, 1),
            ("metric1", datetime(2024, 12, 3), 6, 2),
            ("metric1", datetime(2024, 12, 4), 8, 3)
        ], ["metric_name", "month_start", "unnest_value", "index"])

    @classmethod
    def tearDownClass(cls):
        cls.spark.stop()

    def test_pyspark_job(self):
        # Run the PySpark job
        create_pyspark_job(self.spark)

        # Read the output DataFrame from where your job writes it
        # For the sake of this example, we assume it's written to a specific location
        # Replace this with the actual location and method you use to read the DataFrame
        output_data = self.spark.read.table("output_table")

        # Compare the actual output DataFrame to the expected DataFrame
        self.assertEqual(
            sorted(output_data.collect()),
            sorted(self.expected_output_data.collect())
        )

if __name__ == '__main__':
    spark = SparkSession.builder \
        .appName("Unnest and Aggregate") \
        .getOrCreate()

    create_pyspark_job(spark)
    unittest.main()
