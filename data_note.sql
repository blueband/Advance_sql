-- Create table and populate with auto genartae number
DROP TABLE IF EXISTS unary;
CREATE TABLE unary (a int);
INSERT INTO unary(a)
SELECT i
	FROM generate_series(1,1000, 1) AS i;
	
-- checking the directory of table file/ database
show data_directory;


SELECT relfilenode, relname
FROM pg_class
WHERE relname = 'unary';

-- Query the Leaf Node of current free space
-- to check how many bytes are avaialable 
VACUUM unary;
SELECT * 
FROM pg_freespace('unary');

-- Delete range of row fron unary table
DELETE FROM unary As u
WHERE u.a BETWEEN 400 AND 500;

-- Insert a sentinel to see where heap file will place new row
INSERT INTO unary(a) VALUES(-1);

-- checking table content
TABLE unary

-- see databse page and values
SELECT u.ctid, u.a
FROM unary AS U;

-- in ORDER BY expression, ASC is default
-- in case of ties,
-- expression example
-- SELECT t.*
-- FROM table AS t
-- ORDER BY t.colname 	DESC, t.colname2;
-- NULL  is lager than non-null value
-- ORDE BY is local to the sub query at that running time

-- retrieve ROW that met specific criteria
SELECT t.*
FROM yellow_taxi_data AS t
WHERE t.fare_amount > 5 AND t.tip_amount > 6
ORDER BY t.passenger_count DESC
LIMIT 100;

-- SELECT DISTINCT ON
-- EXPLAIN
-- SELECT DISTINCT ON t.*
-- FROM yellow_taxi_data AS t
-- -- WHERE t.fare_amount > 5 AND t.tip_amount > 6
-- ORDER BY t.fare_amount DESC
-- LIMIT 100;

-- SELECT DISTINCT  is trulyrow wide duplcate removal 

-- AGGREGATE == SUMMATION OF ALL ROWS INTO A SINGLE ROW e.g SUM, COUNT, AVG, MAX, MIN, BOOL_AND, BOOL_OR
SELECT SUM(t.fare_amount) AS total_spent, SUM(t.tip_amount) AS total_tip_given
FROM yellow_taxi_data  AS t
ORDER BY total_spent

-- Use COUNT

-- Create prehistorical table

DROP TABLE IF EXISTS prehistoric;
CREATE TABLE prehistoric(class text,
						"herbivore?" boolean,
						 legs int,
						 species text
						);
						

-- NEXTED QUERY
SELECT t2.payment_type, t2.fare_amount, AVG(t2.tolls_amount) 
FROM
(SELECT t.*
FROM yellow_taxi_data AS t
WHERE t.tip_amount > 5) AS t2
GROUP BY t2.payment_type, t2.fare_amount
LIMIT 100;



CREATE TABLE customers(customer_id int,
						name text,
						 phone_numbers text,
						 country text
						);
CREATE TABLE country_codes(country text,
						country_code text);
						

INSERT INTO customers(customer_id,
						name,
						 phone_numbers,
						 country) VALUES(1, 'raghava', 897653, 'USA');

INSERT INTO customers(customer_id,
						name,
						 phone_numbers,
						 country) VALUES(3, 'kehinde', 84397653, 'Nigeria');


INSERT INTO country_codes(country, country_code) VALUES ('usa','1');
INSERT INTO country_codes(country, country_code) VALUES ('UK','2');
INSERT INTO country_codes(country, country_code) VALUES ('Nigeria','3');

SELECT customer_id, name, CONCAT('+', country_codes.country_code, customers.phone_numbers) AS phone_number
FROM customers
LEFT JOIN country_codes ON country_codes.country=customers.country
GROUP BY customer_id, name, phone_number;



-- Working with multiple table
SELECT y.*, z."Zone" As DOZone
FROM yellow_taxi_data AS y, zones As z
-- LEFT JOIN zones ON y."PULocationID"=zones."LocationID"
WHERE
	y."DOLocationID"=z."LocationID" AND
	y."PULocationID"=z."LocationID"
LIMIT 100;


-- Working with multiple table 2 
SELECT y.tpep_pickup_datetime, y.tpep_dropoff_datetime, 
y.passenger_count, y.trip_distance, y.payment_type, y.fare_amount, 
y.tip_amount, y.tolls_amount, y.total_amount,
departure_zone, Arrival_zone
FROM yellow_taxi_data AS y,
	( SELECT zones."Zone" 
	 FROM zones, yellow_taxi_data AS y
	 WHERE y."PULocationID"=zones."LocationID") AS departure_zone,
	 (SELECT zones."Zone" 
	 FROM zones, yellow_taxi_data AS y
	 WHERE y."DOLocationID"=zones."LocationID") AS Arrival_zone

-- ORDER BY y."passenger_count"
LIMIT 100;


-- Working with multiple table 2 version 2
SELECT y.tpep_pickup_datetime, y.tpep_dropoff_datetime, 
y.passenger_count, y.trip_distance, y.payment_type, y.fare_amount, 
y.tip_amount, y.tolls_amount, y.total_amount,
departure_zone, Arrival_zone
FROM yellow_taxi_data AS y,
	( SELECT zones."Zone" 
	 FROM zones, yellow_taxi_data AS y,
	 	(WHERE y."PULocationID"=zones."LocationID") AS departure_zone,
	 	(WHERE y."DOLocationID"=zones."LocationID") AS departure_zone)
