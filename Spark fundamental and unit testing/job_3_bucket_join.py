
from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder.appName("Bucket Join").getOrCreate()

# Example dataframes
match_details = spark.createDataFrame([(1, "Player1"), (2, "Player2")], ["match_id", "player"])
matches = spark.createDataFrame([(1, "MatchA"), (2, "MatchB")], ["match_id", "match_name"])
medal_matches_players = spark.createDataFrame([(1, "Medal1"), (2, "Medal2")], ["match_id", "medal"])

# Bucket join setup
match_details.write.bucketBy(16, "match_id").saveAsTable("match_details_bucketed")
matches.write.bucketBy(16, "match_id").saveAsTable("matches_bucketed")
medal_matches_players.write.bucketBy(16, "match_id").saveAsTable("medal_matches_players_bucketed")

# Perform join
match_details_bucketed = spark.table("match_details_bucketed")
matches_bucketed = spark.table("matches_bucketed")
medal_matches_players_bucketed = spark.table("medal_matches_players_bucketed")

joined = match_details_bucketed.join(matches_bucketed, "match_id").join(medal_matches_players_bucketed, "match_id")
joined.show()

spark.stop()
