--Checking and exploerering data
SELECT *
FROM Portfolioproject..['Korean_demographics_2000-2022$']

--sejong does not have proper data until 2012
--This is because sejong registeed as special city(?) in 2012

SELECT *
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Region = 'sejong'

SELECT Date, CONVERT(DATE, DATE)
FROM Portfolioproject..['Korean_demographics_2000-2022$']

UPDATE Portfolioproject..['Korean_demographics_2000-2022$']
SET Date = CONVERT(DATE, DATE)

--let's do things with bith/birthrate
--2000,2010,2020 birth cases across regions

--2000
SELECT Region,SUM(Birth)
FROM Portfolioproject..['Korean_demographics_2000-2022$']
Group by Region


--sum(birth) already exists as whole country! what have I done?
WITH region2000totalbirth AS
(
SELECT Region, SUM(Birth) AS region2000totalbirth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Date BETWEEN '2000-01-01' and '2000-01-12' and Region <> 'Whole country'
GROUP BY Region
)
SELECT 
    Region, 
    region2000totalbirth / (SELECT SUM(Birth) FROM Portfolioproject..['Korean_demographics_2000-2022$'] WHERE Date BETWEEN '2000-01-01' AND '2000-01-12'and Region <> 'Whole country') AS BirthPropertionByRegion
FROM 
    region2000totalbirth
ORDER BY
Region



--2010
WITH region2010totalbirth AS
(
SELECT Region, SUM(Birth) AS region2010totalbirth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Date BETWEEN '2010-01-01' and '2010-01-12' and Region <> 'Whole country'
GROUP BY Region
)
SELECT 
    Region, 
    region2010totalbirth / (SELECT SUM(Birth) FROM Portfolioproject..['Korean_demographics_2000-2022$'] WHERE Date BETWEEN '2010-01-01' AND '2010-01-12'and Region <> 'Whole country') AS BirthPropertionByRegion
FROM 
    region2010totalbirth
ORDER BY
	Region

--2020
WITH region2020totalbirth AS
(
SELECT Region, SUM(Birth) AS region2020totalbirth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Date BETWEEN '2020-01-01' and '2020-01-12' and Region <> 'Whole country'
GROUP BY Region
)
SELECT 
    Region, 
    region2020totalbirth / (SELECT SUM(Birth) FROM Portfolioproject..['Korean_demographics_2000-2022$'] WHERE Date BETWEEN '2020-01-01' AND '2020-01-12'and Region <> 'Whole country') AS BirthPropertionByRegion
FROM 
    region2020totalbirth
ORDER BY
	Region


--Aggregate the table to see/compare the result easier
WITH region2000totalbirth AS
(
SELECT Region, SUM(Birth) AS region2000totalbirth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Date BETWEEN '2000-01-01' and '2000-01-12' and Region <> 'Whole country'
GROUP BY Region
)
,
region2010totalbirth AS
(
SELECT Region, SUM(Birth) AS region2010totalbirth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Date BETWEEN '2010-01-01' and '2010-01-12' and Region <> 'Whole country'
GROUP BY Region
)
,
region2020totalbirth AS
(
SELECT Region, SUM(Birth) AS region2020totalbirth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Date BETWEEN '2020-01-01' and '2020-01-12' and Region <> 'Whole country'
GROUP BY Region
)
SELECT 
    region2000totalbirth.Region,
	region2000totalbirth.region2000totalbirth / (SELECT SUM(Birth) FROM Portfolioproject..['Korean_demographics_2000-2022$'] WHERE Date BETWEEN '2000-01-01' AND '2000-01-12'and Region <> 'Whole country') AS BirthPropertionByRegion2000,
	region2010totalbirth.region2010totalbirth / (SELECT SUM(Birth) FROM Portfolioproject..['Korean_demographics_2000-2022$'] WHERE Date BETWEEN '2010-01-01' AND '2010-01-12'and Region <> 'Whole country') AS BirthPropertionByRegion2010,
    region2020totalbirth.region2020totalbirth / (SELECT SUM(Birth) FROM Portfolioproject..['Korean_demographics_2000-2022$'] WHERE Date BETWEEN '2020-01-01' AND '2020-01-12'and Region <> 'Whole country') AS BirthPropertionByRegion2020
FROM 
    region2000totalbirth
JOIN region2010totalbirth ON region2000totalbirth.Region = region2010totalbirth.Region
JOIN region2020totalbirth ON region2010totalbirth.Region = region2020totalbirth.Region
ORDER BY
    region2000totalbirth.Region;



--Birth, Death, Natural_growth comparsion
SELECT Region, Date, Birth, Death, Natural_growth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Region <> 'Whole country'
ORDER BY Region

SELECT Region, Date, Birth, Death, Natural_growth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Region = 'Whole country'
ORDER BY Region

--SELECT Region, Date, SUM(Birth) OVER(PARTITION BY Region ORDER BY Date)--, Death, Natural_growth
--FROM Portfolioproject..['Korean_demographics_2000-2022$']
----GROUP BY Birth, Death, Natural_growth





--Marriage vs Birth vs divorce?
--Can I say Birth/marriage to see the correlation? prob not
SELECT Region, Date, Marriage, Birth
FROM Portfolioproject..['Korean_demographics_2000-2022$']
WHERE Region = 'Whole country'