-- ORDER BY y."passenger_count"
LIMIT 100;



-- Window Function look at vicinity of a given row and perform sertain computation
-- It is a row-based
--  use vicinity to perform computation

--  Types incluse
-- 		ROW --> row position
--      RANGE --> row values vi
-- 		GROUPS -- row peers

--  Example Usages
-- window function   (odering criteria)   					frame specificatin
-- 	<f> OVER 			(ORDER BY <col1>			[ROW <frame> ])
-- 	<f> OVER 			(ORDER BY <col1>			[RANGE <frame> ])
-- 	<f> OVER 			(ORDER BY <col1>			[GROUPS <frame> ])

--  frame type can be one of the following
-- 		BETWEEN UNBOUDED PRECEEDING AND CURRENT ROW
-- 		BETWEEN 1 PRECEEDING AND 2 FOLLOWING
-- 		BETWEEN 2 PRECEEDING AND 2 FOLLOWING
-- 		BETWEEN CURRENT ROW AND UNBOUDED FOLLOWING  

-- use case
-- Q1. What is the chance of fine weather on a weekend
-- Table preparation and data insertion
DROP TABLE IF EXISTS sensors;
CREATE TABLE IF NOT EXISTS sensors(day int PRIMARY KEY, weekdays text, temp float, rain float);
INSERT INTO sensors(day, weekdays, temp, rain) VALUES 
(1,'FRI', 10, 800),
(2,'SAT', 0, 400),
(3,'SUN', 15, 950),
(4, 'MON', 16, 700),
(5,'TUE', 20, 500),
(6,'WED', 13, 500),
(7,'THUR', 20, 670),
(8,'FRI', 15, 900),
(9,'SAT', 45, 200),
(10,'SUN', 21, 560),
(11, 'MON', 19, 780),
(12,'TUE', 24, 630),
(13,'WED', 21, 560),
(14,'THUR', 32, 450),
(15,'FRI', 11, 680),
(16,'SAT', 7, 680),
(17,'SUN', 14, 540),
(18, 'MON', 19, 430),
(19,'TUE', 10, 960),
(20,'WED', 17, 700),
(21,'THUR', 6, 890),
(22,'FRI', 18, 580),
(23,'SAT', 23, 700),
(24,'SUN', 18, 910),
(25, 'MON', 12, 650),
(26,'TUE', 14, 670),
(27,'WED', 23, 900),
(28,'THUR', 21, 620);
-- The weather is fine on day d if  -- on d and the two days prior 
-- the minimum temperature is above 15C and the overall rainfall is less than 
-- 600ml/m2

--  Writing the needed quesy
EXPLAIN VERBOSE
WITH 
--  collect data for each day and two previous days
three_day_sensors_data(day, weekdays, temp, rain) AS (
	SELECT s.day, s.weekdays, 
		MIN(s.temp) OVER three_days AS temp, 
		SUM(s.rain) OVER three_days AS rain
	FROM sensors AS s
	WINDOW three_days AS (ORDER BY s.day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	),
weathers(day, weekdays, condition) AS (
	SELECT s.day, s.weekdays
		CASE WHEN s.temp >= 15 and s.rain <= 600
			THEN '*'
			ELSE "@"
		END AS condition
	FROM three_day_sensors_data AS s
)

SELECT w.weekdays IN ("SAT", "SUN") AS "weekend?",
	COUNT(*) FILTER (WHERE w.condition = '*') * 100.0 /
	COUNT(*) :: int AS "% of fine Weather!"
FROM weathers AS w
GROUP BY "weekend?";
	
-- Complex SQL Query 1 Derive Points table for IIC tournament
-- output table should contain the following
-- 1. team_name
-- 2. Number of match_played
-- 3. Number of Win_matchess as num_of_wins
-- 4. Number of Lost_matches as num_of_lost
-- 	table Preparation
Drop TABLE IF EXISTS icc_world_cup;
CREATE TABLE IF NOT EXISTS icc_world_cup
(
	Team_1 Varchar(20),
	Team_2 Varchar(20),
	Winner Varchar(20)
);
INSERT INTO icc_world_cup VALUES('India', 'SL','India');
INSERT INTO icc_world_cup VALUES('SL', 'Aus','Aus');
INSERT INTO icc_world_cup VALUES('SA', 'Eng','Eng');
INSERT INTO icc_world_cup VALUES('Eng', 'NZ','NZ');
INSERT INTO icc_world_cup VALUES('Aus', 'India','India');
	
-- Checking data integrity
SELECT * 
	FROM icc_world_cup;
	
-- Solution as follow
EXPLAIN VERBOSE	
SELECT team_name, COUNT(*) AS num_of_matched_play, SUM(win_flag) AS num_of_wons, COUNT(*) - SUM(win_flag) AS num_of_lost
	FROM (
SELECT team_1 AS team_name, CASE WHEN team_1=winner THEN 1 ELSE  0 END AS win_flag
FROM 
	icc_world_cup
UNION ALL
	SELECT team_2 AS team_name, CASE WHEN team_2=winner THEN 1 ELSE  0 END AS win_flag
	FROM 
	icc_world_cup) AS A
	GROUP BY team_name
	ORDER BY num_of_wons DESC;