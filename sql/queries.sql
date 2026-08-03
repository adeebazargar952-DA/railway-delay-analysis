-- ============================================
-- Indian Railways Delay Analysis - SQL Queries
-- ============================================

-- 1. Worst stations by average delay (min. 10 records for reliability)
SELECT station_name, 
       AVG(average_delay_minutes) as avg_delay,
       COUNT(*) as num_records
FROM train_delays
GROUP BY station_name
HAVING COUNT(*) >= 10
ORDER BY avg_delay DESC
LIMIT 10;

-- 2. Check for duplicate train-station records (data quality check)
SELECT train_name, station_name, COUNT(*) as num_occurrences
FROM train_delays
GROUP BY train_name, station_name
HAVING COUNT(*) > 1
ORDER BY num_occurrences DESC;

-- 3. Top 3 worst stations per train (CTE + window function)
WITH ranked AS (
    SELECT train_name, station_name, average_delay_minutes,
           RANK() OVER (PARTITION BY train_name ORDER BY average_delay_minutes DESC) as rnk
    FROM train_delays
)
SELECT * FROM ranked WHERE rnk <= 3;

-- 4. Each station's single worst recorded delay
WITH ranked AS (
    SELECT station_name, average_delay_minutes,
           RANK() OVER (PARTITION BY station_name ORDER BY average_delay_minutes DESC) as rank_within_station
    FROM train_delays
)
SELECT * FROM ranked WHERE rank_within_station = 1
ORDER BY average_delay_minutes DESC
LIMIT 10;

-- 5. Deviation from network-wide average delay (window function, no grouping)
SELECT station_name, average_delay_minutes,
       AVG(average_delay_minutes) OVER () as overall_avg,
       average_delay_minutes - AVG(average_delay_minutes) OVER () as deviation_from_avg
FROM train_delays;
