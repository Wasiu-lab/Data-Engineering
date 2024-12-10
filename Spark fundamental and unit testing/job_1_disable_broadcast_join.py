
from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder.appName("Disable Broadcast Join").getOrCreate()

# Disable automatic broadcast joins
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")

print("Broadcast join disabled.")
spark.stop()
