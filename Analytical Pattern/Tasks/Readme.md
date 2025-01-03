
# Week 4 Applying Analytical Patterns
The homework this week will be using the `players`, `players_scd`, and `player_seasons` tables from week 1

- A query that does state change tracking for `players`
  - A player entering the league should be `New`
  - A player leaving the league should be `Retired`
  - A player staying in the league should be `Continued Playing`
  - A player that comes out of retirement should be `Returned from Retirement`
  - A player that stays out of the league should be `Stayed Retired`
  
- A query that uses `GROUPING SETS` to do efficient aggregations of `game_details` data
  - Aggregate this dataset along the following dimensions
    - player and team
      - Answer questions like who scored the most points playing for one team?
    - player and season
      - Answer questions like who scored the most points in one season?
    - team
      - Answer questions like which team has won the most games?
      
- A query that uses window functions on `game_details` to find out the following things:
  - What is the most games a team has won in a 90 game stretch? 
  - How many games in a row did LeBron James score over 10 points a game?

# Homework SQL Queries Analysis  

This repository contains a set of SQL queries designed for analyzing player data, tracking state changes, aggregating performance metrics, and leveraging advanced SQL features like grouping sets and window functions.

## 1. State Change Tracking for Players
This query tracks the state changes of players across seasons. It determines the following states:
- **New**: A player entering the league for the first time.
- **Retired**: A player leaving the league.
- **Continued Playing**: A player who stays in the league across consecutive seasons.
- **Returned from Retirement**: A player who comes out of retirement to play again.
- **Stayed Retired**: A player who remains out of the league after retiring.

### Query Logic:
- Uses window functions (`LAG`) to compare a player's current season and activity status with the previous season.
- Classifies the player's state based on the transitions in these values.

### Example Use Case:
Identify players who returned from retirement in the 2020 season.

---

## 2. Aggregations Using GROUPING SETS
This query performs efficient aggregations on game details data, answering questions like:
- Who scored the most points while playing for one team?
- Who scored the most points in a single season?
- Which team has won the most games?

### Query Logic:
- Uses `GROUPING SETS` to aggregate data across multiple dimensions (e.g., player and team, player and season, team).
- Computes total points and wins for various groupings.

### Example Use Case:
Find the team with the highest total points scored in the last 10 seasons.

---

## 3. Window Functions on Game Details
This query uses advanced window functions to analyze performance metrics and streaks in the game details data.

### Subqueries:
1. **Most Games Won in a 90-Game Stretch**:
   - Calculates the sum of wins over a rolling 90-game window for each team.
   - Identifies the team and season with the highest win streak.

2. **Longest Scoring Streak for LeBron James**:
   - Tracks the number of consecutive games where LeBron James scored over 10 points.
   - Finds the longest such streak in his career.

### Query Logic:
- Leverages `ROWS BETWEEN` for rolling sums and streak calculations.
- Uses conditional aggregation to compute specific metrics like scoring streaks.

### Example Use Case:
Determine the longest streak of games where a specific player scored over 30 points.




