-- Database of Choise is PostgreSQL 13

-- New Tutorial Based on Ahmed Class LAG and LEAD)
--  Create Temperature table with 4 col, city, temp_date, min_temp, max_temp

CREATE TABLE IF NOT EXISTS temperature (city VARCHAR, 
										temp_date  DATE,
										min_temp INTEGER,
										max_temp INTEGER
	
									   );
									   
-- Insert data into Table created 
INSERT INTO temperature(city, temp_date, min_temp, max_temp) 
VALUES
('Lagos', '2012-09-02', 23, 45),
('Lagos', '2012-09-02', 23, 45),
('Minna', '2012-09-02', 22, 47),
('Benin', '2012-09-02', 13, 35),
('Lagos', '2012-09-12', 21, 35),
('Kano', '2012-09-12', 13, 49),
('Lagos', '2012-09-22', 24, 42),
('Lagos', '2012-09-22', 25, 47),
('Kano', '2012-09-22', 24, 55),
('Benin', '2012-09-12', 21, 41),
('Benin', '2012-09-13', 21, 25),
('Lagos', '2012-09-15', 20, 40),
('Lagos', '2012-09-19', 22, 49),
('Kano', '2012-09-17', 22, 65),
('Benin', '2012-09-20', 22, 43),
('Minna', '2012-09-12', 25, 41),
('Minna', '2012-09-15', 21, 41),
('Kano', '2012-09-18', 20, 47),
('Minna', '2012-09-22', 9, 25),
('Minna', '2012-10-12', 22, 43),
('Lagos', '2012-10-02', 23, 35),
('Kano', '2012-10-27', 23, 55),
('Minna', '2012-10-03', 13, 35),
('Kano', '2012-09-10', 23, 55),
('Benin', '2012-10-02', 21, 45),
('Lagos', '2012-09-02', 23, 33);
	

--  Checking Data
SELECT * FROM temperature


-- USE CASE 1: Get Lagos record out of the table
SELECT * 
FROM temperature t
WHERE t.city = 'Lagos'  -- "" != '' for string
ORDER BY max_temp DESC;


-- USE CASE 2:  Determine the max temperature of 2 previous daya 
-- before the current day fof Kano City
SELECT kano_data.*,
LAG(max_temp, 2) OVER( ORDER BY max_temp) AS two_day_previous_max_temp FROM (SELECT * 
FROM temperature t
WHERE t.city = 'Kano'
ORDER BY max_temp) AS kano_data
ORDER BY kano_data.max_temp



-- USE CASE 2:  Determine the max temperature of 2 previous day 
-- before the current day fof Kano City within a Month
SELECT kano_data.*,
LAG(max_temp, 2) OVER( ORDER BY max_temp) AS two_day_previous_max_temp FROM (SELECT * 
FROM temperature t
WHERE t.city = 'Kano' AND temp_date BETWEEN to_date('2012-09-01', 'yyyy-mm-dd') AND to_date('2012-09-30', 'yyyy-mm-dd')
ORDER BY max_temp) AS kano_data
ORDER BY kano_data.max_temp


