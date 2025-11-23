CREATE DATABASE ZOMATO_ANALYSIS;
USE ZOMATO_ANALYSIS;

SELECT * FROM zomato_analysis.zomato_data;

-- Q1

CREATE table Countrymap(
countrycode int primary key, countryname varchar(100)
);
INSERT INTO Countrymap (countrycode,countryname)
VALUES (1,'INDIA'),(14,'AUSTRALIA'),
(30, 'Brazil'),
  (37, 'Canada'),
  (94, 'Indonesia'),
  (148, 'New Zealand'),
  (162, 'Philippines'),
  (166, 'Qatar'),
  (184, 'Singapore'),
  (189, 'South Africa'),
  (191, 'Sri Lanka'),
  (208, 'Turkey'),
  (214, 'UAE'),
  (215, 'United Kingdom'),
  (216, 'United States');

SELECT 
  cm.countryname,
  COUNT(z.RESTAURANTID) AS restaurant_count
FROM zomato_data z 
JOIN CountryMap cm ON z.countrycode = cm.countrycode
GROUP BY cm.countryname WITH ROLLUP
HAVING cm.countryname IS NOT NULL
ORDER BY restaurant_count DESC;


-- Q2

-- Create CalendarTable
DROP TABLE IF EXISTS CalendarTable;

CREATE TABLE CalendarTable (
  DateKey DATE PRIMARY KEY,
  FullDate DATE,
  Year INT,
  MonthNo INT,
  MonthFullName VARCHAR(10),
  Quarter VARCHAR(2),
  YearMonth VARCHAR(10),
  WeekDayNo INT,
  WeekDayName VARCHAR(10),
  FinancialMonth VARCHAR(5),
  FinancialQuarter VARCHAR(3)
);

INSERT INTO CalendarTable (
  DateKey,
  FullDate,
  Year,
  MonthNo,
  MonthFullName,
  Quarter,
  YearMonth,
  WeekDayNo,
  WeekDayName,
  FinancialMonth,
  FinancialQuarter
)
SELECT 
  STR_TO_DATE(datekey_opening, '%Y_%c_%e') AS DateKey,
  STR_TO_DATE(datekey_opening, '%Y_%c_%e') AS FullDate,
  YEAR(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) AS Year,
  MONTH(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) AS MonthNo,
  DATE_FORMAT(STR_TO_DATE(datekey_opening, '%Y_%c_%e'), '%M') AS MonthFullName,
  CONCAT('Q', QUARTER(STR_TO_DATE(datekey_opening, '%Y_%c_%e'))) AS Quarter,
  DATE_FORMAT(STR_TO_DATE(datekey_opening, '%Y_%c_%e'), '%Y-%b') AS YearMonth,
  WEEKDAY(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) + 1 AS WeekDayNo,
  DATE_FORMAT(STR_TO_DATE(datekey_opening, '%Y_%c_%e'), '%W') AS WeekDayName,

  CASE MONTH(STR_TO_DATE(datekey_opening, '%Y_%c_%e'))
    WHEN 4 THEN 'FM1'
    WHEN 5 THEN 'FM2'
    WHEN 6 THEN 'FM3'
    WHEN 7 THEN 'FM4'
    WHEN 8 THEN 'FM5'
    WHEN 9 THEN 'FM6'
    WHEN 10 THEN 'FM7'
    WHEN 11 THEN 'FM8'
    WHEN 12 THEN 'FM9'
    WHEN 1 THEN 'FM10'
    WHEN 2 THEN 'FM11'
    WHEN 3 THEN 'FM12'
  END AS FinancialMonth,

  CASE 
    WHEN MONTH(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) BETWEEN 10 AND 12 THEN 'Q3'
    WHEN MONTH(STR_TO_DATE(datekey_opening, '%Y_%c_%e')) BETWEEN 1 AND 3 THEN 'Q4'
  END AS FinancialQuarter

FROM (
  SELECT DISTINCT datekey_opening
  FROM zomato_data
  WHERE datekey_opening IS NOT NULL
) AS UniqueDates;

select*from calendartable;

-- Q3
SELECT City, CountryCode, COUNT(*) AS restaurant_count
FROM zomato_data
GROUP BY City, CountryCode WITH ROLLUP
HAVING City IS NOT NULL AND CountryCode IS NOT NULL
ORDER BY restaurant_count DESC;

-- Q4
SELECT
  EXTRACT(YEAR FROM Datekey_Opening) AS year,
  EXTRACT(QUARTER FROM Datekey_Opening) AS quarter,
  EXTRACT(MONTH FROM Datekey_Opening) AS month,
  COUNT(*) AS new_openings
FROM zomato_data
GROUP BY year, quarter, month WITH ROLLUP
HAVING year IS NOT NULL AND quarter IS NOT NULL AND month IS NOT NULL
ORDER BY
  year DESC,
  quarter DESC,
  month DESC;


-- Q5

SELECT rating AS average_rating,
       COUNT(RESTAURANTID) AS restaurant_count
FROM ZOMATO_DATA
GROUP BY rating WITH ROLLUP
HAVING rating IS NOT NULL
ORDER BY average_rating DESC;


-- Q6

SELECT 
  CASE
    WHEN average_cost_for_two <= 250 THEN '₹0–250'
    WHEN average_cost_for_two <= 500 THEN '₹251–500'
    WHEN average_cost_for_two <= 1000 THEN '₹501–1000'
    WHEN average_cost_for_two <= 1500 THEN '₹1001–1500'
    WHEN average_cost_for_two <= 2000 THEN '₹1501–2000'
    ELSE '₹2000+' 
  END AS price_bucket,
  COUNT(RESTAURANTID) AS restaurant_count
FROM ZOMATO_DATA
GROUP BY price_bucket WITH ROLLUP
HAVING price_bucket IS NOT NULL
ORDER BY
  CASE price_bucket
    WHEN '₹0–250' THEN 1
    WHEN '₹251–500' THEN 2
    WHEN '₹501–1000' THEN 3
    WHEN '₹1001–1500' THEN 4
    WHEN '₹1501–2000' THEN 5
    WHEN '₹2000+' THEN 6
    ELSE 7
  END;


-- Q7

SELECT 
  COALESCE(CAST(has_table_booking AS CHAR), 'Total') AS has_table_booking,
  COUNT(*) AS restaurant_count,
  CONCAT(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_data)), 2), '%') AS percentage
FROM zomato_data
GROUP BY has_table_booking WITH ROLLUP;



-- Q8

SELECT 
  has_online_delivery,
  COUNT(*) AS restaurant_count,
  CONCAT(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM zomato_data)), 2), '%') AS percentage
FROM zomato_data
GROUP BY has_online_delivery
HAVING has_online_delivery IS NOT NULL;

