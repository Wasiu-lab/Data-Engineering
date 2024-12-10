
from pyspark.sql import SparkSession
from pyspark.sql.functions import broadcast

# Initialize Spark session
spark = SparkSession.builder.appName("Broadcast Joins").getOrCreate()

# Example dataframes for medals and maps
medals = spark.createDataFrame([(1, "Gold"), (2, "Silver"), (3, "Bronze")], ["medal_id", "medal_type"])
maps = spark.createDataFrame([(1, "MapA"), (2, "MapB")], ["map_id", "map_name"])

# Broadcast join
result = medals.join(broadcast(maps), medals.medal_id == maps.map_id, "inner")
result.show()

spark.stop()
