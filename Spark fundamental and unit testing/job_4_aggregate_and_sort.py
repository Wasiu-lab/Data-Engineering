
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count

# Initialize Spark session
spark = SparkSession.builder.appName("Aggregate and Sort").getOrCreate()

# Example dataframes
data = [
    (1, "Player1", "MapA", "PlaylistA", 10, "Killing Spree"),
    (2, "Player2", "MapB", "PlaylistB", 20, "None"),
    (1, "Player1", "MapA", "PlaylistA", 15, "Killing Spree")
]
columns = ["match_id", "player", "map", "playlist", "kills", "medal"]
df = spark.createDataFrame(data, columns)

# Aggregations
avg_kills = df.groupBy("player").agg(avg("kills").alias("avg_kills")).orderBy(col("avg_kills").desc())
most_played_playlist = df.groupBy("playlist").agg(count("*").alias("count")).orderBy(col("count").desc())
most_played_map = df.groupBy("map").agg(count("*").alias("count")).orderBy(col("count").desc())
most_killing_spree_map = df.filter(col("medal") == "Killing Spree").groupBy("map").agg(count("*").alias("count")).orderBy(col("count").desc())

# Display results
avg_kills.show()
most_played_playlist.show()
most_played_map.show()
most_killing_spree_map.show()

# Sorting within partitions
df.sortWithinPartitions("playlist").write.format("parquet").save("/mnt/data/sorted_playlist")
df.sortWithinPartitions("map").write.format("parquet").save("/mnt/data/sorted_map")

spark.stop()
